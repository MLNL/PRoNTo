function stats = prt_stats(model, tte, nk)
% Function to compute predictions machine performance statistcs statistics
%
% Inputs:
% ----------------
% model.predictions: predictions derived from the predictive model
% model.type:        what type of prediction machine (e.g. 'classifier','regression')
%
% tte: true targets (test set)
% nk:  number of classes if classification (empty otherwise)
% flag:  'fold' for statistics in each fold
%         'model' for statistics in each model
% 
% Outputs:
%-------------------
% Classification:
% stats.con_mat: Confusion matrix (nClasses x nClasses matrix, pred x true)
% stats.acc:     Accuracy (scalar)
% stats.b_acc:   Balanced accuracy (nClasses x 1 vector)
% stats.c_acc:   Accuracy by class (nClasses x 1 vector)
% stats.c_pv:    Predictive value for each class (nClasses x 1 vector)
% stats.auc:     AUC under ROC curve for binary classification

%
% Regression:
% stats.mse:     Mean square error between test and prediction
% stats.nmse:    Normalized mean square error between test and prediction
% stats.corr:    Correlation between test and prediction
% stats.r2:      Squared correlation
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A. Marquand and J. Schrouff
% $Id$

% FIXME: is any code using the 'flags' input argument? 
if ~isfield(model,'type')
    warning('prt_stats:modelDoesNotProvideTypeField',...
        'model.type not specified, defaulting to classifier');
    model.type = 'classification';
end

if strcmpi(model.type,'classification') || strcmpi(model.type,'classifier')
    if iscell(tte) && numel(tte)>1
        % Multi-Task Learning classifier
        stats = compute_stats_classifier_MTL(model, tte, nk);
    else
        % Single task learning classifier
        stats = compute_stats_classifier(model, tte, nk);
    end
    
elseif strcmpi(model.type,'regression')
    if iscell(tte) && numel(tte)>1
        % Multi-Task Learning regression
        stats = compute_stats_regression_MTL(model, tte);
    else
        % Single task learning regression
        stats = compute_stats_regression(model, tte);
    end
    
else
    error('prt_stats:unknownTypeSpecified',...
        ['No method exists for processing machine: ',machine.type]);
end

end

% -------------------------------------------------------------------------
% Private functions
% -------------------------------------------------------------------------

function stats = compute_stats_classifier(model, tte, k)

k = max(unique(k));        % number of classes

stats.con_mat = zeros(k,k);
for i = 1:length(tte)
    true_lb = tte(i);
    pred_lb = model.predictions(i); %prediction_train
    if ~any(pred_lb==0)
        stats.con_mat(pred_lb,true_lb) = stats.con_mat(pred_lb,true_lb) + 1;
    end
end

Cc = diag(stats.con_mat);   % correct predictions for each class
Zc = sum(stats.con_mat)';   % total samples for each class (cols)
% nz = Zc ~= 0;               % classes with nonzero totals (cols)
Zcr = sum(stats.con_mat,2); % total predictions for each class (rows)

stats.acc       = sum(Cc) ./ sum(Zc);
stats.c_acc     = zeros(k,1);
stats.c_acc = Cc ./ Zc;
stats.b_acc     = nanmean(stats.c_acc);
stats.c_pv      = zeros(k,1);
stats.c_pv = Cc ./ Zcr;

% confidence interval
% TODO: check IID assumption here (chunks in run_permutation.m)
% before applying tests, and give nans if not applicable...
[lb,ub] = computeWilsonBinomialCI(sum(Cc),sum(Zc));
stats.acc_lb=lb;
stats.acc_ub=ub;

% AUC for binary classification
if k==1
    tpr = NaN;
    fpr = NaN;
    auc = NaN;
    stats.auc = auc;
elseif k==2 % If binary classidication
    n_tte = length(tte);
    k_tte = numel(unique(tte));
    if n_tte==1 || (n_tte>1 && k_tte==1)  % Leave-one-subject-out or only one class in test targets
        tpr = NaN;
        fpr = NaN;
        auc = NaN;
        stats.auc = auc;
    else 
        % Prepare data for computation
        if isfield(model,'func_val')
            scores = model.func_val;
        else
            scores = model.predictions;
        end

        % Compute tpr and fpr
        [tpr,fpr] = prt_tpr_fpr(tte,scores);

        % Compute AUC
        n = size(tpr, 1);
        auc = sum((fpr(2:n) - fpr(1:n-1)).*(tpr(2:n)+tpr(1:n-1)))/2;

        stats.auc = auc;
    end
elseif k>2 % If multiple classification
    tpr = [];
    fpr = [];
    auc = [];
    stats.auc = auc;
    
else
    error('No assigned classes.')
end

end

function stats = compute_stats_regression(model, tte)

if numel(tte)<3
    stats.corr = NaN;
    stats.r2 = NaN;
else
    coef = corrcoef(model.predictions,tte);
    stats.corr = coef(1,2);
    stats.r2 = coef(1,2).^2;
end
stats.mse  = mean((model.predictions-tte).^2);
stats.nmse = mean((model.predictions-tte).^2)/(var(tte));
end

function stats = compute_stats_classifier_MTL(model, tte, k)

nt = numel(tte); % Number of tasks
for t = 1: nt
    model_task.predictions = model.predictions{t};
    targets = tte{t};
    task_stats(t) = compute_stats_classifier(model_task, targets, k{t});
end

stats.acc       = mean([task_stats(:).acc]);
stats.b_acc     = mean([task_stats(:).b_acc]);
stats.c_acc     = NaN;
stats.c_pv      = NaN;
stats.acc_lb    = NaN;
stats.acc_ub    = NaN;
stats.task_stats= task_stats;
stats.task_bacc = [task_stats(:).b_acc];

end

function stats = compute_stats_regression_MTL(model, tte)

nt = numel(tte); % Number of tasks
for t = 1: nt
    model_task.predictions = model.predictions{t};
    targets = tte{t};
    task_stats(t) = compute_stats_regression(model_task, targets);
end

stats.mse       = mean([task_stats(:).mse]);
stats.nmse      = mean([task_stats(:).nmse]);
stats.corr      = mean([task_stats(:).corr]);
stats.r2        = mean([task_stats(:).r2]);
stats.task_stats= task_stats;
stats.task_r2   = [task_stats(:).r2];
% stats.task_r   = [task_stats(:).corr];
% stats.task_mse   = [task_stats(:).mse];

end

function [lb,ub] = computeWilsonBinomialCI(k,n)
% Compute upper and lower 5% confidence interval bounds
% for a binomial distribution using Wilson's 'score interval'
%
% IN
%   k: scalar, number of successes
%   n: scalar, number of samples
%
% OUT
%   lb: lower bound of confidence interval
%   ub: upper bound of confidence interval
%
% REFERENCES
% Brown, Lawrence D., Cai, T. Tony, Dasgupta, Anirban, 1999.
%  Interval estimation for a binomial proportion. Stat. Sci. 16, 101?133.
% Edwin B. Wilson, Probable Inference, the Law of Succession, and
%   Statistical Inference, Journal of the American Statistical Association,
%   Vol. 22, No. 158 (Jun., 1927), pp. 209-212

alpha=0.05;

l=spm_invNcdf(1-alpha/2,0,1); % 
p=k/n;                    % sample proportion of success
q=1-p;

% compute terms of formula
firstTerm=(k+(l^2)/2)/(n+l^2);
secondTerm=((l*sqrt(n))/(n+l^2))*sqrt(p*q+((l^2)/(4*n)));

% compute upper and lower bounds
lb=firstTerm-secondTerm;
ub=firstTerm+secondTerm;

end


