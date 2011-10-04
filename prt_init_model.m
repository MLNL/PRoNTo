function [mid, PRT] = prt_init_model(PRT, in)
% function to initialise the model data structure
%
% FORMAT: Two modes are possible: 
%     mid = prt_init_model(PRT, in)
%     [mid, PRT] = prt_init_model(PRT, in)
%
% USAGE 1:
% ------------------------------------------------------------------------
% function will return the id of a model or an error if it doesn't 
% exist in PRT.mat
% Input:
% ------
% in.model_name: name of the model (string)
%
% Output:
% -------
% mid : is the identifier for the model in PRT.mat
%
% USAGE 2: 
% -------------------------------------------------------------------------
% function will create the model in PRT.mat and overwrite it if it
% already exists.
%
% Input:
% ------
% in.model_name: name of the model to be created (string)
% in.cv_name:    name of the cross-validation structure to use (string)
% in.targets:    vector of targets (nSamples x 1) 
% in.usebf:      use basis functions for this model (boolean)
% in.machine:    prediction machine to use for this model (struct)
%
% Output:
% -------
% Populates the following fields in PRT.mat (copied from above):
% PRT.model(m).model_name 
% PRT.model(m).input.cv_name 
% PRT.model(m).input.targets
% PRT.model(m).input.usebf
% PRT.model(m).input.machine
%
% Note: this function does not write PRT.mat. That should be done by the
%       calling function
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A. Marquand 

% find model index
model_exists = false;
if isfield(PRT,'model')
    if any(strcmpi(in.model_name,{PRT.model(:).model_name}))
        mid = find(strcmpi(in.model_name,{PRT.model(:).model_name}));
        model_exists = true;
    else
        mid = length(PRT.model)+1;
    end
else
    mid = 1;
end

% do we want to create fields in PRT.mat?
if nargout == 1
    if model_exists
        % just display message and exit (returning id)
        disp(['Model ''',in.model_name,''' found in PRT.mat.']);
    else
        error('prt_init_model:modelNotFoundinPRT',...
            ['Model ''',in.model_name,''' not found in PRT.mat.']);
    end
else
    % initialise
    if model_exists
        warning('prt_init_model:modelAlreadyInPRT',['Model ''',in.model_name,...
            ''' already exists in PRT.mat. Overwriting...']);
    else
        disp(['Model ''',in.model_name,''' not found in PRT.mat. Creating...'])
    end
    % always overwrite the model
    PRT.model(mid).model_name    = in.model_name;
    PRT.model(mid).input.cv_name = in.cv_name;
    PRT.model(mid).input.targets = in.targets;
    PRT.model(mid).input.usebf   = in.usebf;
    PRT.model(mid).input.machine = in.machine;
end

end