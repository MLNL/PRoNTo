function prt_plot_accuracy_distribution(PRT, model, axes_handle)
% FORMAT prt_plot_accuracy_distribution(PRT, model, axes_handle)
%
% This function plots the accuracy distribution across folds as a violin
% plot that appears in the prt_ui_results_stats window
% Inputs:
%       PRT             - data/design/model structure (it needs to contain
%                         at least one estimated model).
%       model           - the number of the model that will be ploted
%       axes_handle     - (Optional) axes where the plot will be displayed
%
% Output:
%       None        
%__________________________________________________________________________
% Copyright (C) 2018 Machine Learning & Neuroimaging Laboratory

% Written by J. Schrouff
% $Id: prt_plot_accuracy_distribution.m 706 2013-06-07 14:33:34Z cphillip $

% Set colors
c1 = cbrewer('qual','Set3',3);
c = [c1(1,:); 0.6 0.6 0.6];
c_over = brighten(c,0.5);
c = brighten(c,-0.4);


nfold = length(PRT.model(model).output.fold);

% Get balanced accuracy value
b_acc = zeros(nfold,1);
for i = 1:nfold
    b_acc(i) = PRT.model(model).output.fold(i).stats.b_acc;
end

% Get permuted balanced accuracy values if they exist
if isfield(PRT.model(model).output.stats,'permutation') && ...
        isfield(PRT.model(model).output.stats.permutation,'b_acc') && ...
        ~isempty(PRT.model(model).output.stats.permutation.b_acc)
    perm_bacc = PRT.model(model).output.stats.permutation.b_acc;
else
    perm_bacc = [];
end

% Set axes
%If no axes_handle is given, create a new window
if ~exist('axes_handle', 'var')
    figure;
    axes_handle = axes;
else
    set(axes_handle, 'XScale','linear');
end
rotate3d off
cla(axes_handle, 'reset');

% Get violin plot for balanced accuracy
if isempty(perm_bacc)
    % Only plot balanced accuracy if no permutations
    distributionPlot(axes_handle,b_acc,'color',c_over(1,:),'showMM',2)
    legend_text = {'Balanced accuracy','Mean'};
else
    % Plot balanced accuracy on the left and permutations on the right
    distributionPlot(axes_handle,b_acc,'widthDiv',[2 1],'histOri','left','color',c_over(1,:),'showMM',0)
    distributionPlot(axes_handle,perm_bacc','widthDiv',[2 2],'histOri','right','color',c_over(2,:),'showMM',0)
    distributionPlot(axes_handle,b_acc,'widthDiv',[2 1],'histOri','left','color',c(1,:),'histOpt',0,'showMM',0)
    distributionPlot(axes_handle,perm_bacc','widthDiv',[2 2],'histOri','right','color',c(2,:),'histOpt',0,'showMM',0)
    legend_text = {'True labels','Permuted labels'};
end

% Plot and axes labels
ylim([-0.05 1.05])
set(axes_handle,'XTickLabels','')
title(axes_handle,sprintf('Accuracy distribution'));
ylabel(axes_handle,'Model accuracy','FontWeight','bold')
xlabel(axes_handle,'','FontWeight','bold')
legend(legend_text,'Location','SouthWest')
set(axes_handle,'Color',[1,1,1])