function [PRT_out, fdata] = prt_nested_cv(PRT, fdata, Phi, samp_idx)
% Function to clip the data to be used for the nested CV
%
% Inputs:
% -------
%
% Outputs:
% --------
%
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Matos Monteiro
% $Id: $


train_entries = find(fdata.CV == 1);

% Change samp_idx (used for the kernel)
samp_idx = samp_idx(train_entries);

% Change fdata
fdata.ID      = fdata.ID(train_entries, :);
fdata.CV      = fdata.CV(train_entries);
fdata.Phi_all{1} = Phi(samp_idx,samp_idx); % TODO: I'm not sure this is correct. CHECK!
fdata.t       = fdata.t(train_entries);




% TODO: have inner cv function returning performance for each hyper value

% TODO: change hyper value in PRT.model(mid).machine.args

% generate new CV matrix
[CV,~] = prt_compute_cv_mat(PRT, in, mid, use_nested_cv);
PRT_nest.model(modelid).input.cv_mat = CV;







end