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

n_groups      = length(job.group);
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
        
    % Select all groups
    for g = 1:n_groups
        gid = lookup_name(PRT,job.group(g).gr_name,'group');
            
        % Select all subjects
        for s = 1:length(job.group(g).subjects)
            sid = job.group(g).subjects(s);
                    
            % Select all modalities
            for m = 1:n_mods
                mid = mids(m);
                
                block_mask = prt_load_blocks(mask{m},block_size,b);
                
                % Select scans
                if strcmp(get_mode(job,g,m),'all_scans')   
                    fname = [prt_dir, prt_get_filename([gid,sid,mid])];
                    
                    n_vols_s = length(PRT.group(gid).subject(sid).modality(mid).scans);
                    
                    sample_range = (1:n_vols_s)+max(sample_range);
                    
                    % load the current block
                    data_vols(:,sample_range) = ...
                        repmat(block_mask,1,length(sample_range)) .* ...
                        prt_load_blocks(fname,block_size,b);
                    
                else
                    % Select conditions
                    if strcmp(get_mode(job,g,m),'all_conds')
                        conds = PRT.group(gid).subject(sid).modality(mid).design.conds;
                    else
                        conds = job.group(g).modality(m).conditions.cond_name;
                    end
                    
                    for c = 1:length(conds)    % condition
                        cid = lookup_name(PRT,conds(c).cond_name,'condition',gid,mid);
                        
                        onsets    = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).onsets;
                        durations = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).durations;
                        if (length(durations) == 1)
                            durations = repmat(durations,length(onsets),1);
                        end
                        n_vol_s_c = sum(durations);
                        
                        sample_range = (1:n_vol_s_c)+max(sample_range);
                        
                        fname = [prt_dir, prt_get_filename([gid,sid,mid,cid])];
                        
                        % load the current block
                        data_vols(:,sample_range) = ...
                            repmat(block_mask,1,length(sample_range)) .* ...
                            prt_load_blocks(fname,block_size,b);
                        
                    end       % condition
                end
            end       % modality
        end       % subject
    end       % group
    
    % add this block's contribution to K
    kernel.K = kernel.K + (data_vols' * data_vols);
    
    bstart=bend+1; bend=min(bstart+block_size-1,n_vox);
end

% Normalise
if job.normalise
    kernel.K = prt_normalise_kernel(kernel.K);
end

%K_idx = [[kernel.ids(:).group]' [kernel.ids(:).subject]'  [kernel.ids(:).modality]' [kernel.ids(:).cond]' [kernel.ids(:).scan]'];

% Save kernel and indices
outfile = [prt_dir, 'kernel_',job.kernel_filename];
disp(['Saving kernel to: ',['kernel_',job.kernel_filename],'.mat.......>>'])
if spm_matlab_version_chk('7') >= 0
    save(outfile,'-V6','kernel');
else
    save(outfile,'kernel');
end

% Function output
% -------------------------------------------------------------------------
out.files{1} = outfile;
disp('Kernel construction done.')
end

% -------------------------------------------------------------------------
% Local functions
% -------------------------------------------------------------------------

function kernel = init_kernel(PRT, job)
% function to initialise the kernel data structure
% ------------------------------------------------

kernel.name = job.kernel_filename;
kernel.ids  = struct('modality',{},'group',{},'subject',{},'cond',{},'scan',{}); 

[n_mods mids] = get_modalities(PRT, job);

% Count the total number of samples and set sample ids
sample_range = 0;
for g = 1:length(job.group) % group
    gid = lookup_name(PRT,job.group(g).gr_name,'group');
    
    for s = 1:length(job.group(g).subjects);  % subject
        sid = job.group(g).subjects(s);
        
        % check the input specification
        if job.group(g).subjects(s) > length(PRT.group(gid).subject)
            error ('The number of subjects selected exceeds the group size');
        end
        
        for m = 1:n_mods
            mid = mids(m);
            if strcmp(get_mode(job,g,m),'all_scans');
                n_vols_s = length(PRT.group(gid).subject(sid).modality(mid).scans);
                
                % configure indices
                sample_range = (1:n_vols_s)+max(sample_range);
                [kernel.ids(sample_range).group]    = deal(gid);
                [kernel.ids(sample_range).subject]  = deal(sid);
                [kernel.ids(sample_range).modality] = deal(mid); 
                [kernel.ids(sample_range).cond]     = deal(NaN);
                for ii = 1:length(sample_range)
                    kernel.ids(sample_range(ii)).scan = ii;
                end
                
            else
                if strcmp(get_mode(job,g,m),'all_conds')
                    conds = PRT.group(gid).subject(sid).modality(mid).design.conds;
                else
                    conds = job.group(g).conditions.cond_name;
                end
                % now loop over conditions
                for c = 1:length(conds)    % condition
                    cid = lookup_name(PRT,conds(c).cond_name,'condition',gid,mid);
                    
                    onsets    = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).onsets;
                    durations = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).durations;
                    if (length(durations) == 1)
                        durations = repmat(durations,length(onsets),1);
                    end
                    n_vol_s_c = sum(sum(durations));
                    
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
% function to initialise the kernel data structure
% ------------------------------------------------

[n_mods mids] = get_modalities(PRT, job);
if length(job.mask) ~= n_mods
    warning('No. of masks does not match the no. of modalities. Using mask 1 for all modalities');
    masks = repmat(job.mask, n_mods, 1);
else
    masks = job.mask;
end

mask  = cell(1,n_mods);
for m = 1:n_mods    
    mid = mids(m);
    mfile = char(masks(m)); % = job.mask(m);
    
    %if isfield(job.group(1).modality(mid).conditions,'all_scans')
    if PRT.group(1).subject(1).modality(mid).timesr        
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

function [n_mods mids] = get_modalities(PRT, job)
% function to determine the number of modalities and return their ids.
% Also does some error checking to make sure the same list of modalities
% is specified for every group
% ----------------------------------------------------------------------

n_mods = length(job.group(1).modality);
mids  = zeros(n_mods,1);
for m = 1:n_mods
    mids(m) = lookup_name(PRT,job.group(1).modality(m).mod_name,'modality',1);
end

for g = 1:length(job.group)
    gid = lookup_name(PRT,job.group(g).gr_name,'group');
    
    if length(job.group(g).modality) ~= n_mods
        error(['Subjects do not have the same number of modalities.',...
            ' Group = ',num2str(g)]);
    end
    for m = 1:n_mods
        mid = lookup_name(PRT,job.group(gid).modality(m).mod_name,'modality',gid);
        if mid ~= mids(m)
            error(['Subjects do not have the same modalities specified.',...
                ' Group = ',num2str(g)]);
        end
    end
end

end

function mode = get_mode(job, g, m)
% function to determine how scans are selected for each modality
% --------------------------------------------------------------

if isfield(job.group(g).modality(m).conditions,'all_scans') 
    mode  = 'all_scans';
elseif isfield(job.group(g).modality(m).conditions,'all_cond')
    mode = 'all_conds';
else
    mode = 'selected';
end

end

function id = lookup_name(PRT, target, varargin)
% function to find the id number specified by the 'target' string.
% ---------------------------------------------------------------
% usage: lookup_name(PRT, target, 'group')
%    or: lookup_name(PRT, target, 'modality', gid)
%    or: lookup_name(PRT, target, 'condition', gid, mid)

field = varargin{1};

id = NaN;
% assemble a list to search
switch field 
    case 'group'
        list = {PRT.group.gr_name};
    case 'modality'
        gid = varargin{2};
        % this should be changed to use the masks field
        list = {PRT.group(gid).subject(1).modality.mod_name};
    case 'condition'
        gid = varargin{2};
        mid = varargin{3};
        list = {PRT.group(gid).subject(1).modality(mid).design.conds.cond_name};
    otherwise
        error (['Can''t parse fieldname ',field]);
        
end

% search the list
for i = 1:length(list)
    if strcmpi(list{i},target)
        id = i;
    end
end

% return an error if the target isn't found
if isnan(id)
    error(['Couldn''t find ',field, ' "',target,'" in PRT.mat']);
end

end


