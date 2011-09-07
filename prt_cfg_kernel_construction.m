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
infile.ufilter = 'PRT.mat';
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
% gr_name Modality
% ---------------------------------------------------------------------
gr_name         = cfg_entry;
gr_name.tag     = 'gr_name';
gr_name.name    = 'Group name';
gr_name.help    = {'Specify the name the group to be included'};
gr_name.strtype = 's';
gr_name.num     = [1 Inf];


% ---------------------------------------------------------------------
% modality Modality
% ---------------------------------------------------------------------
modality         = cfg_entry;
modality.tag     = 'modality';
modality.name    = 'Modality';
modality.help    = {'Specify the name of the source modality for this kernel matrix'};
modality.strtype = 's';
modality.num     = [1 Inf];

% ---------------------------------------------------------------------
% Subjects selected (per group)
% ---------------------------------------------------------------------
subjects         = cfg_entry;
subjects.tag     = 'subjects';
subjects.name    = 'Subject numbers';
subjects.help    = {'Subjects to be included in this kernel matrix'};
subjects.strtype = 'e';
subjects.num     = [Inf 1];

% ---------------------------------------------------------------------
% cond_name Name
% ---------------------------------------------------------------------
cond_name         = cfg_entry;
cond_name.tag     = 'cond_name';
cond_name.name    = 'Condition';
cond_name.help    = {'Name of condition to include.'};
cond_name.strtype = 's';
cond_name.num     = [1 Inf];

% ---------------------------------------------------------------------
% sel_cond Conditions
% ---------------------------------------------------------------------
sel_cond         = cfg_repeat;
sel_cond.tag     = 'sel_cond';
sel_cond.name    = 'Specify Conditions';
sel_cond.help    = {'Specify the name of conditions to be included '};
sel_cond.values  = {cond_name};

% ---------------------------------------------------------------------
% all_cond All conditions
% ---------------------------------------------------------------------
all_cond         = cfg_const;
all_cond.tag     = 'all_cond';
all_cond.name    = 'All Conditions';
all_cond.val     = {1};
all_cond.help    = {'Include all conditions in this kernel matrix'};

% ---------------------------------------------------------------------
% all_scans All scans
% ---------------------------------------------------------------------
all_scans         = cfg_const;
all_scans.tag     = 'all_scans';
all_scans.name    = 'All scans';
all_scans.val     = {1};
all_scans.help    = {['No design specified. This option can be used '...
                     'for modalities (e.g. structural scans) that do not '...
                     'have an experimental design or for an fMRI design',...
                     'where you want to include all scans in the timeseries']};
                 
% ---------------------------------------------------------------------
% conditions Conditions
% ---------------------------------------------------------------------
conditions        = cfg_choice;
conditions.tag    = 'conditions';
conditions.name   = 'Conditions';
conditions.values = {sel_cond, all_cond, all_scans};
conditions.help   = {...
['Which task conditions do you want to include in the kernel matrix? '...
 'Select conditions: select specific conditions from the timeseries. ', ...
 'All conditions: include all conditions extracted from the timeseries. ', ...
 'All scans: include all scans for each subject. This may be used for ', ...
 'modalities with only one scan per subject (e.g. PET), ', ... 
 'if you want to include all scans from an fMRI timeseries (assumes you ',...
 'have not already detrended the timeseries and extracted task components)']};


% ---------------------------------------------------------------------
% mod_name Name
% ---------------------------------------------------------------------
mod_name         = cfg_entry;
mod_name.tag     = 'mod_name';
mod_name.name    = 'Name';
mod_name.help    = {'Name of modality. Example: ''BOLD''.'};
mod_name.strtype = 's';
mod_name.num     = [1 Inf];


% ---------------------------------------------------------------------
% modality Modality
% ---------------------------------------------------------------------
modality      = cfg_branch;
modality.tag  = 'modality';
modality.name = 'Modality';
modality.val  = {mod_name conditions};
modality.help = {'Specify modality, such as name and data.'};

% ---------------------------------------------------------------------
% modalities Groups
% ---------------------------------------------------------------------
modalities         = cfg_repeat;
modalities.tag     = 'modalities';
modalities.name    = 'Modalities';
modalities.help    = {'Add modalities'};
modalities.num     = [1 Inf];
modalities.values  = {modality};

% ---------------------------------------------------------------------
% group Group
% ---------------------------------------------------------------------
group         = cfg_branch;
group.tag     = 'group';
group.name    = 'Group';
group.help    = {'Specify data and design for the group.'};
group.val     = {gr_name, subjects, modalities};

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
% mask Mask
% ---------------------------------------------------------------------
mask        = cfg_files;
mask.tag    = 'mask';
mask.name   = 'Kernel masks';
mask.filter = 'image';
%mask.ufilter = '.*';
mask.num    = [1 Inf];
mask.help   = {'Select kernel masks for each modality included in the kernel.'};
  
% ---------------------------------------------------------------------
% Configure Kernel
% ---------------------------------------------------------------------
kernel        = cfg_exbranch;
kernel.tag    = 'kernel';
kernel.name   = 'Kernels';
kernel.val    = {infile, kernel_filename, groups, mask, normalise};
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

