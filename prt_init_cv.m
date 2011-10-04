function [cid, PRT] = prt_init_cv(PRT, in)
% function to initialise a cv data structure
%
% FORMAT: Two modes are possible: 
%     cid = prt_init_cv(PRT, in)
%     [cid, PRT] = prt_init_cv(PRT, in)
%
% USAGE 1:
% -------------------------------------------------------------------------
% function will return the id of a cv structure or an error if it doesn't 
% exist in PRT.mat
% Input:
% ------
% in.cv_name: name of the cv structure (string)
%
% Output:
% -------
% cid : is the identifier for the cv structure in PRT.mat
%
% USAGE 2: 
% -------------------------------------------------------------------------
% function will create the cv structure in PRT.mat and overwrite it if it
% already exists.
%
% Input:
% ------
% in.cv_name:    name of the cross-validation structure to create (string)
% in.cv_mat:     cross-validation matrix (nSamples x nFolds matrix)
% in.fs_name:    name of the feature set to use for this CV struct (string)
% in.fs_indices: indices of samples in the feature set to include (vector)
%
% Output:
% -------
% Populates the following fields in PRT.mat (copied from above):
% PRT.cv(cid).cv_name
% PRT.cv(cid).cv_mat    
% PRT.cv(cid).fs_name  
% PRT.cv(cid).fs_indices
%
% Note: this function does not write PRT.mat. That should be done by the
%       calling function
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A. Marquand 

% find index for cross-validation structure
cv_exists = false;
if isfield(PRT,'cv')
    if any(strcmpi(in.cv_name,{PRT.cv(:).cv_name}))
        cid = find(strcmpi(in.cv_name,{PRT.cv(:).cv_name}));
        cv_exists = true;
    else
        cid = length(PRT.cv)+1;
    end
else
    cid = 1;
end

if nargout == 1
    if cv_exists
        disp(['CV structure ''',in.cv_name,''' found in PRT.mat.']);
    else
        error('prt_init_cv:cvNotFoundInPRT',...
            ['CV structure ''',in.cv_name,''' not found in PRT.mat.'])
    end    
else
    if cv_exists
        warning('prt_init_cv:cvAlreadyInPRT',...
            ['CV structure ''',in.cv_name,''' found in PRT.mat. Overwriting...']);
    else
        disp(['CV structure ''',in.cv_name,''' not found in PRT.mat. Creating...'])
        PRT.cv(cid).cv_name    = in.cv_name;
        PRT.cv(cid).cv_mat     = in.cv_mat;
        PRT.cv(cid).fs_name    = in.fs_name;
        PRT.cv(cid).fs_indices = in.fs_indices;
    end
    
    % check whether feature set is found
    if isfield(PRT,'fs')
        if ~any(strcmpi(in.fs_name,{PRT.fs(:).fs_name}))
            error('prt_init_cv:fsNotFoundInPRT',...
                ['Feature set ''',in.fs_name,''' not found in PRT.mat.'])
        end
    else
        error('prt_init_cv:noFsFoundInPRT','No feature sets found in PRT.mat.')
    end
end
end