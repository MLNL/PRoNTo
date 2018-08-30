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
machine_args.name    = 'Regularization hyper-parameter';
machine_args.help    = {['Hyper-parameter range for prediction machine.']};
machine_args.strtype = 'e';
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
% machine_opt_p
% ---------------------------------------------------------------------
machine_opt_p        = cfg_branch;
machine_opt_p.tag     = 'machine_opt_p';
machine_opt_p.name    = 'Optimize hyper-parameter';
machine_opt_p.help    = {'Specify range of values and nested CV.'};
machine_opt_p.val     = {machine_args,machine_cv_type_nested};

% ---------------------------------------------------------------------
% machine_no_opt
% ---------------------------------------------------------------------
machine_no_opt         = cfg_entry;
machine_no_opt.tag     = 'machine_no_opt';
machine_no_opt.name    = 'No optimization';
machine_no_opt.help    = {'Enter parameter fixed value if needed.'};
machine_no_opt.strtype = 'e';
machine_no_opt.val     = {''};
machine_no_opt.num     = [1 Inf];

% ---------------------------------------------------------------------
% machine_opt group
% ---------------------------------------------------------------------
machine_opt         = cfg_choice;
machine_opt.tag     = 'machine_opt';
machine_opt.name    = 'Custom machine optimization and parameters';
machine_opt.help    = {'Choose whether to optimize machine or not'};
machine_opt.values     = {machine_no_opt,machine_opt_p};


% ---------------------------------------------------------------------
% machine_sargs Custom machine string argument
% ---------------------------------------------------------------------
machine_sargs         = cfg_entry;
machine_sargs.tag     = 'machine_sargs';
machine_sargs.name    = 'Custom machine string argument';
machine_sargs.help    = {['String argument for custom machine.']};
machine_sargs.strtype = 's';
machine_sargs.val     = {''};
machine_sargs.num     = [1 Inf];

% ---------------------------------------------------------------------
% custom_machine Custom machine settings
% ---------------------------------------------------------------------
custom_machine         = cfg_branch;
custom_machine.tag     = 'custom_machine';
custom_machine.name    = 'Custom machine';
custom_machine.help    = {'Choose another prediction machine'};
custom_machine.val     = {machine_func, machine_sargs, machine_opt};

% kernel classification methods

% ---------------------------------------------------------------------
% svm_args SVM argument values
% ---------------------------------------------------------------------
svm_args         = cfg_entry;
svm_args.tag     = 'svm_args';
svm_args.name    = 'Regularization hyper-parameter';
svm_args.help    = {['Value(s) for hyper-parameter. ',...
    'Examples: 10.^[-2:5] or 1:100:1000 or 0.01 0.1 1 10 100.']};
svm_args.strtype = 'e';
svm_args.val     = {def.model.libsvm_optargs};
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
% svm_opt_C
% ---------------------------------------------------------------------
svm_opt_C         = cfg_branch;
svm_opt_C.tag     = 'svm_opt_C';
svm_opt_C.name    = 'Optimize hyper-parameter';
svm_opt_C.help    = {'Specify range of values and nested CV.'};
svm_opt_C.val     = {svm_args,svm_cv_type_nested};

% ---------------------------------------------------------------------
% svm_no_opt
% ---------------------------------------------------------------------
svm_no_opt         = cfg_entry;
svm_no_opt.tag     = 'svm_no_opt';
svm_no_opt.name    = 'No optimization';
svm_no_opt.help    = {'Getting default value.'};
svm_no_opt.strtype = 'e';
svm_no_opt.val     = {def.model.libsvmargs};
svm_no_opt.num     = [1 1];

% ---------------------------------------------------------------------
% svm_opt group
% ---------------------------------------------------------------------
svm_opt         = cfg_choice;
svm_opt.tag     = 'svm_opt';
svm_opt.name    = 'Machine optimization and parameters';
svm_opt.help    = {'Choose whether to optimize machine or not'};
svm_opt.values     = {svm_no_opt,svm_opt_C};

% ---------------------------------------------------------------------
% svm_sargs SVM string argument
% ---------------------------------------------------------------------
svm_sargs         = cfg_entry;
svm_sargs.tag     = 'svm_sargs';
svm_sargs.name    = 'SVM string argument';
svm_sargs.help    = {['String argument for LIBSVM interfacing.']};
svm_sargs.strtype = 's';
svm_sargs.val     = {def.model.libsvm_sargs};
svm_sargs.num     = [1 Inf];

% ---------------------------------------------------------------------
% svm group
% ---------------------------------------------------------------------
svm         = cfg_branch;
svm.tag     = 'svm';
svm.name    = 'SVM Classification';
svm.help    = {'Binary support vector machine.'};
svm.val     = {svm_sargs,svm_opt};

% ---------------------------------------------------------------------
% gpc_args GPC arguments
% ---------------------------------------------------------------------
gpc_sargs         = cfg_entry;
gpc_sargs.tag     = 'gpc_sargs';
gpc_sargs.name    = 'String arguments';
gpc_sargs.help    = {['String arguments for GPML machine binary classification machine.']};
gpc_sargs.strtype = 's';
gpc_sargs.val     = {def.model.gpc_sargs};
gpc_sargs.num     = [1 Inf];

% ---------------------------------------------------------------------
% gpc GPC
% ---------------------------------------------------------------------
gpc         = cfg_branch;
gpc.tag     = 'gpc';
gpc.name    = 'Gaussian Process Classification';
gpc.help    = {'Gaussian Process Classification'};
gpc.val     = {gpc_sargs};

% ---------------------------------------------------------------------
% gpclap_args GPC arguments
% ---------------------------------------------------------------------
gpclap_sargs         = cfg_entry;
gpclap_sargs.tag     = 'gpclap_sargs';
gpclap_sargs.name    = 'String arguments';
gpclap_sargs.help    = {['String arguments for GPML multiclass classification machine.']};
gpclap_sargs.strtype = 's';
gpclap_sargs.val     = {def.model.gpclap_sargs};
gpclap_sargs.num     = [1 Inf];

% ---------------------------------------------------------------------
% gpclap GPC - multiclass
% ---------------------------------------------------------------------
gpclap         = cfg_branch;
gpclap.tag     = 'gpclap';
gpclap.name    = 'Multiclass GPC';
gpclap.help    = {'Multiclass GPC'};
gpclap.val     = {gpclap_sargs};

% ---------------------------------------------------------------------
% sMKL_cla simple (L1) MKL
% ---------------------------------------------------------------------
sMKL_cla         = cfg_branch;
sMKL_cla.tag     = 'sMKL_cla';
sMKL_cla.name    = 'L1 Multi-Kernel Learning';
sMKL_cla.help    = {'Multi-Kernel Learning. Choose only if multiple kernels ' ...
    'were built during the feature set construction (either multiple modalities or ROIs). ' ...
    'It is strongly advised to "normalize" the kernels (in "operations").'};
sMKL_cla.val     = {svm_opt};

% ---------------------------------------------------------------------
% libl2KLR_sargs L2 Logistic Regression string argument (dual)
% ---------------------------------------------------------------------
libl2KLR_sargs         = cfg_entry;
libl2KLR_sargs.tag     = 'libl2KLR_sargs';
libl2KLR_sargs.name    = 'String arguments';
libl2KLR_sargs.help    = {['String arguments for LIBLINEAR interface.']};
libl2KLR_sargs.strtype = 's';
libl2KLR_sargs.val     = {def.model.libl2KLR_sargs};
libl2KLR_sargs.num     = [1 Inf];

% ---------------------------------------------------------------------
% libl2KLR group
% ---------------------------------------------------------------------
libl2KLR         = cfg_branch;
libl2KLR.tag     = 'libl2KLR';
libl2KLR.name    = 'L2-Logistic Regression';
libl2KLR.help    = {'Kernel L2-regularized Logistic Regression from LIBLINEAR.'};
libl2KLR.val     = {libl2KLR_sargs,svm_opt};


% Non-kernel classification methods


% ---------------------------------------------------------------------
% libl2svm_sargs SVM string argument (primal)
% ---------------------------------------------------------------------
libl2svm_sargs         = cfg_entry;
libl2svm_sargs.tag     = 'libl2svm_sargs';
libl2svm_sargs.name    = 'String arguments';
libl2svm_sargs.help    = {['String arguments for LIBLINEAR interfacing.']};
libl2svm_sargs.strtype = 's';
libl2svm_sargs.val     = {def.model.libl2svm_sargs};
libl2svm_sargs.num     = [1 Inf];

% ---------------------------------------------------------------------
% libl2svm group
% ---------------------------------------------------------------------
libl2svm         = cfg_branch;
libl2svm.tag     = 'libl2svm';
libl2svm.name    = 'Binary L2-SVM';
libl2svm.help    = {'Non-kernel L2-regularized L2-Loss support vector machine,can be used for multiclass problem.'};
libl2svm.val     = {libl2svm_sargs,svm_opt};

% ---------------------------------------------------------------------
% libl1svm_sargs L1-SVM string argument (primal)
% ---------------------------------------------------------------------
libl1svm_sargs         = cfg_entry;
libl1svm_sargs.tag     = 'libl1svm_sargs';
libl1svm_sargs.name    = 'String arguments';
libl1svm_sargs.help    = {['String arguments for LIBLINEAR interface.']};
libl1svm_sargs.strtype = 's';
libl1svm_sargs.val     = {def.model.libl1svm_sargs};
libl1svm_sargs.num     = [1 Inf];

% ---------------------------------------------------------------------
% libl1svm group
% ---------------------------------------------------------------------
libl1svm         = cfg_branch;
libl1svm.tag     = 'libl1svm';
libl1svm.name    = 'Binary L1-SVM';
libl1svm.help    = {'Non-kernel L1-regularized L2-Loss support vector machine.'};
libl1svm.val     = {libl1svm_sargs,svm_opt};

% ---------------------------------------------------------------------
% libmulticlsvm_sargs Multiclass-SVM string argument (primal)
% ---------------------------------------------------------------------
libmulticlsvm_sargs         = cfg_entry;
libmulticlsvm_sargs.tag     = 'libmulticlsvm_sargs';
libmulticlsvm_sargs.name    = 'String arguments';
libmulticlsvm_sargs.help    = {['String arguments for LIBLINEAR interface.']};
libmulticlsvm_sargs.strtype = 's';
libmulticlsvm_sargs.val     = {def.model.libmulticlsvm_sargs};
libmulticlsvm_sargs.num     = [1 Inf];

% ---------------------------------------------------------------------
% libmulticlsvm group
% ---------------------------------------------------------------------
libmulticlsvm         = cfg_branch;
libmulticlsvm.tag     = 'libmulticlsvm';
libmulticlsvm.name    = 'Multiclass SVM';
libmulticlsvm.help    = {['Multiclass support vector classification by ',...
    'Crammer and Singer, can also be used for binary classification.']};
libmulticlsvm.val     = {libmulticlsvm_sargs,svm_opt};

% ---------------------------------------------------------------------
% libl2LR_sargs L2 Logistic Regression string argument (primal)
% ---------------------------------------------------------------------
libl2LR_sargs         = cfg_entry;
libl2LR_sargs.tag     = 'libl2LR_sargs';
libl2LR_sargs.name    = 'String arguments';
libl2LR_sargs.help    = {['String arguments for LIBLINEAR interface.']};
libl2LR_sargs.strtype = 's';
libl2LR_sargs.val     = {def.model.libl2LR_sargs};
libl2LR_sargs.num     = [1 Inf];

% ---------------------------------------------------------------------
% libl2LR group
% ---------------------------------------------------------------------
libl2LR         = cfg_branch;
libl2LR.tag     = 'libl2LR';
libl2LR.name    = 'L2-Logistic Regression';
libl2LR.help    = {'Non-kernel L2-regularized Logistic Regression from LIBLINEAR.'};
libl2LR.val     = {libl2LR_sargs,svm_opt};

% ---------------------------------------------------------------------
% libl2LR_sargs L2 Logistic Regression string argument (primal)
% ---------------------------------------------------------------------
libl1LR_sargs         = cfg_entry;
libl1LR_sargs.tag     = 'libl1LR_sargs';
libl1LR_sargs.name    = 'String arguments';
libl1LR_sargs.help    = {['String arguments for LIBLINEAR interface.']};
libl1LR_sargs.strtype = 's';
libl1LR_sargs.val     = {def.model.libl1LR_sargs};
libl1LR_sargs.num     = [1 Inf];

% ---------------------------------------------------------------------
% libl2LR group
% ---------------------------------------------------------------------
libl1LR         = cfg_branch;
libl1LR.tag     = 'libl1LR';
libl1LR.name    = 'L1-Logistic Regression';
libl1LR.help    = {'Non-kernel L1-regularized Logistic Regression from LIBLINEAR.'};
libl1LR.val     = {libl1LR_sargs,svm_opt};

% Regression machines - dual

% ---------------------------------------------------------------------
% gpr_sargs GPR arguments
% ---------------------------------------------------------------------
gpr_sargs         = cfg_entry;
gpr_sargs.tag     = 'gpr_sargs';
gpr_sargs.name    = 'String arguments';
gpr_sargs.help    = {['String arguments for GMPL machine prt_machine_gpr.']};
gpr_sargs.strtype = 's';
gpr_sargs.val     = {def.model.gpr_sargs};
gpr_sargs.num     = [1 Inf];

% ---------------------------------------------------------------------
% gpr GPR
% ---------------------------------------------------------------------
gpr         = cfg_branch;
gpr.tag     = 'gpr';
gpr.name    = 'Gaussian Process Regression';
gpr.help    = {'Gaussian Process Regression'};
gpr.val     = {gpr_sargs};

% ---------------------------------------------------------------------
% sMKL_reg sMKL regression
% ---------------------------------------------------------------------
sMKL_reg         = cfg_branch;
sMKL_reg.tag     = 'sMKL_reg';
sMKL_reg.name    = 'Multi-Kernel Regression';
sMKL_reg.help    = {'Multi-Kernel Regression'};
sMKL_reg.val     = {svm_opt};

% ---------------------------------------------------------------------
% KRR machine
% ---------------------------------------------------------------------
krr         = cfg_branch;
krr.tag     = 'krr';
krr.name    = 'Kernel Ridge Regression';
krr.help    = {'Kernel Ridge Regression.'};
krr.val     = {svm_opt};

% ---------------------------------------------------------------------
% RVR machine
% ---------------------------------------------------------------------
rvr         = cfg_branch;
rvr.tag     = 'rvr';
rvr.name    = 'Relevance Vector Regression';
rvr.help    = {'Relevance Vector Regression. Tipping, Michael E.; Smola, Alex (2001).' ...
    '"Sparse Bayesian Learning and the Relevance Vector Machine". Journal of Machine Learning Research 1: 211?244.'};

% ---------------------------------------------------------------------
% libeSVR_sargs epsilon SVR string argument (dual)
% ---------------------------------------------------------------------
libeSVR_sargs         = cfg_entry;
libeSVR_sargs.tag     = 'libeSVR_sargs';
libeSVR_sargs.name    = 'String arguments';
libeSVR_sargs.help    = {['String arguments for LIBSVM interface.']};
libeSVR_sargs.strtype = 's';
libeSVR_sargs.val     = {def.model.libeSVR_sargs};
libeSVR_sargs.num     = [1 Inf];

% ---------------------------------------------------------------------
% libeSVR group
% ---------------------------------------------------------------------
libeSVR         = cfg_branch;
libeSVR.tag     = 'libeSVR';
libeSVR.name    = 'epsilon-SVR';
libeSVR.help    = {'Kernel epsilon Support Vector Regression from LIBSVM.'};
libeSVR.val     = {libeSVR_sargs,svm_opt};

% Non-kernel regression machines

% ---------------------------------------------------------------------
% libl2SVR_sargs epsilon-SVR string argument (primal)
% ---------------------------------------------------------------------
libl2SVR_sargs         = cfg_entry;
libl2SVR_sargs.tag     = 'libl2SVR_sargs';
libl2SVR_sargs.name    = 'String arguments';
libl2SVR_sargs.help    = {['String arguments for LIBLINEAR interface.']};
libl2SVR_sargs.strtype = 's';
libl2SVR_sargs.val     = {def.model.libl2SVR_sargs};
libl2SVR_sargs.num     = [1 Inf];

% ---------------------------------------------------------------------
% libl2SVR group
% ---------------------------------------------------------------------
libl2SVR         = cfg_branch;
libl2SVR.tag     = 'libl2SVR';
libl2SVR.name    = 'epsilon-SVR';
libl2SVR.help    = {'Non-kernel epsilon-Support Vector Regression from LIBLINEAR.'};
libl2SVR.val     = {libl2SVR_sargs,svm_opt};

% ---------------------------------------------------------------------
% rt_args Arguments to RT
% ---------------------------------------------------------------------
rt_args         = cfg_entry;
rt_args.tag     = 'rt_args';
rt_args.name    = 'Ntrees';
rt_args.help    = {['Number of trees in the forest.']};
rt_args.strtype = 'e';
rt_args.val     = {def.model.rt_optargs};
rt_args.num     = [1 1];

% ---------------------------------------------------------------------
% rt_opt_T
% ---------------------------------------------------------------------
rt_opt_T         = cfg_branch;
rt_opt_T.tag     = 'rt_opt_T';
rt_opt_T.name    = 'Optimize hyper-parameter';
rt_opt_T.help    = {'Specify range of values and nested CV.'};
rt_opt_T.val     = {rt_args,svm_cv_type_nested};

% ---------------------------------------------------------------------
% rt_no_opt
% ---------------------------------------------------------------------
rt_no_opt         = cfg_entry;
rt_no_opt.tag     = 'rt_no_opt';
rt_no_opt.name    = 'No optimization';
rt_no_opt.help    = {'Getting default value.'};
rt_no_opt.strtype = 'e';
rt_no_opt.val     = {def.model.rtargs};
rt_no_opt.num     = [1 1];

% ---------------------------------------------------------------------
% rt_opt group
% ---------------------------------------------------------------------
rt_opt         = cfg_choice;
rt_opt.tag     = 'rt_opt';
rt_opt.name    = 'Random Tree optimization and parameters';
rt_opt.help    = {'Choose whether to optimize machine or not'};
rt_opt.values     = {rt_no_opt,rt_opt_T};

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
rt.val     = {rt_opt};

% ---------------------------------------------------------------------
% mach_cl_nonkernel Select Non-Kernel Machine for classification
% ---------------------------------------------------------------------
mach_cl_nonkernel       = cfg_choice;
mach_cl_nonkernel.tag    = 'mach_cl_nonkernel';
mach_cl_nonkernel.name   = 'Non-kernel machine';
mach_cl_nonkernel.values = {libl2svm,libmulticlsvm,libl1svm, libl2LR,libl1LR, custom_machine}; 
mach_cl_nonkernel.val    =  {custom_machine};
mach_cl_nonkernel.help   = {...
    ['Choose a non-kernel prediction machine for this model']};
% Random Trees = rt

% ---------------------------------------------------------------------
% mach_cl_kernel Select Kernel Machine for classification
% ---------------------------------------------------------------------
mach_cl_kernel       = cfg_choice;
mach_cl_kernel.tag    = 'mach_cl_kernel';
mach_cl_kernel.name   = 'Kernel machine';
mach_cl_kernel.values = {svm,libl2KLR, gpc, gpclap, sMKL_cla, custom_machine}; 
mach_cl_kernel.val    =  {svm};
mach_cl_kernel.help   = {...
    ['Choose a kernel prediction machine for this model']};

% ---------------------------------------------------------------------
% machine_cl_K Kernel or non-kernel machine for classification
% ---------------------------------------------------------------------
machine_cl_K        = cfg_choice;
machine_cl_K.tag    = 'machine_cl_K';
machine_cl_K.name   = 'Classification ';
machine_cl_K.values = {mach_cl_kernel, mach_cl_nonkernel};
machine_cl_K.help   = {'Select whether a kernel or non-kernel method is to be used.'};

% ---------------------------------------------------------------------
% mach_rg_nonkernel Select Non-Kernel Machine for regression
% ---------------------------------------------------------------------
mach_rg_nonkernel       = cfg_choice;
mach_rg_nonkernel.tag    = 'mach_rg_nonkernel';
mach_rg_nonkernel.name   = 'Non-kernel machine';
mach_rg_nonkernel.values = {libl2SVR, custom_machine}; 
mach_rg_nonkernel.val    =  {libl2SVR};
mach_rg_nonkernel.help   = {...
    ['Choose a non-kernel prediction machine for this model']};
% Random Trees = rt

% ---------------------------------------------------------------------
% mach_rg_kernel Select Kernel Machine for regression
% ---------------------------------------------------------------------
mach_rg_kernel       = cfg_choice;
mach_rg_kernel.tag    = 'mach_rg_kernel';
mach_rg_kernel.name   = 'Kernel machine';
mach_rg_kernel.values = {krr,libeSVR,rvr,gpr,sMKL_reg,custom_machine}; 
mach_rg_kernel.val    =  {krr};
mach_rg_kernel.help   = {...
    ['Choose a kernel prediction machine for this model']};

% ---------------------------------------------------------------------
% machine_rg_K Kernel or non-kernel machine for regression
% ---------------------------------------------------------------------
machine_rg_K        = cfg_choice;
machine_rg_K.tag    = 'machine_rg_K';
machine_rg_K.name   = 'Regression ';
machine_rg_K.values = {mach_rg_kernel, mach_rg_nonkernel};
machine_rg_K.help   = {'Select whether a kernel or non-kernel method is to be used.'};

% ---------------------------------------------------------------------
% model_type Model type
% ---------------------------------------------------------------------
model_type        = cfg_choice;
model_type.tag    = 'model_type';
model_type.name   = 'Model Type ';
model_type.values = {machine_cl_K,machine_rg_K};
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

