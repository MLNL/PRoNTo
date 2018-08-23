function [tpr,fpr] = prt_tpr_fpr(targets,scores)
% This function computes true positive rate and false positive rate for 
% binary classifiers. 
% Inputs:
%        targets: true labels
%        scores: function values or predictions from the estimated model

% Outputs:
%        tpr: true positive rate
%        fpr: false positive rate
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by T. Wu 

% Reference: Fawcett, T. (2006). An introduction to ROC analysis. Pattern 
% Recognition Letters, 27(8), 861–874. https://doi.org/10.1016/J.PATREC.2005.10.010
%--------------------------------------------------------------------------

% Check that problem is binary
numClass = numel(unique(targets(:)));


if numClass == 2
    % Compute tpr and fpr
    targpos = targets==1;
    numPos = sum(targpos);
    numNeg = sum(~targpos);
    if numPos<=0 || numNeg<=0
        error('The number(s) of test positives and/or negatives are incorrect.');
    end
    [s_scores,idx] = sort(scores,'descend');
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

    
    if nnz(targpos)<2 || nnz(~targpos)<2
        % Cannot compute tpr or fpr if not enough points
        tpr = NaN;
        fpr = NaN;
    end
    
        
else
    % Cannot compute tpr and fpr is not both classes are present or if not
    % a binary problem
    tpr = NaN;
    fpr = NaN;
end 

