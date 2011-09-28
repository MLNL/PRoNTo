function out = prt_run_preproc(varargin)
%
% PRONTO job execution function
% Read the data structure (PRT.mat);
% Read masks for all modalities, compare them with a sample scan and resize 
% the masks when dimensionality doesn't match;  
% For each group, subject and modality:
% -> Load scan, apply respective mask and store it in a matrix in a matrix
% formed for all the scans from the same subject and modality;
% -> Detrend voxels inside the mask
% -> If it is a timeseries and detrend is done in the preprocessing:
% -> Estimate hemodynamic response
%   -> Extract examples
%   -> Save as a 4D image
% -> If it is a timeseries and detrend is done in the preprocessing:
%   -> Save as a 4D image    
%
% INPUT
%   job    - harvested job data structure (see matlabbatch help)
%
% OUTPUT
%   out    - filename of saved data structure (1 file per group, per 
%            subject, per modality, per condition 
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J.M.Rondina
% $Id: prt_run_preproc.m 79 2011-09-28 09:45:12Z cphillip $

% -------------------------------------------------------------------------
% Job variable
% -------------------------------------------------------------------------

job   = varargin{1};

% -------------------------------------------------------------------------
% Input file
% -------------------------------------------------------------------------

fname = job.infile; 
prt_preproc(fname)


% -------------------------------------------------------------------------
% Function output
% -------------------------------------------------------------------------
disp('Preprocessing done.')
out.files{1} = fname{1};
disp('Done')

 return