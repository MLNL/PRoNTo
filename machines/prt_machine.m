function output = prt_machine(train,test,testcov,tr_labels,machine)
% Run machine function for classification or regression
% FORMAT output = prt_machine(train,test,testcov,tr_labels,machine)
% Inputs:
%    train     - training data (cell array of matrices of row vectors, each
%                [Ntr x D]). each matrix contains one representation of the
%                data. This is useful for approaches such as multiple 
%                kernel learning.
%    test      - testing data  (cell array of matrices row vectors, each
%                [Nte x D])
%    testcov   - test covariance matrix (optional) (only valid for kernel 
%                methods (cell array of matrices of row vectors, each
%                [Nte x Nte])
%    tr_labels - training labels (column vector, [Ntr x 1])
%    machine   - structure with information about the classification or
%                regression machine to use
%      .function - function for classification or regression (string)       
%      .args     - function arguments (either a string, a matrix, or a
%                  struct). This is specific to each machine, e.g. for 
%                  an L2-norm linear SVM this could be the C parameter
% Output:
%    output  - output of machine (struct).
%       Mandatory fields:
%       .predictions - predictions of classification or regression
%                      [Nte x D]
%       Optional fields: the machine is responsible for returning
%       parameters of interest. For exemple for an SVM this could be the
%       number of support vector used in the hyperplane weights computation
%__________________________________________________________________________
% Copyright (C) 2011 PRoNTo

%--------------------------------------------------------------------------
% Written by M.J.Rosa and J.Richiardi
% $Id$

% TODO: make tr_labels a cell array

SANITYCHECK = true; % can turn off for "speed"

% make sure labels are column vectors
tr_labels   = tr_labels(:);

% check if data is kernel and testcov is emprty
dataiskernel = machine.dataiskernel;
existcov     = ~isempty(testcov);

if SANITYCHECK==true
% Initial checks
%--------------------------------------------------------------------------
% Check machine properties
if ~isempty(machine)
    if isstruct(machine)
        if isfield(machine,'function')
            if ~exist(machine.function,'file')
                error('prt_machine:machineFunctionFileNotFound',...
                    ['Error: %s function could not be found!'],...
                    machine.function);
            end
        else 
            error('prt_machine:machineFunctionFieldNotFound',...
                ['Error: machine structure should contain'...
                ' ''.function'' field!']);
        end
        if ~isfield(machine,'args')
            error('prt_machine:argsFieldNotFound',...
                ['Error: machine structure should contain' ...
                ' ''.args'' field!']);
        end       
    else
        error('prt_machine:machineNotStruct',...
            'Error: machine should be a structure!');
    end
else
    error('prt_machine:machineStructEmpty',...
    'Error: machine cannot be empty!');
end

% Check labels properties
if ~isempty(tr_labels)
    if isvector(tr_labels)
        Ntrain_lbs = length(tr_labels);
    else
        error('prt_machine:trainingLabelsNotVector',...
            'Error: training labels should be a vector!');
    end
else
    error('prt_machine:trainingLabelsEmpty',...
        'Error: training labels cannot be empty!');
end

if isempty(train) || isempty(test),
    error('prt_machine:TrAndTeEmpty',...
        'Error: training and testing data cannot be empty!');
else
    if ~iscell(train) || ~iscell(test),
    error('prt_machine:TrAndTeEmpty',...
        'Error: training and testing data should be cell arrays!'); 
    end
end

% Check data properties
Nk_train   = length(train);
Nk_test    = length(test);
if existcov,
    if ~iscell(testcov)
        error('prt_machine:TestCovNotCell',...
            'Error: Test covariance matrix should be a cell array!');
    else
        Nk_cov = length(testcov);
    end
    if ~(Nk_train==Nk_test==Nk_cov)
        error('prt_machine:NktrNkteNkcovNotEq',['Error: Number of training '...
            'and testing datasets should match, but Nktr=%d, Nkte=%d '
            'and Ncov=&d!'],Nk_train, Nk_test, Nk_cov);
    else
        if ~(Nk_train==Nk_test)
            error('prt_machine:NktrNotEqNkte',['Error: Number of training '...
                'and testing datasets should match, but Nktr=%d and Nkte=%d !'],...
                Nk_train, Nk_teat);
        end
    end
end

% Check datasets properties
for k = 1:Nk_train,
    if ~isempty(train{k}) && ~isempty(test{k})
        if ~ismatrix(train{k}) || ~ismatrix(test{k})
            error('prt_machine:TrAndTeNotMatrices',...
               'Error: training and testing datasets should be matrices!'); 
        end
    else
        error('prt_machine:TrAndTeEmpty',...
            'Error: training and testing datasest cannot be empty!');
    end   
    % check dimensions
    [Ntrain Dtrain] = size(train{k});
    [Ntest, Dtest]  = size(test{k});
    % 1: feature space dimension should be equal
    if ~(Dtrain==Dtest)
        error('prt_machine:DtrNotEqDte',['Error: Training and testing '...
            'dimensions should match, but Dtrain=%d and Dtest=%d for '...
            'dataset %d!'],Dtrain,Dtest,k); 
    end
    % 2: check we have as many training labels as examples
    if ~(Ntrain_lbs==Ntrain)
        error('prt_machine:NtrlbsNotEqNtr',['Error: Number of training '...
         'examples and training labels should match, but Ntrain_lbs=%d '...
         'and Ntrain=%d for dataset %d!'],Ntrlbs,Ntr,k);
    end
    % 3: if kernel check for kernel properties
    if dataiskernel
        if ~(Ntrain==Dtrain)
            error('prt_machine:NtrainNotEqDtrain',['Error: Training '...
                'dimensions should match, but Ntr=%d and Dtr=%d for '...
                'dataset %d!'],Ntrain,Dtrain,k);
        end
        if ~(Dtest==Ntrain)
            error('prt_machine:DtestNotEqNtrain',['Error: Testing '...
                'dimensions should match, but Dte=%d and Ntr=%d for '...
                'dataset %d!'],Dtest,Ntrain,k);
        end
        if existcov
            [Ncov, Dcov] = size(testcov{k});
            if ~(Ncov==Dcov==Ntest) 
                error('prt_machine:NcovDcovNteNotEq',['Error: Test '...
                    'covariance dimensions should match, but Ncov=%d, '...
                    'Dcov=%d and Nte=%d for dataset %d!'],Ncov,Dcov,...
                    Ntest,k);
            end
        end
        
    end    
end
end % SANITYCHECK

% Run model
%--------------------------------------------------------------------------
fnch   = str2func(machine.function);
% unfortunately old-style error shaking to support Matlab 7.1...
try
    if ~existcov
        output = fnch(train,test,tr_labels,machine.args);
    else
        error('XXX WRAPPER NOT AVAILABLE FOR TESTCOV (GP) MACHINES YET');
        output = fnch(train,test,testcov,tr_labels,machine.args);
    end
catch
    err = lasterror;
    err_ID=lower(err.identifier);
    err_libProblem = strfind(err_ID,'libNotFound');
    if ~isempty(err_libProblem)
        error('prt_machine:libNotFound',['Error: the library for '... 
            'machine %s could not be found on your path. ' ...
            'SOLUTION: Please XXX]',machine.function);
    else
        % we don't know what more to do here, pass it up
        error('prt_machine:otherProblem','%s %s',erridentifier,...
            err.message);
    end
end

% Final checks
%--------------------------------------------------------------------------
if SANITYCHECK==true

% Check output properties
if ~isfield(output,'predictions');
    error('prt_machine:outputNoPredictions',['Output of machine should '...
        'contain the field ''.predictions''.']);
else
    if (size(output.predictions,1)~= Ntest)
        error('prt_machine:outputNpredictionsNotEqNte',['Error: Number '...
            'of predictions output and number of test examples should '...
            'match, but Npre=%d and Nte=%d !'],...
            size(output.predictions,1),Ntest);
    end
end

end % SANITYCHECK on output

end

