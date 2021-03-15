function output = prt_machine_NN(d,args)
% Kernel ridge regression
% FORMAT output = prt_machine_svm_bin(d,args)
% Inputs:
%   d         - structure with data information, with mandatory fields:
%     .train      - training data (cell array of matrices of row vectors,
%                   each [Ntr x D]). each matrix contains one representation
%                   of the data. This is useful for approaches such as
%                   multiple kernel learning.
%     .test       - testing data  (cell array of matrices row vectors, each
%                   [Nte x D])
%     .tr_targets - training labels (for classification) or values (for
%                   regression) (column vector, [Ntr x 1])
%     .use_kernel - flag, is data in form of kernel matrices (true) of in
%                form of features (false)
%    args     - libSVM arguments
% Output:
%    output  - output of machine (struct).
%     * Mandatory fields:
%      .predictions - predictions of classification or regression [Nte x D]
%     * Optional fields:
%      .func_val - value of the decision function
%      .type     - which type of machine this is (here, 'classifier')
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by Carlton Chu
% $Id$


output.type=d.pred_type;
X=d.train{1};

SANITYCHECK=true; % can turn off for "speed". Expert only.

if SANITYCHECK==true

end


% Run KRR
%----------------------------------------------------------------------
y_pred = prt_NN(X,d.tr_targets,d.test{1},d.te_targets);

[~, output.predictions] = max(y_pred, [], 2) ;

[output.func_val,~] = max(y_pred');

end
