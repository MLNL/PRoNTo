function output = prt_machine_L1svm(d,args)
% Function to run binary L1 SVM. Wrapper for LIBLINEAR.
%
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
%    args     - libSVM arguments
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

%Turn the value of the C hyper-parameter into the arguments format for LIBSVM
if ~ischar(args)
    def = prt_get_defaults('model');
    args = [def.libl1svmargs, num2str(args)];
end

if SANITYCHECK==true
    % args should be a string (empty or otherwise)
    if ~ischar(args)
        error('prt_machine_L1svm:liblinearargsNotString',['Error: liblinear'...
            ' args should be a string. ' ...
            ' SOLUTION: Please do XXX']);
    end
    
    % check we can reach the binary library
    if ~exist('train','file')
        error('prt_machine_L1svm:libNotFound',['Error:'...
            ' liblinear train function could not be found !' ...
            ' SOLUTION: Please check your path.']);
    end
    % check it is indeed a two-class classification problem
    uTL=unique(d.tr_targets(:));
    nC=numel(uTL);
    if nC>2
        error('prt_machine_L1svm:problemNotBinary',['Error:'...
            ' This machine is only for two-class problems but the' ...
            ' current problem has ' num2str(nC) ' ! ' ...
            'SOLUTION: Please select another machine than ' ...
            'prt_machine_svm_bin in XXX']);
    end
    % check it is indeed labelled correctly (probably should be done 
    if ~all(uTL==[1 2]')
        error('prt_machine_L1svm:LabellingIncorect',['Error:'...
            ' This machine needs labels to be in {1,2} ' ...
            ' but they are ' mat2str(uTL) ' ! ' ...
            'SOLUTION: Please relabel your classes by changing the '...
            ' ''tr_targets'' argument to prt_machine_L1svm']);
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


% Run SVM
%--------------------------------------------------------------------------
nlbs  = length(d.tr_targets);
allids_tr = (1:nlbs)';

if contains(args,'-s 5')
    model = train(d.tr_targets,sparse(d.train{:}),args);
else
    model = train(d.tr_targets,d.train{:},args);
end
% model = train(d.tr_targets,[allids_tr d.train{:}],args);

% check if training succeeded:
if isempty(model)
    if (ischar(args))
        args_str = args;
    else
        args_str = '';
    end
    error('prt_machine_L1svm:liblineartrainUnsuccessful',['Error:'...
        ' liblinear train function did not run properly!' ...
        ' This could be a problem with the supplied function arguments'...
        ' ' args_str '']);
end

if contains(args,'-s 5')
    [predictions,~,func_val] = predict(d.te_targets,sparse(d.test{:}),model,'-q');
else
    [predictions,~,func_val] = predict(d.te_targets,d.test{:},model,'-q');
end
% Get SV coefficients (alpha) in the original order and the bias term (b) 
% sgn   = -1*(2 * model.Label(1) - 3); %variable to account for label convention in PRoNTo
% alpha = get_alpha(model,nlbs,sgn);
% b     = -model.rho *sgn;
% 
% % compute prediction directly rather than using svmpredict, which does
% % not allow empty test labels
% if iscell(d.test)
%     func_val = cell2mat(d.test)*alpha+b;
% else
%     func_val = d.test*alpha+b;
% end

% OR
% primal
% func_val = model.w*cell2mat(d.test)'+model.bias;
% % compute hard decisions
% predictions = sign(func_val);
% % change predictions from 1/-1 to 1/2 
% c1PredIdx               = predictions==1; 
% predictions(c1PredIdx)  = 1; %positive values = 1 
% predictions(~c1PredIdx) = 2; %negative values = 2 


% Outputs
%--------------------------------------------------------------------------
output.predictions = predictions;
output.func_val    = func_val;
output.type        = 'classifier';
output.w           = model.w(1:end-1)';
output.b           = model.w(end);
% output.totalSV     = model.totalSV;

end

% Get SV coefficients
%--------------------------------------------------------------------------
function alpha = get_alpha(model,n,sgn)
% needs a function because examples can be re-ordered by libsvm
alpha = zeros(n,1);

for i = 1:model.totalSV
    ind        = model.SVs(i);
    alpha(ind) = model.sv_coef(i);
end

alpha = sgn*alpha;

end

