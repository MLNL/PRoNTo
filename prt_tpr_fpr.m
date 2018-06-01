function [tpr,fpr] = prt_tpr_fpr(targets,scores,numClass)
% This function computes true positive rate and false positive rate for 
% binary classifiers. 
% Inputs:
%        targets: true labels
%        scores: function values or predictions from the estimated model
%        numClass: the number classes
% Outputs:
%        tpr: true positive rate
%        fpr: false positive rate


% Check on the number of classes
if numClass~=2
    if numClass>2
        error(['Computations of true positive rate and false positive rate are',...
              ' currently not implemented for multiclassification problems.',...
              ' The number of classes are %d.'], numClass);
    elseif numClass==1
        error(['Computations of true positive rate and false positive rate are',...
               ' only supported for binary classification.',...
               ' The number of classes are %d.'], numClass);
    end
end

% Compute tpr and fpr
targpos = targets==1;
[~,idx] = sort(scores,'descend');
s_targpos = targpos(idx);

tpr      = cumsum(single(s_targpos))/sum(single(s_targpos));
fpr      = cumsum(single(~s_targpos))/sum(single(~s_targpos));

tpr      = [0 ; tpr ; 1];
fpr      = [0 ; fpr ; 1];

end 
