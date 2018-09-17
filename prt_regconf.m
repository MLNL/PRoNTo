function out = prt_regconf(PRT, in,trainonly,d)
% function to remove confounds from raw data (variable 'in')
% trainonly is a flag set to 1 if removing using training data only
% otherwise do it using all data (only when test set is not present)
% Based on formulations in "Predictive modelling using neuroimaging data in
% the presence of confounds", by A. Rao, J. Monteiro, J Mourao-Miranda and
% the Alzheimer's Disease Initiative, NeuroImage (2017), 150:23-49.
%--------------------------------------------------------------------------
% Written for PRoNTo by A. Rao and J. Schrouff
% Copyright (C) 2016 Machine Learning & Neuroimaging Laboratory

% $Id$

% copy input fields to output
out = in;

% get data and covs
traindata=in.train{d};
traincovs=in.tr_cov;
augtraincovs=[ones(size(traincovs,1),1) traincovs];

if (trainonly==0)
    % adjust using training only
    out.train=traindata-augtraincovs*(pinv(augtraincovs)*traindata);
    %     out.test=testdata-augtestcovs*(pinv(augtraincovs)*traindata);
else
    % Compute correction on train
    corr = pinv(augtraincovs)*traindata;
    
    % Correct train and test separately
    testdata=in.test{d};
    testcovs=in.te_cov;
    augtestcovs=[ones(size(testcovs,1),1) testcovs];
    
    out.train=traindata-augtraincovs*corr;
    out.test=testdata-augtestcovs*corr;
end

end

