function [alpha_y,beta,b] = ENMKLSVMtrain(y,K,C,beta,mu)
% ENMKLSVMTRAIN  MKL-SVM with elastic-net on beta
%
% Input: 
%   y       -   vector of labels
%   K       -   cell array of m×m kernel matrices
%   C       -   scalar misclassification parameter 
%   beta    -   weights of kernels 
%   mu      -   parameter to regularise between 1-norm and 2-norm. mu in (0,1]
%
% Outputs:
%   alpha_y   -   vector of final dual variables times labels
%   beta      -   final normalized kernel weights (sum(beta)=1)
%   b  -   bias term
%
% Written by Zakria Hussain, UCL, March 2010
% Modified by Janaina Mourao-Miranda, UCL, January 2013, February 2014, September 2022, August 2024, September 2025

m = length(y);
p = size(K,2);
err = 10e3;
count = 0;
oldalpha = inf*ones(m,1);
norm_w = zeros(p,1);
delta = 10e-8;% small constant to avoid divide-by-zero


% fprintf('Start MKL optimization...\n')

while err > 10e-5 

    count = count+1;

    % Build combined kernel
    newK = zeros(m,m);
    for j=1:p
        newK = newK + beta(j)*K{j};
    end
    
    %Solve SVM dual via SMO 
    Q = repmat(y,1,m).*newK.*repmat(y',m,1);
    alpha = smo_train(Q,y,C);

    % Update norms of individual kernel-space weights
    for j=1:p
        norm_w(j) = beta(j)*sqrt((y.*alpha)'*K{j}*(y.*alpha));
        if norm_w(j) < 10e-5
            norm_w(j) = 0;
        end
    end

    % Compute λ and update beta via elastic-net formula  
    lambda = norm_w./(sqrt(mu)*sum(norm_w)+delta);
    for j=1:p
        beta(j) = 1/((sqrt(mu)/lambda(j))+(1-mu));
    end
    
    % Compute convergence criteria
    err = sum(oldalpha-alpha);
    oldalpha = alpha;

end

% rescales the dual variables α to compensate for the renormalization of the kernel weights 
alpha = sum(beta)*alpha;

% renormalization of the kernel weights
beta = beta./sum(beta);

% Recompute combined kernel for final bias (b) estimation
newK = zeros(m,m);
for j=1:p
    newK = newK+beta(j)*K{j};
end

pos_index = y == 1;
neg_index = y == -1;

dual = (y.*alpha)'*newK;

b = -0.5*(min(dual(pos_index))+max(dual(neg_index)));

% Multiply the dual variables by the labels for output

alpha_y = y.*alpha;

end