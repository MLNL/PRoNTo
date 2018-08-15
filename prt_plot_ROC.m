function prt_plot_ROC(PRT, model, fold, axes_handle)
% FORMAT prt_plot_ROC(PRT, model, fold, axes_handle)
%
% This function plots the ROC plot that appears on prt_ui_results 
% Inputs:
%       PRT             - data/design/model structure (it needs to contain
%                         at least one estimated model).
%       model           - the number of the model that will be ploted
%       fold            - the number of the fold
%       axes_handle     - (Optional) axes where the plot will be displayed
%
% Output:
%       None        
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by M. J. Rosa and J. Schrouff
% $Id: prt_plot_ROC.m 706 2013-06-07 14:33:34Z cphillip $


nfold = length(PRT.model(model).output.fold);

if fold == 1
    % Compute average and std ROC, based on scikit-learn function
    % plot_roc_crossval
    mean_fpr = linspace(0,1,100);
    tprs   = zeros();
    
    for f = 1:nfold
        targets = PRT.model(model).output.fold(f).targets;
        if isfield(PRT.model(model).output.fold(f),'func_val')
            fVals  = PRT.model(model).output.fold(f).func_val;
        else
            fVals  = PRT.model(model).output.fold(f).predictions;
        end
%         [tpr,fpr] = prt_tpr_fpr(targets,fVals);
        [tpr,fpr] = perfcurve(targets,fVals,1);
        tprs(f,:) = interp1(fpr',tpr',mean_fpr);
        
    end
    tpr = mean(tprs,1);
    fpr = mean_fpr;
    std_tpr = std(tprs,[],1);
else
    % if folds wise
    targets = PRT.model(model).output.fold(fold-1).targets;
    if isfield(PRT.model(model).output.fold(fold-1),'func_val')
        fVals  = PRT.model(model).output.fold(fold-1).func_val;
    else
        fVals  = PRT.model(model).output.fold(fold-1).predictions;
    end
    [tpr,fpr] = prt_tpr_fpr(targets,fVals);
    std_tpr = [];
end



%If no axes_handle is given, create a new window
if ~exist('axes_handle', 'var')
    figure;
    axes_handle = axes;
else
    set(axes_handle, 'XScale','linear');
end

% Prepare axis
rotate3d off
cla(axes_handle, 'reset');

% Plot curve
plot(axes_handle,fpr,tpr,'--ks','LineWidth',1, 'MarkerEdgeColor','k',...
    'MarkerFaceColor','k',...
    'MarkerSize',2);
% Plot std of curve if across folds
if ~isempty(std_tpr)
    tpr_up = min(tpr+std_tpr,1);
    tpr_low = max(tpr-std_tpr,0);
    std_x = [fpr, fliplr(fpr)];
    inBetween = [tpr_low,fliplr(tpr_up)];
    fill(axes_handle,std_x,inBetween,[0.5 0.5 0.5],'FaceAlpha',0.5);
end
    
title(axes_handle,sprintf('Receiver Operator Curve'));
xlabel(axes_handle,'False positive rate','FontWeight','bold')
ylabel(axes_handle,'True positive rate','FontWeight','bold')
set(axes_handle,'Color',[1,1,1])
xlim([-0.05 1.05])
ylim([-0.05 1.05])

