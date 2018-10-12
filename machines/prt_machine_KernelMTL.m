function output = prt_machine_KernelMTL(d,args)
% Run Multi-Task Learning - wrapper for Kernel MTL using code from
%Ciliberto, Carlo, Tomaso Poggio, and Lorenzo Rosasco. "Convex Learning of
%Multiple Tasks and their Structure". International Conference on Machine 
%Learning (ICML), 2015. Code at https://github.com/cciliber/matMTL
% FORMAT output = prt_machine_KernelMTL(d,args)
% Inputs:
%   d         - structure with data information, with mandatory fields:
%     .train      - training data (cell array of matrices of row vectors,
%                   each [Ntr x D]). each matrix contains one representation
%                   of the data. This is useful for approaches such as
%                   multiple kernel learning.
%     .test       - testing data  (cell array of matrices row vectors, each
%                   [Nte x D])
%     .tr_targets - training labels (for classification) or values (for
%                   regression) (column vector, [Ntr x 1])
%     .te_targets - testing labels (for classification) or values (for
%                   regression) (column vector, [Ntr x 1])
%    args         - Regularization parameter
% Output:
%    output  - output of machine (struct).
%     * Mandatory fields:
%      .predictions - predictions of classification or regression [Nte x D]
%     * Optional fields:
%      .func_val - value of the decision function
%      .type     - which type of machine this is (here, 'classifier')
%__________________________________________________________________________
% Copyright (C) 2018 Machine Learning & Neuroimaging Laboratory

% Written by J. Schrouff
% $Id$

SANITYCHECK=true; % can turn off for "speed". Expert only.

%Regularization parameter
if isempty(args)
    def = prt_get_defaults('model');
    args = def.MTLargs;
end

reg = 0;
nt  = numel(d.tr_targets);

if SANITYCHECK==true
    
    % Check for classification machines
    if strcmpi(d.pred_type,'classification')

        % check it is indeed a two-class classification problem
        for i= 1:nt
            uTL=unique(d.tr_targets{1}(:));
            nC=numel(uTL);
            if nC>2
                error('prt_machine_MTL_MALSAR:problemNotBinary',['Error:'...
                    ' This machine is only for two-class problems but the' ...
                    ' current problem has ' num2str(nC) ' ! ' ...
                    'SOLUTION: Please select another machine than ' ...
                    'prt_machine_MTL_MALSAR in XXX']);
            end
            % check it is indeed labelled correctly (probably should be done)
            if ~all(uTL==[1 2]')
                error('prt_machine_MTL_MALSAR:LabellingIncorect',['Error:'...
                    ' This machine needs labels to be in {1,2} ' ...
                    ' but they are ' mat2str(uTL) ' ! ' ...
                    'SOLUTION: Please relabel your classes by changing the '...
                    ' ''tr_targets'' argument to prt_machine_MTL_MALSAR']);
            end
        end
        output.type = 'classification';
    else
        output.type = 'regression';
        reg = 1;
    end   
end


% Run Multi-Task
%--------------------------------------------------------------------------

dt = cellfun(@transpose,d.train,'UniformOutput',false);
Xtmp = cell2mat(dt);
% Add bias
Xtmp = [Xtmp;ones(1,size(Xtmp,2))];
% Compute kernel
Ktr = Xtmp'*Xtmp;

Kts = cell(nt,1);
for idx_t=1:nt
    Testd = [d.test{idx_t},ones(size(d.test{idx_t},1),1)];
    Kts{idx_t}=Testd*Xtmp;
end

valued_args = args(regexp(args,'-args','once')+5:end);
vals = sscanf(valued_args,'%f');
if isnan(vals(1))
    error('prt_machine_KernelMTL:WrongArguments',...
        'Argument after -args should be numerical and separated by one white space')
end


if ~isempty(regexp(args,'-s\s+[1]','once')) % Feature learning
    method = Train.rls_mtl_dual('trace');
elseif ~isempty(regexp(args,'-s\s+[2]','once')) % Independent learning
    method = Train.rls_mtl_dual('ind');
elseif ~isempty(regexp(args,'-s\s+[3]','once')) % Variance
    if length(vals)<2 %only one argument, fix gamma
        gamma = 0.01;
    else
        gamma = vals(2);
    end
    A = eye(nt,nt) - gamma*ones(nt,nt);
    [~,p] = chol(A); %check A is psd
    if p
        error('prt_machine_KernelMTL:FixednotPSD',...
            'Fixed relationship matrix A must be positive definite')
    end
    tmp_train_method = Train.rls_mtl_dual('fix');
    method = @(X,Y,lambda) tmp_train_method(X,Y,lambda,A);
end
  
% prepare the learning machine 
lm = LearningMachine;
lm.verbose = false;

% set the output kernel learning modality
lm.setTrain(method);

% call the Train/Test methods
lm.Train(Ktr,d.tr_targets,vals(1));
pred = lm.Test(Kts);

% Need to do take the sign of predictions for classification 
if ~reg   
    predictions = cell(1,nt);
    for t = 1:nt
        pred{t} = sign(pred{t});
        c1PredIdx        = pred{t}==1; 
        pred{t}(c1PredIdx)  = 1; %positive values = 1 
        pred{t}(~c1PredIdx) = 2; %negative values = 2 
        predictions{t} = pred{t};
    end
else
    predictions = pred;
end


% Outputs
%--------------------------------------------------------------------------
% check if training succeeded:
if isempty(lm.internal_params) || ~nnz(lm.internal_params.C)
    error('prt_machine_MTL_MALSAR:MALSARtrainUnsuccessful',['Error:'...
        ' Kernel MTL machine function did not run properly!' ...
        ' This could be a problem with the supplied function arguments'...
        ' ' num2str(args) '']);
end

output.predictions = predictions;
output.func_val    = predictions;
output.alpha       = lm.internal_params.C;
% Get extra outputs for specific algorithms
if ~isempty(lm.internal_params.A)
    output.others.A = lm.internal_params.A; 
end

% Compute primal weights as non-kernel machine for PRoNTo
primalw = output.alpha'*Xtmp';
output.w = primalw(:,1:end-1)';
output.b = primalw(:,end)';

end

% Argiryiou and Pontil's code
% % Define method for computing f(D)
% function v = vec_inv(d)
%     v = zeros(length(d),1);
%     ind = find(d > eps);
%     v(ind) = 1 ./ d(ind);
% end
% 
% 
% trainx = [];
% trainy = [];
% index_train = zeros(nt,1);
% cnt = 1;
% %Machine specific inputs
% for t = 1:nt
%     if ~reg
%         % Change targets to be +1/-1
%         c2 = d.tr_targets{t}==2;
%         d.tr_targets{t}(c2) = -1;
%     end
%     % Change from cell array to matrix for training
%     trainx = [trainx,d.train{t}'];
%     trainy = [trainy;d.tr_targets{t}];
%     index_train(t) = cnt;
%     cnt = cnt+ size(d.train{t},1);
% end
%[W,P] = train_alternating(trainx,trainy,task_indexes,gamma,Dini,iterations,...
%    method,kernel_method,@vec_inv, @(b)(b/sum(b)));
% predictions = cell(1,nt);
% func_val = cell(1,nt);
% for t = 1:nt
%     if ~ reg
%         func_val{t} = d.test{t} * W(:, t) + C(t);
%         pred = sign(func_val{t});
%         % change predictions from 1/-1 to 1/2 
%         c1PredIdx               = pred==1; 
%         pred(c1PredIdx)  = 1; %positive values = 1 
%         pred(~c1PredIdx) = 2; %negative values = 2 
%         predictions{t} = pred;
%     else
%         func_val{t} = d.test{t} * W(:, t);
%         predictions{t} = func_val{t};
%     end
%     
% end