function out = prt_apply_operation(PRT, in, opid)

% function to apply a data operation to the training, test and 
% in.train:      training data
% in.test:       test data
% in.testcov:    test covariance (only if use_kernel = true)
% in.tr_targets: training targets
% in.te_targets: test targets
% in.tr_id:      id matrix for training data
% in.te_id:      id matrix for test data
% in.use_kernel: are the data in kernelised form
%
% opid specifies the operation to apply, where:
%    1 = Temporal Compression
%    2 = Sample averaging (average samples for each subject/condition)
%    3 = Mean centre features over subjects
%    4 = Divide data vectors by their norm
%    5 = Perform a GLM (fMRI only)
%
% Written by A Marquand

for d = 1:length(in.train)
    switch opid
        case 1  % temporal compression
            Ptr = compute_tc_mat(in.tr_id);
            Pte = compute_tc_mat(in.te_id);
            
            if in.use_kernel
                out.train{d} = Ptr*in.train{d}*Ptr';
                out.test{d}  = Pte*in.test{d}*Ptr';
            else
                out.train{d} = Ptr*in.train{d};
                out.test{d}  = Pte*in.test{d};
            end
            out.tr_targets = Ptr*in.tr_targets;
            out.te_targets = Pte*in.te_targets;
            out.tr_id = round(Ptr*in.tr_id);
            out.te_id = round(Pte*in.te_id);
            
        case 2  % sample averaging            
            Ptr = compute_sa_mat(in.tr_id);
            Pte = compute_sa_mat(in.te_id);
            
            if in.use_kernel
                out.train{d} = Ptr*in.train{d}*Ptr';
                out.test{d}  = Pte*in.test{d}*Ptr';
            else
                out.train{d} = Ptr*in.train{d};
                out.test{d}  = Pte*in.test{d};
            end
            out.tr_targets = Ptr*in.tr_targets;
            out.te_targets = Pte*in.te_targets;
            out.tr_id = round(Ptr*in.tr_id);
            out.te_id = round(Pte*in.te_id);
        
        case 3 % mean centre features over subjects
            if in.use_kernel
                [out.train{d}, out.test{d}] = ...
                    centre_kernel(in.train{d},in.test{d});
            else
                m = mean(in.train{d});
                
                out.train{d} = in.train{d} - repmat(m,size(in.train{d},2),1);
                out.test{d}  = in.test{d} - repmat(m,size(in.test{d},2),1);
            end
            out.tr_targets = in.tr_targets;
            out.te_targets = in.te_targets;
            out.tr_id = in.tr_id;
            out.te_id = in.te_id;
            
        case 4 % divide each feature vector by its norm
            if in.use_kernel
                out.train{d} = normalise_kernel(in.train{d});
                out.test{d}  = normalise_kernel(in.test{d});
            else
                for r = 1:size(in.train{d})
                    in.train{d}(r,:) = in.train{d}(r,:) / norm(in.train{d}(r,:));
                end
                for r = 1:size(in.test{d})
                    in.test{d}(r,:) = in.test{d}(r,:) / norm(in.test{d}(r,:));
                end
            end
            out.tr_targets = in.tr_targets;
            out.te_targets = in.te_targets;
            out.tr_id = in.tr_id;
            out.te_id = in.te_id;
            
        case 5 % GLM
            error ('GLM not implemented yet');
                        
        otherwise
            error('prt_apply_operation:UnknownOperationSpecified',...
                'Unknown operation requested');
    end
end

out.use_kernel = in.use_kernel;
end

% -------------------------------------------------------------------------
% Private Functions
% -------------------------------------------------------------------------

function P = compute_tc_mat(ID)
% function to compute the block averaging matrix (P) necessary to apply
% temporal compression

% give each block a unique id
IDc = zeros(size(ID,1),1);
C = {}; 
ccount = 0; 
lastid = zeros(1,5);
for c = 1:size(ID,1)
    currid = ID(c,1:5);  
    if any(lastid ~= currid)
        ccount = ccount + 1;
    end
    lastid = currid;
    IDc(c) = ccount;
end

% Compute sample averaging matrix
cids  = unique(IDc);
cnums = histc(IDc,cids);
C = cell(length(cnums),1);
for c = 1:length(cnums)
    C{c} = 1/cnums(c) .* ones(1,cnums(c));
end
P = blkdiag(C{:});
end

function P = compute_sa_mat(ID)
% function to compute the block averaging matrix (P) necessary to apply
% temporal compression

error('Sample averaging (within subject/condition) Not implemented yet')

% give each subject a unique id
gids = unique(ID(:,1));
gc = 0;
for g = 1:length(gids)
    gidx = ID(:,1) == gids(g);
    ID(gidx,2) = ID(gidx,2) + gc;
    gc = gc + max(ID(gidx,2));
end

% Compute sample averaging matrix
sids  = unique(ID(:,2));
snums = histc(ID(:,2),sids);
S = cell(length(snums),1);
for s = 1:length(snums)
    S{s} = 1/snums(s) .* ones(1,snums(s));
end
P = blkdiag(S{:});

end

function [C,Cs,Css] = centre_kernel(K, Ks, Kss)

% [C,C_tstr] = centre_kernel_train_test(K,Ks) : centers
% train/test kernels.

l = size(K,1);
j = ones(l,1);
C = K - (j*j'*K)/l - (K*j*j')/l + ((j'*K*j)*j*j')/(l^2);

if( nargin > 1 )
    tk =  (1/l)*sum(K,1); % (1 x l)
    tl = ones(size(Ks,1),1); % (n x 1)
    Cs = Ks - ( tl * tk); % ( n x l )
    tk2 = (1/(size(Ks,2)))*sum(Cs,2); % ( n x 1 )   
    Cs = Cs - (tk2 * j'); % ( n x l )
    
    % Two equivalent ways to achieve the same thing
    %Cs = Ks - repmat(sum(K),size(Ks,1),1)/l - repmat(sum(Ks,2),1,size(Ks,2))/size(Ks,2) + repmat(j'*K*j,size(Ks,1),size(Ks,2))/(l^2);
    %Cs = Ks - (tl*sum(K))/l - (sum(Ks,2)*j')/size(Ks,2) + ((j'*K*j)*tl*j')/(l^2);
    
    if nargin > 2
        ttj = ones(size(Kss,1),1);
        Css = Kss - (sum(Ks,2)*ttj')/l - (ttj*sum(Ks,2)')/l + ((j'*K*j)*ttj*ttj')/(l^2);
    end
end 

end

function C = normalise_kernel(K)

% This function normalises the kernel matrix such that each entry is 
% divided by the product of the std deviations, i.e.
% K_new(x,y) = K(x,y) / sqrt(var(x)*var(y)) 

d  = diag(K);
K0 = sqrt(repmat(d,[1,size(K,1)]).* repmat(d',[size(K,1),1]));
C  = K./K0;

end