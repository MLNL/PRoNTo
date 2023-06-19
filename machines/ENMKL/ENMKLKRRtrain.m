function [alpha,beta] = ENMKLKRRtrain(y,K,L,beta,mu)

%
% Input: 
%   y       -   labels
%   K       -   cell of kernels
%   L       -   regularization parameter
%   beta    -   weights of kernels
%   mu      -   parameter to regularise between 1-norm and 2-norm. mu in (0,1]
%
% Outputs:
%   alpha   -   final dual weight vector
%   lambda  -   weights of kernels
%
% Written by Janaina Mourao-Miranda, UCL, July, 2014
% Revised by Janaina Mourao-Miranda, UCL, September 2022 

m = length(y);
p = size(K,2);
err = 10e3;
count = 0;
oldalpha = inf*ones(m,1);
norm_w = zeros(p,1);

% fprintf('Start MKL optimization...\n')

while err > 10e-3
    
    count = count+1;
    
%      if mod(count,25)==0
%          fprintf('.\n');
%      else
%          fprintf('.');
%      end
     
    newK = zeros(m,m);
    
    for j=1:p
        newK = newK + beta(j)*K{j}; 
    end
   
    alpha = prt_KRR(newK,y,L);
    
    for j=1:p
        norm_w(j) = beta(j)*sqrt(alpha'*K{j}*alpha);
        if norm_w(j) < 10e-5
            norm_w(j) = 0;
        end
    end
    
    lambda = norm_w./(sqrt(mu)*sum(norm_w)); 
    
    for j=1:p
        beta(j) = 1/((sqrt(mu)/lambda(j))+(1-mu)); 
    end
    
    err = sum(oldalpha-alpha);
    oldalpha = alpha;
   
end

beta = beta/sum(beta);


