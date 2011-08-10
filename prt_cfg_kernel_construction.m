function kernel = prt_cfg_kernel_construction
% Data & design configuration file
% This configures the kernel construction for each modality.
%_______________________________________________________________________
% Copyright (C) 2011, ...

% Written by Andre Marquand
% $Id$

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
% kernel_filename Name
% ---------------------------------------------------------------------
kernel_filename         = cfg_entry;
kernel_filename.tag     = 'kernel_filename';
kernel_filename.name    = 'Name';
kernel_filename.help    = {'Target filename (will be saved as kernel_xxx.mat'};
kernel_filename.strtype = 's';
kernel_filename.num     = [1 Inf];

% ---------------------------------------------------------------------
% Groups selected
% ---------------------------------------------------------------------
gr_num         = cfg_entry;
gr_num.tag     = 'gr_num';
gr_num.name    = 'Group number';
gr_num.help    = {'Group to be included in this kernel matrix'};
gr_num.strtype = 'e';
gr_num.num     = [1 1];

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
% Subjects selected (per group)
% ---------------------------------------------------------------------
subjects         = cfg_entry;
subjects.tag     = 'subjects';
subjects.name    = 'Subjects';
subjects.help    = {'Subjects to be included in this kernel matrix'};
subjects.strtype = 'e';
subjects.num     = [Inf 1];

% ---------------------------------------------------------------------
% Conditions selected (per group)
% ---------------------------------------------------------------------
conditions         = cfg_entry;
conditions.tag     = 'conditions';
conditions.name    = 'Conditions';
conditions.help    = {'Conditions to be included in this kernel matrix'};
conditions.strtype = 'e';
conditions.num     = [Inf 1];

% ---------------------------------------------------------------------
% Normalise Kernel
% ---------------------------------------------------------------------
normalise         = cfg_menu;
normalise.tag     = 'normalise';
normalise.name    = 'Normalize Kernel';
normalise.help    = {'Normalize the kernel matrix? (Equivalent to dividing each data vector by its norm)'};
normalise.labels  = {
               'No'
               'Yes'
}';
normalise.values  = {0 1};
normalise.val     = {0};

% ---------------------------------------------------------------------
% group Group
% ---------------------------------------------------------------------
group         = cfg_branch;
group.tag     = 'group';
group.name    = 'Group';
group.help    = {'Specify data and design for the group.'};
group.val     = {gr_num, subjects, conditions};

% ---------------------------------------------------------------------
% groups Groups
% ---------------------------------------------------------------------
groups         = cfg_repeat;
groups.tag     = 'groups';
groups.name    = 'Groups';
groups.help    = {['Add data and design for one group. Click ''new'' '...
                    'or ''repeat'' to add another group.']};
groups.num     = [1 Inf];
groups.values  = {group};

% ---------------------------------------------------------------------
% Configure Kernel
% ---------------------------------------------------------------------
kernel        = cfg_exbranch;
kernel.tag    = 'kernel';
kernel.name   = 'Configure Kernel';
kernel.val    = {infile, kernel_filename, modality, groups, normalise};
kernel.help   = {'Compute kernel matrices according to the design specified'};
kernel.prog   = @prt_run_kernel_construction;
kernel.vout   = @vout_data;

% Output function
%------------------------------------------------------------------------
function cdep = vout_data(job)
% Specifies the output from this modules, i.e. the filename of the mat file

cdep(1)            = cfg_dep;
cdep(1).sname      = 'Configure Kernels';
cdep(1).src_output = substruct('()',{1}, '.','fname','()',{':'});
cdep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
%------------------------------------------------------------------------

