function prt_defaults
% Sets the defaults which are used by the Pattern Recognition for
% Neuroimaging Toolbox, aka. PRoNTo.
%
% FORMAT prt_defaults
%_______________________________________________________________________
%
% This file can be customised to any the site/person own setup.
% Individual users can make copies which can be stored on their own
% matlab path. Make sure your 'prt_defaults' is the first one found in the
% path. See matlab documentation for details on setting path.
%
% Care must be taken when modifying this file!
%
% The structure and content of this file are largely inspired by SPM:
% http://www.fil.ion.ucl.ac.uk/spm
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by Christophe Phillips
% $Id$

%%
global prt_def

% Global defaults
% prt_loc = which('prt_batch');
% prt_def.global.install_dir = fileparts(prt_loc);
prt_def.global.install_dir = prt('dir');


% Parameters for the data and design
%-----------------------------------------------
prt_def.datad.hrfd = 0; % HRF delay in seconds
prt_def.datad.hrfw = 0; % HRF FWHM, used to compute the overlap between conditions

prt_def.prep.default_mask  = [prt_def.global.install_dir,...
                            '/masks/SPM_mask_noeyes.hdr'];% default mask

% Preprocessing defaults
%------------------------------------------------
% memory limit for kernel/file arrays construction
prt_def.fs.mem_limit = 64*1024*1024;  % bytes of memory to use
prt_def.fs.writeraw = 0;              % flag to write the data detrended (default) or raw (to set to 1).

% Design specification default
prt_def.dspec.use3 = [1 2];


% Specify model: Parameters of the different machines
%--------------------------------------------------
prt_def.model.svmargs='-s 0 -t 4 -c 1';
prt_def.model.gpcargs='-l erf -h';
prt_def.model.krrargs=1;
prt_def.model.rtargs=601;

return
