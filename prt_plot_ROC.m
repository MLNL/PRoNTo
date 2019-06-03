function prt_plot_ROC(PRT, model, fold, axes_handle)
% Function that plots the ROC plot that appears on prt_ui_results
%
% FORMAT prt_plot_ROC(PRT, model, fold, axes_handle)
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
stats_tool = which('perfcurve');
tpr_up = [];

if fold == 1
    fpr_mean = linspace(0,1,100);
    tpr = cell(nfold,1);
    fpr = cell(nfold,1);
    tpr_mean = zeros(nfold,length(fpr_mean));
    % Compute average ROC with std if possible
    for f = 1:nfold
        targets = PRT.model(model).output.fold(f).targets;
        if isfield(PRT.model(model).output.fold(f),'func_val')
            fVals  = PRT.model(model).output.fold(f).func_val;
        else
            fVals  = PRT.model(model).output.fold(f).predictions;
        end
        if stats_tool
            [tpr{f},fpr{f}] = prt_tpr_fpr(targets,fVals);
        else
            [fpr{f},tpr(f)] = perfcurve(targets,fVals,1);   
        end
        if all(isnan(tpr{f})) || all(isnan(fpr{f}))
            tpr_mean(f,:) = NaN * ones(1,length(fpr_mean));
        end
        if which('interp1q')
            tpr_mean(f,:) = (interp1q(fpr{f},tpr{f},fpr_mean'))';
        else
            legend_labs{f} = ['ROC fold ',num2str(f)];
        end
    end
    if which('interp1q') % was able to compute interpolation for average
        clear tpr fpr
        tpr{1} = mean(tpr_mean,1)';
        tpr_std = std(tpr_mean,[],1)';
        fpr{1} = fpr_mean';
        if tpr{1}(1)~= 0 % Add (0,0) point if needed
            tpr{1} =[0;tpr{1}];
            fpr{1} =[0;fpr{1}];
            tpr_std = [0;tpr_std];
        elseif tpr{1}(end) ~= 1 % Add (1,1) point if needed
            tpr{1} =[tpr{1};1];
            fpr{1} =[fpr{1};1];
            tpr_std = [tpr_std;1];
        end
        if ~any(isnan(tpr{1}))
            tpr_low = max(tpr{1}-tpr_std,0);
            tpr_up = min(tpr{1}+tpr_std,1);
            legend_labs = {'ROC curve','+/- 1*std'};
        else
            legend_labs = {'No ROC to display'};
        end        
    end
else
    % if folds wise
    targets = PRT.model(model).output.fold(fold-1).targets;
    if isfield(PRT.model(model).output.fold(fold-1),'func_val')
        fVals  = PRT.model(model).output.fold(fold-1).func_val;
    else
        fVals  = PRT.model(model).output.fold(fold-1).predictions;
    end
    if stats_tool
        [fpr{1},tpr{1}] = perfcurve(targets,fVals,1);
    else
        [tpr{1},fpr{1}] = prt_tpr_fpr(targets,fVals);
    end
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
    if numel(tpr{i})<40 % display markers at each point
        plot(axes_handle,fpr{i},tpr{i},'-s','Color',cc(i,:), ...
            'LineWidth',2, 'MarkerEdgeColor',cc(i,:),...
            'MarkerFaceColor',cc(i,:),...
            'MarkerSize',4);
    else % Do not display markers if a lot are present
        plot(axes_handle,fpr{i},tpr{i},'-','Color',cc(i,:), ...
            'LineWidth',2);
    end
end

% Plot std of curve if across folds and not NaN
if ~isempty(tpr_up)
    std_x = [fpr{1}; flipud(fpr{1})];
    inBetween = [tpr_low;flipud(tpr_up)];
    fill(axes_handle,std_x,inBetween,[0.8 0.8 0.8],'FaceAlpha',0.4,'EdgeColor',[0.5 0.5 0.5]);
end

%Plot 'luck'
plot([0 1],[0,1],'--r')
legend_labs = [legend_labs,{'Chance'}];
    
title(axes_handle,sprintf('Receiver Operator Curve'));
xlabel(axes_handle,'False positive rate','FontWeight','bold')
ylabel(axes_handle,'True positive rate','FontWeight','bold')
set(axes_handle,'Color',[1,1,1])
xlim([-0.05 1.05])
ylim([-0.05 1.05])
legend(legend_labs,'Location','SouthEast')

