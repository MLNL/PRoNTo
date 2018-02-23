function [model, targets] = prt_cv_fold(PRT, in)
% Function to run a single cross-validation fold 
%
% Inputs:
% -------
% PRT:           data structure
% in.mid:        index to the model we are working on
% in.ID:         ID matrix
% in.CV:         Cross-validation matrix (current fold only)
% in.Phi_all:    Cell array of data matri(ces) (training and test)
% in.t           prediction targets
%
% Outputs:
% --------
% model:         the model returned by the machine
% targets.train: training targets
% targets.test:  test targets
%
% Notes: 
% ------
% The training and test targets output byt this function are not
% necessarily equivalent to the targets that are supplied to the function.
% e.g. some data operations can modify the number of samples (e.g. sample
% averaging). In such cases size(targets.train) ~= size(in.t)
%
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A Marquand and J. Schrouff
% $Id$

% configure model parameters
cvdata.use_kernel = PRT.model(in.mid).input.use_kernel;
cvdata.pred_type  = PRT.model(in.mid).input.type;

% Single Task or Multi-task model: apply operations and prepare data
if iscell(in.CV) && iscell(in.t)
    ntasks = numel(in.CV);
    m = in.midMTL;
    for t = 1:ntasks
        % Train-Test separation
        tr_idx = in.CV{t} == 1;
        te_idx = in.CV{t} == 2;
        [Phi_tr(t), Phi_te(t), Phi_tt(t)] = ...
            split_data(in.Phi_all(t), tr_idx, te_idx, PRT.model(in.mid).input.use_kernel);        
       
        % configure operation parameters (e.g. needed to compute a GLM)
        opsdata.tr_targets = in.t{t}(tr_idx,:);
        opsdata.te_targets = in.t{t}(te_idx,:);
        opsdata.tr_id      = in.ID{t}(tr_idx,:);
        opsdata.te_id      = in.ID{t}(te_idx,:);
        opsdata.tr_param = prt_cv_opt_param(PRT, in.ID{t}(tr_idx,:),m(t));
        opsdata.te_param = prt_cv_opt_param(PRT, in.ID{t}(te_idx,:), m(t));
        opsdata.train      = Phi_tr(t);
        opsdata.test       = Phi_te(t);
        opsdata.use_kernel = PRT.model(in.mid).input.use_kernel;
        if PRT.model(m(t)).input.use_kernel
            opsdata.testcov    = Phi_tt(t);
        end
        
        % Apply any operations specified
        ops = PRT.model(m(t)).input.operations(PRT.model(m(t)).input.operations ~=0 );
        if any(ismember(ops,5))
            opsdata.tr_cov = in.cov{t}(tr_idx,:);
            opsdata.te_cov = in.cov{t}(te_idx,:);
            posglm = find(ops==5);
            if posglm~=1 % GLM should be first
                idxops = 1:length(ops);
                newidx = setdiff(idxops,posglm);
                ops=[5,ops(newidx)];
            end
        end
        for o = 1:length(ops)
            opsdata = prt_apply_operation(PRT, opsdata, ops(o));
        end
        
        % Assemble data structure to supply to machine
        cvdata.train(t)      = opsdata.train;
        cvdata.test(t)       = opsdata.test;
        cvdata.tr_targets{t} = opsdata.tr_targets;
        cvdata.te_targets{t} = opsdata.te_targets;
        if opsdata.use_kernel
            cvdata.testcov(t)    = opsdata.testcov;
        end
        
    end
    
else
    ntasks = 1;
    tr_idx = in.CV == 1;
    te_idx = in.CV == 2;
    
    [Phi_tr, Phi_te, Phi_tt] = ...
        split_data(in.Phi_all, tr_idx, te_idx, PRT.model(in.mid).input.use_kernel);
    
    cvdata.tr_targets = in.t(tr_idx,:);
    cvdata.te_targets = in.t(te_idx,:);
    cvdata.tr_id      = in.ID(tr_idx,:);
    cvdata.te_id      = in.ID(te_idx,:);
    
    % configure additional CV parameters (e.g. needed to compute a GLM)
    cvdata.tr_param = prt_cv_opt_param(PRT, in.ID(tr_idx,:), in.mid);
    cvdata.te_param = prt_cv_opt_param(PRT, in.ID(te_idx,:), in.mid);
    
    % Assemble data structure to supply to machine
    cvdata.train      = Phi_tr;
    cvdata.test       = Phi_te;
    if PRT.model(in.mid).input.use_kernel
        cvdata.testcov    = Phi_tt;
    end
    
    % Apply any operations specified
    ops = PRT.model(in.mid).input.operations(PRT.model(in.mid).input.operations ~=0 );
    if any(ismember(ops,5))
        cvdata.tr_cov = in.cov(tr_idx,:);
        cvdata.te_cov = in.cov(te_idx,:);
        posglm = find(ops==5);
        if posglm~=1 % GLM should be first
            idxops = 1:length(ops);
            newidx = setdiff(idxops,posglm);
            ops=[5,ops(newidx)];
        end
    end
    for o = 1:length(ops)
        cvdata = prt_apply_operation(PRT, cvdata, ops(o));
    end
    
end


% train the prediction model
try
    model = prt_machine(cvdata, PRT.model(in.mid).input.machine);
catch err
    warning('prt_cv_fold:modelDidNotReturn',...
        'Prediction method did not return [%s]',err.message);
    if ntasks>1
        for t=1:ntasks
            model.predictions{t} = zeros(size(cvdata.te_targets{t}));
        end
    else
        model.predictions = zeros(size(cvdata.te_targets));
    end
end

% check that it produced a predictions field
if ~any(strcmpi(fieldnames(model),'predictions'))
    error(['prt_cv_model:machineDoesNotGivePredictions',...
        'Machine did not produce a predictions field']);
end

% does the model alter the target vector (e.g. change its dimension) ?
if isfield(model,'te_targets')
    if ntasks>1
        for t=1:ntasks
            targets.test{t} = model.te_targets{t}(:);
        end
    else
        targets.test = model.te_targets(:);
    end
else
    targets.test = cvdata.te_targets;
end
if isfield(model,'tr_targets')
    if ntasks>1
        for t=1:ntasks
            targets.train{t} = model.tr_targets{t}(:);
        end
    else
        targets.train = model.tr_targets(:);
    end
else
    targets.train= cvdata.tr_targets;
end

end

% -------------------------------------------------------------------------
% Private functions
% -------------------------------------------------------------------------
        
function [Phi_tr, Phi_te,Phi_tt] = split_data(Phi_all, tr_idx, te_idx, usebf)
% function to split the data matrix into training and test

n_mat = length(Phi_all);

% training
Phi_tr = cell(1,n_mat);
for i = 1:n_mat
    if usebf
        cols_tr = tr_idx;
    else
        cols_tr = 1:size(Phi_all{i},2);
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
    cols_tr = 1:size(Phi_all{i},2);
    cols_te = 1:size(Phi_all{i},2);
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
