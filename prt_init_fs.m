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
% in.fas:     structure for the file_array 
% in.k_file:  relative path filename for the kernel for this feature set
%
% Output:
% -------
% fid : is the identifier for the model constructed in PRT.mat
%
% Populates the following fields in PRT.mat (copied from above):
%   PRT.fs(f).fs_name
%   PRT.fs(f).fas
%   PRT.fs(f).k_file
% Also computes the following fields:
%   PRT.fs(f).id_mat:       Identifier matrix (useful later)
%   PRT.fs(f).id_col_names: Columns in the id matrix
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
        fid = length(PRT.fs)+1;
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
    
    % get the index of the modalities to include
    n_mods=length(in.mod);
    mids=[];
    for i=1:n_mods
        if ~isempty(in.mod(i).mask)
            mids=[mids,i];
        end
    end
    
    % initialise basic fields of fs structure
    PRT.fs(fid).fs_name  = in.fs_name;
    PRT.fs(fid).k_file   = in.k_file;
    PRT.fs(fid).fas      = in.fas;
    %PRT.fs(fid).modality = in.mod; 
    
    % First count the total number of samples. Loops are needed since each
    % subject may have a variable number of scans
    n = 0;
    for gid = 1:length(PRT.group) % group
        for sid = 1:length(PRT.group(gid).subject);  % subject
            for m = 1:n_mods
                mid = mids(m);
                if strcmpi(in.mod(mid).mode,'all_scans');
                    n = n + size(PRT.group(gid).subject(sid).modality(mid).scans,1);
                elseif strcmpi(in.mod(mid).mode,'all_cond')
                    for cid = 1:length(PRT.group(gid).subject(sid).modality(mid).design.conds)    % condition
                        n = n + length(PRT.group(gid).subject(sid).modality(mid).design.conds(cid).scans);
                    end
                end
            end  % modality
        end  % subject
    end  % group
    
    % Now configure id matrix
    col_names = {'group','subject','modality','condition','block','scan'};
    id_mat = zeros(n,length(col_names));
    sample_range = 0; 
    for gid = 1:length(PRT.group) % group
        for sid = 1:length(PRT.group(gid).subject);  % subject
            for m = 1:n_mods
                mid = mids(m);
                if strcmpi(in.mod(mid).mode,'all_scans');      
                    n_vols_s = size(PRT.group(gid).subject(sid).modality(mid).scans,1);
                    
                    % configure indices
                    sample_range = (1:n_vols_s)+max(sample_range);
                    id_mat(sample_range,1) = gid;
                    id_mat(sample_range,2) = sid;
                    id_mat(sample_range,3) = mid;
                    
                    if isfield(PRT.group(gid).subject(sid).modality(mid).design,'conds')
                        conds = PRT.group(gid).subject(sid).modality(mid).design.conds;
                        
                        for cid = 1:length(conds)
                            scans  = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).scans;
                            blocks = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).blocks;
                            
                            id_mat(sample_range(scans),4) = cid;
                            id_mat(sample_range(scans),5) = blocks;
                            id_mat(sample_range(scans),6) = 1:length(scans);
                        end
                    else
                         scans  = 1:size(PRT.group(gid).subject(sid).modality(mid).scans,1);
                         id_mat(sample_range,6) = scans;
                    end
                    
                % all conditions
                elseif strcmpi(in.mod(mid).mode,'all_cond')
                    conds = PRT.group(gid).subject(sid).modality(mid).design.conds;
                    
                    % now loop over conditions
                    for cid = 1:length(conds)    % condition
                        scans = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).scans;
                        blocks = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).blocks;
                        n_vol_s_c = length(scans);
                        
                        % configure indices
                        sample_range = (1:n_vol_s_c)+max(sample_range);                      
                        id_mat(sample_range,1) = gid;
                        id_mat(sample_range,2) = sid;
                        id_mat(sample_range,3) = mid;
                        id_mat(sample_range,4) = cid;
                        id_mat(sample_range,5) = blocks;
                        id_mat(sample_range,6) = 1:length(sample_range);
                    end
                end
                
            end  % modality
        end  % subject
    end  % group
    
    PRT.fs(fid).id_mat       = id_mat;               
    PRT.fs(fid).id_col_names = col_names;
end

end