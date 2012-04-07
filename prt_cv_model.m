function [outfile]=prt_cv_model(PRT,in)
% Function to run a cross-validation structure on a given model 
%
% Inputs:
% -------
% PRT containing the specified model plus the following arguments:
% in.fname:      filename for PRT.mat (string)
% in.model_name: name for this model (string)
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
% Notes: - The PRT.model(m).input fields are set by prt_init_model, not by
%          this function
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
n_Phi    = length(PRT.model(mid).input.fs); % number of data matrices
samp_idx = PRT.model(mid).input.samp_idx;   % which samples are in the model

% targets
if isfield(PRT.model(mid).input,'include_allscans') && ...
   PRT.model(mid).input.include_allscans
    t = PRT.model(mid).input.targ_allscans;
else
    t = PRT.model(mid).input.targets;
end

% load data files and configure ID matrix
disp('Loading data files.....>>');
Phi_all = cell(1,n_Phi);
%for i = 1:size(PRT.fs,1)
for i = 1:length(PRT.model(mid).input.fs)
    fid = prt_init_fs(PRT, PRT.model(mid).input.fs(i));
    
    if i == 1
        ID = PRT.fs(fid).id_mat(PRT.model(mid).input.samp_idx,:);
    end
        
    if PRT.model(mid).input.use_kernel
        load(fullfile(prt_dir, PRT.fs(fid).k_file));
        Phi_all{i} = Phi(samp_idx,samp_idx);
    else
        error('training with features not implemented yet');
        % this should be improved (e.g. need to load feat_idx)
        vname = whos('-file', [prt_dir,PRT.fs(fid).fs_file]);
        eval(['Phi_all{',num2str(i),'}=',vname,'(samp_idx,:);']);
    end
    % check size of data matrix
    % [afm]
    %if size(t,1) ~= size(Phi_all{i},1)
    %    error('prt_cv_model:fsSizeDoesNotMatchTargets',...
    %        ['size of Feature set ',num2str(fid),' does not match targets']);
    %end
end

% Begin cross-validation loop
% -------------------------------------------------------------------------
PRT.model(mid).output.fold = struct();
for f = 1:n_folds
    disp ([' > running CV fold: ',num2str(f),' of ',num2str(n_folds),' ...'])
    % configure training and test indices (validation is done later)
    tr_idx = CV(:,f) == 1;
    te_idx = CV(:,f) == 2;   
    
    [Phi_tr, Phi_te, Phi_tt] = ...
        split_data(Phi_all, tr_idx, te_idx, PRT.model(mid).input.use_kernel);
 
    % Assemble data structure to supply to machine
    cvdata.train      = Phi_tr;
    cvdata.test       = Phi_te;
    if PRT.model(mid).input.use_kernel
        cvdata.testcov    = Phi_tt;
    end

    % configure basic CV parameters
    cvdata.tr_targets = t(tr_idx,:);
    cvdata.te_targets = t(te_idx,:);
    cvdata.tr_id      = ID(tr_idx,:);
    cvdata.te_id      = ID(te_idx,:);
    cvdata.use_kernel = PRT.model(mid).input.use_kernel;
    cvdata.pred_type  = PRT.model(mid).input.type;
    
    % configure additional CV parameters (e.g. needed to compute a GLM)
    cvdata.tr_param = prt_cv_opt_param(PRT, ID(tr_idx,:), mid);
    cvdata.te_param = prt_cv_opt_param(PRT, ID(te_idx,:), mid);

    % Apply any operations specified
    ops = PRT.model(mid).input.operations(PRT.model(mid).input.operations ~=0 );
    for o = 1:length(ops)
        cvdata = prt_apply_operation(PRT, cvdata, ops(o));
    end
    
    % train the prediction model
    model = prt_machine(cvdata, PRT.model(mid).input.machine);
    
    % check that it produced a predictions field
    if ~any(strcmpi(fieldnames(model),'predictions'))
        error(['prt_cv_model:machineDoesNotGivePredictions',...
            'Machine did not produce a predictions field']);
    end  
    
    % does the model alter the target vector (e.g. change its dimension) ?
    if isfield(model,'te_targets')
        true_te_targets = model.te_targets(:);
    else
        true_te_targets = cvdata.te_targets(:);
    end
    if isfield(model,'tr_targets')
        tr_targets = model.tr_targets(:);
    else
        tr_targets = cvdata.tr_targets(:);
    end
    
    % compute stats
    stats = prt_stats(model, true_te_targets, tr_targets);
    
    % update PRT - ensuring column vectors throughout
    %PRT.model(mid).output.fold(f).targets     = cvdata.te_targets(:); 
    PRT.model(mid).output.fold(f).targets     = true_te_targets; 
    PRT.model(mid).output.fold(f).predictions = model.predictions(:);
    PRT.model(mid).output.fold(f).stats       = stats;
    % save func_val for later analysis if available
    if isfield(model,'func_val')
        PRT.model(mid).output.fold(f).func_val    = model.func_val; 
    end
    
    % copy other fields from the model
    flds = fieldnames(model);
    for fld = 1:length(flds)
        fldnm = char(flds(fld));
        if ~strcmpi(fldnm,'predictions')
            %eval(['PRT.model(mid).output.fold(f).',fldnm,'=model.',fldnm,';']);
            PRT.model(mid).output.fold(f).(fldnm)=model.(fldnm);
        end
    end
end

% Model level statistics (across folds)
t             = vertcat(PRT.model(mid).output.fold(:).targets);
m.type        = PRT.model(mid).output.fold(1).type;
m.predictions = vertcat(PRT.model(mid).output.fold(:).predictions);
%m.func_val=[PRT.model(mid).output.fold(:).func_val];
stats         = prt_stats(m,t(:),'model');

PRT.model(mid).output.stats=stats;

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

% -------------------------------------------------------------------------
% Private functions
% -------------------------------------------------------------------------
        
function [Phi_tr Phi_te Phi_tt] = split_data(Phi_all, tr_idx, te_idx, usebf)
% function to split the data matrix into training and test

n_mat = length(Phi_all);

% training
Phi_tr = cell(1,n_mat);
for i = 1:n_mat;
    if usebf
        cols_tr = tr_idx;
    else
        cols_tr = size(Phi_all{i},2);
    end
    
    Phi_tr{i} = Phi_all{i}(tr_idx,cols_tr);
end

% test
Phi_te  = cell(1,n_mat);
Phi_tt = cell(1,n_mat);
if usebf
    cols_tr = tr_idx;
    cols_te = te_idx;
else
    cols_tr = size(Phi_all{i},2);
    %cols_te = size(Phi_all{i},2);
end

for i = 1:length(Phi_all)
    Phi_te{i} = Phi_all{i}(te_idx, cols_tr);
    if usebf
        Phi_tt{i} = Phi_all{i}(te_idx, cols_te);
    else
        Phi_tt{i} = [];
    end
end
end

