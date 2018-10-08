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

% Written by M. J. Rosa, modified by T. Wu.
% Reference: Fawcett, T. (2006). An introduction to ROC analysis. Pattern 
% Recognition Letters, 27(8), 861–874. https://doi.org/10.1016/J.PATREC.2005.10.010
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

% Check that how many classes are there in the targets
numClass = numel(unique(targets(:)));

if numClass == 2
    % Compute tpr and fpr
    targpos = targets==1;
    numPos = sum(targpos);
    numNeg = sum(~targpos);

    if numPos<=0 || numNeg<=0
        error('The number(s) of test positives and/or negatives cannot be negative or zero.');
    else
        [s_scores,idx] = sort(fVals,'descend');
        s_targets = targets(idx);% Sorted targets

        tp = 0;
        fp = 0;
        thr_prev = s_scores(1)+1; % For (0,0) in ROC space
        num_scores = length(s_scores);
        num_thr = length(unique(s_scores))+1;
        tpr = [];
        fpr = [];
        i = 1;
        j = 1;
        while i<=num_scores && j<=num_thr
            if thr_prev~=s_scores(i)
                tpr(j,1) = tp/numPos;
                fpr(j,1) = fp/numNeg;
                thr_prev = s_scores(i);
                j = j+1;
            end

            if s_targets(i)==1
                tp = tp+1;
            else
                fp = fp+1;
            end

            i = i+1; 
        end
        tpr(j,1) = tp/numPos; % (1,1) in ROC space
        fpr(j,1) = fp/numNeg;
    end

else
    % Cannot compute tpr and fpr if there is only one class in the targets
    tpr = NaN;
    fpr = NaN;
end 


n       = size(tpr, 1);
A       = sum((fpr(2:n) - fpr(1:n-1)).*(tpr(2:n)+tpr(1:n-1)))/2;
%
%                 axis xy
plot(axes_handle,fpr,tpr,'--ks','LineWidth',1, 'MarkerEdgeColor','k',...
    'MarkerFaceColor','k',...
    'MarkerSize',2);
title(axes_handle,sprintf('Receiver Operator Curve / Area Under Curve = %3.2f',A));
xlabel(axes_handle,'False positives','FontWeight','bold')
ylabel(axes_handle,'True positives','FontWeight','bold')
set(axes_handle,'Color',[1,1,1])

