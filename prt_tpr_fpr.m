function [tpr,fpr] = prt_tpr_fpr(targets,scores)
% This function computes true positive rate and false positive rate for 
% binary classifiers. 
% Inputs:
%        targets: true labels
%        scores: function values or predictions from the estimated model

% Outputs:
%        tpr: true positive rate
%        fpr: false positive rate

% Check that problem is binary
numClass = numel(unique(targets(:)));


if numClass == 2
    % Compute tpr and fpr
    targpos = targets==1;
    [~,idx] = sort(scores,'descend');
    s_targpos = targpos(idx);% Sorted targets

    tpr      = cumsum(single(s_targpos))/sum(single(s_targpos));
    fpr      = cumsum(single(~s_targpos))/sum(single(~s_targpos));
    
    if nnz(targpos)<2 || nnz(~targpos)<2
        % Cannot compute tpr or fpr if not enough points
        tpr = NaN;
        fpr = NaN;
    end
    
    % Deal with tails, avoiding repeated values
    if tpr(1) ~= 0
        tpr      = [0 ; tpr];
        fpr      = [0 ; fpr];
    elseif tpr(end) ~= 1
        tpr      = [tpr ; 1];
        fpr      = [fpr ; 1];
    end
        
else
    % Cannot compute tpr and fpr is not both classes are present or if not
    % a binary problem
    tpr = NaN;
    fpr = NaN;
end 

