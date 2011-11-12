function [C,C_s,C_ss] = prt_centre_kernel(K,K_s,K_ss)

% FORMAT [C,C_s,C_ss] = Centre_kernel(K,K_s,K_ss)
%
% This function centres the kernel matrix using only the training data
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by D. Hardoon, A. Marquand and J. Mourao-Miranda
% Id:$

if iscell(K), K = K{:}; end
if iscell(K_s), K_s = K_s{:}; end
if iscell(K_ss), K_ss = K_ss{:}; end

l = size(K,1);
j = ones(l,1);
C = K - (j*j'*K)/l - (K*j*j')/l + ((j'*K*j)*j*j')/(l^2);

if( nargin > 1 )
    tk =  (1/l)*sum(K,1); % (1 x l)
    tl = ones(size(K_s,1),1); % (n x 1)
    C_s = K_s - ( tl * tk); % ( n x l )
    tk2 = (1/(size(K_s,2)))*sum(C_s,2); % ( n x 1 )   
    C_s = C_s - (tk2 * j'); % ( n x l )
    
    % Two equivalent ways to achieve the same thing
    %C_s = K_s - repmat(sum(K),size(K_s,1),1)/l - repmat(sum(K_s,2),1,size(K_s,2))/size(K_s,2) + repmat(j'*K*j,size(K_s,1),size(K_s,2))/(l^2);
    %C_s = K_s - (tl*sum(K))/l - (sum(K_s,2)*j')/size(K_s,2) + ((j'*K*j)*tl*j')/(l^2);
    
    if nargin > 2
        ttj = ones(size(K_ss,1),1);
        C_ss = K_ss - (sum(K_s,2)*ttj')/l - (ttj*sum(K_s,2)')/l + ((j'*K*j)*ttj*ttj')/(l^2);
    end
end

C={C};
C_s={C_s};
C_ss={C_ss};
