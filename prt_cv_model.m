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
% Copyright (C) 2011

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
t = PRT.model(mid).input.targets;

% load data files and configure ID matrix
disp('Loading data files.....>>');
Phi_all = cell(1,n_Phi);
for i = 1:size(PRT.fs,1)
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
    if size(t,1) ~= size(Phi_all{i},1)
        error('prt_cv_model:fsSizeDoesNotMatchTargets',...
            ['size of Feature set ',num2str(fid),' does not match targets']);
    end
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
    
    % Assemble data structure
    cvdata.train      = Phi_tr;
    cvdata.test       = Phi_te;
    cvdata.tr_targets = t(tr_idx,:);
    cvdata.te_targets = t(te_idx,:);
    cvdata.tr_id      = ID(tr_idx,:);
    cvdata.te_id      = ID(te_idx,:);
    cvdata.use_kernel = PRT.model(mid).input.use_kernel;
    %if PRT.model(mid).input.use_kernel
    %    cvdata.testcov    = Phi_tt;
    %end
    
    % Apply any operations specified
    for o = PRT.model(mid).input.operations
        cvdata = prt_apply_operation(PRT, cvdata, o);
    end
    
    % train the prediction model
    model = prt_machine(cvdata, PRT.model(mid).input.machine);
    
    % check that it produced a predictions field
    if ~any(strcmpi(fieldnames(model),'predictions'))
        error(['prt_cv_model:machineDoesNotGivePredictions',...
            'Machine did not produce a predictions field']);
    end  
    
    % compute stats
    stats = prt_stats(model, cvdata.te_targets);
    acc = stats.acc % for debugging
    
    % update PRT 
    PRT.model(mid).output.fold(f).targets     = cvdata.te_targets;
    PRT.model(mid).output.fold(f).predictions = model.predictions; 
    PRT.model(mid).output.fold(f).stats       = stats;
    
    % copy other fields from the model
    flds = fieldnames(model);
    for fld = 1:length(flds)
        fldnm = char(flds(fld));
        if ~strcmpi(fldnm,'predictions')
            eval(['PRT.model(mid).output.fold(f).',fldnm,'=model.',fldnm,';']);
        end
    end
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

