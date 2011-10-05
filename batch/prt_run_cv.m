function out = prt_run_cv(varargin)
%
% PRoNTo job execution function
% takes a harvested job data structure and rearrange data into "proper"
% data structure, then save do what it has to do...
% Here simply the harvested job structure in a mat file.
%
% INPUT
%   job    - harvested job data structure (see matlabbatch help)
%
% OUTPUT
%   out    - filename of saved data structure.
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A Marquand
% $Id$

% Job variable
% -------------------------------------------------------------------------
job   = varargin{1};

% Load PRT.mat
% -------------------------------------------------------------------------
fname = char(job.infile);
load(fname);

% in.cv_name:    name of the cross-validation structure to create (string)
% in.cv_mat:     cross-validation matrix (nSamples x nFolds matrix)
% in.fs_name:    name of the feature set to use for this CV struct (string)
% in.fs_indices: indices of samples in the feature set to include (vector)

cv.cv_name = job.cv_name;
cv.fs_name = {job.fset.fs_name};

% configure cv matrix
mat.cv_type = job.cv_type;
mat.cv

cv.cv_mat = prt_cv_mat(PRT, mat);

% configure fs_indices
if isfield(job.fs_samples,'all_samples')
    cv.fs_indices = 1:size(cv.cvmat,1);
else
    
end

% initialize CV structure
[cid, PRT] = prt_init_cv(PRT, cv);

% Save PRT.mat
disp('Updating PRT.mat.......>>')
if spm_matlab_version_chk('7') >= 0
    save(in.fname,'-V6','PRT');
else
    save(in.fname,'-V6','PRT');
end

% Function output
% -------------------------------------------------------------------------
out.filescv{1} = fname;
disp('Cross-validation done.')
end
