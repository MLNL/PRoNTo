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
    stats_tool = which('perfcurve');
    % Compute average ROC with confidence intervals if possible
    if stats_tool
        targets = {PRT.model(model).output.fold(:).targets};
        if isfield(PRT.model(model).output.fold(1),'func_val')
            fVals  = {PRT.model(model).output.fold(:).func_val};
        else
            fVals  = {PRT.model(model).output.fold(:).predictions};
        end
        [fprs,tprs] = perfcurve(targets,fVals,1);        
        tpr{1} = tprs(:,1);
        fpr{1} = fprs(:,1);
        tpr_up = min(tprs(:,3),1);
        tpr_low = max(tprs(:,2),0);
        legend_labs = {'ROC curve','Confidence intervals'};
    else % Computing ROC for each fold and plotting them all
        tpr = cell(nfold,1);
        fpr = cell(nfold,1);
        legend_labs = cell(nfold,1);
        for f = 1:nfold
            targets = PRT.model(model).output.fold(f).targets;
            if isfield(PRT.model(model).output.fold(f),'func_val')
                fVals  = PRT.model(model).output.fold(f).func_val;
            else
                fVals  = PRT.model(model).output.fold(f).predictions;
            end
            [tpr{f},fpr{f}] = prt_tpr_fpr(targets,fVals);
            legend_labs{f} = ['ROC fold ',num2str(f)];
        end
        tpr_up = [];
    end
else
    % if folds wise
    targets = PRT.model(model).output.fold(fold-1).targets;
    if isfield(PRT.model(model).output.fold(fold-1),'func_val')
        fVals  = PRT.model(model).output.fold(fold-1).func_val;
    else
        fVals  = PRT.model(model).output.fold(fold-1).predictions;
    end
    [tpr{1},fpr{1}] = prt_tpr_fpr(targets,fVals);
    tpr_up = [];
    legend_labs = {'ROC curve'};
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
cc = cbrewer('qual','Set3',max(length(tpr),3));
cc = brighten(cc,-0.5);
hold on

% Plot ROC curves, one per fold if no stats toolbox
for i = 1:length(tpr)
    plot(axes_handle,fpr{i},tpr{i},'-s','Color',cc(i,:), ...
        'LineWidth',2, 'MarkerEdgeColor',cc(i,:),...
        'MarkerFaceColor',cc(i,:),...
        'MarkerSize',4);
end

% Plot std of curve if across folds
if ~isempty(tpr_up)
    std_x = [fpr{1}; flipud(fpr{1})];
    inBetween = [tpr_low;flipud(tpr_up)];
    fill(axes_handle,std_x,inBetween,[0.8 0.8 0.8],'FaceAlpha',0.4,'EdgeColor',[0.5 0.5 0.5]);
end

%Plot 'luck'
plot([0 1],[0,1],'--r')
legend_labs = [legend_labs,{'Luck'}];
    
title(axes_handle,sprintf('Receiver Operator Curve'));
xlabel(axes_handle,'False positive rate','FontWeight','bold')
ylabel(axes_handle,'True positive rate','FontWeight','bold')
set(axes_handle,'Color',[1,1,1])
xlim([-0.05 1.05])
ylim([-0.05 1.05])
legend(legend_labs,'Location','SouthEast')

