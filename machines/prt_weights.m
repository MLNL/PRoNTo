function weights = prt_weights(PRT,model,wfunc)
% Run function to compute weights
% FORMAT weights = prt_weights(PRT,model,wfunc)
% Inputs:
%       PRT     - PRT data structure (must contain fields .fs and .model)
%       model   - index of model to be used (integer)
%       wfunc   - function to compute weights (string)
% Output:
%       weights - filename of 4d image with weights (string)
%__________________________________________________________________________
% Copyright (C) 2011 PRoNTo

%--------------------------------------------------------------------------
% Written by M.J.Rosa and J.Mourao-Miranda
% $Id: prt_weitghts.m $

SANITYCHECK = true; % turn off for speed

% Initial checks
%--------------------------------------------------------------------------
if SANITYCHECK == true
    if ~isinteger(int8(model))
        error('prt_weights:modelIsNotInteger',['Error: ''model'' input '...
            'should be an integer indexing the model to use.']);
    end    
    if ~isempty(PRT)
        if isstruct(PRT)
            if ~isfield(PRT,'fs')
                    error('prt_weights:fsFieldNotFound',...
                        ['Error: PRT structure must contain ''.fs'' field '...
                        'with feature set']);
            end
            if isfield(PRT,'model')
                if ~isfield(PRT.model(model),'input')
                    error('prt_weights:inputFieldNotFound',...
                        ['Error: PRT.model must contain ''.input'' '...
                        'field with inputs provided to the model.']);
                end
                if ~isfield(PRT.model(model),'output')
                    error('prt_weights:outputFieldNotFound',...
                        ['Error: PRT.model must contain ''.output'' '...
                        'field with results.']);
                end
            else
                error('prt_weights:modelFieldNotFound',...
                    ['Error: PRT structure must contain ''.model'' field '...
                    'with model']);
            end
        else
            error('prt_weights:PRTnotStruct',['Error: ''PRT'' should '...
                'be a structure!']);
        end
    else
        error('prt_weigths:PRTstructEmpty',...
            'Error: ''PRT'' cannot be empty!');
    end
end

% Run weights
%--------------------------------------------------------------------------
fnch    = str2func(wfunc);
weights = fnch(PRT,model);

% Final checks
%--------------------------------------------------------------------------
if SANITYCHECK == true
    if ~ischar(weights)
        error('prt_weights:weightsIsNotString',['Error: ''weights'' '...
            'should be a string with file name of weights.']);
    else
        if ~exist(weights,'file')
            error('prt_weights:weightsFileNotFound',['Error: %s file '...
                'not found!',weigths]);
        end
    end
end