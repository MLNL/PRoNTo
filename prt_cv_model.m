function [outfile]=prt_cv_model(PRT,in)
% Function to run a cross-validation structure on a given model
%
% Inputs:
% -------
% PRT:             data structure
% in.fname:        filename for PRT.mat (string)
% in.model_name:   name for this model (string)
% in.f_ind_models: compute models using the kernels independently (1) or
%                  not (0, default)
%
% Outputs:
% --------
% Writes the following fields in the PRT data structure:
%
% PRT.model(m).output.fold(i).targets:     targets for fold(i)
% PRT.model(m).output.fold(i).predictions: predictions for fold(i)
% PRT.model(m).output.fold(i).stats:       statistics for fold(i)
% PRT.model(m).output.fold(i).{custom}:    optional fields
%
% Notes:
% ------
% The PRT.model(m).input fields are set by prt_init_model, not by
% this function
%
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A Marquand
% $Id$

prt_dir = char(regexprep(in.fname,'PRT.mat', ''));

% Get index of specified model
mid = prt_init_model(PRT, in);

% configure some variables
CV       = PRT.model(mid).input.cv_mat;     % CV matrix
n_folds  = size(CV,2);                      % number of CV folds
samp_idx = PRT.model(mid).input.samp_idx;   % which samples are in the model

% targets
if isfield(PRT.model(mid).input,'include_allscans') && ...
        PRT.model(mid).input.include_allscans
    t = PRT.model(mid).input.targ_allscans;
else
    t = PRT.model(mid).input.targets;
end

%get number of classes
if strcmpi(PRT.model(mid).input.type,'classification')
    nc=max(unique(t));
else
    nc=[];
end
fdata.nc = nc;

if ~isfield(in,'f_ind_models')
    flag = 0;
else
    flag = in.f_ind_models;
end

% load data files and configure ID matrix
disp('Loading data files.....>>');
for i = 1:length(PRT.model(mid).input.fs)
    %first case: combine feature sets
    if length(PRT.model(mid).input.fs)>1
        n_Phi = length(PRT.model(mid).input.fs);
        Phi_all=cell(1,n_Phi);
        fid = prt_init_fs(PRT, PRT.model(mid).input.fs(i));
        
        if i == 1
            ID = PRT.fs(fid).id_mat(PRT.model(mid).input.samp_idx,:);
        end
        
        if PRT.model(mid).input.use_kernel
            load(fullfile(prt_dir, PRT.fs(fid).k_file));
            Phi_all{i} = Phi(samp_idx,samp_idx);
        else
            error('training with features not implemented yet');
            %vname = whos('-file', [prt_dir,PRT.fs(fid).fs_file]);
            %eval(['Phi_all{',num2str(i),'}=',vname,'(samp_idx,:);']);
        end
    else
        %If only one feature set, load kernel to see which case
        if PRT.model(mid).input.use_kernel
            fid = prt_init_fs(PRT, PRT.model(mid).input.fs(i));
            load(fullfile(prt_dir, PRT.fs(fid).k_file));
            ID = PRT.fs(fid).id_mat(samp_idx,:);
            if ~iscell(Phi) || length(Phi)==1
                Phi_all{1} = Phi(samp_idx,samp_idx);
            else
                Phi_all=cell(1,length(Phi));
                for j=1:length(Phi)
                    Phi_all{j}=Phi{j}(samp_idx,samp_idx);
                end
            end
        else
            error('training with features not implemented yet');
            %vname = whos('-file', [prt_dir,PRT.fs(fid).fs_file]);
            %eval(['Phi_all{',num2str(i),'}=',vname,'(samp_idx,:);']);
        end
    end
end

% Begin cross-validation loop
% -------------------------------------------------------------------------
PRT.model(mid).output=struct();

if flag %loop over the kernels and output accuracy for each kernel only
    nk = length(Phi_all);
else
    nk = 1;
end

for k = 1:nk
    PRT.model(mid).output(k).fold = struct();
    for f = 1:n_folds
        disp ([' > running CV fold: ',num2str(f),' of ',num2str(n_folds),' ...'])
        % configure data structure for prt_cv_fold
        fdata.ID      = ID;
        fdata.mid     = mid; %index of model
        fdata.CV      = CV(:,f);
        if nk ==1
            fdata.Phi_all = Phi_all; %kernels for multiple kernel learning
        else
            fdata.Phi_all = Phi_all(k); %kernel to be treated independently
        end
        fdata.t       = t; %targets
        
        % Nested CV for hyper-parameter optimisation or feature selection
        if PRT.model(mid).input.use_nested_cv            
            [out] = prt_nested_cv(PRT, mid, fdata);
            PRT.model(mid).output(k).fold(f).param_effect = out;
        end
        
        % compute the model for this CV fold
        [model, targets] = prt_cv_fold(PRT,fdata);
               
        %for classification check that for each fold, the test targets have been trained
        if strcmpi(PRT.model(mid).input.type,'classification')
            if ~all(ismember(unique(targets.test),unique(targets.train)))
                beep
                disp('At least one class is in the test set but not in the training set')
                disp('Abandoning modelling, please correct class selection/cross-validation')
                return
            end
        end
        
        % compute stats
        stats = prt_stats(model, targets.test, nc); %targets.train
        
        % update PRT
        PRT.model(mid).output(k).fold(f).targets     = targets.test;
        PRT.model(mid).output(k).fold(f).predictions = model.predictions(:);
        PRT.model(mid).output(k).fold(f).stats       = stats;
        % copy other fields from the model
        flds = fieldnames(model);
        for fld = 1:length(flds)
            fldnm = char(flds(fld));
            if ~strcmpi(fldnm,'predictions')
                PRT.model(mid).output(k).fold(f).(fldnm)=model.(fldnm);
            end
        end
    end
    
    
    % Model level statistics (across folds)
    ttt             = vertcat(PRT.model(mid).output(k).fold(:).targets);
    m.type        = PRT.model(mid).output(k).fold(1).type;
    m.predictions = vertcat(PRT.model(mid).output(k).fold(:).predictions);
    %m.func_val    = [PRT.model(mid).output.fold(:).func_val];
    stats         = prt_stats(m,ttt(:),nc);
    
    PRT.model(mid).output(k).stats=stats;
end
if flag && length(Phi_all)>1
    PRT.model(mid).output = rmfield(PRT.model(mid).output,'fold');
end


% Save PRT containing machine output
% -------------------------------------------------------------------------
outfile = [prt_dir, 'PRT'];
disp('Updating PRT.mat.......>>')
if spm_matlab_version_chk('7') >= 0
    save(outfile,'-V6','PRT');
else
    save(outfile,'PRT');
end
end

