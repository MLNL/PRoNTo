function output = prt_machine_ENMKL_KRR(d,arg)
% Run Elastic-net KRR - wrapper for ENMKL
% FORMAT output = prt_machine_ENKRR(d,args)
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
%    args     - ENMKL arguments
% Output:
%    output  - output of machine (struct).
%     * Mandatory fields:
%      .predictions - predictions of classification or regression [Nte x D]
%     * Optional fields:
%      .func_val - value of the decision function
%      .type     - which type of machine this is (here, 'classifier')
%      .
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Mourao-Miranda 

% Run ENKRR
%--------------------------------------------------------------------------
C = arg(1);
mu = arg(2);
beta = 1/size(d.train,2)*ones(1,size(d.train,2)); %initialize kernel weights
m = mean(d.tr_targets);
tr_targets = d.tr_targets - m;

[alpha,beta] = ENMKLKRRtrain(tr_targets,d.train,C,beta,mu);

ktest_final = zeros(length(d.te_targets),length(d.tr_targets));
for i = 1:size(d.train,2)
    ktest_final = ktest_final + beta(i)*d.test{i};
end

ktrain_final = zeros(length(d.tr_targets),length(d.tr_targets)); % Added in June 2026 for the Save permutation parameters bug
for i = 1:size(d.train,2)
    ktrain_final = ktrain_final + beta(i)*d.train{i};
end

func_val = (ktest_final*alpha)+m;
func_val_train = (ktrain_final*alpha)+m; % Added in June 2026 for the Save permutation parameters bug
predictions = func_val;
predictions_train = func_val_train; % Added in June 2026 for the Save permutation parameters bug

% Outputs
%--------------------------------------------------------------------------
output.predictions = predictions;
output.targets_train = d.tr_targets; % Added in June 2026 for the Save permutation parameters bug
output.predictions_train = predictions_train; % Added in June 2026 for the Save permutation parameters bug
output.func_val    = func_val;
output.func_val_train    = func_val_train; % Added in June 2026 for the Save permutation parameters bug
output.type        = 'regression';
output.alpha       = alpha;
output.beta        = beta; %kernel weights

end