function [cvdata] = prt_prepare_task_input_STL(PRT,in)
% Function to gather task information before MTL model estimation.
%
% Inputs:
% -------
% PRT: PRT structure
% in: input structure with the following fields
%   - class: class structure as defined in 'select classes/samples'
%   - ID: ID matrix 
%   - CV: CV matrix 
%   - mid: model id
%   - Phi_all: input data, cell array
%   - t: targets
%   - nc: number of classes 
%   - cov: covariates 
%   - opt_Rep: flag, whether to optimize based on reproducibility of kernel
%   weights.
%   - cv: inner cv parameters (type and k)
% 
% Outputs:
% -------
% cvdata: structure with all task info after performing CV
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A. Marquand and J. Schrouff
% $Id$

tr_idx = in.CV == 1;
te_idx = in.CV == 2;

[Phi_tr, Phi_te, Phi_tt] = ...
    split_data(in.Phi_all, tr_idx, te_idx, PRT.model(in.mid).input.use_kernel);

	% A FIX I THOUGHT WAS CORRECT FOR THE CVperm PROBLEM, BUT IN FACT IT WAS STUPID/WRONG
% if isfield(in,'f') % check to prt_permutation script
%     tr_idx = in.CVperm == 1;
%     te_idx = in.CVperm == 2;
% end
cvdata.tr_targets = in.t(tr_idx,:);
cvdata.te_targets = in.t(te_idx,:);
cvdata.tr_id      = in.ID(tr_idx,:);
cvdata.te_id      = in.ID(te_idx,:);
cvdata.use_kernel = PRT.model(in.mid).input.use_kernel;
cvdata.pred_type  = PRT.model(in.mid).input.type;

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