function [outfile]=prt_fs(PRT,in)
% Function to build file arrays containing the (linearly detrended) data
% and compute a linear (dot product) kernel from them
%
% Inputs:
% -------
% in.fname:      filename for the PRT.mat (string)
% in.fs_name:    name of fs and relative path filename for the kernel matrix
%
% in.mod(m).mod_name:  name of modality to include in this kernel (string)
% in.mod(m).kernel_dt: detrend the kernel (scalar: 0 = none, 1 = linear)
% *in.mod(m).param_dt:  parameters for the kernel detrend (e.g. DCT bases)
% in.mod(m).mode:      'all_cond' or 'all_scans' (string)
% in.mod(m).mask:      mask file used to create the kernel
% *in.mod(m).normalise: 0 = none, 1 = normalise_kernel, 2 = scale modality
% *in.mod(m).matnorm:   scaling
%
% Outputs:
% --------
% Calls prt_init_fs to populate basic fields in PRT.fs(f)...
% Writes PRT.mat
% Writes the kernel matrix to the path indicated by in.kname
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A. Marquand and J. Schrouff

% $Id$

% Configure some variables and get defaults
% -------------------------------------------------------------------------
prt_dir = regexprep(in.fname,'PRT.mat', ''); % or: fileparts(fname);

n_groups      = length(PRT.group);
% get the index of the modalities for which the user wants a kernel/data
n_mods=length(in.mod);
mids=[];
for i=1:n_mods
    if ~isempty(in.mod(i).mod_name)
        mids = [mids, i];
    end
end
n_mods=length(mids);
def=prt_get_defaults('fs');

% Load mask(s) and resize if necessary
[mask,precmask,headers] = load_masks(PRT, prt_dir, in,mids);

% Initialize the file arrays, kernel and feature set parameters
[fid,PRT,tocomp] = prt_init_fs(PRT,in,mids,mask,precmask,headers);

n   = length(PRT.fs(fid).id_mat);
Phi = zeros(n);

% Build confound and residual forming matrices (for detrending)
% -------------------------------------------------------------------------
kern_norm = false;
% configure confound matrix
C = [];
for gid = 1:length(PRT.group)
    for sid = 1:length(PRT.group(gid).subject)
        for m = 1:n_mods
            if in.mod(mids(m)).kernel_dt == 1
                linear_dt = true;
            end
            if in.mod(mids(m)).normalise == 1
                kern_norm = true;
            end
            rg = (PRT.fs(fid).id_mat(:,1) == gid) & ...
                (PRT.fs(fid).id_mat(:,2) == sid) & ...
                (PRT.fs(fid).id_mat(:,3) == mids(m));
            c  = zeros(n,2);
            c(rg,1:2) = [(1:sum(rg))' ones(sum(rg),1)];
            C = [C c];
        end
    end
end
PRT.fs(fid).rf_mat = eye(n)-C*pinv(C);

% -------------------------------------------------------------------------
% ---------------------Build file arrays and kernel------------------------
% -------------------------------------------------------------------------
mem = def.mem_limit;
nfa = [];
for m=1:n_mods
    nfa = [nfa, PRT.fas(mids(m)).dat.dim(1)];
    n_vox = PRT.fas(mids(m)).dat.dim(2);
end
block_size  = floor(mem/8/max([nfa, n])); % Block size (double = 8 bytes)
n_block     = ceil(n_vox/block_size);
bstart=1; bend=min(block_size,n_vox);
h = waitbar(0,'Please wait while images are pre-processed');
step=1;
for b = 1:n_block
    disp ([' > processing block: ', num2str(b),' of ',num2str(n_block),' ...'])
    vox_range = bstart:bend;
    block_size=length(vox_range);
    kern_vols=zeros(block_size,n);
    for m=1:n_mods
        mid=mids(m);
        
        %Parameters for the masks and indexes of the voxels
        %-------------------------------------------------------------------
        
        %get the indexes of the voxels within the file array mask (data &
        %design step)
        ind_ddmask = PRT.fas(mid).idfeat_img(vox_range);
        
        %load the mask for that modality if another one was specified
        if ~isempty(precmask{m})
            prec_mask = prt_load_blocks(precmask{m},ind_ddmask);
        else
            prec_mask = ones(block_size,1);
        end
        %indexes to access the file array
        indm=find(PRT.fs(fid).fas.im==mid);
        ifa=PRT.fs(fid).fas.ifa(indm);
        
        %get the data from each subject of each group and save its linear
        %detrended version in a file array
        %-------------------------------------------------------------------
        if tocomp(mid)  %need to build the file array corresponding to that modality
            sample_range=0;
            nfa=PRT.fas(mid).dat.dim(1);
            datapr=zeros(nfa,block_size);
            
            %get the data for each subject of each group
            for gid = 1:n_groups
                for sid = 1:length(PRT.group(gid).subject)
                    n_vols_s = size(PRT.group(gid).subject(sid).modality(mid).scans,1);
                    sample_range=(1:n_vols_s)+max(sample_range);
                    fname = PRT.group(gid).subject(sid).modality(mid).scans;
                    datapr(sample_range,:) = (prt_load_blocks(fname,ind_ddmask))';
                    if ~def.writeraw
                        %datapr(sample_range,:)=detrend(datapr(sample_range,:));
                        datapr(sample_range,:)=detrend(datapr(sample_range,:));
                    end
                end
            end
            
            %Write the data detrended into the file array
            namedat=['Data_matrix_',char(in.mod(mid).mod_name),'.dat'];
            fpd_clean = fopen(fullfile(prt_dir,namedat), 'a'); % 'a' append
            if b==1
                % write the data in file .dat
                fwrite(fpd_clean, datapr, 'float32');
                fclose(fpd_clean);
            else
                % Append the data in file .dat
                fseek(fpd_clean,0,'eof');
                fwrite(fpd_clean, datapr, 'float32');
                fclose(fpd_clean);
            end
            
            % get the data to build the kernel
            kern_vols(:,indm) = datapr(ifa,:)'.* ...
                repmat(prec_mask,1,length(ifa));
            % if a scaling was entered, apply it now
            if ~isempty(PRT.fs(fid).modality(m).normalise.scaling)
                kern_vols(:,indm) = kern_vols(:,indm)./ ...
                    reshape(PRT.fs(fid).modality(m).normalise.scaling,block_size,1);
            end
            clear datapr
        else
            kern_vols(:,indm) = (PRT.fas(mid).dat(ifa,vox_range))' .* ...
                repmat(prec_mask,1,length(ifa));
            % if a scaling was entered, apply it now
            if ~isempty(PRT.fs(fid).modality(m).normalise.scaling)
                kern_vols(:,indm) = kern_vols(:,indm)./ ...
                    reshape(PRT.fs(fid).modality(m).normalise.scaling,block_size,1);
            end
            
        end
        waitbar(step/ (n_block*n_mods),h);
        step=step+1;
    end
    Phi = Phi + (kern_vols' * kern_vols);
    bstart=bend+1; bend=min(bstart+block_size-1,n_vox);
    clear block_mask kern_vols
end
close(h)

% Normalise
% -------------------------------------------------------------------------
if kern_norm
    Phi = prt_normalise_kernel(Phi);
end

% Save kernel and function output
% -------------------------------------------------------------------------
outfile = in.fname;
disp('Saving feature set to: PRT.mat.......>>')
disp(['Saving kernel to: ',in.fs_name,'.mat.......>>'])
fs_file = [prt_dir,in.fs_name];
if spm_matlab_version_chk('7') >= 0
    save(outfile,'-V6','PRT');
    save(fs_file,'-V6','Phi');
else
    save(outfile,'PRT');
    save(fs_file,'Phi');
end

% -------------------------------------------------------------------------
% Private functions
% -------------------------------------------------------------------------

function [mask, precmask, headers] = load_masks(PRT, prt_dir, in, mids)
% function to load the mask for each modality
% -------------------------------------------
n_mods=length(mids);
mask  = cell(1,n_mods);
precmask  = cell(1,n_mods);
headers = cell(1,n_mods);
for m = 1:n_mods
    mid=mids(m);
    
    %get mask for the within-brain voxels (from data and design)
    ddmask=PRT.masks(mid).fname;
    try
        M=nifti(ddmask);
    catch
        error('prt_prepare_data:CouldNotLoadFile',...
            'Could not load mask file');
    end
    
    %get mask for the kernel if one was specified
    mfile=in.mod(mid).mask;
    if ~isempty(mfile) &&  mfile ~= 0
        try
            precM = nifti(mfile);
        catch
            error('prt_prepare_data:CouldNotLoadFile',...
                'Could not load mask file for preprocessing');
        end
    end
    
    %get header of the first scan of that modality
    if isfield(PRT,'fas') && ~isempty(PRT.fas(mid).dat)
        N=PRT.fas(mid).hdr;
    else
        N=spm_vol(PRT.group(1).subject(1).modality(mid).scans(1,:));
    end
    headers{m}=N;
    
    
    % compute voxel dimensions and check for equality if n_mod > 1
    if m == 1
        n_vox = prod(N.dim(1:3));
    elseif n_mods > 1 && n_vox ~= prod(N.dim(1:3))
        error('prt_prepare_data:multipleModatlitiesVariableFeatures',...
            'Multiple modalities specified, but have variable numbers of features');
    end
    
    %resize the different masks if needed
    if any(size(M.dat(:,:,:,1)) ~= N.dim)
        warning('prt_prepare_data:maskAndImagesDifferentDim',...
            'Mask has different dimensions to the image files. Resizing...');
        
        V2 = spm_vol(char(ddmask));
        mfile_new       = N;
        mfile_new.fname = [prt_dir 'updated_kernel_mask_m',num2str(mid),'.img'];
        tmp             = spm_imcalc([N V2],mfile_new,'0.*i1+(i2>0)');
        mask{m}         = mfile_new.fname;
    else
        mask{m} = ddmask;
        
    end
    if ~isempty(mfile) && mfile ~= 0  && any((size(precM.dat(:,:,:,1))~= N.dim))
        warning('prt_prepare_data:maskAndImagesDifferentDim',...
            'Preprocessing mask has different dimensions to the image files. Resizing...');
        
        V2 = spm_vol(char(mfile));
        mfile_new       = precM;
        mfile_new.fname = [prt_dir 'updated_kernel_mask_m',num2str(mid),'.img'];
        tmp             = spm_imcalc([precM V2],mfile_new,'0.*i1+(i2>0)');
        precmask{m}     = mfile_new.fname;
    else
        precmask{m} = mfile;
    end
    clear M N precM V1 V2 mfile mfile_new
end

