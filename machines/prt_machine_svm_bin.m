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
%    output  - output of machine (struct). Mandatory fields:
%      .predictions - predictions of classification or regression [Nte x D]
%__________________________________________________________________________
% Copyright (C) 2011 PRoNTo

%--------------------------------------------------------------------------
% Written by M.J.Rosa, J.Mourao-Miranda and J.Richiardi
% $Id$

% FIXME: support for multiple kernels / feature representations 
% is not yet tested, there might be transposition or dimensionality errors.

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
            ' SOLUTION: Please check your path XXX']);
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

% Run SVM
%--------------------------------------------------------------------------
nlbs  = length(tr_lbs);
model = svmtrain(tr_lbs,[(1:nlbs)' train{:}],args);

% check if training succeeded:
if isempty(model)
    error('prt_machine_svm_bin:libSVMsvmtrainUnsuccessful',['Error:'...
        ' libSVM svmtrain function did not run properly!']);
end

alpha = get_alpha(model,nlbs);
b     = -model.rho * model.Label(1);
% compute prediction directly rather than using svmpredict, which does
% not allow empty test labels
if iscell(test)
    predictions = cell2mat(test)*alpha+b;
else
    predictions = test*alpha+b;
end
alpha       = model.Label(1)*alpha;

% Outputs
%--------------------------------------------------------------------------
output.predictions = predictions;
output.type        = 'classifier';
output.alpha       = alpha;
output.b           = b;
output.totalSV     = model.totalSV;

end

% Get SV coefficients
%--------------------------------------------------------------------------
function alpha = get_alpha(model,n)

alpha = zeros(n,1);

for i = 1:model.totalSV
    ind        = model.SVs(i);
    alpha(ind) = model.sv_coef(i);
end
alpha = model.Label(1)*alpha;

end

