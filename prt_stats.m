function stats = prt_stats(model, t,flag)
% Function to compute predictions machine performance statistcs statistics
%
% Inputs:
% ----------------
% model.predictions: predictions derived from the predictive model
% model.type:        what type of prediction machine (e.g. 'classifier','regression') 
%
% t: true targets
%flag:  'fold' for statistics in each fold 
%         'model' for statistics in each model
% Outputs: 
%-------------------
% Classification:
% stats.con_mat: Confusion matrix (nClasses x nClasses matrix, pred x true)
% stats.acc:     Accuracy (scalar)
% stats.b_acc:   Balanced accuracy (nClasses x 1 vector)
% stats.c_acc:   Accuracy by class (nClasses x 1 vector)
% stats.c_pv:    Predictive value for each class (nClasses x 1 vector)
%
%Regression:
%stats.mse:     Mean square error between test and prediction
%stats.corr:     Correlation between test and prediction
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A. Marquand
% $Id$

% Do some checks ...
if size(t,1) ~= size(model.predictions,1)
    error(['prt_stats:machineProvidesWrongNumberOfPredictions',...
        'Number of predictions is not equal to the number of targets']);
end

if ~isfield(model,'type')
    warning('prt_stats:modelDoesNotProvideTypeField',...
            'model.type not specified, defaulting to classifier');
    model.type = 'classifier';
end

switch model.type
    case 'classifier'
        
        stats = compute_stats_classifier(model, t);
        
    case 'regression'
        
         stats = compute_stats_regression(model, t);
        
    otherwise
        error('prt_stats:unknownTypeSpecified',...
              ['No method exists for processing machine: ',machine.type]);
end

end

% -------------------------------------------------------------------------
% Private functions
% -------------------------------------------------------------------------

function stats = compute_stats_classifier(model, t)
    
    k = max(size(t,2),2);       % number of classes
               
    stats.con_mat = zeros(k,k);
    for i = 1:length(t)
        true_lb = t(i);
        pred_lb = model.predictions(i);
        stats.con_mat(pred_lb,true_lb) = stats.con_mat(pred_lb,true_lb) + 1;
    end
    
    Cc = diag(stats.con_mat);   % correct predictions for each class
    Zc = sum(stats.con_mat)';   % total predictions for each class
    nz = Zc ~= 0;               % classes with nonzero totals
    
    stats.acc = sum(Cc) ./ sum(Zc);
    stats.c_acc = zeros(k,1);
    stats.c_acc(nz) = Cc(nz) ./ Zc(nz);       
    stats.b_acc = mean(stats.c_acc);    
end

 function stats = compute_stats_regression(model, t)
 
 if numel(t)<3
    stats.corr=NaN;
 else
     coef=corrcoef(model.predictions,t);
     stats.corr=coef(1,2);
 end
    stats.mse=mean((model.predictions-t).^2);
 end
 