function output = prt_machine_MTL_MALSAR(d,args)
% Run binary SVM - wrapper for LIBLINEAR
% FORMAT output = prt_machine_L1svm(d,args)
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
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Schrouff from prt_machine_svm_bin.m
% $Id$

SANITYCHECK=true; % can turn off for "speed". Expert only.

%Regularization parameter
if isempty(args)
    def = prt_get_defaults('model');
    args = def.MTLargs;
end

if SANITYCHECK==true
%     % args should be a string (empty or otherwise)
%     if ~ischar(args)
%         error('prt_machine_L1svm:liblinearargsNotString',['Error: liblinear'...
%             ' args should be a string. ' ...
%             ' SOLUTION: Please do XXX']);
%     end
    
%     % check we can reach the binary library
%     if ~exist('train','file')
%         error('prt_machine_L1svm:libNotFound',['Error:'...
%             ' liblinear train function could not be found !' ...
%             ' SOLUTION: Please check your path.']);
%     end
    % check it is indeed a two-class classification problem
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
    
    % check we are using the C-SVC (exclude types -s 1,2,3,4)
%     if ~isempty(regexp(args,'-s\s+[1234]','once'))
%         error('prt_machine_svm_bin:argsProblem:onlyCSVCsupport',['Error:'...
%             ' This machine only supports a C-SVC formulation ' ...
%             ' (''-s 0'' in the ''args'' parameter), but the args ' ...
%             ' supplied are ''' args ''' ! ' ...
%             'SOLUTION: Please change the offending part of args to '...
%             '''-s 0''']);
%     end
    
    % check we are using linear or precomputed kernels
    % (exclude types -t 1,2,3)
%     if ~isempty(regexp(args,'-t\s+[123]','once'))
%         error('prt_machine_svm_bin:argsProblem:onlyLinOrPrecomputeSupport',...
%             ['Error: This machine only supports linear or precomputed ' ...
%             'kernels (''-t 0/4'' in the ''args'' parameter), but the args ' ...
%             ' supplied are ''' args ''' ! ' ...
%             'SOLUTION: Please change the offending part of args to '...
%             '''-t 0'' or ''-t 4'' as intended']);
%     end
    
end


% Run Multi-Task in MALSAR
%--------------------------------------------------------------------------
nt  = numel(d.tr_targets);

%Machine specific inputs
for t = 1:nt
    % Change targets to be +1/-1
    c2 = d.tr_targets{t}==2;
    d.tr_targets{t}(c2) = -1;
    % Add bias
%     d.train{t} = [d.train{t}, ones(size(d.train{t},1),1)];
%     d.test{t} = [d.test{t}, ones(size(d.test{t},1),1)];
end

opts.init = 0; % compute start point from data.
opts.tFlag = 1; % terminate after objective value does not changes much.
opts.tol = 10^-5; % tolerance.
opts.maxIter = 1500; % maximum iteration number of optimization.

% [W,C] = Logistic_L21(d.train,d.tr_targets,args,opts);
[W,C] = Logistic_Trace(d.train,d.tr_targets,args,opts);
% [W,C] = Logistic_Lasso(d.train,d.tr_targets,args,opts);


% check if training succeeded:
if isempty(W) || ~nnz(W)
    error('prt_machine_MTL_MALSAR:MALSARtrainUnsuccessful',['Error:'...
        ' MALSAR LogisticL21 function did not run properly!' ...
        ' This could be a problem with the supplied function arguments'...
        ' ' num2str(args) '']);
end

predictions = cell(1,nt);
func_val = cell(1,nt);
for t = 1:nt
    func_val{t} = d.test{t} * W(:, t) + C(t);
    pred = sign(func_val{t});
    % change predictions from 1/-1 to 1/2 
    c1PredIdx               = pred==1; 
    pred(c1PredIdx)  = 1; %positive values = 1 
    pred(~c1PredIdx) = 2; %negative values = 2 
    predictions{t} = pred;
end




% Outputs
%--------------------------------------------------------------------------
output.predictions = predictions;
output.func_val    = func_val;
output.type        = 'classifier';
output.w           = W;
output.b           = C;

end

