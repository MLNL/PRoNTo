function [outfile] = prt_fs(PRT,in)
% Function to build file arrays containing the (linearly detrended) data
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
% in.mod(m).multroi    1 if one kernel per region required
% in.mod(m).atlasroi   name of the atlas to build one kernel per region
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

% Written by A. Marquand and J. Schrouff
% $Id$

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

% Load mask(s) and resize if necessary
% force second-level masking by atlas if provided
for i=1:length(in.mod)
    if isfield(in.mod(i),'atlasroi')
        if ~isempty(in.mod(i).atlasroi) && isempty(in.mod(i).mask)
            in.mod(i).mask = in.mod(i).atlasroi; 
        end
    end
end

% Load masks, atlas and labels - check for dimensionality
[mask,precmask,headers,PRT,ratl, lab_atlas] = load_masks(PRT, prt_dir, in, mids);

% Initialize the file arrays, kernel and feature set parameters
[fid,PRT,tocomp] = prt_init_fs(PRT,in,mids,mask,precmask,headers);

in.tocomp = tocomp;
in.precmask = precmask;
in.fid = fid;

% Build the feature set and kernel
%--------------------------------------------------------------------------

Phi = [];
% igd = [];
PRT.fs(fid).multkernelROI = 0; % Multiple kernels with an atlas
PRT.fs(fid).multkernel = 0;    % Multiple kernels from different modalities

% if in.flag_mm   % One kernel per modality so need to treat them independently
%     for i = 1:n_mods  % multiple modalities
%         % For each modality, get the corresponding ID mat and sample index
%         idtk = PRT.fs(fid).id_mat(:,3) == mids(i);
%         nimm = length(unique(PRT.fs(fid).id_mat(:,3) == mids(i)));
%
%         % check that modalities have the same dimensions in terms of samples
%         nim1 =length(unique(PRT.fs(fid).id_mat(:,3) == mids(1)));
%         if nimm~= nim1
%             error('prt_fs:MultKernMod_DifIm',...
%                 'Modalities should have the same number of samples to be considered for MKL')
%         end
%         addin.ID = PRT.fs(fid).id_mat(idtk,:);
%
%         % If second-level, i.e. atlas-based kernels as well
%         if isfield(in.mod(mids(i)),'multroi') ...
%                 && in.mod(mids(i)).multroi
%             %Initialize all fields and compute the feature sets if needed
%             if any(in.tocomp)
%                 [PRT] = prt_fs_modality(PRT,in,1,addin);
%             end
%             [PRT,Phim,igd] = prt_compute_ROI_kernels(PRT,in,fid,mids(i),ratl{i},addin,i);
%             PRT.fs(fid).atlas_name = ratl;
%             PRT.fs(fid).atlas_label = lab_atlas;
%             kerns = Phim(igd);
%         else
%             [PRT,Phim] = prt_fs_modality(PRT,in,1,addin);
%             [d1,idmax] = max(Phim);
%             [d1,idmin] = min(Phim);
%             min_max = find(idmax==idmin);
%             if isempty(min_max) || unique(Phim(:,min_max))~=0 % Kernel does not contain a whole line of zeros
%                 igd = i;
%                 Phim = {Phim};
%                 kerns = Phim;
%             else
%                 beep
%                 disp('No overlap between data and mask/atlas for at least one sample')
%                 disp(['Kernel ',num2str(i),' will be removed from further analysis'])
%                 kerns = [];
%                 nmodin = 1:length(PRT.fs(fid).modality);
%                 igm = setdiff(nmodin,i);
%                 PRT.fs(fid).modality = PRT.fs(fid).modality(igm);
%             end
%             PRT.fs(fid).atlas_name = {};
%             PRT.fs(fid).atlas_label = {};
%         end
%         kerns = reshape(kerns,1,length(kerns));
%         Phi = [Phi, kerns];
%         PRT.fs(fid).modality(i).igood_kerns = igd;
%     end
%     % post-hoc: the ID mat should be the same for all modalities involved,
%     % so only the first one will be saved
%     indm=PRT.fs(fid).fas.im==1;
%     PRT.fs(fid).id_mat=PRT.fs(fid).id_mat(indm,:);
%     PRT.fs(fid).multkernel = 1;
% else

% First check that all concatenated modalitlies have the same flag and
% atlas, or no atlas
if n_mods>1
    mult = zeros(n_mods,1);
    for i = 1:n_mods
        if isfield(in.mod(mids(i)),'multroi') ...
                && in.mod(mids(i)).multroi
            mult(i) = 1;
            atl = ratl{i};
            if i ==1
                atlmod = atl;
            end
            if ~strcmpi(atl,atlmod)
                error('prt_fs:ConcatenatingWithDifferentAtlases',...
                    'Concatenated multiple modalities should have the same atlas');
            end
        end
    end
    if length(unique(mult))~=1
        error('prt_fs:ConcatenateModalitiesWithandWithoutAtlas',...
            'Modalities cannot be concatenated unless they all have no or the same atlas')
    end
end


addin = struct();
% Chosen to build multiple kernels
if isfield(in.mod(mids(1)),'multroi') ...
        && in.mod(mids(1)).multroi
    % Initialize all fields and compute the feature sets if needed
    if any(in.tocomp)
        [PRT] = prt_fs_modality(PRT,in,0,[]);
    end
    % Build multiple kernels per ROI
    [PRT,Phim,igd] = prt_compute_ROI_kernels(PRT,in,fid,mids(1),ratl{1},addin,1);
    PRT.fs(fid).atlas_name{1} = ratl{1};
    PRT.fs(fid).atlas_label{1} = lab_atlas{1};
    if isempty(igd)
        error('prt_fs:NoDataInMask',...
            'No overlap between data and mask/atlas for at least one sample, cannot create kernel')
    end
    kerns = Phim(igd); % Making sure the dimensions are consistent
    kerns = reshape(kerns,1,length(kerns));
    Phi = kerns;
else % Simply concatenate the modalities in samples
    
    [PRT,Phim] = prt_fs_modality(PRT,in,0,[]);
    PRT.fs(fid).multkernel = 0;
    PRT.fs(fid).atlas_name = {};
    PRT.fs(fid).atlas_label = {};
    [d1,idmax] = max(Phim);
    [d1,idmin] = min(Phim);
    min_max = find(idmax==idmin);
    if isempty(min_max) || unique(Phim(:,min_max))~=0 %Kernel does not contain a whole line of zeros
        igd = 1;
        Phi{1}=Phim;
    else
        error('prt_fs:NoDataInMask',...
            'No overlap between data and mask/atlas for at least one sample, cannot create kernel')
    end
end
PRT.fs(fid).modality(1).igood_kerns = igd;
% end

clear Phim

% Save kernel and function output
% -------------------------------------------------------------------------
outfile = in.fname;
disp('Saving feature set to: PRT.mat.......>>')
disp(['Saving kernel to: ',in.fs_name,'.mat.......>>'])
fs_file = [prt_dir,in.fs_name];
if spm_check_version('MATLAB','7') < 0
    save(outfile,'-V6','PRT');
    save(fs_file,'-V6','Phi');
else
    try
        save(outfile,'-v7.3','PRT');
        save(fs_file,'-v7.3','Phi');
    catch
        save(outfile,'PRT');
        save(fs_file,'Phi');
    end
end
disp('Done.')

%--------------------------------------------------------------------------
%------------------------- Private function -------------------------------
%--------------------------------------------------------------------------

function [mask, precmask, headers,PRT, ratl, lab_atl] = load_masks(PRT, prt_dir, in, mids)
% function to load the mask for each modality
% -------------------------------------------
n_mods   = length(mids);
mask     = cell(1,n_mods);
precmask = cell(1,n_mods);
headers  = cell(1,n_mods);
ratl     = cell(1,n_mods);
lab_atl  = cell(1,n_mods);
for m = 1:n_mods
    mid = mids(m);
    
    % get mask for the within-brain voxels (from data and design)
    % Only for nifti files
    if isfield(PRT.masks(mid), 'fname')
        ddmask = PRT.masks(mid).fname;
        if strcmp(PRT.masks(mid).type,'nifti')
            try
                M = spm_vol(ddmask);
            catch 
                error('prt_fs:CouldNotLoadFile',...
                    'Could not load mask file');
            end
        end
    end
    
    % get mask for the kernel if one was specified, nifti or .mat
    mfile = in.mod(mid).mask;
    if ~isempty(mfile) 
        if strcmp(PRT.masks(mid).type,'nifti') % nifti, spm_vol
            try
                precM = spm_vol(char(mfile));
            catch
                error('prt_fs:CouldNotLoadFile',...
                    'Could not load mask file for preprocessing');
            end
        elseif strcmp(PRT.masks(mid).type,'.mat') % .mat, load 1st variable
            try
                tmp1 = load(mfile);
            catch
                error('prt_fs:NoMatMask',...
                    'Could not load .mat mask')
            end
            tmp2 = fieldnames(tmp1);
            if length(tmp2) > 1
                warning('Mask .mat file contains more than one variable. First variable will be read, rest will be ignored!');
            end
            tmp2 = tmp2{1}; % Assuming matrix is saved in the first variable of .mat!!!
            precM = tmp1.(tmp2);
        end
    end
    
    % get atlas for the ROI based kernel if one was specified, nifti or
    % .mat
    if isfield(in.mod(mid),'atlasroi')
        alfile = in.mod(mid).atlasroi;
        if ~isempty(alfile)
            if strcmp(PRT.masks(mid).type,'nifti') %nifti, spm_vol
                try
                    precA = spm_vol(char(alfile));
                catch
                    error('prt_fs:CouldNotLoadFile',...
                        'Could not load mask file for preprocessing');
                end
            elseif strcmp(PRT.masks(mid).type,'.mat') % .mat, load 1st variable
                try
                    tmp1 = load(alfile);
                catch
                    error('prt_fs:NoMatAtlas',...
                        'Could not load .mat atlas')
                end
                tmp2 = fieldnames(tmp1);
                if length(tmp2) > 1
                    warning('Atlas .mat file contains more than one variable. First variable will be read, rest will be ignored!');
                end
                tmp2 = tmp2{1}; % Assuming matrix is saved in the first variable of .mat!!!
                precA = tmp1.(tmp2);
            end
            [a,b]=fileparts(alfile);
            try
                load(fullfile(a,['Labels_',b,'.mat']))
                try
                    lab_atl{mid}=ROI_names;
                catch
                    disp('No variable ROI_names found, generic names used')
                end
            end
        end
    else
        alfile=[];
    end
    
    % get header of the first scan of that modality
    if strcmp(PRT.masks(mid).type,'nifti')
        if isfield(PRT,'fas') && mid<=length(PRT.fas) && ...
                ~isempty(PRT.fas(mid).dat)
            N = PRT.fas(mid).hdr;
        else
            N = spm_vol(PRT.group(1).subject(1).modality(mid).scans(1,:));
        end
        headers{m}=N;
    else
        if strcmp(PRT.masks(mid).type,'.mat')
            try
                tmp1 = load(char(PRT.group(1).subject(1).modality(mid).scans(1,:)));
            catch
                error('prt_fs:CouldNotLoadFile',...
                    'Could not load data for preprocessing');
            end
            tmp2 = fieldnames(tmp1);
            if length(tmp2) > 1
                warning('.mat file contains more than one variable. First variable will be read, rest will be ignored!');
            end
            tmp2 = tmp2{1}; % Assuming matrix is saved in the first variable of .mat!!!
            mat_data = tmp1.(tmp2);
            N.dim = size(mat_data);
            if length(size(mat_data))==2 % transform 2D into 3D, as is done with images
                N.dim = [size(mat_data), 1];
            end
            headers{m}=N;
        end
    end
    
    % compute voxel dimensions and check for equality if n_mod > 1
    if m == 1
        n_vox = prod(N.dim(1:3));
         
    elseif (n_mods > 1 && n_vox ~= prod(N.dim(1:3))) && (in.flag_mm==0)
        error('prt_fs:multipleModatlitiesVariableFeatures',...
            'Multiple modalities specified, but have variable numbers of features');
    end
    
    if strcmp(PRT.masks(mid).type,'nifti')
        % resize the different masks if needed
        if N.dim(3)==1, Npdim = N.dim(1:2); else Npdim = N.dim; end % handling case of 2D images
        if numel(N.dim)==4, Npdim = N.dim(1:3); else Npdim = N.dim; end % handling case of 4D images
        if any((M.dim ~= Npdim))
            disp('Resizing 1st level mask...')            
            V2 = spm_vol(char(ddmask));
            % reslicing V2
            fl_res = struct('mean',false,'interp',0,'which',1,'prefix','tmp_');
            spm_reslice([N V2],fl_res)
            % now renaming the file
            [V2_pth,V2_fn,V2_ext] = spm_fileparts(V2.fname);
            rV2_fn = [fl_res.prefix,V2_fn];
            if strcmp(V2_ext,'.nii')
                % turn .nii into .img/.hdr image!
                V_in = spm_vol(fullfile(V2_pth,[rV2_fn,'.nii']));
                V_out = V_in; V_out.fname = fullfile(V2_pth,[rV2_fn,'.img']);
                spm_imcalc(V_in,V_out,'i1');
            end
            mfile_new = ['updated_1stlevel_mask_m',num2str(mid)];
            movefile(fullfile(V2_pth,[rV2_fn,'.img']), ...
                fullfile(prt_dir,[mfile_new,'.img']));
            movefile(fullfile(V2_pth,[rV2_fn,'.hdr']), ...
                fullfile(prt_dir,[mfile_new,'.hdr']));
            PRT.masks(mid).fname = fullfile(prt_dir,[mfile_new,'.img']);
            mask{m} = PRT.masks(mid).fname;
        else
            mask{m} = ddmask;
        end
        if ~isempty(mfile) && any((precM.dim~= N.dim)) % && mfile ~= 0
            disp('Resizing 2nd level mask...') 
            V2 = spm_vol(char(mfile));
            % reslicing V2
            fl_res = struct('mean',false,'interp',0,'which',1,'prefix','tmp_');
            spm_reslice([N V2],fl_res)
            % now renaming the file
            [V2_pth,V2_fn,V2_ext] = spm_fileparts(V2.fname);
            rV2_fn = [fl_res.prefix,V2_fn];
            if strcmp(V2_ext,'.nii')
                % turn .nii into .img/.hdr image!
                V_in = spm_vol(fullfile(V2_pth,[rV2_fn,'.nii']));
                V_out = V_in; V_out.fname = fullfile(V2_pth,[rV2_fn,'.img']);
                spm_imcalc(V_in,V_out,'i1');
            end
            % if more than one 2nd level mask to resize
            nummask = 1;
            while exist(fullfile( ...
                    prt_dir,['updated_2ndlevel_mask_m',num2str(mid),'_',...
                    num2str(nummask),'.img']),'file')
                nummask = nummask+1;
            end
            mfile_new = ['updated_2ndlevel_mask_m',num2str(mid),...
                '_',num2str(nummask)];
            movefile(fullfile(V2_pth,[rV2_fn,'.img']), ...
                fullfile(prt_dir,[mfile_new,'.img']));
            movefile(fullfile(V2_pth,[rV2_fn,'.hdr']), ...
                fullfile(prt_dir,[mfile_new,'.hdr']));
            precmask{m} = fullfile(prt_dir,[mfile_new,'.img']);
        else
            precmask{m} = mfile;
        end
        if ~isempty(alfile) && any((precA.dim~= N.dim))
            disp('Resizing atlas...') 
            V2 = spm_vol(char(alfile));
            % reslicing V2
            fl_res = struct('mean',false,'interp',0,'which',1,'prefix','tmp_');
            spm_reslice([N V2],fl_res)
            % now renaming the file
            [V2_pth,V2_fn,V2_ext] = spm_fileparts(V2.fname);
            rV2_fn = [fl_res.prefix,V2_fn];
            if strcmp(V2_ext,'.nii')
                % turn .nii into .img/.hdr image!
                V_in = spm_vol(fullfile(V2_pth,[rV2_fn,'.nii']));
                V_out = V_in; V_out.fname = fullfile(V2_pth,[rV2_fn,'.img']);
                spm_imcalc(V_in,V_out,'i1');
            end
            alfile_new = ['updated_atlas_',V2_fn];
            movefile(fullfile(V2_pth,[rV2_fn,'.img']), ...
                fullfile(prt_dir,[alfile_new,'.img']));
            movefile(fullfile(V2_pth,[rV2_fn,'.hdr']), ...
                fullfile(prt_dir,[alfile_new,'.hdr']));
            ratl{m} = fullfile(prt_dir,[alfile_new,'.img']);
        else
            ratl{m} = alfile;
        end
        clear M N precM precA V1 V2 mfile mfile_new
    % .mat files
    elseif strcmp(PRT.masks(mid).type,'.mat')
        if N.dim(3)==1, Npdim = N.dim(1:2); else Npdim = N.dim; end %handling 2D vectors
        if ~isempty(mfile) % 2nd level mask
            if any(size(precM)~= Npdim) % check dimensions agree
                error('prt_init_fs:WrongDimMask',...
                    ['2nd level mask of modality ',num2str(m),' does not have correct data dimensions'])
            end
            precmask{m} = mfile;
        end
        if ~isempty(alfile) %Same checks for atlas                      
            if any(size(precA)~= Npdim)
                error('prt_fs:WrongDimAtlas',...
                    ['Atlas of modality ',num2str(m),' does not have correct data dimensions'])
            end
            ratl{m} = alfile;
        end
        clear M N precM precA mfile
    end
end


function [PRT,Phi,igd,nroi] = prt_compute_ROI_kernels(PRT,in,fid,mids,atl,addin,ind_mod)
% function to load the mask for each modality
% -------------------------------------------

%For each region, get the indexes of the voxels in the 2nd level mask
if strcmpi(PRT.masks(mids).type,'nifti')
    atl = spm_vol(atl);
    h=spm_read_vols(atl);
elseif strcmpi(PRT.masks(mids).type,'.mat')
    tmp1 = load(atl);
    tmp2 = fieldnames(tmp1);
    tmp2 = tmp2{1};
    h = tmp1.(tmp2);
end
if ~isempty(PRT.fs(fid).modality(ind_mod).idfeat_fas)
    idt = PRT.fs(fid).modality(ind_mod).idfeat_fas; %indexes of voxels in second-level mask
else
    idt = 1:length(PRT.fas(mids).idfeat_img);
end
idm1 = PRT.fas(mids).idfeat_img(idt); %indexes of voxels in first level mask
interh = h(idm1);
roi = unique(interh(interh>0));
nroi = length(roi);
Phi=cell(nroi,1);
in.tocomp = zeros(1,length(in.tocomp));
%For each region, compute kernel and save the indexes in the image for
%further computation of the weights
PRT.fs(fid).modality(ind_mod).idfeat_img = cell(nroi,1);
igd = []; %indexes of non 0 kernels
for i=1:nroi
    disp ([' > Computing kernel: ', num2str(i),' of ',num2str(nroi),' ...'])
    addin.idvox_fas = idt(interh == roi(i));
    [PRT,Phim] = prt_fs_modality(PRT,in,1,addin);
    [d1,idmax] = max(Phim);
    [d1,idmin] = min(Phim);
    min_max = find(idmax==idmin);
    if isempty(min_max) || unique(Phim(:,min_max))~=0 %Kernel does not contain a whole line of zeros
        igd = [igd,i];
    else
        beep
        disp('No overlap between data and mask/atlas for at least one sample')
        disp(['Region ',num2str(i),' will be removed from further analysis'])
    end
    Phi{i}=Phim;
    %         idts = idt(interh == roi(i));
    PRT.fs(fid).modality(ind_mod).idfeat_img{i} = find(interh == roi(i)) ;
end
PRT.fs(fid).multkernelROI = 1;
if ~isempty(igd)
    PRT.fs(fid).modality(ind_mod).idfeat_img = PRT.fs(fid).modality(ind_mod).idfeat_img(igd);
    PRT.fs(fid).modality(ind_mod).num_ROI = roi(igd);
end


return
