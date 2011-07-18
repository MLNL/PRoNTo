function kernels = prt_cfg_kernel_construction
% Data & design configuration file
% This configures the kernel construction for each modality.
%_______________________________________________________________________
% Copyright (C) 2011, ...

% Andre Marquand
% $Id:$

% ---------------------------------------------------------------------
% filename Filename(s) of data
% ---------------------------------------------------------------------
infile        = cfg_files;
infile.tag    = 'infile';
infile.name   = 'Data structure file';
infile.filter = 'mat';
infile.num    = [1 1];
infile.help   = {'Select data/design structure file (PRT.mat).'};

% ---------------------------------------------------------------------
% Modalities
% ---------------------------------------------------------------------
modality         = cfg_entry;
modality.tag     = 'modality';
modality.name    = 'Modality';
modality.help    = {'Specify the source modality for this kernel matrix'};
modality.strtype = 'e';
modality.num     = [1 1];

% ---------------------------------------------------------------------
% Subjects
% ---------------------------------------------------------------------
subjects         = cfg_entry;
subjects.tag     = 'subjects';
subjects.name    = 'Subjects';
subjects.help    = {'Which subjects are to be included in this kernel matrix'};
subjects.strtype = 'e';
subjects.num     = [Inf 1];

% ---------------------------------------------------------------------
% Configure Kernels
% ---------------------------------------------------------------------
kernels        = cfg_exbranch;
kernels.tag    = 'kernels';
kernels.name   = 'Configure Kernels';
kernels.val    = {infile, modality, subjects};
kernels.help   = {'Compute kernel matrices according to the design specified'};
kernels.prog   = @prt_run_kernel_construction;
kernels.vout   = @vout_data;


% Output function
%------------------------------------------------------------------------
function cdep = vout_data(job)
% Specifies the output from this modules, i.e. the filename of the mat file

cdep(1)            = cfg_dep;
cdep(1).sname      = 'Configure Kernels';
cdep(1).src_output = substruct('()',{1}, '.','fname','()',{':'});
cdep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
%------------------------------------------------------------------------

