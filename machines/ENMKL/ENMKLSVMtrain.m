function [alpha,beta,b] = ENMKLSVMtrain(y,K,C,beta,mu)
%
% Input: 
%   y       -   labels
%   K       -   cell of kernels
%   C       -   misclassification parameter
%   beta    -   weights of kernels
%   mu      -   parameter to regularise between 1-norm and 2-norm. mu in (0,1]
%
% Outputs:
%   alpha   -   final dual weight vector
%   lambda  -   weights of kernels
%
% Written by Zakria Hussain, UCL, March 2010
% Modified by Janaina Mourao-Miranda, UCL, January, 2013
% Revised by Janaina Mourao-Miranda, UCL, February 2014
% Revised by Janaina Mourao-Miranda, UCL, September 2022

m = length(y);
p = size(K,2);
err = 10e3;
count = 0;
oldalpha = inf*ones(m,1);
norm_w = zeros(p,1);
delta = 10e-8;

% fprintf('Start MKL optimization...\n')

while err > 10e-5
    
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
    
    Q = repmat(y,1,m).*newK.*repmat(y',m,1);
    alpha = smo_train(Q,y,C);   

    for j=1:p
        norm_w(j) = beta(j)*sqrt((y.*alpha)'*K{j}*(y.*alpha));
        if norm_w(j) < 10e-5
            norm_w(j) = 0;
        end
    end
    
    lambda = norm_w./(sqrt(mu)*sum(norm_w)+delta); 
    
    for j=1:p
        beta(j) = 1/((sqrt(mu)/lambda(j))+(1-mu)); 
    end
    
    err = sum(oldalpha-alpha);
    oldalpha = alpha;
   
end

beta = beta/sum(beta);

newK = zeros(m,m); 
for j=1:p        
    newK = newK+beta(j)*K{j}; 
end

pos_index = y == 1; 
neg_index = y == -1;

dual = (y.*alpha)'*newK;

b = -0.5*(min(dual(pos_index))+max(dual(neg_index)));


end