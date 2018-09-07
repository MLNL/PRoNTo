function prt_plot_prediction_reg_scatter(PRT, model, fold,axes_handle)
% FORMAT prt_plot_prediction_reg_scatter(PRT, model, fold,axes_handle)
%
% This function plots the scatter plot that appears on prt_ui_results
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

% Written by M. J. Rosa
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
for f = 1:nfold
    tars = [tars; PRT.model(model).output.fold(f).targets];
end

minp = min(tars);
maxp = max(tars);

preds1 = PRT.model(model).output.fold(fold-1).targets;
preds2 = PRT.model(model).output.fold(fold-1).predictions;

err = preds1-preds2;
poserr = err>=0;
negerr = err<0;
cmapall = [];
if nnz(negerr)
    cmap = cbrewer('seq','Blues',max(3,nnz(negerr)));
    cmap = flip(cmap,1);
    cmapall=[cmapall;cmap];
end
if nnz(poserr)
    cmapall = [cmapall; cbrewer('seq','Reds',max(3,nnz(poserr)))];
end
cmapall = brighten(cmapall,-0.4); % Make it darker to see the middle points
colormap(cmapall);
scatter(axes_handle,preds2,preds1,[],preds1-preds2,'filled');
plot([minp,maxp],[minp,maxp],'--','Color',[0.5 0.5 0.5])
xlabel(axes_handle,'predictions','FontWeight','bold');
ylabel(axes_handle,'targets','FontWeight','bold');

hold off
