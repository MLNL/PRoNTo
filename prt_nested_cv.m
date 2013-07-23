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

% Change PRT
PRT_out = PRT;
PRT_out.fs(1).id_mat = fdata.ID; % TODO: I'm not sure this is enought. CHECK!





end