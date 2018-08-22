function copymodel = prt_cfg_copy_model
% Copies a model and allows to change a few field
% This is particularly useful with random subsampling.
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by Jessica Schrouff based on prt_cfg_model
% $Id$

def = prt_get_defaults;

% ---------------------------------------------------------------------
% filename Filename(s) of data
% ---------------------------------------------------------------------
infile        = cfg_files;
infile.tag    = 'infile';
infile.name   = 'Load PRT.mat';
infile.ufilter = 'PRT.mat';
infile.num    = [1 1];
infile.help   = {'Select data/design structure file (PRT.mat).'};

% ---------------------------------------------------------------------
% model_name Name
% ---------------------------------------------------------------------
model_name         = cfg_entry;
model_name.tag     = 'model_name';
model_name.name    = 'Model name';
model_name.help    = {'Name for new model.'};
model_name.strtype = 's';
model_name.num     = [1 Inf];

% ---------------------------------------------------------------------
% copymodel_name Name
% ---------------------------------------------------------------------
copymodel_name         = cfg_entry;
copymodel_name.tag     = 'copymodel_name';
copymodel_name.name    = 'Model to copy';
copymodel_name.help    = {'Name of the model to copy.'};
copymodel_name.strtype = 's';
copymodel_name.num     = [1 Inf];

% ---------------------------------------------------------------------
% fs_name Feature set name
% ---------------------------------------------------------------------
fs_name         = cfg_entry;
fs_name.tag     = 'fs_name';
fs_name.name    = 'Name';
fs_name.help    = {['Enter the name of a feature set to include in this model. ',...
                  'This can be kernel or a feature matrix. ', ...
                  ]};
fs_name.strtype = 's';
fs_name.num     = [1 Inf];


% ---------------------------------------------------------------------
% featureset Feature set names (v3.0: multiple allowed)
% ---------------------------------------------------------------------
featureset         = cfg_repeat;
featureset.tag     = 'featureset';
featureset.name    = 'Feature set name';
featureset.help    = {['Add onefeature set to this model. Click ''new'' '...
                    'or ''repeat'' to add another feature set.']};
featureset.num     = [1 Inf];
featureset.values     = {fs_name};

% ---------------------------------------------------------------------
% fsets Feature set(s)
% ---------------------------------------------------------------------
fsets         = cfg_branch;
fsets.tag     = 'fsets';
fsets.name    = 'Feature sets';
fsets.help    = {'Feature set(s) to include in this model.'};
fsets.val     = {featureset};
% fsets.val     = {featureset, indmodels};

% ---------------------------------------------------------------------
% k_args Define k for partioning
% ---------------------------------------------------------------------
k_args         = cfg_entry;
k_args.tag     = 'k_args';
k_args.name    = 'k';
k_args.help    = {['Number of folds/partitions for CV. To create a 50%-50%,' ...
    'choose k as 2. Please note that there can be more partitions than'...
    ' specified when leaving subjects per group out. Also note that '...
    'leaving more than 50% of the data out is not permitted.']};
k_args.strtype = 'e';
k_args.num     = [1 1];

% ---------------------------------------------------------------------
% cv_loso Leave-one-subject-out
% ---------------------------------------------------------------------
cv_loso         = cfg_const;
cv_loso.tag     = 'cv_loso';
cv_loso.name    = 'Leave one subject out';
cv_loso.val     = {1};
cv_loso.help    = {'Leave a single subject out each cross-validation iteration'};

% ---------------------------------------------------------------------
% cv_lkso K-folds CV on Subjects
% ---------------------------------------------------------------------
cv_lkso         = cfg_branch;
cv_lkso.tag     = 'cv_lkso';
cv_lkso.name    = 'k-folds CV on subjects';
cv_lkso.val     = {k_args};
cv_lkso.help    = {'k-partitioning of subjects at each cross-validation iteration'};

% ---------------------------------------------------------------------
% cv_losgo Leave-one-subject-per-group-out
% ---------------------------------------------------------------------
cv_losgo         = cfg_const;
cv_losgo.tag     = 'cv_losgo';
cv_losgo.name    = 'Leave one subject per group out';
cv_losgo.val     = {1};
cv_losgo.help    = {...
    ['Leave out a single subject from each group at a time. ', ...
     'Appropriate for repeated measures or paired samples designs.']};
 
% ---------------------------------------------------------------------
% cv_lksgo K_folds CV on Subjects per Group
% ---------------------------------------------------------------------
cv_lksgo         = cfg_branch;
cv_lksgo.tag     = 'cv_lksgo';
cv_lksgo.name    = 'k-folds CV on subjects per group';
cv_lksgo.val     = {k_args};
cv_lksgo.help    = {...
    ['K-partitioning of subjects from each group at a time. ', ...
     'Appropriate for repeated measures or paired samples designs.']};
 
% ---------------------------------------------------------------------
% cv_lobo Leave-one-block-out
% ---------------------------------------------------------------------
cv_lobo         = cfg_const;
cv_lobo.tag     = 'cv_lobo';
cv_lobo.name    = 'Leave one block out';
cv_lobo.val     = {1};
cv_lobo.help    = {...
    ['Leave out a single block or event from each subject each iteration. ', ...
     'Appropriate for single subject designs.']};

% ---------------------------------------------------------------------
% cv_lkbo K-fold CV on blocks
% ---------------------------------------------------------------------
cv_lkbo         = cfg_branch;
cv_lkbo.tag     = 'cv_lkbo';
cv_lkbo.name    = 'k-folds CV on blocks';
cv_lkbo.val     = {k_args};
cv_lkbo.help    = {...
    ['k-partitioning on blocks or events from each subject each iteration. ', ...
     'Appropriate for single subject designs.']};
 
% ---------------------------------------------------------------------
% cv_locbo Leave-one-block per class out
% ---------------------------------------------------------------------
cv_locbo         = cfg_const;
cv_locbo.tag     = 'cv_locbo';
cv_locbo.name    = 'Leave one block per class out';
cv_locbo.val     = {1};
cv_locbo.help    = {...
    ['Leave out a single block or event from each class each iteration. ', ...
     'Appropriate for single subject designs.']};

% ---------------------------------------------------------------------
% cv_lkcbo K-fold CV on blocks per class
% ---------------------------------------------------------------------
cv_lkcbo         = cfg_branch;
cv_lkcbo.tag     = 'cv_lkcbo';
cv_lkcbo.name    = 'k-folds CV on block per class';
cv_lkcbo.val     = {k_args};
cv_lkcbo.help    = {...
    ['k-partitioning on blocks or events from each class each iteration. ', ...
     'Appropriate for single subject designs.']};
 
% ---------------------------------------------------------------------
% cv_loro Leave--one-run-per-subject-out (leave one modality out per
% subject)
% ---------------------------------------------------------------------
cv_loro         = cfg_const;
cv_loro.tag     = 'cv_loro';
cv_loro.name    = 'Leave one run/session out';
cv_loro.val     = {1};
cv_loro.help    = {...
    ['Leave out a single run (modality) from each subject each iteration. ', ...
     'Appropriate for single subject designs with multiple runs/sessions.']};

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
% machine_args Custom machine arguments
% ---------------------------------------------------------------------
machine_args         = cfg_entry;
machine_args.tag     = 'machine_args';
machine_args.name    = 'Arguments';
machine_args.help    = {['Arguments for prediction machine.']};
machine_args.strtype = 's';
machine_args.num     = [1 Inf];

% ---------------------------------------------------------------------
% cv_type Cross-validation type for custom machine
% ---------------------------------------------------------------------
machine_cv_type_nested        = cfg_choice;
machine_cv_type_nested.tag    = 'machine_cv_type_nested';
machine_cv_type_nested.name   = 'Cross-validation type for hyper-parameter optimization';
machine_cv_type_nested.values = {cv_loso,cv_lkso, cv_losgo,cv_lksgo, cv_lobo,...
    cv_lkbo, cv_locbo, cv_lkcbo, cv_loro};
machine_cv_type_nested.val    = {cv_loso};
machine_cv_type_nested.help   = {'Choose the type of cross-validation to be used'};

% ---------------------------------------------------------------------
% machine_opt custom : flag whether to optimize hyperparameters
% ---------------------------------------------------------------------
machine_opt         = cfg_menu;
machine_opt.tag     = 'machine_opt';
machine_opt.name    = 'Optimize hyper-parameter';
machine_opt.help    = {['Whether to optimize the machine hyper-parameter(s), or not. '...
    'If Yes, than provide a range of possible values, in the form '...
    'min:step:max. Examples: 10.^[-2:5] or 1:100:1000 or 0.01 0.1 1 10 100. ' ...
    'Multiple hyperparameters should be entered as a cell array, e.g. '...
    '{[0.1 1 10],[0.1:0.1:0.9]}. If not, provide a default value.']};
machine_opt.labels  = {
    'No'
    'Yes'
    }';
machine_opt.values  = {0 1};
machine_opt.val     = {0};

% ---------------------------------------------------------------------
% custom_machine Custom machine settings
% ---------------------------------------------------------------------
custom_machine         = cfg_branch;
custom_machine.tag     = 'custom_machine';
custom_machine.name    = 'Custom machine';
custom_machine.help    = {'Choose another prediction machine'};
custom_machine.val     = {machine_func, machine_opt,machine_args,machine_cv_type_nested};

% ---------------------------------------------------------------------
% svm_opt SVM : flag whether to optimize C
% ---------------------------------------------------------------------
svm_opt         = cfg_menu;
svm_opt.tag     = 'svm_opt';
svm_opt.name    = 'Optimize hyper-parameter';
svm_opt.help    = {['Whether to optimize C, the SVM hyper-parameter, or not. '...
    'If Yes, than provide a range of possible values for C, in the form '...
    'min:step:max. Examples: 10.^[-2:5] or 1:100:1000 or 0.01 0.1 1 10 100. ' ...
    'If not, a default value will be used (C=1).']};
svm_opt.labels  = {
    'No'
    'Yes'
    }';
svm_opt.values  = {0 1};
svm_opt.val     = {0};

% ---------------------------------------------------------------------
% svm_args Regression Targets
% ---------------------------------------------------------------------
svm_args         = cfg_entry;
svm_args.tag     = 'svm_args';
svm_args.name    = 'Soft-margin hyper-parameter';
svm_args.help    = {['Value(s) for prt_machine_svm_bin: soft-margin C. ',...
    'Examples: 10.^[-2:5] or 1:100:1000 or 0.01 0.1 1 10 100.']};
svm_args.strtype = 'e';
svm_args.val     = {def.model.svmargs};
svm_args.num     = [1 Inf];

% ---------------------------------------------------------------------
% cv_type Cross-validation type
% ---------------------------------------------------------------------
svm_cv_type_nested        = cfg_choice;
svm_cv_type_nested.tag    = 'cv_type_nested';
svm_cv_type_nested.name   = 'Cross-validation type for hyper-parameter optimization';
svm_cv_type_nested.values = {cv_loso,cv_lkso, cv_losgo,cv_lksgo, cv_lobo,...
    cv_lkbo, cv_locbo, cv_lkcbo, cv_loro};
svm_cv_type_nested.val    = {cv_loso};
svm_cv_type_nested.help   = {'Choose the type of cross-validation to be used'};

% ---------------------------------------------------------------------
% svm group
% ---------------------------------------------------------------------
svm         = cfg_branch;
svm.tag     = 'svm';
svm.name    = 'SVM Classification';
svm.help    = {'Binary support vector machine.'};
svm.val     = {svm_opt, svm_args, svm_cv_type_nested};

% ---------------------------------------------------------------------
% gpc_args GPC arguments
% ---------------------------------------------------------------------
gpc_args         = cfg_entry;
gpc_args.tag     = 'gpc_args';
gpc_args.name    = 'Arguments';
gpc_args.help    = {['Arguments for prt_machine_gpml']};
gpc_args.strtype = 's';
gpc_args.val     = {def.model.gpcargs};
gpc_args.num     = [1 Inf];

% ---------------------------------------------------------------------
% gpc GPC
% ---------------------------------------------------------------------
gpc         = cfg_branch;
gpc.tag     = 'gpc';
gpc.name    = 'Gaussian Process Classification';
gpc.help    = {'Gaussian Process Classification'};
gpc.val     = {gpc_args};

% ---------------------------------------------------------------------
% gpclap_args GPC arguments
% ---------------------------------------------------------------------
gpclap_args         = cfg_entry;
gpclap_args.tag     = 'gpclap_args';
gpclap_args.name    = 'Arguments';
gpclap_args.help    = {['Arguments for prt_machine_gpclap']};
gpclap_args.strtype = 's';
gpclap_args.val     = {def.model.gpclapargs};
gpclap_args.num     = [1 Inf];

% ---------------------------------------------------------------------
% gpclap GPC
% ---------------------------------------------------------------------
gpclap         = cfg_branch;
gpclap.tag     = 'gpclap';
gpclap.name    = 'Multiclass GPC';
gpclap.help    = {'Multiclass GPC'};
gpclap.val     = {gpclap_args};

% ---------------------------------------------------------------------
% sMKL_cla_opt L1-MKL : flag whether to optimize C
% ---------------------------------------------------------------------
sMKL_cla_opt         = cfg_menu;
sMKL_cla_opt.tag     = 'sMKL_cla_opt';
sMKL_cla_opt.name    = 'Optimize hyper-parameter';
sMKL_cla_opt.help    = {['Whether to optimize C, the SVM hyper-parameter, or not. '...
    'If Yes, than provide a range of possible values for C, in the form '...
    'min:step:max. Examples: 10.^[-2:5] or 1:100:1000 or 0.01 0.1 1 10 100. ' ...
    'If not, a default value will be used (C=1).']};
sMKL_cla_opt.labels  = {
    'No'
    'Yes'
    }';
sMKL_cla_opt.values  = {0 1};
sMKL_cla_opt.val     = {0};

% ---------------------------------------------------------------------
% sMKL_cla_args L1-MKL arguments
% ---------------------------------------------------------------------
sMKL_cla_args         = cfg_entry;
sMKL_cla_args.tag     = 'sMKL_cla_args';
sMKL_cla_args.name    = 'Arguments';
sMKL_cla_args.help    = {['Arguments for prt_machine_sMKL_cla (same as for SVM)',...
    'Examples: 10.^[-2:5] or 1:100:1000 or 0.01 0.1 1 10 100.']};
sMKL_cla_args.strtype = 'e';
sMKL_cla_args.val     = {def.model.l1MKLargs};
sMKL_cla_args.num     = [1 Inf];

% ---------------------------------------------------------------------
% cv_type Cross-validation type
% ---------------------------------------------------------------------
sMKL_cla_cv_type_nested        = cfg_choice;
sMKL_cla_cv_type_nested.tag    = 'cv_type_nested';
sMKL_cla_cv_type_nested.name   = 'Cross-validation type for hyper-parameter optimization';
sMKL_cla_cv_type_nested.values = {cv_loso,cv_lkso, cv_losgo,cv_lksgo, cv_lobo,...
    cv_lkbo, cv_locbo, cv_lkcbo, cv_loro};
sMKL_cla_cv_type_nested.val    = {cv_loso};
sMKL_cla_cv_type_nested.help   = {'Choose the type of cross-validation to be used'};

% ---------------------------------------------------------------------
% sMKL_cla simple (L1) MKL
% ---------------------------------------------------------------------
sMKL_cla         = cfg_branch;
sMKL_cla.tag     = 'sMKL_cla';
sMKL_cla.name    = 'L1 Multi-Kernel Learning';
sMKL_cla.help    = {'Multi-Kernel Learning. Choose only if multiple kernels ' ...
    'were built during the feature set construction (either multiple modalities or ROIs). ' ...
    'It is strongly advised to "normalize" the kernels (in "operations").'};
sMKL_cla.val     = {sMKL_cla_opt, sMKL_cla_args, sMKL_cla_cv_type_nested};

% ---------------------------------------------------------------------
% gpr_args GPR arguments
% ---------------------------------------------------------------------
gpr_args         = cfg_entry;
gpr_args.tag     = 'gpr_args';
gpr_args.name    = 'Arguments';
gpr_args.help    = {['Arguments for prt_machine_gpr']};
gpr_args.strtype = 's';
gpr_args.val     = {def.model.gprargs};
gpr_args.num     = [1 Inf];

% ---------------------------------------------------------------------
% gpr GPR
% ---------------------------------------------------------------------
gpr         = cfg_branch;
gpr.tag     = 'gpr';
gpr.name    = 'Gaussian Process Regression';
gpr.help    = {'Gaussian Process Regression'};
gpr.val     = {gpr_args};

% ---------------------------------------------------------------------
% sMKL_reg_opt L1-MKL : flag whether to optimize the hyperparameter
% ---------------------------------------------------------------------
sMKL_reg_opt         = cfg_menu;
sMKL_reg_opt.tag     = 'sMKL_reg_opt';
sMKL_reg_opt.name    = 'Optimize hyper-parameter';
sMKL_reg_opt.help    = {['Whether to optimize C, the MKL hyper-parameter, or not. '...
    'If Yes, than provide a range of possible values for C, in the form '...
    'min:step:max. Examples: 10.^[-2:5] or 1:100:1000 or 0.01 0.1 1 10 100. ' ...
    'If not, a default value will be used (C=1).']};
sMKL_reg_opt.labels  = {
    'No'
    'Yes'
    }';
sMKL_reg_opt.values  = {0 1};
sMKL_reg_opt.val     = {0};

% ---------------------------------------------------------------------
% sMKL_reg_args sMKL_reg arguments
% ---------------------------------------------------------------------
sMKL_reg_args         = cfg_entry;
sMKL_reg_args.tag     = 'sMKL_reg_args';
sMKL_reg_args.name    = 'Arguments';
sMKL_reg_args.help    = {['Arguments for prt_machine_sMKL_reg']};
sMKL_reg_args.strtype = 'e';
sMKL_reg_args.val     = {def.model.l1MKLargs};
sMKL_reg_args.num     = [1 Inf];

% ---------------------------------------------------------------------
% cv_type Cross-validation type
% ---------------------------------------------------------------------
sMKL_reg_cv_type_nested        = cfg_choice;
sMKL_reg_cv_type_nested.tag    = 'cv_type_nested';
sMKL_reg_cv_type_nested.name   = 'Cross-validation type for hyper-parameter optimization';
sMKL_reg_cv_type_nested.values = {cv_loso,cv_lkso, cv_losgo,cv_lksgo, cv_lobo,...
    cv_lkbo, cv_loro};
sMKL_reg_cv_type_nested.val    = {cv_loso};
sMKL_reg_cv_type_nested.help   = {'Choose the type of cross-validation to be used'};

% ---------------------------------------------------------------------
% sMKL_reg sMKL regression
% ---------------------------------------------------------------------
sMKL_reg         = cfg_branch;
sMKL_reg.tag     = 'sMKL_reg';
sMKL_reg.name    = 'Multi-Kernel Regression';
sMKL_reg.help    = {'Multi-Kernel Regression'};
sMKL_reg.val     = {sMKL_reg_opt, sMKL_reg_args, sMKL_reg_cv_type_nested};

% ---------------------------------------------------------------------
% krr_opt SVM : flag whether to optimize C
% ---------------------------------------------------------------------
krr_opt         = cfg_menu;
krr_opt.tag     = 'krr_opt';
krr_opt.name    = 'Optimize hyper-parameter';
krr_opt.help    = {['Whether to optimize K, the KRR hyper-parameter, or not. '...
    'If Yes, than provide a range of possible values for K, in the form '...
    'min:step:max. Examples: 10.^[-2:5] or 1:100:1000 or 0.01 0.1 1 10 100. ' ...
    'If not, a default value will be used.']};
krr_opt.labels  = {
    'No'
    'Yes'
    }';
krr_opt.values  = {0 1};
krr_opt.val     = {0};

% ---------------------------------------------------------------------
% krr_args Regression Targets
% ---------------------------------------------------------------------
krr_args         = cfg_entry;
krr_args.tag     = 'krr_args';
krr_args.name    = 'Regularization';
krr_args.help    = {['Regularization for prt_machine_krr. ',...
    'Examples: 10.^[-2:5] or 1:100:1000 or 0.01 0.1 1 10 100.']};
krr_args.strtype = 'e';
krr_args.val     = {1};
krr_args.num     = [1 Inf];

% ---------------------------------------------------------------------
% cv_type Cross-validation type
% ---------------------------------------------------------------------
krr_cv_type_nested        = cfg_choice;
krr_cv_type_nested.tag    = 'cv_type_nested';
krr_cv_type_nested.name   = 'Cross-validation type for hyper-parameter optimization';
krr_cv_type_nested.values = {cv_loso,cv_lkso, cv_losgo,cv_lksgo, cv_lobo,...
    cv_lkbo, cv_loro};
krr_cv_type_nested.val    = {cv_loso};
krr_cv_type_nested.help   = {'Choose the type of cross-validation to be used'};

% ---------------------------------------------------------------------
% KRR group
% ---------------------------------------------------------------------
krr         = cfg_branch;
krr.tag     = 'krr';
krr.name    = 'Kernel Ridge Regression';
krr.help    = {'Kernel Ridge Regression.'};
krr.val     = {krr_opt,krr_args,krr_cv_type_nested};

% ---------------------------------------------------------------------
% RVR group
% ---------------------------------------------------------------------
rvr         = cfg_branch;
rvr.tag     = 'rvr';
rvr.name    = 'Relevance Vector Regression';
rvr.help    = {'Relevance Vector Regression. Tipping, Michael E.; Smola, Alex (2001).' ...
    '"Sparse Bayesian Learning and the Relevance Vector Machine". Journal of Machine Learning Research 1: 211?244.'};

% ---------------------------------------------------------------------
% rt_args Arguments to RT
% ---------------------------------------------------------------------
rt_args         = cfg_entry;
rt_args.tag     = 'rt_args';
rt_args.name    = 'Ntrees';
rt_args.help    = {['Number of trees in the forest.']};
rt_args.strtype = 'e';
rt_args.val     = {601};
rt_args.num     = [1 1];

% ---------------------------------------------------------------------
% RT group
% ---------------------------------------------------------------------
rt         = cfg_branch;
rt.tag     = 'rt';
rt.name    = 'Random Forest';
rt.help    = {'Random Forest. Breiman, Leo (2001)."Random Forests". ' ...
               'Machine Learning 45:5-32. This is a wrapper around ' ...
               'Peter Geurt''s implementation in his Regression Tree ' ...
               ' package.' };
rt.val     = {rt_args};

% ---------------------------------------------------------------------
% machine Select Features
% ---------------------------------------------------------------------
machine        = cfg_choice;
machine.tag    = 'machine';
machine.name   = 'Machine';
machine.values = {svm,gpc,gpclap,sMKL_cla,krr,rvr,gpr,sMKL_reg,custom_machine};
machine.val    =  {svm};
machine.help   = {...
    ['Choose a prediction machine for this model']};
% rt is out for the moment

% ---------------------------------------------------------------------
% model_type Model type
% ---------------------------------------------------------------------
model_type        = cfg_choice;
model_type.tag    = 'model_type';
model_type.name   = 'Model Type ';
model_type.values = {machine};
model_type.help   = {'Select which machine should be used. The selected '...
    'machine should be of the same type (i.e. classification or regression)'...
    ' as in the copied model.'};

% ---------------------------------------------------------------------
% no_op All scans
% ---------------------------------------------------------------------
no_op         = cfg_const;
no_op.tag     = 'no_op';
no_op.name    = 'No operations';
no_op.val     = {1};
no_op.help    = {['No design specified. This option can be used '...
    'for modalities (e.g. structural scans) that do not '...
    'have an experimental design or for an fMRI design',...
    'where you want to include all scans in the timeseries']};

% ---------------------------------------------------------------------
% data_op Operation
% ---------------------------------------------------------------------
data_op         = cfg_menu;
data_op.tag     = 'data_op';
data_op.name    = 'Operation';
data_op.help    = {'Select an operation to apply.'};
% data_op.labels  = {
%     'Done'
%     'Sample averaging (within block)'
%     'Sample averaging (within subject/condition)'
%     'Mean centre features using training data'
%     'Normalize samples'
%     'Regress out covariates (subjects only)'
% }';
% data_op.values  = {0 1 2 3 4 5};
data_op.labels  = {
    'Done'
    'Sample averaging (within block)'
    'Sample averaging (within subject/condition)'
    'Mean centre features using training data'
    'Normalize samples'
    }';
data_op.values  = {0 1 2 3 4};
data_op.val     = {0};

% ---------------------------------------------------------------------
% data_op Operation
% ---------------------------------------------------------------------
data_op_mc         = cfg_menu;
data_op_mc.tag     = 'data_op_mc';
data_op_mc.name    = 'Mean centre features';
data_op_mc.help    = {'Select an operation to apply.'};
data_op_mc.labels  = {
    'Yes'
    'No'
}';
data_op_mc.values  = {1 0};
data_op_mc.val     = {1};

% ---------------------------------------------------------------------
% other_ops Other Operations
% ---------------------------------------------------------------------
other_ops         = cfg_repeat;
other_ops.tag     = 'other_ops';
other_ops.name    = 'Select Operations';
other_ops.help    = {...
    ['Add zero or more operations to be applied to the data before the ',...
     'prediction machine is called. These are executed within the ',...
     'cross-validation loop (i.e. they respect training/test independence) ',...
     'and will be executed in the order specified. ']};
other_ops.num     = [1 Inf];
other_ops.values  = {data_op};

% ---------------------------------------------------------------------
% use_other_ops Use other operations
% ---------------------------------------------------------------------
use_other_ops        = cfg_choice;
use_other_ops.tag    = 'use_other_ops';
use_other_ops.name   = 'Other Operations';
use_other_ops.values = {no_op, other_ops };
use_other_ops.val    = {no_op};
use_other_ops.help   = {'Include other operations?'};

% ---------------------------------------------------------------------
% sel_ops Class
% ---------------------------------------------------------------------
sel_ops         = cfg_branch;
sel_ops.tag     = 'sel_ops';
sel_ops.name    = 'Data operations';
sel_ops.help    = {...
    ['Specify operations to apply']};
sel_ops.val     = {data_op_mc use_other_ops};

% ---------------------------------------------------------------------
% data_ops Select Features
% ---------------------------------------------------------------------
data_ops        = cfg_choice;
data_ops.tag    = 'data_ops';
data_ops.name   = 'Data Operations';
data_ops.values = {data_op_mc, sel_ops};
data_ops.val    =  {no_op};
data_ops.help   = {...
    ['This branch controls operations that can be applied to the data ',...
     'before the data is passed to the classifier. Add zero or more ',...
     'operations to be applied. These will be executed in the order ',...
     'specified. ']}; 

% ---------------------------------------------------------------------
% modchoices Choice of field to modify
% ---------------------------------------------------------------------
modchoices        = cfg_choice;
modchoices.tag    = 'modchoices';
modchoices.name   = 'Field';
modchoices.values = {fsets,model_type,sel_ops};
modchoices.val    =  {fsets};
modchoices.help   = {...
    ['Field to modify in copied model. All choices performed should ',...
    'be consistent with the selected model type, selected samples ',...
    'and cross-validation scheme.']}; 
  
% ---------------------------------------------------------------------
%  tochange fields to be modified
% ---------------------------------------------------------------------
tochange         = cfg_repeat;
tochange.tag     = 'tochange';
tochange.name    = 'Fields to modify';
tochange.help    = {['Modify one field in this model. Click ''new'' '...
                    'or ''repeat'' to add another field.']};
tochange.num     = [1 Inf];
tochange.values     = {modchoices};
 
% ---------------------------------------------------------------------
% modify Feature set(s)
% ---------------------------------------------------------------------
modify         = cfg_branch;
modify.tag     = 'modify';
modify.name    = 'Modify the model';
modify.help    = {'Choose one or more fields to modify in copied model.'};
modify.val     = {tochange};

% ---------------------------------------------------------------------
% copymodel Model
% ---------------------------------------------------------------------
copymodel        = cfg_exbranch;
copymodel.tag    = 'copymodel';
copymodel.name   = 'Model: Specify from';
copymodel.val    = {infile, ...
                model_name, ...
                copymodel_name, ...
                tochange};
copymodel.help   = {'Specify model from a previsouly specified model and change a few fields.'};
copymodel.prog   = @prt_run_copy_model;
copymodel.vout   = @vout_data;

%------------------------------------------------------------------------
%% Output function
%------------------------------------------------------------------------
function cdep = vout_data(job)
% Specifies the output from this modules, i.e. the filename of the mat file

cdep(1)            = cfg_dep;
cdep(1).sname      = 'PRT.mat file';
cdep(1).src_output = substruct('.','files');
cdep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
cdep(2)            = cfg_dep;
cdep(2).sname      = 'Model name';
cdep(2).src_output = substruct('.','mname');
cdep(2).tgt_spec   = cfg_findspec({{'strtype','s'}});
%------------------------------------------------------------------------

% ---------------------------------------------------------------------
% use_kernel Use Kernels - Do not allow to change kernel or not
% ---------------------------------------------------------------------
% use_kernel         = cfg_menu;
% use_kernel.tag     = 'use_kernel';
% use_kernel.name    = 'Use kernels';
% use_kernel.help    = {...
%     ['Are the data for this model in the form of kernels/basis functions? ', ...
%      'If ''No'' is selected, it is assumed the data are in the form of ',...
%      'feature matrices']};
% use_kernel.labels  = {
%                'Yes'
%                'No'
% }';
% use_kernel.values  = {1 0};
% use_kernel.val     = {1};

