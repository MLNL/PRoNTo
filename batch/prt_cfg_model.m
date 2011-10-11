function model = prt_cfg_model
% Data & design configuration file
% This configures the kernel construction for each modality.
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by Andre Marquand
% $Id: prt_cfg_cv.m 129 2011-10-05 13:00:36Z amarquan $

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
% model_name Name
% ---------------------------------------------------------------------
model_name         = cfg_entry;
model_name.tag     = 'model_name';
model_name.name    = 'Model name';
model_name.help    = {'Name for model'};
model_name.strtype = 's';
model_name.num     = [1 Inf];
 
% ---------------------------------------------------------------------
% use_kernel Use Kernels
% ---------------------------------------------------------------------
use_kernel         = cfg_menu;
use_kernel.tag     = 'use_kernel';
use_kernel.name    = 'Use kernels';
use_kernel.help    = {...
    ['Are the data for this model in the form of kernels/basis functions? ', ...
     'If ''No'' is selected, it is assumed the data are in the form of ',...
     'feature matrices']};
use_kernel.labels  = {
               'Yes'
               'No'
}';
use_kernel.values  = {1 0};
use_kernel.val     = {1};

% ---------------------------------------------------------------------
% all_features All features
% ---------------------------------------------------------------------
all_features         = cfg_const;
all_features.tag     = 'all_features';
all_features.name    = 'All Features';
all_features.val     = {1};
all_features.help    = {...
    'Include all features from all modalities in this feature set'};

% ---------------------------------------------------------------------
% fs_name Feature set name
% ---------------------------------------------------------------------
fs_name         = cfg_entry;
fs_name.tag     = 'fs_name';
fs_name.name    = 'Name';
fs_name.help    = {'Name of a feature set'};
fs_name.strtype = 's';
fs_name.num     = [1 Inf];
% 
% % ---------------------------------------------------------------------
% % fmask Feature set mask
% % ---------------------------------------------------------------------
% fmask        = cfg_files;
% fmask.tag    = 'fmask';
% fmask.name   = 'Specify mask file';
% fmask.filter = 'img';
% fmask.ufilter = '.*';
% fmask.num    = [1 1];
% fmask.help   = {'Select one mask for each modality.'};

% ---------------------------------------------------------------------
% mod_name Modality name
% ---------------------------------------------------------------------
mod_name         = cfg_entry;
mod_name.tag     = 'mod_name';
mod_name.name    = 'Name';
mod_name.help    = {'Name of modality. Example: ''BOLD''. Must match design specification'};
mod_name.strtype = 's';
mod_name.num     = [1 Inf];

% % ---------------------------------------------------------------------
% % mask Mask
% % ---------------------------------------------------------------------
% mask         = cfg_branch;
% mask.tag     = 'mask';
% mask.name    = 'Modality';
% mask.help    = {'Specify name of modality and file for each mask.'};
% mask.val     = {mod_name, fmask };
%             
% % ---------------------------------------------------------------------
% % masks Masks
% % ---------------------------------------------------------------------
% masks         = cfg_repeat;
% masks.tag     = 'masks';
% masks.name    = 'Specify masks';
% masks.help    = {['Select mask for each ',...
%                   'modality. The name of the modalities should be the same ',...
%                   'as the ones entered for subjects/scans.']};
% masks.num     = [1 Inf];
% masks.values  = {mask };
% 
% % ---------------------------------------------------------------------
% % sel_features Select Features
% % ---------------------------------------------------------------------
% sel_features        = cfg_choice;
% sel_features.tag    = 'sel_features';
% sel_features.name   = 'Data features';
% sel_features.values = {all_features, masks};
% sel_features.val    =  {all_features};
% sel_features.help   = {...
%     ['Which features (e.g. voxels) would you like to include in the model?']};

% ---------------------------------------------------------------------
% fset Feature set
% ---------------------------------------------------------------------
fset         = cfg_branch;
fset.tag     = 'fset';
fset.name    = 'Feature set';
fset.help    = {'Feature set to include in this model'};
%fset.val     = {fs_name, sel_features};
fset.val     = {fs_name};
            
% ---------------------------------------------------------------------
% fsets Feature sets
% ---------------------------------------------------------------------
fsets         = cfg_repeat;
fsets.tag     = 'fsets';
fsets.name    = 'Feature sets';
fsets.help    = {['Select feature sets to include in this model. ',...
                  'These can be kernels or feature matrices. ', ...
                  'If multiple feature sets are included, they must all have ',...
                  'the same number of rows']};
fsets.num     = [1 Inf];
%fsets.values  = {fsets};
fsets.values  = {fset};


% ---------------------------------------------------------------------
% gr_name Group name
% ---------------------------------------------------------------------
gr_name         = cfg_entry;
gr_name.tag     = 'gr_name';
gr_name.name    = 'Name';
gr_name.help    = {'Name of the group to include. Must exist in PRT.mat'};
gr_name.strtype = 's';
gr_name.num     = [1 Inf];

% ---------------------------------------------------------------------
% all_cond All conditions
% ---------------------------------------------------------------------
all_cond         = cfg_const;
all_cond.tag     = 'all_cond';
all_cond.name    = 'All Conditions';
all_cond.val     = {1};
all_cond.help    = {'Include all conditions in this model'};

% ---------------------------------------------------------------------
% cond_name Condition name
% ---------------------------------------------------------------------
cond_name         = cfg_entry;
cond_name.tag     = 'cond_name';
cond_name.name    = 'Name';
cond_name.help    = {'Name of condition to include.'};
cond_name.strtype = 's';
cond_name.num     = [1 Inf];

% ---------------------------------------------------------------------
% conds Conditions
% ---------------------------------------------------------------------
conds         = cfg_branch;
conds.tag     = 'conds';
conds.name    = 'Condition';
conds.help    = {'Specify condition:.'};
conds.val     = {cond_name};

% ---------------------------------------------------------------------
% sel_cond Select conditions
% ---------------------------------------------------------------------
sel_cond         = cfg_repeat;
sel_cond.tag     = 'sel_cond';
sel_cond.name    = 'Specify Conditions';
sel_cond.help    = {'Specify the name of conditions to be included '};
sel_cond.values  = {conds};

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
    ['Which task conditions do you want to include? '...
    'Select conditions: select specific conditions from the timeseries. ', ...
    'All conditions: include all conditions extracted from the timeseries. ', ...
    'All scans: include all scans for each subject. This may be used for ', ...
    'modalities with only one scan per subject (e.g. PET), ', ...
    'if you want to include all scans from an fMRI timeseries (assumes you ',...
    'have not already detrended the timeseries and extracted task components)']};

% ---------------------------------------------------------------------
% modality Modality
% ---------------------------------------------------------------------
modality      = cfg_branch;
modality.tag  = 'modality';
modality.name = 'Modality';
modality.val  = {mod_name conditions};
modality.help = {'Specify modality, such as name and data.'};

% ---------------------------------------------------------------------
% modalities Modalities
% ---------------------------------------------------------------------
modalities         = cfg_repeat;
modalities.tag     = 'modalities';
modalities.name    = 'Modalities';
modalities.help    = {'Add modalities'};
modalities.num     = [1 Inf];
modalities.values  = {modality};

% ---------------------------------------------------------------------
% subj_num Subjects selected (per group)
% ---------------------------------------------------------------------
subj_nums         = cfg_entry;
subj_nums.tag     = 'subj_nums';
subj_nums.name    = 'Subject number(s)';
subj_nums.help    = {
    ['Subjects to be included in this class. Note that individual ',...
     'subject numbers (e.g. 1), or a range of subject numbers ',...
     '(e.g. 3:5) can be entered'] };
subj_nums.strtype = 'e';
subj_nums.num     = [Inf 1];

% ---------------------------------------------------------------------
% group Group
% ---------------------------------------------------------------------
group         = cfg_branch;
group.tag     = 'group';
group.name    = 'Group';
group.help    = {'Specify data and design for the group.'};
group.val     = {gr_name, subj_nums, modalities};

% ---------------------------------------------------------------------
% class_name Class name
% ---------------------------------------------------------------------
class_name         = cfg_entry;
class_name.tag     = 'class_name';
class_name.name    = 'Name';
class_name.help    = {'Name for this class, e.g. ''controls'' '};
class_name.strtype = 's';
class_name.num     = [1 Inf];

% ---------------------------------------------------------------------
% groups Groups
% ---------------------------------------------------------------------
groups         = cfg_repeat;
groups.tag     = 'groups';
groups.name    = 'Groups';
groups.help    = {['Add one group to this class. Click ''new'' '...
                    'or ''repeat'' to add another group.']};
groups.num     = [1 Inf];
groups.values  = {group};

% ---------------------------------------------------------------------
% class Class
% ---------------------------------------------------------------------
class         = cfg_branch;
class.tag     = 'class';
class.name    = 'Class';
class.help    = {...
    ['Specify which groups, modalities, subjects and conditions should ',...
     'be included in this class']};
class.val     = {class_name, groups};

% ---------------------------------------------------------------------
% classification Classification
% ---------------------------------------------------------------------
classification         = cfg_repeat;
classification.tag     = 'classification';
classification.name    = 'Classification';
classification.help    = {['Specify which elements belong to this class. Click ''new'' '...
                           'or ''repeat'' to add another class.']};
classification.num     = [1 Inf];
classification.values  = {class};

% ---------------------------------------------------------------------
% reg_targets Regression Targets
% ---------------------------------------------------------------------
reg_targets         = cfg_entry;
reg_targets.tag     = 'reg_targets';
reg_targets.name    = 'Targets';
reg_targets.help    = {['Specify continuous valued target variables']};
reg_targets.strtype = 'e';
reg_targets.num     = [Inf 1];

% ---------------------------------------------------------------------
% reg_group Regression group
% ---------------------------------------------------------------------
reg_group         = cfg_branch;
reg_group.tag     = 'reg_group';
reg_group.name    = 'Group';
reg_group.help    = {'Specify data and design for the group.'};
reg_group.val     = {gr_name, subj_nums, conditions, reg_targets};

% ---------------------------------------------------------------------
% regression Regression
% ---------------------------------------------------------------------
regression         = cfg_repeat;
regression.tag     = 'regression';
regression.name    = 'Regression';
regression.help    = {['Add one group to this regression model. Click ''new'' '...
                    'or ''repeat'' to add another group.']};
regression.num     = [1 Inf];
regression.values  = {reg_group};

% ---------------------------------------------------------------------
% model_type Model type
% ---------------------------------------------------------------------
model_type        = cfg_choice;
model_type.tag    = 'model_type';
model_type.name   = 'Model Type ';
model_type.values = {classification, regression};
model_type.help   = {'Select which kind of predictive model is to be used.'};

% ---------------------------------------------------------------------
% machine_func Filename(s) of data
% ---------------------------------------------------------------------
machine_func        = cfg_files;
machine_func.tag    = 'machine_func';
machine_func.name   = 'Function';
machine_func.ufilter = '^*.m';
machine_func.num    = [1 1];
machine_func.help   = {'Choose a function that will perform prediction.'};

% ---------------------------------------------------------------------
% machine_args Regression Targets
% ---------------------------------------------------------------------
machine_args         = cfg_entry;
machine_args.tag     = 'machine_args';
machine_args.name    = 'Arguments';
machine_args.help    = {['Arguments for prediction machine.']};
machine_args.strtype = 's';
machine_args.num     = [1 Inf];

% ---------------------------------------------------------------------
% custom_machine Regression group
% ---------------------------------------------------------------------
custom_machine         = cfg_branch;
custom_machine.tag     = 'custom_machine';
custom_machine.name    = 'Custom machine';
custom_machine.help    = {'Choose another prediction machine'};
custom_machine.val     = {machine_func, machine_args};

% ---------------------------------------------------------------------
% svm_args Regression Targets
% ---------------------------------------------------------------------
svm_args         = cfg_entry;
svm_args.tag     = 'svm_args';
svm_args.name    = 'Arguments';
svm_args.help    = {['Arguments for prt_machine_svm_bin.']};
svm_args.strtype = 's';
svm_args.val     = {'-s 0 -t 4 -c 1'};
svm_args.num     = [1 Inf];

% ---------------------------------------------------------------------
% svm Regression group
% ---------------------------------------------------------------------
svm         = cfg_branch;
svm.tag     = 'svm';
svm.name    = 'SVM';
svm.help    = {'Binary support vector machine.'};
svm.val     = {svm_args};

% ---------------------------------------------------------------------
% machine Select Features
% ---------------------------------------------------------------------
machine        = cfg_choice;
machine.tag    = 'machine';
machine.name   = 'Machine';
machine.values = {svm, custom_machine};
machine.val    =  {svm};
machine.help   = {...
    ['Choose a prediction machine for this model']};

% % ---------------------------------------------------------------------
% % cv_train Cross-validation training set
% % ---------------------------------------------------------------------
% cv_train         = cfg_repeat;
% cv_train.tag     = 'cv_train';
% cv_train.name    = 'Train';
% cv_train.help    = {['Specify training set.']};
% cv_train.num     = [1 Inf];
% cv_train.values  = {group};
% 
% % ---------------------------------------------------------------------
% % cv_use_test Use test set
% % ---------------------------------------------------------------------
% cv_use_test         = cfg_repeat;
% cv_use_test.tag     = 'cv_use_test';
% cv_use_test.name    = 'Specify test set';
% cv_use_test.help    = {['Include a test set in this fold']};
% cv_use_test.num     = [1 Inf];
% cv_use_test.values  = {group};
% 
% % ---------------------------------------------------------------------
% % cv_no_test No test set
% % ---------------------------------------------------------------------
% cv_no_test         = cfg_const;
% cv_no_test.tag     = 'cv_no_test';
% cv_no_test.name    = 'No test set';
% cv_no_test.val     = {0};
% cv_no_test.help    = {['Do not use a test set for this fold']};
% % ---------------------------------------------------------------------
% % cv_test Cross-validation test set
% % ---------------------------------------------------------------------
% cv_test        = cfg_choice;
% cv_test.tag    = 'cv_test';
% cv_test.name   = 'Test';
% cv_test.help   = {'Specify test set (if any).'};
% cv_test.values = {cv_no_test, cv_use_test };
% 
% % ---------------------------------------------------------------------
% % cv_use_valid Use validation set
% % ---------------------------------------------------------------------
% cv_use_valid         = cfg_repeat;
% cv_use_valid.tag     = 'cv_use_valid';
% cv_use_valid.name    = 'Specify validation set';
% cv_use_valid.help    = {['Use a validation set for this fold']};
% cv_use_valid.num     = [1 Inf];
% cv_use_valid.values  = {group};
% 
% % ---------------------------------------------------------------------
% % cv_no_valid No validation set
% % ---------------------------------------------------------------------
% cv_no_valid         = cfg_const;
% cv_no_valid.tag     = 'cv_no_valid';
% cv_no_valid.name    = 'No validation set';
% cv_no_valid.val     = {0};
% cv_no_valid.help    = {['Do not use a validation set for this fold']};
% 
% % ---------------------------------------------------------------------
% % cv_valid Cross-validation validation set
% % ---------------------------------------------------------------------
% cv_valid        = cfg_choice;
% cv_valid.tag    = 'cv_valid';
% cv_valid.name   = 'Validation';
% cv_valid.help   = {'Specify validation set (if any).'};
% cv_valid.values = {cv_no_valid, cv_use_valid };
% %cv_valid.val    = {cv_no_valid};
% 
% ---------------------------------------------------------------------
% cv_loo Leave-one-out
% ---------------------------------------------------------------------
cv_loso         = cfg_const;
cv_loso.tag     = 'cv_loso';
cv_loso.name    = 'Leave one subject out';
cv_loso.val     = {1};
cv_loso.help    = {'Leave a single subject out each cross-validation iteration'};

% ---------------------------------------------------------------------
% cv_losgo Leave-one-subject-per-group-out
% ---------------------------------------------------------------------
cv_losgo         = cfg_const;
cv_losgo.tag     = 'cv_losgo';
cv_losgo.name    = 'Leave one subject per group out';
cv_losgo.val     = {1};
cv_losgo.help    = {...
    ['Leave out a single subject from each group at a time. ', ...
     'Useful for repeated measures or paired samples designs.']};
%  
% % ---------------------------------------------------------------------
% % cv_fold Cross-validation fold
% % ---------------------------------------------------------------------
% cv_fold         = cfg_branch;
% cv_fold.tag     = 'cv_fold';
% cv_fold.name    = 'Fold';
% cv_fold.help    = {...
%     ['Specify the groups, subjects, modalities and conditions to be ',...
%      'included in this fold']};
% cv_fold.val     = {cv_train cv_test cv_valid};
% 
% % ---------------------------------------------------------------------
% % cv_custom_fold Custom cross-validation fold
% % ---------------------------------------------------------------------
% cv_custom         = cfg_repeat;
% cv_custom.tag     = 'cv_custom';
% cv_custom.name    = 'Custom';
% cv_custom.help    = {'Specify a custom cross-validation approach.'};
% cv_custom.num     = [1 Inf];
% cv_custom.values  = {cv_fold};

% ---------------------------------------------------------------------
% cv_custom Feature set mask
% ---------------------------------------------------------------------
cv_custom        = cfg_files;
cv_custom.tag    = 'cv_custom';
cv_custom.name   = 'Custom';
cv_custom.filter = 'mat';
cv_custom.ufilter = '.*';
cv_custom.num    = [1 1];
cv_custom.help   = {...
    ['Load a cross-validation matrix. Note that an interface ',...
     'will be provided for this functionality in a later release']};

% ---------------------------------------------------------------------
% cv_type Cross-validation type
% ---------------------------------------------------------------------
cv_type        = cfg_choice;
cv_type.tag    = 'cv_type';
cv_type.name   = 'Cross-validation type';
cv_type.values = {cv_loso, cv_losgo, cv_custom};
cv_type.val    = {cv_loso};
cv_type.help   = {'Choose the type of cross-validation to be used'};

% ---------------------------------------------------------------------
% model Model
% ---------------------------------------------------------------------
model        = cfg_exbranch;
model.tag    = 'model';
model.name   = 'Specify model';
model.val    = {infile, model_name, use_kernel, fsets, model_type, machine, cv_type};
model.help   = {'Construct model according to design specified'};
model.prog   = @prt_run_model;
model.vout   = @vout_data;

%------------------------------------------------------------------------
% Output function
%------------------------------------------------------------------------
function cdep = vout_data(job)
% Specifies the output from this modules, i.e. the filename of the mat file

cdep(1)            = cfg_dep;
cdep(1).sname      = 'Cross validation';
cdep(1).src_output = substruct('.','files');
cdep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
%------------------------------------------------------------------------

