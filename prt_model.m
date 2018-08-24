function [PRT, CV, ID] = prt_model(PRT,in)
% Function to configure and build the PRT.model data structure
%
% Input:
% ------
%
%   in.fname:      filename for PRT.mat
%   in.model_name: name for this cross-validation structure
%   in.type:       'classification' or 'regression'
%   in.use_kernel: does this model use kernels or features?
%   in.operations: operations to apply before prediction
%
%   in.fs(f).fs_name:     feature set(s) this CV approach is defined for
%
%   in.class(c).class_name
%   in.class(c).group(g).subj(s).num
%   in.class(c).group(g).subj(s).modality(m).mod_name
%   EITHER: in.class(c).group(g).subj(s).modality(m).conds(c).cond_name
%   OR:     in.class(c).group(g).subj(s).modality(m).all_scans
%   OR:     in.class(c).group(g).subj(s).modality(m).all_cond
%
%   in.cv.type:     type of cross-validation ('loso','losgo','custom')
%   in.cv.mat_file: file specifying CV matrix (if type='custom')
%   in.savePRT:     flag specifying if PRT is saved at the end, if omited 
%                   save by default (to ensure back compatibility)
%
% Output:
% -------
%
%   This function performs the following functions:
%      1. populates basic fields in PRT.model(m).input
%      2. computes PRT.model(m).input.targets based on in.class(c)...
%      3. computes PRT.model(m).input.samp_idx based on targets
%      4. computes PRT.model(m).input.cv_mat based on the labels and CV spec
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A Marquand, modified by J. Schrouff
% $Id$

% Populate basic fields in PRT.mat
% -------------------------------------------------------------------------
[modelid, PRT] = prt_init_model(PRT,in);

% specify model type and feature sets
PRT.model(modelid).input.type = in.type;
if strcmp(in.type,'classification')
    for c = 1:length(in.class)
        PRT.model(modelid).input.class(c) = in.class(c);
    end
else
    PRT.model(modelid).input.group = in.group;
end

if ~isfield(in,'subsample') % No subsampling of the trials by default
    subsample = 0;
else
    subsample = in.subsample;
end
    

for f = 1:length(in.fs)  
    PRT.model(modelid).input.fs(f).fs_name = in.fs(f).fs_name;
end

% compute targets and samp_idx
% -------------------------------------------------------------------------

% Get targets, samples and covariates
if strcmp(in.type,'classification')
    [targets, samp_idx, t_allscans, samp_allscans,covar,cov_all] = compute_targets(PRT, in, 0,subsample);
else
    % One RT per trial
    [targets, samp_idx, t_allscans,samp_allscans, covar,cov_all] = compute_targets(PRT, in, 1,subsample);
end


%[afm]
if isfield(in,'include_allscans') && in.include_allscans   
    PRT.model(modelid).input.samp_idx = samp_allscans;
    PRT.model(modelid).input.include_allscans = in.include_allscans;
else
    PRT.model(modelid).input.samp_idx = samp_idx;
    PRT.model(modelid).input.include_allscans = false;
end
PRT.model(modelid).input.targets          = targets;
PRT.model(modelid).input.targ_allscans    = t_allscans;
PRT.model(modelid).input.covar            = covar;
PRT.model(modelid).input.cov_allscans     = cov_all;

% compute cross-validation matrix and specify operations to apply
% -------------------------------------------------------------------------
if isfield(in.cv,'k')
    PRT.model(modelid).input.cv_k=in.cv.k;
else
    PRT.model(modelid).input.cv_k = 0;
end  
[CV,ID] = prt_compute_cv_mat(PRT,in, modelid);
PRT.model(modelid).input.cv_mat     = CV;
PRT.model(modelid).input.cv_type=in.cv.type;
% Deal with nested CV parameters
if isfield(in.cv,'type_nested') && ~isempty(in.cv.type_nested)
    PRT.model(modelid).input.cv_type_nested = in.cv.type_nested;
end
if isfield(in.cv,'k_nested') && ~isempty(in.cv.k_nested)
    PRT.model(modelid).input.cv_k_nested = in.cv.k_nested;
end
if isfield(in.cv,'nested_param') && ~isempty(in.cv.nested_param)
    PRT.model(modelid).input.nested_param = in.cv.nested_param;
end

PRT.model(modelid).input.operations = in.operations;

% Save PRT.mat
% -------------------------------------------------------------------------
if ~isfield(in,'savePRT') || in.savePRT 
    disp('Updating PRT.mat.......>>')
    if spm_check_version('MATLAB','7') >= 0
        save(in.fname,'-V7','PRT');
    else
        save(in.fname,'-V6','PRT');
    end
end

end

%% ------------------------------------------------------------------------
% Private Functions
% -------------------------------------------------------------------------
function [targets, samp_idx, t_all, samp_all,covar,cov_all] = compute_targets(PRT, in, regression,subsample)

% Function to compute the prediction targets. Also does some error checking

% Set the reference feature set
fid = prt_init_fs(PRT, in.fs(1));
ID  = PRT.fs(fid).id_mat;
n   = size(ID,1);

% Check the considered feature sets have the same ID matrix.
idcheck = [1,2,4]; %skip modality column and scans
for f = 2:length(in.fs)
    fid_oth = prt_init_fs(PRT, in.fs(f));
    ID_oth = PRT.fs(fid_oth).id_mat;
    % Constraint: targets should be exactly equal across feature sets
    if any(any(ID_oth(:,idcheck)~=ID(:,idcheck)))
        error('prt_model:DesignOfFeatureSetsDiffer',...
            ['Multiple feature sets included, but they have different ',...
            'designs']);
    end
end

modalities = {PRT.masks(:).mod_name};
groups     = {PRT.group(:).gr_name};

% Initialize output values
% ------------------------
t_all    = zeros(n,1);
samp_all = zeros(n,1);

if isfield(PRT.group(1).subject(1).modality(1),'covar') && ~isempty(PRT.group(1).subject(1).modality(1).covar)
    cov_all = zeros(n,size(PRT.group(1).subject(1).modality(1).covar,2)); % Assume all subjects have the same number of covariates
else
    cov_all = [];
end

if ~regression
    nc = length(in.class);
else
    nc = 1; %deal with regression
    in.class.group = in.group;
end

% Gather targets for each scan
% ----------------------------

for c = 1:nc
    % groups
    for g = 1:length(in.class(c).group)
        gr_name = in.class(c).group(g).gr_name;
        if any(strcmpi(gr_name,groups))
            gid = find(strcmpi(gr_name,groups));
        else
            error('prt_model:groupNotFoundInPRT',...
                ['Group ',gr_name,' not found in PRT.mat']);
        end
        
        % subjects
        for s = 1:length(in.class(c).group(g).subj)
            sid = in.class(c).group(g).subj(s).num;
            % modalities
            for m = 1:length(in.class(c).group(g).subj(s).modality)
                mod_name = in.class(c).group(g).subj(s).modality(m).mod_name;
                if any(strcmpi(mod_name,modalities))
                    mid = find(strcmpi(mod_name,modalities));
                else
                    error('prt_model:groupNotFoundInPRT',...
                        ['Modality ',mod_name,' not found in PRT.mat']);
                end
                
                % Case 1: conditions were specified and there is a design
                % (i.e. within-subject classification or regression)
                if isfield(in.class(c).group(g).subj(s).modality(m),'conds') && ...
                        isfield(PRT.group(gid).subject(sid).modality(mid).design,'conds')
                    conds     = {PRT.group(gid).subject(sid).modality(mid).design.conds(:).cond_name};
                    blocks=1;
                    for cond = 1:length(in.class(c).group(g).subj(s).modality(m).conds)
                        cond_name = in.class(c).group(g).subj(s).modality(m).conds(cond).cond_name;
                        
                        if any(strcmpi(cond_name,conds))
                            cid = find(strcmpi(cond_name,conds));
                            idx = ID(:,1) == gid & ID(:,2) == sid & ID(:,3) == mid & ID(:,4) == cid;
                            if regression %regression
                                try
                                    idb = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).blocks;
                                    t_all(idx) = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).rt_trial(idb);
                                catch
                                    error('prt_model:WrongTargetNumber',...
                                        'Bad number of regression targets')
                                end
                            else
                                t_all(idx) = c;
                            end
                            if any(ismember(in.operations, 5)) % Get the covariates for GLM
                                idb = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).blocks;
                                cov_all(idx) = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).cov_trial(idb);
                            end
                            samp_all(idx) = 1;
                        else
                            continue % Skip a subject/modality for which a condition is not found
                        end
                    end
                    
                % Case 2: all conditions were chosen and there is a design    
                elseif isfield(in.class(c).group(g).subj(s).modality(m), 'all_cond') && ...
                        isfield(PRT.group(gid).subject(sid).modality(mid).design,'conds')
                    conds     = {PRT.group(gid).subject(sid).modality(mid).design.conds(:).cond_name};
                    blocks=1;
                    % all conditions
                    for cid = 1:length(conds)
                        idx = ID(:,1) == gid & ID(:,2) == sid & ID(:,3) == mid & ID(:,4) == cid;
                        if regression % Regression
                            try
                                idb = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).blocks;
                                t_all(idx) = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).rt_trial(idb);
                            catch
                                error('prt_model:WrongTargetNumber',...
                                    'Bad number of regression targets')
                            end
                        else
                            t_all(idx) = c;
                        end
                        if any(ismember(in.operations, 5)) % Get the covariates for GLM
                            idb = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).blocks;
                            cov_all(idx) = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).cov_trial(idb);
                        end
                        samp_all(idx) = 1;
                    end
                    
                % Case 3: multiple regression targets are present in the feature set but we only access one    
                elseif isfield(in.class(c).group(g).subj(s).modality(m),'conds') && ...
                        ~isfield(PRT.group(gid).subject(sid).modality(mid).design,'conds')
                    idx = ID(:,1) == gid & ID(:,2) == sid & ID(:,3) == mid;
                    if any(ismember(in.operations, 5)) %Get covariates
                        cov_all(idx,:) = PRT.group(gid).subject(sid).modality(mid).covar;
                    end
                    try
                        tars = {PRT.group(gid).subject(sid).modality(mid).rt_subj(:).name}; %Gather target names
                        sel_tar = in.class(c).group(g).subj(s).modality(m).conds(1).cond_name; % Can only select one target
                        rt = strcmpi(sel_tar,tars);
                        rt_tar = PRT.group(gid).subject(sid).modality(mid).rt_subj(rt).tar;
                        if ~isnan(rt_tar)
                            t_all(idx) = rt_tar;
                        else
                            continue
                        end
                    catch
                        error('prt_model:WrongNumberofTargets',...
                            'Number of regression targets with specified name does not correspond to number of images')
                    end
                    samp_all(idx) = 1;
                else
                    blocks=0;
                    % check whether this was included in the feature set
                    % using 'all conditions' (which is invalid)
                    if strcmpi(PRT.fs(fid).modality(m).mode,'all_cond')
                        error('prt_model:fsIsAllCondModelisAllScans',...
                            ['''All scans'' selected for subject ',num2str(s),...
                            ', group ',num2str(g), ', modality ', num2str(m),...
                            ' but the feature set was constructed using ',...
                            '''All conditions''. This syntax is invalid. ',...
                            'Please use ''All Conditions'' instead.']);
                    end
                    
                    % otherwise add all scans for each subject
                    %[afm] idx = ID(:,1) == gid & ID(:,2) == s & ID(:,3) == mid;
                    idx = ID(:,1) == gid & ID(:,2) == sid & ID(:,3) == mid;
                    if any(ismember(in.operations, 5)) %Get covariates
                        cov_all(idx,:) = PRT.group(gid).subject(sid).modality(mid).covar;
                    end
                    if ~regression
                        t_all(idx) = c;
                    else
                        try 
                            tars = {PRT.group(gid).subject(sid).modality(mid).rt_subj(:).name}; %Gather target names
                            sel_tar = in.class(c).group(g).subj(s).modality(m).conds(1).cond_name; % Can only select one target
                            rt = strfind(tars,sel_tar);
                            t_all(idx) = PRT.group(gid).subject(sid).modality(mid).rt_subj(rt).tar;
                        catch
                            error('prt_model:WrongNumberofTargets',...
                                'Number of regression targets does not correspond to number of images')
                        end
                    end
                    samp_all(idx) = 1;
                end
            end
        end
    end
end


if nargin>=4 && subsample
    nc_count = hist(t_all(t_all~=0),unique(t_all(t_all~=0))); % count how many trials per class
    ntk = min(nc_count);
    for i = 1:nc
        indnc = find(t_all==i);
        % Randomly select BLOCKS of trials to match the number of lowest
        % sample as close as possible, balancing the sub-categories.
        if length(indnc) > ntk
            if blocks
                id_ID=5;
            else
                id_ID=2;
            end
            indb = unique(ID(indnc,id_ID));
            nbcount = hist(ID(indnc,id_ID),indb);
            rs = randperm(length(indb));
            [minrs,pivot] = min(abs(cumsum(nbcount(rs))-ntk));
            disp(['Imbalanced for class ',num2str(i),':',num2str(minrs)])
            if pivot<length(rs)
                for j = pivot+1:length(indb)
                    ii = find(ID(indnc,id_ID)==rs(j));
                    t_all(indnc(ii)) = 0;
                    samp_all(indnc(ii)) = 0;
                end
            end
        end
    end
end
    
samp_idx = find(samp_all);
samp_all = find(samp_all);    
targets  = t_all(samp_idx);
if ~isempty(cov_all)
    covar = cov_all(samp_idx,:);
else
    covar = [];
end

end
