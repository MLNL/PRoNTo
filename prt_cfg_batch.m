function prt = prt_cfg_batch
% Pattern Recognition for Neuroimaging Toolbox, PRONTO.
% PRN configuration file
% This builds the whole tree for the various tools and their GUI.
%_______________________________________________________________________
% Copyright (C) 2011, ...

% Written by Christophe Phillips
% $Id$

% if ~isdeployed, addpath(fullfile(spm('Dir'),'toolbox','PRoNTo')); end
% Only needed if
% - PRN is installed in SPM8 toolbox directory, for example
%   SPM8\toolbox\PRoNTo
% - and this directory isn't saved on Matlab path (which it shouldn't)



% ---------------------------------------------------------------------
% prn PRONTO series of modules
% ---------------------------------------------------------------------
prt         = cfg_choice;
prt.tag     = 'prt';
prt.name    = 'PRoNTo';
prt.help    = {[...
    'This is the batch interface for PRoNTo, i.e. Pattern Recognition '...
    'for Neuroimaging Toolbox providing a GUI for the various tools.']
                  }';
%  Only two modules so far... and not doing much.
prt.values  = {prt_cfg_design, prt_cfg_preproc, prt_cfg_kernel_construction };
% Assuming 4 main modules: 
% - defining data & design, 
% - pre-processing,
% - pattern recognition
% - results
%------------------------------------------------------------------------

return