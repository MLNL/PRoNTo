function output = prt_machine(d,m)
% Run machine function for classification or regression
% FORMAT output = prt_machine(d,m)
% Inputs:
%   d         - structure with information about the data, with fields:
%    .train    - training data (cell array of matrices of row vectors,
%                each [Ntr x D]). each matrix contains one representation
%                of the data. This is useful for approaches such as
%                multiple kernel learning.
%    .test     - testing data  (cell array of matrices row vectors, each
%                [Nte x D])
%    .testcov  - test covariance matrix (optional) (only valid for kernel
%                methods) (cell array of matrices of row vectors, each
%                [Nte x Nte])
%    .tr_targets - training labels (for classification) or values (for
%                  regression) (column vector, [Ntr x 1])
%    .usebf  - flag, is data in form of kernel matrices (true) of in form
%                of features (false)
%   m          - structure with information about the classification or
%                regression machine to use, with fields:
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

% TODO: make tr_targets a cell array (?)
% TODO: fix 80-cols limit in source code

SANITYCHECK = true; % can turn off for "speed"

%% INPUT CHECKS
%--------------------------------------------------------------------------
if SANITYCHECK==true
    % Check machine struct properties
    if ~isempty(m)
        if isstruct(m)
            if isfield(m,'function')
                % TODO: This case maybe needs more cautious handling
                if ~exist(m.function,'file')
                    error('prt_machine:machineFunctionFileNotFound',...
                        ['Error: %s function could not be found!'],...
                        m.function);
                end
            else
                error('prt_machine:machineFunctionFieldNotFound',...
                    ['Error: machine structure should contain'...
                    ' ''.function'' field!']);
            end
            if ~isfield(m,'args')
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
            'Error: ''machine'' struct cannot be empty!');
    end
    
    %----------------------------------------------------------------------
    % Check data struct properties
    if ~isempty(d)
        % 1: BASIC: check all mandatory fields exist so we can relax later
        if ~isfield(d,'train')
            error('prt_machine:noTrainField',...
                ['Error: ''data'' struct must contain a ''train'' '...
                ' field!']);
        end
        if ~isfield(d,'test')
            error('prt_machine:noTestField',...
                ['Error: ''data'' struct must contain a ''test'' '...
                ' field!']);
        end
        if ~isfield(d,'tr_targets')
            error('prt_machine:noTargetsField',...
                ['Error: ''data'' struct must contain a ''tr_targets'' '...
                ' field!']);
        end
        if ~isfield(d,'usebf')
            error('prt_machine:noUsebfField',...
                ['Error: ''data'' struct must contain a ''usebf'' '...
                ' field!']);
        end
        
        % 2: BASIC: check datatype of train/test sets
        if isempty(d.train) || isempty(d.test),
            error('prt_machine:TrAndTeEmpty',...
                'Error: training and testing data cannot be empty!');
        else
            if ~iscell(d.train) || ~iscell(d.test),
                error('prt_machine:TrAndTeEmpty',...
                    'Error: training and testing data should be cell arrays!');
            end
        end
        
        % 3: BASIC: check datatypes of labels
        if ~isempty(d.tr_targets)
            if isvector(d.tr_targets)
                % force targets to column vectors
                d.tr_targets   = d.tr_targets(:);
                Ntrain_lbs = length(d.tr_targets);
            else
                error('prt_machine:trainingLabelsNotVector',...
                    'Error: training labels should be a vector!');
            end
        else
            error('prt_machine:trainingLabelsEmpty',...
                'Error: training labels cannot be empty!');
        end
        
        % 4: BASIC: check if testcov is empty
        if isfield(d,'testcov')
            existcov     = ~isempty(d.testcov);
            if (existcov && (d.usebf == false))
                warning('prt_machine:tescovOnlyWithKernelMethods',...
                    ['Warning: A test covariance matrix can only be ' ...
                    ' provided when using kernel methods! The usebf flag ' ...
                    ' should be set.']);
            end
        else
            existcov = false;
        end
        
        % 5: Check data properties (over cells)
        Nk_train   = length(d.train);
        Nk_test    = length(d.test);
        if existcov,
            if ~iscell(d.testcov)
                error('prt_machine:TestCovNotCell',...
                    'Error: Test covariance matrix should be a cell array!');
            else
                Nk_cov = length(d.testcov);
            end
            if ~(Nk_train==Nk_test==Nk_cov)
                error('prt_machine:NktrNkteNkcovNotEq', ...
                    ['Error: Number of training and testing datasets should ' ...
                    'match, but Nktr=%d, Nkte=%d and Ncov=%d!'],...
                    Nk_train, Nk_test, Nk_cov);
            else
                if ~(Nk_train==Nk_test)
                    error('prt_machine:NktrNotEqNkte',['Error: Number of training '...
                        'and testing datasets should match, but Nktr=%d and Nkte=%d !'],...
                        Nk_train, Nk_teat);
                end
            end
        end
        
        % 6: Check datasets properties (within cells)
        for k = 1:Nk_train,
            if ~isempty(d.train{k}) && ~isempty(d.test{k})
                if ~ismatrix(d.train{k}) || ~ismatrix(d.test{k})
                    error('prt_machine:TrAndTeNotMatrices',...
                        'Error: training and testing datasets should be matrices!');
                end
            else
                error('prt_machine:TrAndTeEmpty',...
                    'Error: training and testing datasest cannot be empty!');
            end
            % check dimensions
            [Ntrain Dtrain] = size(d.train{k});
            [Ntest, Dtest]  = size(d.test{k});
            % a: feature space dimension should be equal
            if ~(Dtrain==Dtest)
                error('prt_machine:DtrNotEqDte',['Error: Training and testing '...
                    'dimensions should match, but Dtrain=%d and Dtest=%d for '...
                    'dataset %d!'],Dtrain,Dtest,k);
            end
            % b: check we have as many training labels as examples
            if ~(Ntrain_lbs==Ntrain)
                error('prt_machine:NtrlbsNotEqNtr',['Error: Number of training '...
                    'examples and training labels should match, but Ntrain_lbs=%d '...
                    'and Ntrain=%d for dataset %d!'],Ntrlbs,Ntr,k);
            end
            % c: if kernel check for kernel properties
            if d.usebf
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
                    [Ncov, Dcov] = size(d.testcov{k});
                    if ~((Ncov==Dcov) && (Ncov==Ntest) && (Dcov==Ntest))
                        error('prt_machine:NcovDcovNteNotEq',['Error: Test '...
                            'covariance dimensions should match, but Ncov=%d, '...
                            'Dcov=%d and Nte=%d for dataset %d!'],Ncov,Dcov,...
                            Ntest,k);
                    end
                end
                
            end
        end
    else
        error('prt_machine:dataStructEmpty',...
            'Error: data struct cannot be empty!');
    end
end % SANITYCHECK

%% Run model
%--------------------------------------------------------------------------
fnch   = str2func(m.function);
% unfortunately old-style error checking to support Matlab 7.1...
try
    if ~existcov
        output = fnch(d.train,d.test,d.tr_targets,m.args);
    else
        error('XXX WRAPPER NOT AVAILABLE FOR TESTCOV (GP) MACHINES YET');
        output = fnch(d.train,d.test,d.testcov,tr_targets,m.args);
    end
catch
    err = lasterror;
    err_ID=lower(err.identifier);
    err_libProblem = strfind(err_ID,'libnotfound');
    err_argsProblem = strfind(err_ID,'argsproblem');
    disp('prt_machine: machine did not run sucessfully.');
    if ~isempty(err_libProblem)
        error('prt_machine:libNotFound',['Error: the library for '...
            'machine %s could not be found on your path. ' ...
            'SOLUTION: Please XXX'],m.function);
    elseif ~isempty(err_argsProblem)
        disp(['Error: the arguments supplied '...
            ' are invalid. ' ...
            'SOLUTION: Please follow the advice given by the machine.']);
        error('prt_machine:argsProblem',...
            ['** Error running machine %s: %s %s ** '], ...
            m.function,err.identifier,err.message);
    else
        % we don't know what more to do here, pass it up
        disp(['SOLUTION: Please read the message below and attempt to' ...
            ' correct the problem, or ask the developpers for ' ...
            'assistance by copy-pasting all messages and explaining the'...
            ' exact steps that led to the problem.']);
        disp(['This kinds of issues are typically caused by Matlab '...
            'path problems.']);
        for en=numel(err.stack):-1:1
            e=err.stack(en);
            fprintf('%d : function [%s] in file [%s] at line [%d]\n',...
                en,e.name,e.file,e.line);
        end
        error('prt_machine:otherProblem',...
            ['** Error running machine %s: %s %s ** '], ...
            m.function,err.identifier,err.message);
    end
end

%% OUTPUT CHECKS
%--------------------------------------------------------------------------
if SANITYCHECK==true
    
    % Check output properties
    if ~isfield(output,'predictions');
        error('prt_machine:outputNoPredictions',['Output of machine should '...
            'contain the field ''.predictions''.']);
    else
        % FIXME: multiple kernels / feature representations is unsupported
        % here
        if (size(output.predictions,1)~= Ntest)
            error('prt_machine:outputNpredictionsNotEqNte',['Error: Number '...
                'of predictions output and number of test examples should '...
                'match, but Npre=%d and Nte=%d !'],...
                size(output.predictions,1),Ntest);
        end
    end
    
end % SANITYCHECK on output

end

