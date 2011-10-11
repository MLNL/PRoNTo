function stats = prt_stats(model, t)
% Function to compute predictions machine performance statistcs statistics
%
% Inputs:
% ----------------
% model.predictions: predictions derived from the predictive model
% model.type:        what type of prediction machine (e.g. 'classifier','regression') 
%
% t: true targets
%
% Outputs:
% ----------------
% stats.con_mat: Confusion matrix (nClasses x nClasses matrix, pred x true)
% stats.acc:     Accuracy (scalar)
% stats.b_acc:   Balanced accuracy (nClasses x 1 vector)
% stats.c_acc:   Accuracy by class (nClasses x 1 vector)
% stats.c_pv:    Predictive value for each class (nClasses x 1 vector)
%__________________________________________________________________________
% Copyright (C) 2011 PRoNTo

% Written by A. Marquand

% Do some checks ...
if size(t,1) ~= size(model.predictions,1)
    error(['prt_stats:machineProvidesWrongNumberOfPredictions',...
        'Number of predictions is not equal to the number of targets']);
end

switch model.type
    case 'classifier'
        
        stats = compute_stats_classifier(model, t);
        
    case 'regression'
        
        disp ('Not implemented yet');
        
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