 function output = prt_machine_ENMKL_SVM(d,arg)
% Run Elastic-net MKL 
% FORMAT output = prt_machine_simpleMKL(d,args)
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
%      
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Mourao-Miranda 

%--------------------------------------------------------------------------
% Run ENMKL
%--------------------------------------------------------------------------

C = arg(1);
mu = arg(2);
beta = 1/size(d.train,2)*ones(1,size(d.train,2)); %initialize kernel weights

% change targets from 1/2 to -1/1 
tr_targets = d.tr_targets;
c1PredIdx            = tr_targets  ==1; 
tr_targets  (c1PredIdx)  = 1; %positive values = 1 
tr_targets  (~c1PredIdx) = -1; %negative values = 2 

[alpha,beta,b] = ENMKLSVMtrain(tr_targets,d.train,C,beta,mu);

ktest_final = zeros(length(d.te_targets),length(d.tr_targets));

for i = 1:size(d.train,2)
    ktest_final = ktest_final + beta(i)*d.test{i};
end

func_val = (ktest_final*(tr_targets.*alpha))+b;

predictions = sign(func_val);

% Outputs
%--------------------------------------------------------------------------
% change predictions from 1/-1 to 1/2 
c1PredIdx               = predictions==1; 
predictions(c1PredIdx)  = 1; %positive values = 1 
predictions(~c1PredIdx) = 2; %negative values = 2 

output.predictions = predictions;
output.func_val    = func_val;
output.type        = 'classifier';
output.alpha       = alpha;
output.b           = b;
output.totalSV     = length(find(alpha~=0));
output.beta        = beta; %kernel weights

end