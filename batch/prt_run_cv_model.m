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
mid = prt_init_model(PRT, in);

% Special cross-validation for MCKR
if strcmp(PRT.model(mid).input.machine.function,'prt_machine_mckr')
    out=prt_cv_mckr(PRT,in);
else
    out=prt_cv_model(PRT, in);
end


% -------------------------------------------------------------------------
% Function output
% -------------------------------------------------------------------------
disp('Model execution complete.')
out.files{1} = in.fname{1};
disp('Done')

 return