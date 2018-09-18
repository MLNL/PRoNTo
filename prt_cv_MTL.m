function [outfile] = prt_cv_MTL(PRT,in)

% Function to run a cross-validation structure on a given model
%
% Inputs:
% -------
% PRT:             data structure
% in.fname:        filename for PRT.mat (string)
% in.model_name:   name for this model (string)
% in.models_MTL:   names of models to combine (cell array)
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

% Written by J. Schrouff based on prt_cv_model
% $Id$

prt_dir = char(regexprep(in.fname,'PRT.mat', ''));

% Get index of specified MTL model
mid = prt_init_model(PRT, in);

% Prepare information for each task
nt = numel(in.models_MTL); %number of tasks
m = zeros(nt,1);
Phi_all = cell(nt,1);
ID = cell(nt,1);
CV = cell(nt,1);
Y = cell(nt,1);
cov = cell(nt,1);
for t=1:nt
    
    % Get index of STL models to combine
    in.model_name = in.models_MTL{t};
    m(t) = prt_init_model(PRT, in);
    
    % Load data: Memory usage - only load one fold at a time? vs i-o
    if PRT.model(mid).input.use_kernel
        %load kernels and get the used sample in this model
        [Phi_all(t),ID{t}] = prt_getKernelModel(PRT,prt_dir,m(t),0);
    else
        [Phi_all(t),ID{t}] = prt_getFeatureModel(PRT,m(t));
    end
    
    % Gather all info
    [CV{t},Y{t},cov{t},nc{t}] = gather_task_info(PRT,m(t));
    
    % Check all tasks have same number of folds
    n_folds  = size(CV{1},2);    
    if n_folds~= size(CV{t},2)
        error('prt_cv_MTL:CVdoNotMatch',...
            'Number of folds in each model must be the same');
    end
    
    if isfield(PRT.model(m(t)).input,'class')
        fdata.class{t}   = PRT.model(m(t)).input.class; %to build inner CV for classification special cases
    end
    
end


if ~isfield(in,'opt_Rep')
    opt_Rep = 0;
end

% Begin cross-validation loop
% -------------------------------------------------------------------------
PRT.model(mid).output=struct();

PRT.model(mid).output.fold = struct();

for f = 1:n_folds
    disp ([' > running CV fold: ',num2str(f),' of ',num2str(n_folds),' ...'])
    
    % configure data structure for prt_cv_fold
    fdata.ID      = ID;
    fdata.mid     = mid; %index of model
    for t=1:nt        
        fdata.CV{t}      = CV{t}(:,f);
    end    
    fdata.Phi_all = Phi_all; %all kernels
    fdata.t       = Y; %targets
    fdata.nc      = nc; %number of classes for within-task confusion matrix
    if ~isempty(cov)
        fdata.cov = cov;
    end
    
    fdata.opt_Rep = opt_Rep;
    fdata.midMTL  = m;
    
    % Nested CV for hyper-parameter optimisation or feature selection
    if isfield(PRT.model(mid).input,'use_nested_cv')
        if PRT.model(mid).input.use_nested_cv
            if f==1 && isempty(PRT.model(mid).input.nested_param)
                beep
                warning('No parameter range specified for optimization, using defaults.')
            end
            if ~isempty(stringpar) %Reset to string before optimization
                PRT.model(mid).input.machine.args = stringpar;
            end
            [out] = prt_nested_cv(PRT, fdata);
            PRT.model(mid).output.fold(f).param_effect = out;
            if isempty(stringpar)
                PRT.model(mid).input.machine.args = out.opt_param;
            else
                PRT.model(mid).input.machine.args = [stringpar, num2str(out.opt_param)];
            end
        end
    end
    
    % compute the model for this CV fold
    [model, targets] = prt_cv_fold(PRT,fdata);
    
    %for classification check that for each fold, the test targets have been trained
    if strcmpi(PRT.model(mid).input.type,'classification')
        for t=1:nt
            if ~all(ismember(unique(targets.test{t}),unique(targets.train{t})))
                beep
                disp('At least one class is in the test set but not in the training set')
                disp('Abandoning modelling, please correct class selection/cross-validation')
                return
            end
        end
    end
    
    % compute stats
    stats = prt_stats(model, targets.test, nc); %targets.train
    
    % update PRT
    PRT.model(mid).output.fold(f).targets     = targets.test;
    PRT.model(mid).output.fold(f).predictions = model.predictions;
    PRT.model(mid).output.fold(f).stats       = stats;
    % copy other fields from the model
    flds = fieldnames(model);
    for fld = 1:length(flds)
        fldnm = char(flds(fld));
        if ~strcmpi(fldnm,'predictions')
            PRT.model(mid).output.fold(f).(fldnm)=model.(fldnm);
        end
    end
end

% Model level statistics (across folds) - average across folds
fnamestats = fieldnames(stats);
if ismember('task_stats',fnamestats)
    its = ismember(fnamestats,'task_stats');
    fnamestats = fnamestats(~its);
end
gstats = struct;
for i=1:length(fnamestats)
    size_stats = size(PRT.model(mid).output.fold(1).stats.(fnamestats{i}));
    val = zeros(prod(size_stats),n_folds);
    for j = 1:n_folds
        val(:,j) = PRT.model(mid).output.fold(j).stats.(fnamestats{i})(:);
    end
    av_stats = reshape(nanmean(val,2),size_stats);
    gstats = setfield(gstats,fnamestats{i},av_stats);
end
% No confusion matrix for MTL - refer to each task separately

PRT.model(mid).output.stats=gstats;


% Save PRT containing machine output
% -------------------------------------------------------------------------
if ~isfield(in,'savePRT') || in.savePRT
    outfile = fullfile(prt_dir, 'PRT.mat');
    disp('Updating PRT.mat.......>>')
    if spm_check_version('MATLAB','7') < 0
        save(outfile,'-V6','PRT');
    else
        save(outfile,'PRT');
    end
else
    outfile = PRT;
end

end


% Subfunctions
% -------------------------------------------------------------------------
function [CV,Y,cov,nc] = gather_task_info(PRT,m)

% CV matrix
CV    = PRT.model(m).input.cv_mat;     

% targets
if isfield(PRT.model(m).input,'include_allscans') && ...
        PRT.model(m).input.include_allscans
    Y = PRT.model(m).input.targ_allscans;
    % Get covariates if GLM required
    if any(ismember(PRT.model(m).input.operations,5))
        cov = PRT.model(m).input.cov_allscans;
    else
        cov=[];
    end
else
    Y = PRT.model(m).input.targets;
    % Get covariates if GLM required
    if any(ismember(PRT.model(m).input.operations,5))
        cov = PRT.model(m).input.covar;
    else
        cov=[];
    end
end

%get number of classes
if strcmpi(PRT.model(m).input.type,'classification')
    nc=max(unique(Y));
else
    nc=[];
end



end
