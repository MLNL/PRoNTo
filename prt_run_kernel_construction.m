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
fname = job.infile;
load(char(fname));

%prt_dir=fileparts(char(fname));
prt_dir=regexprep(char(fname),'PRT.mat', '');

% initialize the modality
mid   = job.modality;
%N     = nifti([prt_dir,'g1_s1_m',num2str(mid),'_c1.img']);
N     = nifti([prt_dir,prt_get_filename(PRT,1,1,1,1),'.img']);
n_vox = prod(N.dat.dim(1:3));
n_groups    = length(job.group);

% Count the total number of samples in the different groups
% -------------------------------------------------------------------------
n = 0;
for g = 1:n_groups                                   % group
    gid = job.group(g).gr_num;                   
    for s = 1:length(job.group(g).subjects);         % subject
        sid = job.group(g).subjects(s);       
        for c = 1:length(job.group(g).conditions)    % condition
            cid = job.group(g).conditions(c);
            %n_vols_s_c = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).durations;
            onsets    = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).onsets;
            durations = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).durations;
            if (length(durations) == 1)
                durations = repmat(durations,length(onsets),1);
            end
            n_vols_s_c = sum(durations);
            n = n + sum(n_vols_s_c);
        end
    end
end

% Set memory limit
mem         = prt_get_defaults('kernel.mem_limit');
block_size  = ceil(mem/8/n); % Block size (double = 8 bytes)
n_block     = ceil(n_vox/block_size);

% Initialize K
K     = zeros(n);
K_idx = zeros(n,3);

% Compute kernel (block-wise)
% -------------------------------------------------------------------------
bstart=1; bend=min(block_size,n_vox);
%X = zeros(n_vox,n);
for b = 1:n_block
    samp_range = 0; % initialise (will be set later)
    for g = 1:n_groups
        gid = job.group(g).gr_num;
        
        disp ([' > processing block: ', num2str(b),' of ',num2str(n_block),' ...'])
        vox_range=bstart:bend;
        
        data_vols=zeros(length(vox_range),n);
        % load data from all subjects
        % ---------------------------
        for s = 1:length(job.group(g).subjects)
            sid = job.group(g).subjects(s);
            %disp([' >> subject: ',num2str(s)]);
            
            for c = 1:length(job.group(g).conditions)
                cid = job.group(g).conditions(c);
                %n_vol_s_c = sum(PRT.group(gid).subject(sid).modality(mid).design.conds(cid).durations);   
                onsets    = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).onsets;
                durations = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).durations;
                if (length(durations) == 1)
                    durations = repmat(durations,length(onsets),1);
                end
                n_vol_s_c = sum(durations);
                
                samp_range = (1:n_vol_s_c)+max(samp_range);
                
                %fname = [prt_dir,'g',num2str(gid),'_s',num2str(sid),'_m',num2str(mid),'_c',num2str(cid)];
                fname = [prt_dir, prt_get_filename(PRT,gid,sid,mid,cid)];

                data_vols(:,samp_range) = prt_load_blocks(fname,block_size,b);
                
                % configure indices
                K_idx(samp_range,1) = gid;
                K_idx(samp_range,2) = sid;
                K_idx(samp_range,3) = cid;
                
                % for testing
                %sdata2 = prt_load_vols(fname,[],true);
                %X(:,samp_range) = sdata2;
            end
        end
    end
    
    % add this block's contribution to the kernel matrix
    K = K + (data_vols' * data_vols);
    
    bstart=bend+1; bend=min(bstart+block_size-1,n_vox);
end

% for testing
% K2 = X'*X;

% Mean centre and normalise
%K = prt_remove_confounds(K,ones(n,1));
if job.normalise
    K = prt_normalise_kernel(K);
end

% Save kernel and indices
outfile = [prt_dir, 'kernel_',job.kernel_filename];
disp(['Saving kernel to: ',job.kernel_filename,'.mat.......>>'])
if spm_matlab_version_chk('7') >= 0
    save(outfile,'-V6','K','K_idx');
else
    save(outfile,'K','K_idx');
end

% Function output
% -------------------------------------------------------------------------
out.files{1} = outfile;
disp('Kernel construction done.')
end
