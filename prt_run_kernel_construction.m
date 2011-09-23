function out = prt_run_kernel_construction(varargin)
% PRONTO job execution function
% takes a harvested job data structure and rearrange data into "proper"
% data structure, then save do what it has to do...
% Here simply the harvested job structure in a mat file.
%
% Input:
% job    - harvested job data structure (see matlabbatch help)
% Output:
% out    - filename of saved data structure.
%__________________________________________________________________________
% Copyright (C) 2011

% Written by A Marquand
% $Id$

% Job variable
% -------------------------------------------------------------------------
job   = varargin{1};

% Load PRT.mat and configure some variables
% -------------------------------------------------------------------------
fname = char(job.infile);
load(fname);

prt_dir = regexprep(fname,'PRT.mat', ''); % or: fileparts(fname);

n_groups      = length(PRT.group);
[n_mods mids] = get_modalities(PRT, job);

% Load mask(s) and resize if necessary
[mask, n_vox] = load_masks(PRT, prt_dir, job);

% Initialize kernel
kernel = init_kernel(PRT,job);
n      = length(kernel.ids);

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
                switch get_mode(job,m)
                    case 'all_scans'
                        
                        fname = [prt_dir, prt_get_filename([gid,sid,mid])];
                        n_vols_s = size(PRT.group(gid).subject(sid).modality(mid).scans,1);
                        sample_range = (1:n_vols_s)+max(sample_range);
                        
                        % load the current block
                        data_vols(:,sample_range) = ...
                            repmat(block_mask,1,length(sample_range)) .* ...
                            prt_load_blocks(fname,block_size,b);
                        
                    case 'all_conds'
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
    kernel.K = kernel.K + (data_vols' * data_vols);
    
    bstart=bend+1; bend=min(bstart+block_size-1,n_vox);
end

% Detrend
% -------------------------------------------------------------------------
linear_dt = false;
% construct indicator matrix
Kidx = [[kernel.ids(:).group]', ...
        [kernel.ids(:).subject]', ...
        [kernel.ids(:).modality]', ...
        [kernel.ids(:).cond]', ... 
        [kernel.ids(:).scan]'];
% configure confound matrix
C = [];
for gid = 1:length(PRT.group)    
    for sid = 1:length(PRT.group(gid).subject)
        for m = 1:n_mods
            if job.modality(m).kernel_dt == 1
                linear_dt = true; 
                rg = logical(double(Kidx(:,1) == gid) .* double(Kidx(:,2) == sid) .* double(Kidx(:,3) == mids(m)));
                c  = zeros(n,2);
                c(rg,1:2) = [(1:sum(rg))' ones(sum(rg),1)];
                C = [C c];
            end
        end
    end
end

% detrend
if linear_dt
    kernel.K = prt_remove_confounds(kernel.K,C);
end

% Normalise
% -------------------------------------------------------------------------
if job.normalise
    kernel.K = prt_normalise_kernel(kernel.K);
end

% Save kernel and function output
% -------------------------------------------------------------------------
outfile = [prt_dir, 'kernel_',job.kernel_filename,'.mat'];
disp(['Saving kernel to: ',['kernel_',job.kernel_filename],'.mat.......>>'])
if spm_matlab_version_chk('7') >= 0
    save(outfile,'-V6','kernel');
else
    save(outfile,'kernel');
end

out.fname{1} = outfile;
disp('Kernel construction done.')
end

% -------------------------------------------------------------------------
% Private functions
% -------------------------------------------------------------------------

function kernel = init_kernel(PRT, job)
% function to initialise the kernel data structure
% ------------------------------------------------

kernel.name = job.kernel_filename;
kernel.ids  = struct('modality',{},'group',{},'subject',{},'cond',{},'scan',{}); 

[n_mods mids] = get_modalities(PRT, job);
for m = 1:n_mods
   kernel.modality(m).mod_name = PRT.masks(m).mod_name;
   kernel.modality(m).kernel_dt = job.modality(m).kernel_dt;
end

% Count the total number of samples and set sample ids
sample_range = 0;
for gid = 1:length(PRT.group) % group    
    for sid = 1:length(PRT.group(gid).subject);  % subject       
        for m = 1:n_mods
            mid = mids(m);
            if strcmp(get_mode(job,m),'all_scans');
                n_vols_s = size(PRT.group(gid).subject(sid).modality(mid).scans,1);
                
                % configure indices
                sample_range = (1:n_vols_s)+max(sample_range);
                [kernel.ids(sample_range).group]    = deal(gid);
                [kernel.ids(sample_range).subject]  = deal(sid);
                [kernel.ids(sample_range).modality] = deal(mid);
                [kernel.ids(sample_range).cond]     = deal(0);
                for ii = 1:length(sample_range)
                    kernel.ids(sample_range(ii)).scan = ii;
                end
                
            elseif strcmp(get_mode(job,m),'all_conds')
                conds = PRT.group(gid).subject(sid).modality(mid).design.conds;
                
                % now loop over conditions
                for cid = 1:length(conds)    % condition
                    scans = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).scans;
                    n_vol_s_c = length(scans);
                    
                    % configure indices
                    sample_range = (1:n_vol_s_c)+max(sample_range);
                    [kernel.ids(sample_range).group]    = deal(gid);
                    [kernel.ids(sample_range).subject]  = deal(sid);
                    [kernel.ids(sample_range).modality] = deal(mid); 
                    [kernel.ids(sample_range).cond]     = deal(cid);
                    for ii = 1:length(sample_range)
                        kernel.ids(sample_range(ii)).scan = ii;
                    end
                end                
            end
        end  % modality
    end  % subject 
end  % group

kernel.K = zeros(length(kernel.ids)); 
end

function [mask, n_vox] = load_masks(PRT, prt_dir, job)
% function to load the mask for each modality
% -------------------------------------------

[n_mods mids mnames] = get_modalities(PRT, job);
if length(job.mask) ~= n_mods
    error('Number of masks does not match the number of modalities.');
end

mask  = cell(1,n_mods);
for m = 1:n_mods    
    mid = mids(m);
    mname = char(job.mask(m).mod_name);
    
    %mfile = char(job.mask(m).fmask); % = job.mask(m);
    mfile = 'xxx';
    for mm = 1:length(mnames)
       if strcmp(mname, mnames(mm))
           mfile = job.mask(mm).fmask;
       end
    end
    if strcmp(mfile,'xxx');
        error(['Can''t find mask for modality ', mname]);
    end
    
    if PRT.group(1).subject(1).modality(mid).detrend        
        file_idx = [1 1 mid 1];
    else
        file_idx = [1 1 mid];
    end

    M = nifti(mfile);
    N = nifti([prt_dir,prt_get_filename(file_idx),'.img']);
    
    % compute voxel dimensions and check for equality if n_mod > 1
    if m == 1 
        n_vox = prod(N.dat.dim(1:3));  
    elseif n_mods > 1 && n_vox ~= prod(N.dat.dim(1:3))
        error('Multiple modalities specified, but have variable numbers of features');  
    end

    if size(M.dat(:,:,:,1)) ~= size(N(1).dat(:,:,:,1))
        warning('Mask has different dimensions to the image files. Resizing...');
        
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

function [n_mods mids mnames] = get_modalities(PRT, job)
% function to determine the number of modalities and return their ids.
% ----------------------------------------------------------------------

n_mods = length(job.modality);
mids   = zeros(n_mods,1);
for m = 1:n_mods
    %mids(m) = lookup_name(PRT,job.modality(m).mod_name,'modality');
    
    mnames   = {PRT.masks.mod_name};
    target      = job.modality(m).mod_name;
    
    % search the list of modalities
    id = NaN;
    for i = 1:length(mnames)
        if strcmpi(mnames{i},target)
            id = i;
        end
    end
    
    % return an error if the target isn't found
    if isnan(id)
        error(['Couldn''t find modality "',target,'" in PRT.mat']);
    end
    
    mids(m) = id;
end
end

function mode = get_mode(job, m)
% function to determine how scans are selected for each modality
% --------------------------------------------------------------

if isfield(job.modality(m).conditions,'all_scans') 
    mode  = 'all_scans';
elseif isfield(job.modality(m).conditions,'all_cond')
    mode = 'all_conds';
else
   error ('Invalid mode selected')
end

end



