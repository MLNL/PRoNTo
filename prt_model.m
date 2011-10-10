function PRT = prt_model(PRT,in)
% Function to configure and build the PRT.model data structure
%
% Input:
% ------
% 
%   in.fname:      filename for PRT.mat
%   in.model_name: name for this cross-validation structure
%   in.type:       'classification' or 'regression'
%   in.use_kernel: does this model use kernels or features?
%
%   in.fs(f).fs_name:     feature set(s) this CV approach is defined for
%
%   in.class(c).class_name
%   in.class(c).group(g).subj(s).num
%   in.class(c).group(g).subj(s).modality(m).mod_name
%   in.class(c).group(g).subj(s).modality(m).conds(c).cond_name
%
%   in.cv.type:     type of cross-validation ('loso','losgo','custom')
%   in.cv.mat_file: file specifying CV matrix (if type='custom');
%
% Output:
% -------
%
%   This function performs the following functions:
%      1. computes PRT.model.input.targets based on in.class(c)...
%      2. computes PRT.model.input.samp_idx based on labels
%      3. computes PRT.model.input.fs(f).feat_idx based on the input masks
%      4. computes PRT.model.input.cv_mat based on the labels and CV spec
%      5. populates remaining fields in PRT.model.input
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A. Marquand 

% populate basic fields in PRT.mat
% -------------------------------------------------------------------------
[modelid, PRT] = prt_init_model(PRT,in);

% type 
PRT.model(modelid).input.type = in.type;

% feature sets
for f = 1:length(in.fs)
    fid = prt_init_fs(PRT,in.fs(f));
    
    if length(PRT.fs(fid).modality) > 1 && length(in.fs) > 1
        error('prt_model:multipleFeatureSetsAppliedAsSamplesAndAsFeatures',...
            ['Feature set ',in.fs(f).fs_name,' contains multiple modalities ',...
             'and job specifies that multiple feature sets should be ',...
             'supplied to the machine. This usage is not supported.']);
    end
    
    PRT.model(modelid).fs(f).fs_name = in.fs(f).fs_name;
end

% compute labels and samp_idx
% -------------------------------------------------------------------------
% first check the feature sets have the same number of samples (eg for MKL)
fid = prt_init_fs(PRT, in.fs(1));
ID  = PRT.fs(fid).id_mat;
n   = size(ID,1);
if length(in.fs) > 1
    for f = 1:length(in.fs)
        fid = prt_init_fs(PRT, in.fs(f));
        if size(PRT.fs(fid).id_mat,1) ~= n
            error('prt_model:sizeOfFeatureSetsDiffer',...
                ['Multiple feature sets included, but they have different ',...
                'numbers of samples']);
        end
    end
end

modalities = {PRT.masks(:).mod_name};
groups     = {PRT.group(:).gr_name};

t_all = zeros(n,1);
for c = 1:length(in.class)
    
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
            
            % modalities
            for m = 1:length(in.class(c).group(g).subj(s).modality)
                mod_name = in.class(c).group(g).subj(s).modality(m).mod_name;
                if any(strcmpi(mod_name,modalities))
                    mid = find(strcmpi(mod_name,modalities));
                else
                    error('prt_model:groupNotFoundInPRT',...
                        ['Modality ',mod_name,' not found in PRT.mat']);
                end
                
                % conditions
                for cond = 1:length(in.class(c).group(g).subj(s).modality(m).conds)
                    cond_name = in.class(c).group(g).subj(s).modality(m).conds(cond).cond_name;
                    conds     = {PRT.group(gid).subject(s).modality(mid).design.conds(:).cond_name};
                   
                    if any(strcmpi(cond_name,conds))
                        cid = find(strcmpi(cond_name,conds));
                    else
                        error('prt_model:groupNotFoundInPRT',...
                            ['Condition ',cond_name,' not found in PRT.mat']);
                    end
                    
                    idx = ID(:,1) == gid & ID(:,2) == s & ID(:,3) == mid & ID(:,4) == cid;
                    t_all(idx) = c;
                end
            end
        end
    end
end
PRT.model(modelid).samp_idx = find(t_all);
PRT.model(modelid).targets  = t_all(PRT.model(modelid).samp_idx);

% compute cross-validation matrix
% -------------------------------------------------------------------------
% build CV matrix
switch in.type
    case 'loso'
        n_groups = length(in.class(:).group);
        n_mod    = length(PRT.masks(:).mod_name);    
        
        G = cell(n_groups,1);
        for g = 1:n_groups
            n_sub_g = length(PRT.group(g).subject(:));
            
            for s = 1:n_sub_g
                for m = 1:n_mod
                    
                      mod_len(m)
                end
            end
            kron(ones(nmod), mod_lens)
            
        end
        n = length({PRT.group(g).subject(:).subj_name});
        
        model.cv_mat = blkdiag(n_scans_s{:});
        
    case 'losgo'
        error('losgo CV not implemented yet');
        
    case 'custom'
        error('custom CV not implemented yet');
        
    otherwise
        error('prt_cv:unknownTypeSpecified',...
             ['Unknown type specified for CV structure (',in.type',')']);
end

cv.cv_mat     = kron(eye(5),ones(n_scans_s,1))+1;


cv.fs_indices = (1:size(Phi_id,1))';


[cid, PRT] = prt_init_cv(PRT,cv);

save(mod.fname,'PRT');

cv.cv_mat = prt_cv_mat(PRT, mat);

% configure fs_indices
if isfield(job.fs_samples,'all_samples')
    cv.fs_indices = 1:size(cv.cvmat,1);
else
    
end

% Save PRT.mat
disp('Updating PRT.mat.......>>')
if spm_matlab_version_chk('7') >= 0
    save(in.fname,'-V6','PRT');
else
    save(in.fname,'-V6','PRT');
end

end
