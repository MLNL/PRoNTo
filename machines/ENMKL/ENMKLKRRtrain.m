function [alpha,beta] = ENMKLKRRtrain(y,K,L,beta,mu)
% ENMKLKRRTRAIN  Elastic-net MKL for Kernel Ridge Regression
%
% Input: 
%   y       -   vector of labels
%   K       -   cell array of m×m kernel matrices
%   L       -   scalar ridge regularization  parameter
%   beta    -   weights of kernels
%   mu      -   parameter to regularise between 1-norm and 2-norm. mu in (0,1]
%
% Outputs:
%   alpha   -   final dual weight vector
%   beta  -   final normalized kernel weights (sum(beta)=1)
%
% Written by Janaina Mourao-Miranda, UCL, July, 2014
% Revised by Janaina Mourao-Miranda, UCL, September 2022, August 2024, September 2025.

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

    newK = zeros(m,m);

    % Build combined kernel
    for j=1:p
        newK = newK + beta(j)*K{j};
    end

    %solve KRR dual
    alpha = prt_KRR(newK,y,L);

    % Update norms of individual kernel-space weights
    for j=1:p
        norm_w(j) = beta(j)*sqrt(alpha'*K{j}*alpha);
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

end




