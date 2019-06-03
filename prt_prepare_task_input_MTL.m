function [cvdata] = prt_prepare_task_input_MTL(PRT,in)
% Function to gather task information before MTL model estimation.
%
% Inputs:
% -------
% PRT: PRT structure
% in: input structure with the following fields
%   - class: class structure for each task, cell array
%   - ID: ID matrix for each task, cell array
%   - CV: CV matrix for each task, cell array
%   - mid: model id
%   - Phi_all: input data, cell array
%   - t: targets, cell array
%   - nc: number of classes in each task, cell array
%   - cov: covariates for each task, cell array
%   - opt_Rep: flag, whether to optimize based on reproducibility of kernel
%   weights.
%   - midMTL: index of models in MTL model
%   - cv: inner cv parameters (type and k)
% 
% Outputs:
% -------
% cvdata: structure with all task info after performing CV
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A. Marquand and J. Schrouff
% $Id$

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
    
    % Apply any operations specified: if imposed at MTL level, extract
    % these, otherwise get the model specific operations
    if isfield(PRT.model(in.mid).input,'operations') && ...
            ~isempty(PRT.model(in.mid).input.operations)
        ops = PRT.model(in.mid).input.operations(PRT.model(in.mid).input.operations ~=0 );
    else
        ops = PRT.model(m(t)).input.operations(PRT.model(m(t)).input.operations ~=0 );
    end
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