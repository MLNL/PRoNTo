function [fid, PRT] = prt_init_fs(PRT, in)
% function to initialise the feature set data structure. 
%
% FORMAT: Two modes are possible: 
%     fid = prt_init_fs(PRT, in)
%     [fid, PRT] = prt_init_fs(PRT, in)
%
% USAGE 1: 
% -------------------------------------------------------------------------
% function will return the id of a feature set or an error if it doesn't 
% exist in PRT.mat
% Input:
% ------
% in.fs_name: name for the feature set (string)
%
% Output:
% -------
% fid : is the identifier for the feature set in PRT.mat
%
% USAGE 2: 
% -------------------------------------------------------------------------
% function will create the feature set in PRT.mat and overwrite it if it
% already exists.
% Input:
% ------
% in.fs_name: name for the feature set (string)
% in.fs_file: relative path filename for the datafile for this feature set
%
% in.mod(m).mod_name:  name of modality to include in this kernel (string)
% in.mod(m).mode:      'all_cond' or 'all_scans' (string)
% in.mod(m).mask:      mask file used to create the kernel (string)
% in.mod(m).kernel_dt: was this modality detrended in the kernel (boolean)
%
% Output:
% -------
% fid : is the identifier for the model constructed in PRT.mat
%
% Populates the following fields in PRT.mat (copied from above):
%
% PRT.fs(f).fs_name
% PRT.fs(f).fs_file
%
% PRT.fs(f).mod(m).mod_name
% PRT.fs(f).mod(m).mode
% PRT.fs(f).mod(m).mask 
% PRT.fs(f).mod(m).kernel_dt
%
% PRT.fs(f).ids.group
% PRT.fs(f).ids.subject
% PRT.fs(f).ids.modality
% PRT.fs(f).ids.cond
% PRT.fs(f).ids.scan
%
% Note: this function does not write PRT.mat. That should be done by the
%       calling function
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A. Marquand 

% find index for the new feature set
fs_exists = false;
if isfield(PRT,'fs')
    if any(strcmpi(in.fs_name,{PRT.fs(:).fs_name}))
        fid = find(strcmpi(in.fs_name,{PRT.fs(:).fs_name}));
        fs_exists = true;
    else
        fid = length(PRT.cv)+1;
    end
else
    fid = 1;
end

% do we want to create fields in PRT.mat?
if nargout == 1
    if fs_exists
        % just display message and exit (returning id)
        disp(['Feature set ''',in.fs_name,''' found in PRT.mat.']);
    else
        error('prt_init_fs:fsNotFoundinPRT',...
            ['Feature set ''',in.fs_name,''' not found in PRT.mat.']);
    end
else 
    % initialise
    if fs_exists
        warning('prt_init_fs:overwriteFsInPRT',...
            ['Feature set ''',in.fs_name,''' found in PRT.mat. Overwriting ...']);
    else
        % doesn't exist. initialise the structure
        disp(['Feature set ''',in.fs_name,''' not found in PRT.mat. Creating...'])
    end
    
    % get the index of the modalities for which the user wants to include
    n_mods=length(in.mod);
    mids=[];
    for i=1:n_mods
        if ~isempty(in.mod(i).mask)
            mids=[mids,i];
        end
    end
    
    % initialise structure
    PRT.fs(fid).fs_name = in.fs_name;
    PRT.fs(fid).fs_file = in.fs_file;
    PRT.fs(fid).mod     = in.mod;
    PRT.fs(fid).ids  = struct('modality',{},'group',{},'subject',{},'cond',{},'scan',{});
    
    n_mods=length(mids);
    for m = 1:n_mods
        PRT.fs(fid).modality(m).mod_name = in.mod(mids(m)).mod_name;
        PRT.fs(fid).modality(m).kernel_dt = in.mod(mids(m)).kernel_dt;
    end
    
    % Count the total number of samples and set sample ids
    sample_range = 0;
    for gid = 1:length(PRT.group) % group
        for sid = 1:length(PRT.group(gid).subject);  % subject
            for m = 1:n_mods
                mid = mids(m);
                if strcmpi(in.mod(mid).mode,'all_scans');
                    n_vols_s = size(PRT.group(gid).subject(sid).modality(mid).scans,1);
                    
                    % configure indices
                    sample_range = (1:n_vols_s)+max(sample_range);
                    [PRT.fs(fid).ids(sample_range).group]    = deal(gid);
                    [PRT.fs(fid).ids(sample_range).subject]  = deal(sid);
                    [PRT.fs(fid).ids(sample_range).modality] = deal(mid);
                    [PRT.fs(fid).ids(sample_range).cond]     = deal(0);
                    for ii = 1:length(sample_range)
                        PRT.fs(fid).ids(sample_range(ii)).scan = ii;
                    end
                    
                elseif strcmpi(in.mod(mid).mode,'all_cond')
                    conds = PRT.group(gid).subject(sid).modality(mid).design.conds;
                    
                    % now loop over conditions
                    for cid = 1:length(conds)    % condition
                        scans = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).scans;
                        n_vol_s_c = length(scans);
                        
                        % configure indices
                        sample_range = (1:n_vol_s_c)+max(sample_range);
                        [PRT.fs(fid).ids(sample_range).group]    = deal(gid);
                        [PRT.fs(fid).ids(sample_range).subject]  = deal(sid);
                        [PRT.fs(fid).ids(sample_range).modality] = deal(mid);
                        [PRT.fs(fid).ids(sample_range).cond]     = deal(cid);
                        for ii = 1:length(sample_range)
                            PRT.fs(fid).ids(sample_range(ii)).scan = ii;
                        end
                    end
                end
            end  % modality
        end  % subject
    end  % group
    
end

end