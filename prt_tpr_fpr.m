function [tpr,fpr] = prt_tpr_fpr(targets,scores)
% This function computes true positive rate and false positive rate for 
% binary classifiers. 
% Inputs:
%        targets: true labels
%        scores: function values or predictions from the estimated model

% Outputs:
%        tpr: true positive rate
%        fpr: false positive rate



% Compute tpr and fpr
targpos = targets==1;
[~,idx] = sort(scores,'descend');
s_targpos = targpos(idx);

tpr      = cumsum(single(s_targpos))/sum(single(s_targpos));
fpr      = cumsum(single(~s_targpos))/sum(single(~s_targpos));

tpr      = [0 ; tpr ; 1];
fpr      = [0 ; fpr ; 1];

end 
