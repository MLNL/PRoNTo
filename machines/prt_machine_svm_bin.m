function output = prt_machine_svm_bin(train,test,tr_lbs,args)
% Run binary SVM - wrapper for libSVM
% FORMAT output = prt_machine_svm_bin(train,test,tr_lbs,args)
% Inputs:
%    train   - training data (cell array of matrices of row vectors, each
%              [Ntr x D]). each matrix contains one representation of the
%              data. This is useful for approaches such as multiple kernel
%              learning.
%    test    - testing data  (cell array of matrices row vectors, each
%              [Nte x D])
%    tr_lbs  - training labels (column vector, [Ntr x 1])
%    args    - libSVM arguments
% Output:
%    output  - output of machine (struct).
%     * Mandatory fields:
%      .predictions - predictions of classification or regression [Nte x D]
%     * Optional fields:
%      .func_val - value of the decision function
%      .type     - which type of machine this is (here, 'classifier')
%__________________________________________________________________________
% Copyright (C) 2011 PRoNTo

%--------------------------------------------------------------------------
% Written by M.J.Rosa, J.Mourao-Miranda and J.Richiardi
% $Id$

% FIXME: prediction code not yet tested for feature input case

% FIXME: support for multiple kernels / feature representations
% is not yet tested, there might be transposition or dimensionality errors.

% TODO: check class label coding at input and potentially remap at output

% TODO: maybe also check the prt_machine .usebf argument for compatibility
% with lbSVM syntax ?

% TODO: make sure the svmtrain we reach is the libsvm one, not the one
% with the same name from the bioinformatics toolbox!
% toolbox/bioinfo/biolearning/


SANITYCHECK=true; % can turn off for "speed". Expert only.

if SANITYCHECK==true
    % args should be a string (empty or otherwise)
    if ~ischar(args)
        error('prt_machine_svm_bin:libSVMargsNotString',['Error: libSVM'...
            ' args should be a string. ' ...
            ' SOLUTION: Please do XXX']);
    end
    
    % check we can reach the binary library
    if ~exist('svmtrain','file')
        error('prt_machine_svm_bin:libNotFound',['Error:'...
            ' libSVM svmtrain function could not be found !' ...
            ' SOLUTION: Please check your path.']);
    end
    % check it is indeed a two-class classification problem
    nC=numel(unique(tr_lbs));
    if nC>2
        error('prt_machine_svm_bin:problemNotBinary',['Error:'...
            ' This machine is only for two-class problems but the' ...
            ' current problem has ' num2str(nC) ' !' ...
            'SOLUTION: Please select another machine than ' ...
            'prt_machine_svm_bin in XXX']);
    end
end

% TODO: check/convert labels

if ~isempty(regexp(args,'-t\s+4','once'))
    hasPrecomputedKernel=true;
else
    hasPrecomputedKernel=false;
end

% Run SVM
%--------------------------------------------------------------------------
nlbs  = length(tr_lbs);
if hasPrecomputedKernel
    allids=(1:nlbs)';
else
    allids=[];
end
model = svmtrain(tr_lbs,[allids train{:}],args);

% check if training succeeded:
if isempty(model)
    if (ischar(args))
        args_str=args;
    else
        args_str='';
    end
    error('prt_machine_svm_bin:libSVMsvmtrainUnsuccessful',['Error:'...
        ' libSVM svmtrain function did not run properly!' ...
        ' This could be a problem with the supplied function arguments'...
        ' ' args_str '']);
end
b     = -model.rho * model.Label(1);

if hasPrecomputedKernel
    alpha = get_alpha(model,nlbs);
else
    alpha=model.sv_coef;    % recover alphas directly
    SVs=model.SVs;          % recover also the SV's themselves
end

% compute prediction directly rather than using svmpredict, which does
% not allow empty test labels
if hasPrecomputedKernel
    if iscell(test)
        func_val = cell2mat(test)*alpha+b;
    else
        func_val = test*alpha+b;
    end
else
    % compute primal weight vector
    w=SVs'*alpha;
    % compute function
    if iscell(test)
        func_val=cell2mat(test)*w+b;
    else
        func_val=test*w+b;
    end
end

% compute hard decisions
predictions=sign(func_val);

% TODO: convert labels to 

% Outputs
%--------------------------------------------------------------------------
output.predictions = predictions;
output.func_val    = func_val;
output.type        = 'classifier';
output.alpha       = alpha;
output.b           = b;
output.totalSV     = model.totalSV;
if exist('w','var')==1
    output.w=w;
end

end

% Get SV coefficients
%--------------------------------------------------------------------------
function alpha = get_alpha(model,n)
% needs a function because examples can be re-ordered by libsvm
alpha = zeros(n,1);

for i = 1:model.totalSV
    ind        = model.SVs(i);
    alpha(ind) = model.sv_coef(i);
end
alpha = model.Label(1)*alpha;

end

