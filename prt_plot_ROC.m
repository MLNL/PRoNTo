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

% Written by M. J. Rosa
% $Id: prt_plot_ROC.m 706 2013-06-07 14:33:34Z cphillip $


nfold = length(PRT.model(model).output.fold);

if fold == 1
    fVals   = [];
    targets = [];
    
    for f = 1:nfold,
        targets = [targets;PRT.model(model).output.fold(f).targets];
        if isfield(PRT.model(model).output.fold(f),'func_val')
            fVvals_exist = 1;
            fVals  = [fVals;PRT.model(model).output.fold(f).func_val];
        else
            fVvals_exist = 0;
            fVals  = [fVals;...
                PRT.model(model).output.fold(f).predictions];
        end
    end
else
    % if folds wise
    targets = PRT.model(model).output.fold(fold-1).targets;
    if isfield(PRT.model(model).output.fold(fold-1),'func_val')
        fVals  = PRT.model(model).output.fold(fold-1).func_val;
        fVvals_exist = 1;
    else
        fVvals_exist = 0;
        fVals  = PRT.model(model).output.fold(fold-1).predictions;
    end
end



%If no axes_handle is given, create a new window
if ~exist('axes_handle', 'var')
    figure;
    axes_handle = axes;
else
    set(axes_handle, 'XScale','linear');
end


rotate3d off
cla(axes_handle, 'reset');

numClass = numel(unique(targets(:)));
[tpr,fpr] = prt_tpr_fpr(targets,fVals,numClass);


%
%                 axis xy
plot(axes_handle,fpr,tpr,'--ks','LineWidth',1, 'MarkerEdgeColor','k',...
    'MarkerFaceColor','k',...
    'MarkerSize',2);
title(axes_handle,sprintf('Receiver Operator Curve'));
xlabel(axes_handle,'False positive rate','FontWeight','bold')
ylabel(axes_handle,'True positive rate','FontWeight','bold')
set(axes_handle,'Color',[1,1,1])

