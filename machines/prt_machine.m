function output = prt_machine(train,test,tr_lbs,machine)
% Run machine function for classification or regression
% FORMAT output = prt_machine(train,test,tr_lbs,machine)
% Inputs:
%    train   - training data (cell array of matrices of row vectors, each
%              [Ntr x D]). each matrix contains one representation of the
%              data. This is useful for approaches such as multiple kernel
%              learning.
%    test    - testing data  (cell array of matrices row vectors, each
%              [Nte x D])
%    tr_lbs  - training labels (column vector, [Ntr x 1])
%    machine - structure with information about the classification or
%              regression machine to use
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

% TODO: make tr_lbs a cell array

SANITYCHECK=true; % can turn off for "speed"

% make sure labels are column vectors
tr_lbs = tr_lbs(:);

if SANITYCHECK==true
% Initial checks
%--------------------------------------------------------------------------
% Check machine properties
if ~isempty(machine)
    if isstruct(machine)
        if isfield(machine,'function')
            if ~exist(machine.function,'file')
                error('prt_model:machineFunctionFileNotFound',...
                    ['Error: %s function could not be found!'],...
                    machine.function);
            end
        else 
            error('prt_model:machineFunctionFieldNotFound',...
                ['Error: machine structure should contain'...
                ' ''.function'' field!']);
        end
        if ~isfield(machine,'args')
            error('prt_model:argsFieldNotFound',...
                ['Error: machine structure should contain' ...
                ' ''.args'' field!']);
        end       
    else
        error('prt_model:machineNotStruct',...
            'Error: machine should be a structure!');
    end
else
    error('prt_model:machineStructEmpty',...
    'Error: machine cannot be empty!');
end

% Check labels properties
if ~isempty(tr_lbs)
    if isvector(tr_lbs)
        Ntrlbs = length(tr_lbs);
    else
        error('prt_model:trainingLabelsNotVector',...
            'Error: training labels should be a vector!');
    end
else
    error('prt_model:trainingLabelsEmpty',...
        'Error: training labels cannot be empty!');
end

if isempty(train) || isempty(test),
    error('prt_model:TrAndTeEmpty',...
        'Error: training and testing data cannot be empty!');
else
    if ~iscell(train) || ~iscell(test),
    error('prt_model:TrAndTeEmpty',...
        'Error: training and testing data should be cell arrays!'); 
    end
end

% Check data properties
Nktr   = length(train);
Nkte   = length(test);
if ~(Nktr==Nkte)
    error('prt_model:NktrNotEqNkte',['Error: Number of training '...
        'and testing datasets should match, but Nktr=%d and Nkte=%d !'],...
        Nktr, Nkte);
end

% Check datasets properties
for k = 1:Nktr,
    if ~isempty(train{k}) && ~isempty(test{k})
        if ~ismatrix(train{k}) || ~ismatrix(test{k})
            error('prt_model:TrAndTeNotMatrices',...
               'Error: training and testing datasets should be matrices!'); 
        end
    else
        error('prt_model:TrAndTeEmpty',...
            'Error: training and testing datasest cannot be empty!');
    end   
    % check dimensions
    [Ntr Dtr] = size(train{k});
    [Nte Dte] = size(test{k});
    % 1: feature space dimension should be equal
    if ~(Dtr==Dte)
        error('prt_model:DtrNotEqDte',['Error: Training and testing '...
            'dimensions should match, but Dtr=%d and Dte=%d for '...
            'dataset %d!'],Dtr,Dte,k); 
    end
    % 2: check we have as many training labels as examples
    if ~(Ntrlbs==Ntr)
        error('prt_model:NtrlbsNotEqNtr',['Error: Number of training '...
            'examples and training labels should match, but Ntrlbs=%d '...
            'and Ntr=%d for dataset %d!'],Ntrlbs,Ntr,k);
    end
end
end % SANITYCHECK

% Run model
%--------------------------------------------------------------------------
fnc    = inline([machine.function,'(train,test,tr_lbs,args)'],'train',...
    'test','tr_lbs','args');
output = feval(fnc,train,test,tr_lbs,machine.args);

if SANITYCHECK==true
% Final checks
%--------------------------------------------------------------------------
% Check output properties
if ~isfield(output,'predictions');
    error('prt_model:outputNoPredictions',['Output of machine should '...
        'contain the field ''.predictions''.']);
else
    if (size(output.predictions,1)~= Nte)
        error('prt_model:outputNpredictionsNotEqNte',['Error: Number '...
            'of predictions output and number of test examples should '...
            'match, but Npre=%d and Nte=%d !'],...
            size(output.predictions,1),Nte);
    end
end

end % SANITYCHECK on output

end

