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
% $Id: prt_run_kernel_construction.m 33 2011-08-10 08:47:17Z cphillip $

% Job variable
% -------------------------------------------------------------------------
job   = varargin{1};

% Load PRT.mat and configure some variables
% -------------------------------------------------------------------------
fname = char(job.infile);
load(fname);

disp('This is just a placeholder. Not implemented yet');

% Function output
% -------------------------------------------------------------------------
out.filescv{1} = '';
disp('Cross-validation done.')
end
