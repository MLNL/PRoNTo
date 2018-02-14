function [outfile] = prt_cv_model(PRT,in)

% Function to run a cross-validation structure on a given model
%
% Inputs:
% -------
% PRT:             data structure
% in.fname:        filename for PRT.mat (string)
% in.model_name:   name for this model (string)
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
% Modified by J. Schrouff and J.M. Monteiro for versions 2.0 and 3.0
% $Id$

prt_dir = char(regexprep(in.fname,'PRT.mat', ''));

% Get index of specified model
mid = prt_init_model(PRT, in);

% configure some variables
CV       = PRT.model(mid).input.cv_mat;     % CV matrix
n_folds  = size(CV,2);                      % number of CV folds

% targets
if isfield(PRT.model(mid).input,'include_allscans') && ...
        PRT.model(mid).input.include_allscans
    t = PRT.model(mid).input.targ_allscans;
    % Get covariates if GLM required
    if any(ismember(PRT.model(mid).input.operations,5))
        cov = PRT.model(mid).input.cov_allscans;
    else
        cov=[];
    end
else
    t = PRT.model(mid).input.targets;
    % Get covariates if GLM required
    if any(ismember(PRT.model(mid).input.operations,5))
        cov = PRT.model(mid).input.covar;
    else
        cov=[];
    end
end

%get number of classes
if strcmpi(PRT.model(mid).input.type,'classification')
    nc=max(unique(t));
else
    nc=[];
end
fdata.nc = nc;

if ~isfield(PRT.model(mid).input,'indmodels')
    indmodels = 0;
else
    indmodels = PRT.model(mid).input.indmodels;
end

if ~isfield(in,'opt_Rep')
    opt_Rep = 0;
end

if PRT.model(mid).input.use_kernel
    %load kernels and get the used sample in this model
    [Phi_all,ID] = prt_getKernelModel(PRT,prt_dir,mid,indmodels);
else
    [Phi_all,ID] = prt_getFeatureModel(PRT,mid);
end

% Gather machine string parameters if any
if ~ isempty(PRT.model(mid).input.machine.args) && ...
        ischar(PRT.model(mid).input.machine.args)
    stringpar = PRT.model(mid).input.machine.args;
else
    stringpar = [];
end

% Begin cross-validation loop
% -------------------------------------------------------------------------
PRT.model(mid).output=struct();
if indmodels %loop over the kernels and output accuracy for each kernel only
    nk = length(Phi_all);
else
    nk = 1;
end

% For each model
for k = 1:nk
    if nk>1
        disp([' > Estimating model: ',num2str(k),' of ',num2str(nk),' ...'])
    end
    PRT.model(mid).output(k).fold = struct();
    for f = 1:n_folds
        disp ([' > running CV fold: ',num2str(f),' of ',num2str(n_folds),' ...'])
        % configure data structure for prt_cv_fold
        fdata.ID      = ID;
        fdata.mid     = mid; %index of model
        fdata.CV      = CV(:,f);
        if isfield(PRT.model(mid).input,'class')
            fdata.class   = PRT.model(mid).input.class; %to build inner CV for classification special cases
        end
        if nk>1
            fdata.Phi_all = Phi_all(k); %selected kernel for independent modelling
        else
            fdata.Phi_all = Phi_all; %all kernels
        end
        fdata.t       = t; %targets
        if ~isempty(cov)
            fdata.cov = cov;
        end
        fdata.opt_Rep = opt_Rep;
        
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
                PRT.model(mid).output(k).fold(f).param_effect = out;
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
%      ttt       = vertcat(PRT.model(mid).output(k).fold(:).targets);
%      m.type    = PRT.model(mid).output(k).fold(1).type;
%      m.predictions = vertcat(PRT.model(mid).output(k).fold(:).predictions);
%      %m.func_val   = [PRT.model(mid).output.fold(:).func_val];
%      gstats        = prt_stats(m,ttt(:),nc);
%     % Model level statistics (across folds) - average across folds
    fnamestats = fieldnames(stats);
    gstats = struct;
    for i=1:length(fnamestats)
        size_stats = size(PRT.model(mid).output(k).fold(1).stats.(fnamestats{i}));
        val = zeros(prod(size_stats),n_folds);
        for j = 1:n_folds
            val(:,j) = PRT.model(mid).output(k).fold(j).stats.(fnamestats{i})(:);
        end
        av_stats = reshape(nanmean(val,2),size_stats);
        gstats = setfield(gstats,fnamestats{i},av_stats);
    end
    % If classifier, get confusion matrix globally
     m.type        = PRT.model(mid).output(k).fold(1).type;
     if strcmpi(m.type,'classifier')
         ttt             = vertcat(PRT.model(mid).output(k).fold(:).targets);
         m.predictions = vertcat(PRT.model(mid).output(k).fold(:).predictions);
         %m.func_val    = [PRT.model(mid).output.fold(:).func_val];
         temp_stats         = prt_stats(m,ttt(:),nc);
         gstats.con_mat = temp_stats.con_mat;
     end
%     
      PRT.model(mid).output(k).stats=gstats;
end

% Save PRT containing machine output
% -------------------------------------------------------------------------
if ~isfield(in,'savePRT') || in.savePRT
    outfile = [prt_dir, filesep,'PRT.mat'];
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


