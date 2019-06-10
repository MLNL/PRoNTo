function prt_plot_prediction_reg_scatter(PRT, model, fold,axes_handle)
% Function to plot the scatter plot that appears on prt_ui_results
%
% FORMAT prt_plot_prediction_reg_scatter(PRT, model, fold,axes_handle)
% Inputs:
%       PRT             - data/design/model structure (it needs to contain
%                         at least one estimated model).
%       model           - the number of the model that will be ploted
%       fold            - the index of fold to plot
%       axes_handle     - (Optional) axes where the plot will be displayed
%
% Output:
%       None
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by M. J. Rosa and J. Schrouff
% $Id: prt_plot_prediction_reg_scatter.m 706 2013-06-07 14:33:34Z cphillip $

nfold = length(PRT.model(model).output.fold);

%If no axes_handle is given, create a new window
if ~exist('axes_handle', 'var')
    figure;
    axes_handle = axes;
else
    set(axes_handle, 'XScale','linear');
end


cla(axes_handle, 'reset');
hold on
tars = [];
preds = [];
fold_idx = []; %used when plotting the overall scatter plot
label = cell(nfold,1);
for f = 1:nfold
    tars = [tars; PRT.model(model).output.fold(f).targets];
    preds = [preds; PRT.model(model).output.fold(f).predictions];
    fold_idx = [fold_idx; f*ones(numel(PRT.model(model).output.fold(f).targets),1)];
    label{f} = ['Fold ',num2str(f)];
end

minp = min(tars);
maxp = max(tars);

cmap = cbrewer('qual','Set3',max(3,nfold));
cmapall = cmap(fold_idx,:);
cmapall = brighten(cmapall,-0.6); % Make it darker

if fold>1 % scatter plot for each fold
    preds1 = PRT.model(model).output.fold(fold-1).targets;
    preds2 = PRT.model(model).output.fold(fold-1).predictions;
    cmapfold = cmapall(fold_idx==fold-1,:);
    scatter(axes_handle,preds2,preds1,[],cmapfold,'filled',...
        'MarkerEdgeColor','k','MarkerFaceAlpha',0.8);
    plot([minp,maxp],[minp,maxp],'--','Color',[0.5 0.5 0.5])
else % scatter with colorscheme based on fold
    scatter(axes_handle,preds,tars,[],cmapall,'filled',...
        'MarkerEdgeColor','k','MarkerFaceAlpha',0.8);
%     if nfold>4
%         location = 'OutsideSouthEast';
%     else
%         location = 'SouthEast';
%     end
%     legend(axes_handle,label,'Location',location);
    plot([minp,maxp],[minp,maxp],'--','Color',[0.5 0.5 0.5])
end
xlabel(axes_handle,'predictions','FontWeight','bold');
ylabel(axes_handle,'targets','FontWeight','bold');

hold off
