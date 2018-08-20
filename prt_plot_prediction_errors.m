function prt_plot_prediction_errors(PRT, model, fold, marker_size, axes_handle)
% FORMAT prt_plot_prediction_errors(PRT, model, fold, marker_size, axes_handle)
%
% This function plots the prediction error plot that appears on prt_ui_results
% Inputs:
%       PRT             - data/design/model structure (it needs to contain
%                         at least one estimated model).
%       model           - the number of the model that will be ploted
%       fold            - the number of the fold
%       marker_size     - (Optional) the size of the markers in the plot,
%                         the default is 7
%       axes_handle     - (Optional) axes where the plot will be displayed
%
% Output:
%       None
%__________________________________________________________________________
% Copyright (C) 2018 Machine Learning & Neuroimaging Laboratory

% Written by J. Schrouff based prt_plot_prediction by M.J. Rosa
% $Id: prt_plot_prediction.m 706 2013-06-07 14:33:34Z cphillip $


nfold = length(PRT.model(model).output.fold);

fVals   = [];
targets = [];
for f = 1:nfold
    targets = [targets;PRT.model(model).output.fold(f).targets];
    fVals  = [fVals;PRT.model(model).output.fold(f).predictions];
end
predErr = targets - fVals ;
% Keep scale consistent across folds
maxErr = max(predErr);
minErr = min(predErr);


%Defined the marker size, if no value is given
if ~exist('marker_size', 'var')
    marker_size = 7;
end

%If no axes_handle is given, create a new window
if ~exist('axes_handle', 'var')
    figure;
    axes_handle = axes;
else
    set(axes_handle, 'XScale','linear');
end

% Prepare axes
cla(axes_handle, 'reset');
rotate3d off
colorbar('peer',axes_handle,'off')
set(axes_handle,'Color',[1,1,1])

% Plot prediction errors
if fold == 1
    foldlabels = 1:nfold;
    for f = 2:nfold+1
        targets = PRT.model(model).output.fold(f-1).targets;
        fVals   = PRT.model(model).output.fold(f-1).predictions;
        predError = targets - fVals;
        yc = (f-1)*ones(length(predErrors),1);
        pl = plot(axes_handle,predError,yc,'kx','MarkerSize',marker_size);
    end
else
    foldlabels  = fold-1;
    yc = (fold-1)*ones(length(predErr),1);
    pl = plot(axes_handle,predErr,yc,'kx','MarkerSize',marker_size);
end
y = [0:nfold+1]';
x = zeros(nfold+2,1);
plot(axes_handle,x,y,'--','Color',[1 1 1]*.6);
xlim(axes_handle,[minErr-0.1*(abs(minErr)) maxErr-0.1*(abs(maxErr))]);

ylim(axes_handle,[0 nfold+1.3]);
xlabel(axes_handle,'Prediction Errors','FontWeight','bold');
h=ylabel(axes_handle,'fold','FontWeight','bold');
set(h,'Rotation',90)

set(axes_handle,'YTick',foldlabels)
hold(axes_handle,'off');
set(axes_handle,'Color',[1,1,1],'Visible','on')
title(axes_handle,'')
end
