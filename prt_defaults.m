function prt_defaults
% Sets the defaults which are used by PRoNTo, Pattern Recognition in
% Neuroimaging Toolbox
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
prt_loc = which('prt_batch');
prt_def.global.install_dir = fileparts(prt_loc);


% Parameters for the data and design
%-----------------------------------------------
prt_def.datad.hrfd = 6; % HRF delay in seconds
prt_def.datad.hrfw = 6; % HRF FWHM, used to compute the overlap between conditions
%prt_def.datad.hrfd = 3; % HRF delay in seconds
%prt_def.datad.hrfw = 1; % HRF FWHM, used to compute the overlap between conditions



% Preprocessing defaults
prt_def.prep.use1  = 5;      
prt_def.prep.use2  = 'kk'; % pre
% Put in whatever default value is useful for the preprocessing step. It
% could be a flag (value 1/0), some scalar or vector of values, or even
% some strings...

% default mask
prt_def.prep.default_mask  = [prt_def.global.install_dir,'/masks/SPM_mask_noeyes.hdr'];

% memory limit for kernel construction
prt_def.kernel.mem_limit = 128*1024*1024;  % bytes of memory to use

% Design specification default
prt_def.dspec.use3 = [1 2];


% Other default values should be added as sub-fields in the prt_def
% structure. Values related to the same module should preferably be grouped
% into a single substructure.

return
