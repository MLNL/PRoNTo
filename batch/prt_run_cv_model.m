function out = prt_run_cv_model(varargin)
%
% PRONTO job execution function
%
% INPUT
%   job    - harvested job data structure (see matlabbatch help)
%
% OUTPUT
%   out    - filename of saved data structure (1 file per group, per 
%            subject, per modality, per condition 
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A Marquand
% $Id$

job   = varargin{1};

% Load PRT.mat
% -------------------------------------------------------------------------
fname = char(job.infile);
load(fname);

% -------------------------------------------------------------------------
% Input file
% -------------------------------------------------------------------------

in.fname      = job.infile;
in.model_name = job.model_name;

prt_cv_model(PRT, in)

% -------------------------------------------------------------------------
% Function output
% -------------------------------------------------------------------------
disp('Model execution complete.')
out.files{1} = in.fname{1};
disp('Done')

 return