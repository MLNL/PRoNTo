function [model, targets] = prt_cv_fold(PRT, in)
% Function to run a single cross-validation fold.
%
% Inputs:
% -------
% PRT:           data structure
% in.mid:        index to the model we are working on
% in.ID:         ID matrix
% in.CV:         Cross-validation matrix (current fold only)
% in.Phi_all:    Cell array of data matri(ces) (training and test)
% in.t           prediction targets
% in.cov         covariates 
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

% Single Task or Multi-task model: apply operations and prepare data
if iscell(in.CV) && iscell(in.t)
    ntasks = numel(in.CV);
    [cvdata] = prt_prepare_task_input_MTL(PRT,in);    
else
    ntasks = 1;
    [cvdata] = prt_prepare_task_input_STL(PRT,in);    
end
cvdata.use_kernel = PRT.model(in.mid).input.use_kernel;
cvdata.pred_type  = PRT.model(in.mid).input.type;

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



