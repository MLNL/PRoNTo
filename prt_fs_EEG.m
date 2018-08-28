function [outfile] = prt_fs_EEG(PRT,in)
% Function to build file arrays containing the preprocessed MEEG data
% and compute a linear (dot product) kernel from them
%
% Inputs:
% -------
% in.fname:      filename for the PRT.mat (string)
% in.fs_name:    name of fs and relative path filename for the kernel matrix
%
% in.mod(m).mod_name:  name of modality to include in this kernel (string)
% in.mod(m).detrend:   detrend (scalar: 0 = none, 1 = linear)
% in.mod(m).param_dt:  parameters for the kernel detrend (e.g. DCT bases)
% in.mod(m).mode:      'all_cond' or 'all_scans' (string)
% in.mod(m).mask:      mask file used to create the kernel
% in.mod(m).normalise: 0 = none, 1 = normalise_kernel, 2 = scale modality
% in.mod(m).matnorm:   filename for scaling matrix
% in.mod(m).aver:       average across one or multiple dimensions
% in.mod(m).multkern:   multiple kernels across one or multiple dimensions
% in.mod(m).multkernparam:   multiple kernels over time window - length of
%                            window

%
% in.flag_mm:   Perform multi-kernel learning (1) or not (0)? If yes, the
% kernel is saved as a cell vector, with one kernel per modality
%
% Outputs:
% --------
% Calls prt_init_fs to populate basic fields in PRT.fs(f)...
% Writes PRT.mat
% Writes the kernel matrix to the path indicated by in.fs_name
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Schrouff
% $Id: prt_fs_EEG.m 792 2013-11-04 15:12:20Z schrouff $

% Configure some variables and get defaults
% -------------------------------------------------------------------------
prt_dir  = regexprep(in.fname,'PRT.mat', ''); % or: fileparts(fname);

% get the index of the modalities for which the user wants a kernel/data
n_mods=length(in.mod);
mids=[];
for i=1:n_mods
    if ~isempty(in.mod(i).mod_name)
        mids = [mids, i];
    end
end
n_mods=length(mids);

% Initialize the file arrays, kernel and feature set parameters
[fid,PRT,tocomp,n_vols_s] = prt_init_fs_EEG(PRT,in,mids);
in.fid = fid;
in.tocomp = tocomp;
% Build mask from the selected channels, frequencies and/or time points
[mask,PRT,dim_m] = build_mask(PRT,in,mids,fid);

for i = 1:n_mods
    in.precmask{i} = mask{i}(:);
end

% Build the kernel
%--------------------------------------------------------------------------

% Total number of kernels to compute: nkm * n_kern
% Number of kernels per modality : n_kern
n_kern = zeros(n_mods,1);
dim = zeros(n_mods,3);
for i = 1:n_mods
    if isfield(in.mod(mids(i)),'multkern') && any(in.mod(mids(i)).multkern)
        dim(i,:) = dim_m(i,:);
        for j = 1:length(dim(i,:)) % taking into account kernels over e.g. a time-window
            if ~isempty(in.mod(mids(i)).multkernparam) &&...
                    ~isempty(in.mod(mids(i)).multkernparam{j})
                winsize = in.mod(mids(i)).multkernparam{j};
                newdim = ceil(dim(i,j)/in.mod(mids(i)).multkernparam{j});
                dim(i,j) = newdim;
            end
        end            
        kernt = dim(i,:) .* in.mod(mids(i)).multkern;
        kernt(kernt==0) = 1;
        n_kern(i) = prod(kernt);
    else
        n_kern(i) = 1;
    end
end
% Check if all modalities have the same number of kernels
% if length(unique(n_kern))>1
%     disp('Warning: Modalities do not have the same number of kernels')
% end
% Number of kernels for the different modalities: nkm
if in.flag_mm
    nkm = n_mods;
else
    nkm = 1;
end

% Build kernels
PRT.fs(fid).atlas_label = {};
Phi = [];
nim1 =length(find(PRT.fs(fid).id_mat(:,3) == mids(1)));
PRT.fs(fid).multkernelROI = 0;
PRT.fs(fid).multkernel = 0;
addin.n_vols_s = n_vols_s;
Dsubj1 = PRT.fas(mids(1)).hdr;

for ik = 1:nkm
    if in.flag_mm
        idtk = PRT.fs(fid).id_mat(:,3) == mids(ik);
        nimm = length(find(PRT.fs(fid).id_mat(:,3) == mids(ik)));
        if nimm~= nim1 %check that modalities have the same dimensions in terms of samples
            error('prt_fs:MultKernMod_DifIm',...
                'Modalities should have the same number of samples to be considered for MKL')
        end
        addin.ID = PRT.fs(fid).id_mat(idtk,:);
    else
        addin.ID = PRT.fs(fid).id_mat;
    end
    addin.dim_m = dim_m;
    if n_kern(ik) ==1
        addin.buildkern = 1;
        [PRT,Phik] = prt_fs_modality(PRT,in,1,addin);        
        [d1,idmax] = max(Phik);
        [d1,idmin] = min(Phik);
        min_max = find(idmax==idmin);
        if isempty(min_max) || unique(Phik(:,min_max))~=0 %Kernel does not contain a whole line of zeros
            PRT.fs(fid).modality(ik).igood_kerns = 1;
        else
            error('prt_fs:NoDataInMask',...
                'Signal is zero for at least one event, cannot create kernel')
        end
        Phim = {Phik};        
        clear Phik
    else
        %Initialize all fields and compute the feature sets if needed
        if any(tocomp)
            addin.buildkern = 0;
            [PRT] = prt_fs_modality(PRT,in,1,addin);
        end
        Phim=cell(n_kern(ik),1);
        in.tocomp = zeros(1,length(tocomp));
        %For each dimension, compute kernel and save the indexes in the image for
        %further computation of the weights
        PRT.fs(fid).modality(1).idfeat_img = cell(n_kern(ik),1);
        igd = []; %indexes of non 0 kernels
        nroi = 1;
        addin.buildkern = 1;
        lab_atl = cell(n_kern(ik),1);
        fprintf(['> Computing kernel (out of %d):',repmat(' ',1,ceil(log10(n_kern(ik)))),'%d'],n_kern(ik), nroi);
        for ich = 1:kernt(1)
            itpstart = 1;
            for ifr = 1:kernt(2)
                for itp = 1:kernt(3)
                    % Update kernel counter display
                    if nroi>1
                        for idisp = 1:ceil(log10(nroi)) % delete previous counter display
                            fprintf('\b');
                        end
                        fprintf('%d',nroi);
                    end
                    % Build mask corresponding to which kernel to build
                    if kernt(1) ==1
                        icht = in.mod(mids(ik)).ich(1:dim_m(ik,1)); 
                    else
                        icht = in.mod(mids(ik)).ich(ich);
                        lab_atl{nroi} = char(chanlabels(Dsubj1,icht));
                    end %i
                    if kernt(2) ==1
                        if ~isempty(in.mod(mids(ik)).ifr)
                            ifrt = in.mod(mids(ik)).ifr(1:dim_m(ik,2));
                        else
                            ifrt = 1;
                        end
                    else
                        ifrt = in.mod(mids(ik)).ifr(ifr); 
                        if ~isempty(lab_atl{nroi})
                            lab_atl{nroi} = [lab_atl{nroi},'_Fr',num2str(ifrt)];
                        else
                            lab_atl{nroi} = ['Fr',num2str(ifrt)];
                        end
                    end %i
                    time = in.mod(mids(ik)).time;
                    if kernt(3) ==1                 %consider all time points selected
                        itpt = in.mod(mids(ik)).itp(1:dim_m(ik,3)); 
                    elseif kernt(3)== dim_m(ik,3)   %one kernel per tp
                        itpt = in.mod(mids(ik)).itp(itp); 
                        if ~isempty(lab_atl{nroi})
                            lab_atl{nroi} = [lab_atl{nroi},'_Tp',num2str(time(itpt))];
                        else
                            lab_atl{nroi} = ['Tp',num2str(time(itpt))];
                        end
                    else                            %one kernel per time window
                        itpstop = min(itpstart+winsize-1,length(in.mod(mids(ik)).itp));
                        itpt = in.mod(mids(ik)).itp(round(itpstart):round(itpstop));
                        itpstart = itpstart+winsize;    
                        if ~isempty(lab_atl{nroi})
                            lab_atl{nroi} = [lab_atl{nroi},'_TpWin',num2str(time(itpt(1)))];
                        else
                            lab_atl{nroi} = ['TpWin',num2str(time(itpt(1)))];
                        end
                    end %i
                    tot_vox = 1:numel(mask{ik});
                    tot_vox = reshape(tot_vox,size(mask{ik}));
                    idvox_fas = tot_vox(icht,ifrt,itpt);
                    addin.idvox_fas = idvox_fas(mask{ik}(icht,ifrt,itpt));
                    clear idvox_fas tot_vox
                    tmp = [length(ich), length(ifrt), length(itpt)];
                    addin.dim_m = repmat(tmp,n_mods,1);
                    % Build specific kernel
                    [PRT,Phitmp] = prt_fs_modality(PRT,in,1,addin);
                    [d1,idmax] = max(Phitmp);
                    [d1,idmin] = min(Phitmp);
                    min_max = find(idmax==idmin);
                    if isempty(min_max) || unique(Phitmp(:,min_max))~=0 %Kernel does not contain a whole line of zeros
                        igd = [igd,nroi];
                    else
                        beep
                        disp('No overlap between data and mask/atlas for at least one event')
                        disp(['Kernel ',num2str(nroi),' will be removed from further analysis'])
                    end                    
                    Phim{nroi}=Phitmp;
                    [d,dd,ddd] = intersect(squeeze(addin.idvox_fas),PRT.fs(fid).modality(ik).idfeat_fas);
                    PRT.fs(fid).modality(ik).idfeat_img{nroi} = ddd;
                    nroi = nroi+1;
                end
            end
        end
        PRT.fs(fid).multkernelROI = 1;
        PRT.fs(fid).atlas_name = {'Ch_fr_tp'};
        PRT.fs(fid).atlas_label{ik} = lab_atl;
        if isempty(igd)
            error('prt_fs:NoDataInMask',...
                'Signal is zero for at least one event, cannot create kernel')
        else
            Phim = Phim(igd);
            PRT.fs(fid).modality(ik).igood_kerns = igd;
            PRT.fs(fid).modality(ik).idfeat_img = PRT.fs(fid).modality(ik).idfeat_img(igd);
        end

    end
    

    if in.flag_mm
        %post-hoc: the ID mat should be the same for all modalities involved,
        %so only the first one will be saved
        PRT.fs(fid).multkernel = 1;
        indm=PRT.fs(fid).fas.im==1;
        PRT.fs(fid).id_mat=PRT.fs(fid).id_mat(indm,:);
        PRT.fs(fid).multkernel = 1;
        PRT.fs(fid).atlas_name = [];
        PRT.fs(fid).atlas_label = {};
    end
    Phi= [Phi, Phim];
    clear Phim
    fprintf('\n') % new line 
end

% Save kernel and function output
% -------------------------------------------------------------------------
outfile = in.fname;
disp('Saving feature set to: PRT.mat.......>>')
disp(['Saving kernel to: ',in.fs_name,'.mat.......>>'])
fs_file = [prt_dir,in.fs_name,'.mat'];
if spm_check_version('matlab','7') < 0
    save(outfile,'-V6','PRT');
    save(fs_file,'-V6','Phi');
else
%     try
%         save(outfile,'PRT');
%         save(fs_file,'Phi');
%     catch
        save(outfile,'-v7.3','PRT');
        save(fs_file,'-v7.3','Phi');
%     end
end
disp('Done.')

%--------------------------------------------------------------------------
%------------------------- Private function -------------------------------
%--------------------------------------------------------------------------

function [mask,PRT,dim_m] = build_mask(PRT, in, mids,fid)
% function to build the mask
% ---------------------------
n_mods = length(mids);
mask = cell(n_mods,1);
dim_m = zeros(n_mods,3);
for i = 1:n_mods
    mid = mids(i);
    ich = in.mod(mid).ich; %i
    ifr = in.mod(mid).ifr; %i
    itp = in.mod(mid).itp; %i
    ndim = size(PRT.fas(mid).hdr); 
    if length(ndim)==3 % No frequency information
        ndim = [ndim(1),1,ndim(2)];
    else
        ndim = ndim(1:end-1);
    end
    if isempty(ifr) && ndim(2)==1
        ifr = 1;
    end
    dim_m(i,:) = [length(ich), length(ifr), length(itp)];
    d1 = zeros(ndim);
    d2 = zeros(ndim);
    d3 = zeros(ndim); 
    d1(ich,:,:) = 1;
    d2(:,ifr,:) = 1;
    d3(:,:,itp) = 1;
    mask{i} = (d1 & d2 & d3);
    PRT.fs(fid).modality(i).idfeat_fas = find(mask{i});
    PRT.fs(fid).modality(i).dim_m = {ich, ifr, itp};
end

return
