function [Phi_tr, Phi_te,Phi_tt] = split_data(Phi_all, tr_idx, te_idx, usebf)
% Function to split the data matrix into training and test.
%
% Inputs:
% -------
% Phi_tr: input data (in kernel form or not), in cell array
% tr_idx: index of training samples
% te_idx: index of test samples
% usebf : whether data is in kernel form (1) or not (0)
% 
% Outputs:
% -------
% Phi_tr: train,train data matrix
% Phi_te: test,test data matrix
% Phi_tt: train,test covariance (kernel only)
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by Andre Marquand, modified by J. Schrouff
% $Id$


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