function cv_struct = prt_cfg_cv
% Data & design configuration file
% This configures the kernel construction for each modality.
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by Andre Marquand
% $Id: prt_cfg_kernel_construction.m 33 2011-08-10 08:47:17Z cphillip $

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
% kfile Filenames(s) for feature sets(s)
% ---------------------------------------------------------------------
fs_file        = cfg_files;
fs_file.tag    = 'fs_file';
fs_file.name   = 'Feature sets';
fs_file.filter = 'mat';
fs_file.num    = [1 Inf];
fs_file.help   = {'Select Kernel matrices (kernel_xxx.mat).'};

% ---------------------------------------------------------------------
% specify_labels Specify labels
% ---------------------------------------------------------------------
specify_labels         = cfg_entry;
specify_labels.tag     = 'specify_labels';
specify_labels.name    = 'Specify labels';
specify_labels.help    = {'Specify the label for each entry in the kernel matrix'};
specify_labels.strtype = 'e';
specify_labels.num     = [Inf 1];

% ---------------------------------------------------------------------
% label_file Filename for Labels
% ---------------------------------------------------------------------
label_file        = cfg_files;
label_file.tag    = 'label_file';
label_file.name   = 'Load from file';
label_file.num    = [1 1];
label_file.help   = {'Specify file containing labels (ASCII or mat).'};

% ---------------------------------------------------------------------
% labels Labels
% ---------------------------------------------------------------------
labels        = cfg_choice;
labels.tag    = 'labels';
labels.name   = 'Labels';
labels.values = {specify_labels, label_file};
labels.help   = {...
    ['Labels for each of the samples in the kernel matrices. '...
    'Can be entered into a text box or loaded from a file']};

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
% Subjects selected (per group)
% ---------------------------------------------------------------------
subjects         = cfg_entry;
subjects.tag     = 'subjects';
subjects.name    = 'Subject numbers';
subjects.help    = {'Subjects to be included in this kernel matrix'};
subjects.strtype = 'e';
subjects.num     = [Inf 1];

% ---------------------------------------------------------------------
% all_cond All conditions
% ---------------------------------------------------------------------
all_cond         = cfg_const;
all_cond.tag     = 'all_cond';
all_cond.name    = 'All Conditions';
all_cond.val     = {1};
all_cond.help    = {'Include all conditions in this kernel matrix'};

% ---------------------------------------------------------------------
% Sel_cond Specify conditions
% ---------------------------------------------------------------------
sel_cond         = cfg_entry;
sel_cond.tag     = 'sel_cond';
sel_cond.name    = 'Specify Conditions';
sel_cond.help    = {'Conditions to be included in this kernel matrix'};
sel_cond.strtype = 'e';
sel_cond.num     = [Inf 1];

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
% group Group
% ---------------------------------------------------------------------
group         = cfg_branch;
group.tag     = 'group';
group.name    = 'Group';
group.help    = {'Specify data and design for the group.'};
group.val     = {gr_num, subjects, conditions};


% ---------------------------------------------------------------------
% cv_train Train
% ---------------------------------------------------------------------
cv_train         = cfg_repeat;
cv_train.tag     = 'cv_train';
cv_train.name    = 'Train';
cv_train.help    = {['Add data and design for one group. Click ''new'' '...
                    'or ''repeat'' to add another group.']};
cv_train.num     = [1 Inf];
cv_train.values  = {group};

% ---------------------------------------------------------------------
% cv_use_test Use test
% ---------------------------------------------------------------------
cv_use_test         = cfg_repeat;
cv_use_test.tag     = 'cv_use_test';
cv_use_test.name    = 'Specify test set';
cv_use_test.help    = {['Add data and design for one group. Click ''new'' '...
                    'or ''repeat'' to add another group.']};
cv_use_test.num     = [1 Inf];
cv_use_test.values  = {group};

% ---------------------------------------------------------------------
% cv_no_test No test
% ---------------------------------------------------------------------
cv_no_test         = cfg_const;
cv_no_test.tag     = 'cv_no_test';
cv_no_test.name    = 'No test set';
cv_no_test.val     = {0};
cv_no_test.help    = {['Do not specify design. This option can be used '...
                     'for modalities (e.g. structural scans) that do not '...
                     'have an experimental design.']};
% ---------------------------------------------------------------------
% cv_test Test
% ---------------------------------------------------------------------
cv_test        = cfg_choice;
cv_test.tag    = 'cv_test';
cv_test.name   = 'Test';
cv_test.help   = {'Specify data and design.'};
cv_test.values = {cv_no_test, cv_use_test };
%cv_test.val    = {cv_no_test};

% ---------------------------------------------------------------------
% cv_use_valid Use Valid
% ---------------------------------------------------------------------
cv_use_valid         = cfg_repeat;
cv_use_valid.tag     = 'cv_use_valid';
cv_use_valid.name    = 'Specify validation set';
cv_use_valid.help    = {['Add data and design for one group. Click ''new'' '...
                    'or ''repeat'' to add another group.']};
cv_use_valid.num     = [1 Inf];
cv_use_valid.values  = {group};

% ---------------------------------------------------------------------
% cv_no_valid No Valid
% ---------------------------------------------------------------------
cv_no_valid         = cfg_const;
cv_no_valid.tag     = 'cv_no_valid';
cv_no_valid.name    = 'No validation set';
cv_no_valid.val     = {0};
cv_no_valid.help    = {['Do not specify design. This option can be used '...
                     'for modalities (e.g. structural scans) that do not '...
                     'have an experimental design.']};

% ---------------------------------------------------------------------
% cv_valid Validation
% ---------------------------------------------------------------------
cv_valid        = cfg_choice;
cv_valid.tag    = 'cv_valid';
cv_valid.name   = 'Validation';
cv_valid.help   = {'Specify data and design.'};
cv_valid.values = {cv_no_valid, cv_use_valid };
%cv_valid.val    = {cv_no_valid};

% ---------------------------------------------------------------------
% cv_loo All Leave-one-out
% ---------------------------------------------------------------------
cv_loo         = cfg_const;
cv_loo.tag     = 'cv_loo';
cv_loo.name    = 'Leave one subject out';
cv_loo.val     = {1};
cv_loo.help    = {'Conventional Leave-one-out cross-validation'};

% ---------------------------------------------------------------------
% cv_lopo Leave-one-pair-out
% ---------------------------------------------------------------------
cv_lopo         = cfg_const;
cv_lopo.tag     = 'cv_lopo';
cv_lopo.name    = 'Leave one pair out';
cv_lopo.val     = {1};
cv_lopo.help    = {['Leave out a pair of subjects at a time. ', ...
                    'Useful for repeated measures or paired samples designs.']};
% ---------------------------------------------------------------------
% group Group
% ---------------------------------------------------------------------
cv_fold         = cfg_branch;
cv_fold.tag     = 'cv_fold';
cv_fold.name    = 'Fold';
cv_fold.help    = {'Specify data and design for the group.'};
cv_fold.val     = {cv_train cv_test cv_valid};

% ---------------------------------------------------------------------
% cv_custom_fold Fold
% ---------------------------------------------------------------------
cv_custom         = cfg_repeat;
cv_custom.tag     = 'cv_custom';
cv_custom.name    = 'Custom';
cv_custom.help    = {['Specify the configuration for one fold.']};
cv_custom.num     = [1 Inf];
cv_custom.values  = {cv_fold};
             
% ---------------------------------------------------------------------
% cv_type CV Type
% ---------------------------------------------------------------------
cv_type        = cfg_choice;
cv_type.tag    = 'cv_type';
cv_type.name   = 'Cross-validation type';
cv_type.values = {cv_loo, cv_lopo, cv_custom};
cv_type.help   = {'Choose the type of cross-validation to be used'};

% ---------------------------------------------------------------------
% Configure CV
% ---------------------------------------------------------------------
cv_struct        = cfg_exbranch;
cv_struct.tag    = 'cv_struct';
cv_struct.name   = 'Cross-validation';
cv_struct.val    = {infile, fs_file, labels, cv_type};
cv_struct.help   = {'Compute kernel matrices according to the design specified'};
cv_struct.prog   = @prt_run_cv;
cv_struct.vout   = @vout_data;

%------------------------------------------------------------------------
% Output function
%------------------------------------------------------------------------
function cdep = vout_data(job)
% Specifies the output from this modules, i.e. the filename of the mat file

cdep(1)            = cfg_dep;
cdep(1).sname      = 'Cross validation';
cdep(1).src_output = substruct('.','filescv');
cdep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
%------------------------------------------------------------------------

