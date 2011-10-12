function [fs_file] = prt_fs(PRT,in)
% Function to compute a linear (dot product) kernel
%
% Inputs:
% -------
% in.fname:     filename for the PRT.mat (string)
% in.kname:     relative path filename for the kernel matrix (string)
% in.normalise: scale the kernel to a unit hypersphere (boolean)
%
% in.mod(m).mod_name:  name of modality to include in this kernel (string)
% in.mod(m).kernel_dt: detrend the kernel (scalar: 0 = none, 1 = linear)
% in.mod(m).mode:      'all_cond' or 'all_scans' (string)
% in.mod(m).mask:      mask file used to create the kernel
%
% Outputs:
% --------
% This function performs the following functions:
%   1. Calls prt_init_fs to populate basic fields in PRT.fs(f). 
%   2. Populates the following fields in PRT.mat:
%       PRT.fs(f).modality(m).mod_name
%       PRT.fs(f).modality(m).mode
%       PRT.fs(f).modality(m).mask 
%       PRT.fs(f).modality(m).feat_idx 
%       PRT.fs(f).modality(m).rf_mat
%   3. Writes PRT.mat
%   4. Writes the kernel matrix to the path indicated by in.kname
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A. Marquand and J. Schrouff 
% $Id$

% !!!!!!!!!!! NOTE !!!!!!!!!!
% This file should be modified to accommodate the unified preprocessing
% structure

% Configure some variables
% -------------------------------------------------------------------------
prt_dir = regexprep(in.fname,'PRT.mat', ''); % or: fileparts(fname);
n_groups      = length(PRT.group);

% get the index of the modalities for which the user wants to include
mids=[];
for i=1:length(in.mod)
    if ~isempty(in.mod(i).mask)
        mids=[mids,i];
    end
end
n_mods = length(mids);

% Load mask(s) and resize if necessary
[mask, n_vox] = load_masks(PRT, prt_dir, in.mod,mids);

% Initalise feature set
fs.mod     = in.mod;
fs.fs_name = in.kname;
% NOTE!! the next two fields will need to be updated separately once the
%        unified preprocessing structure is implemented.
fs.k_file  = in.kname;   
fs.fas  = [];               % not implemented yet
[fid, PRT] = prt_init_fs(PRT,fs);

% Initialize kernel
n   = size(PRT.fs(fid).id_mat,1);
Phi = zeros(n); 

% Set memory limit
mem         = prt_get_defaults('kernel.mem_limit');
block_size  = ceil(mem/8/n); % Block size (double = 8 bytes)
n_block     = ceil(n_vox/block_size);

% Compute kernel (block-wise)
% -------------------------------------------------------------------------
bstart=1; bend=min(block_size,n_vox);
for b = 1:n_block
    sample_range = 0; % initialise (will be set later)
    disp ([' > processing block: ', num2str(b),' of ',num2str(n_block),' ...'])
            
   vox_range=bstart:bend;
   data_vols=zeros(length(vox_range),n);
        
    for gid = 1:n_groups
        for sid = 1:length(PRT.group(gid).subject)            
            for m = 1:n_mods
                mid = mids(m);
                block_mask = prt_load_blocks(mask{m},block_size,b);
                
                % Select scans
                switch in.mod(mid).mode
                    case 'all_scans'
                        
                        fname = [prt_dir, prt_get_filename([gid,sid,mid])];
                        n_vols_s = size(PRT.group(gid).subject(sid).modality(mid).scans,1);
                        sample_range = (1:n_vols_s)+max(sample_range);
                        
                        % load the current block
                        data_vols(:,sample_range) = ...
                            repmat(block_mask,1,length(sample_range)) .* ...
                            prt_load_blocks(fname,block_size,b);
                        
                    case 'all_cond'     
                        conds = PRT.group(gid).subject(sid).modality(mid).design.conds;
                        
                        
                        for cid = 1:length(conds)    % condition                           
                            scans = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).scans;
                            n_vol_s_c = length(scans);
                            
                            sample_range = (1:n_vol_s_c)+max(sample_range);
                            
                            fname = [prt_dir, prt_get_filename([gid,sid,mid,cid])];
                            
                            % load the current block
                            data_vols(:,sample_range) = ...
                                repmat(block_mask,1,length(sample_range)) .* ...
                                prt_load_blocks(fname,block_size,b);
                            
                        end    % condition
                end        % case
            end       % modality
        end       % subject
    end       % group
    
    % add this block's contribution to K
    Phi = Phi + (data_vols' * data_vols);
    
    bstart=bend+1; bend=min(bstart+block_size-1,n_vox);
end

% Detrend
% FIXME: this should be integrated into the prepare_data architecture and
% written so that it doesn't need three nested for loops
% -------------------------------------------------------------------------
linear_dt = false;
% configure confound matrix
C = [];
for gid = 1:length(PRT.group)    
    for sid = 1:length(PRT.group(gid).subject)
        for m = 1:n_mods
            if in.mod(mids(m)).kernel_dt == 1
                linear_dt = true;
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

% detrend
if linear_dt
    [Phi, R] = prt_remove_confounds(Phi,C);
    PRT.fs(fid).kernel_dt = 1;
else
    R = eye(n)-C*pinv(C);
    PRT.fs(fid).kernel_dt = 0;
end
PRT.fs(fid).rf_mat = R;

% Normalise
% -------------------------------------------------------------------------
if in.normalise
    Phi = prt_normalise_kernel(Phi);
end

% Populate additional fields in PRT.mat
% -------------------------------------------------------------------------
for m = 1:length(mids)
    PRT.fs(fid).modality(m).mod_name  = in.mod(m).mod_name;
    PRT.fs(fid).modality(m).mode      = in.mod(m).mode;
    PRT.fs(fid).modality(m).mask_file = mask{m};
    
    N = nifti(mask{m});
    PRT.fs(fid).modality(m).feat_idx  = ...
        find(reshape(N.dat(:,:,:,1),prod(N.dat.dim(1:3)),1));
end
PRT.fs(fid).normalise = in.normalise;

% Save kernel and function output
% -------------------------------------------------------------------------
fs_file = [prt_dir,in.kname];
disp(['Saving kernel to: ',in.kname,'.mat.......>>'])
disp('Updating PRT.mat.......>>')
if spm_matlab_version_chk('7') >= 0
    save(fs_file,'-V6','Phi');
    save(in.fname,'-V6','PRT');
else
    save(fs_file,'Phi');
    save(in.fname,'-V6','PRT');
end
end

% -------------------------------------------------------------------------
% Private functions
% -------------------------------------------------------------------------

function [mask, n_vox] = load_masks(PRT, prt_dir, in, mids)
% function to load the mask for each modality
% -------------------------------------------
n_mods=length(mids);
mask  = cell(1,n_mods);
for m = 1:n_mods
    mid=mids(m);
    mfile=in(mid).mask;

    if PRT.group(1).subject(1).modality(mid).detrend        
        file_idx = [1 1 mid 1];
    else
        file_idx = [1 1 mid];
    end
    try
        M = nifti(mfile);
    catch
        error(['Could not load mask file ',mfile]);
    end
    N = nifti([prt_dir,prt_get_filename(file_idx),'.img']);
    
    % compute voxel dimensions and check for equality if n_mod > 1
    if m == 1 
        n_vox = prod(N.dat.dim(1:3));  
    elseif n_mods > 1 && n_vox ~= prod(N.dat.dim(1:3))
        error('prt_fs:multipleModatlitiesVariableFeatures',...
              'Multiple modalities specified, but have variable numbers of features');  
    end

    if size(M.dat(:,:,:,1)) ~= size(N(1).dat(:,:,:,1))
        warning('prt_fs:maskAndImagesDifferentDim',...
            'Mask has different dimensions to the image files. Resizing...');
        
        V1 = spm_vol([prt_dir,prt_get_filename(file_idx),'.img,1']);
        V2 = spm_vol(char(mfile));
        mfile_new       = V1;
        mfile_new.fname = [prt_dir 'updated_kernel_mask_m',num2str(mid),'.img'];       
        tmp     = spm_imcalc([V1 V2],mfile_new,'0.*i1+(i2>0)');
        mask{m} = mfile_new.fname;
    else
        mask{m} = mfile;
    end
    clear M N V1 V2 mfile mfile_new
end
end
