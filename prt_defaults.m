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
% The structure and content of this file are largely inspired by SPM.
%_______________________________________________________________________
% Copyright (C) 2011, ...

% $Id:$

%%
global prt_def

% Global defaults
prt_loc = which('prt_batch');
prt_def.global.install_dir = fileparts(prt_loc);

% Preprocessing defaults
prt_def.prep.use1  = 5;      
prt_def.prep.use2  = 'kk'; % pre
% Put in whatever default value is useful for the preprocessing step. It
% could be a flag (value 1/0), some scalar or vector of values, or even
% some strings...

% default mask
prt_def.prep.default_mask  = [prt_def.global.install_dir,'/masks/SPM_mask_noeyes.hdr'];

% Design specification default
pre_def.dspec.use3 = [1 2];


% Other default values should be added as sub-fields in the prt_def
% structure. Values related to the same module should preferably be grouped
% into a single substructure.

return
