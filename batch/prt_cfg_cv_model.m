function cv_model = prt_cfg_cv_model
% Preprocessing of the data.
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A. Marquand and J. Schrouff
% $Id$

% ---------------------------------------------------------------------
% filename Filename(s) of data
% ---------------------------------------------------------------------
infile        = cfg_files;
infile.tag    = 'infile';
infile.name   = 'Load PRT.mat';
infile.filter = 'mat';
infile.num    = [1 1];
infile.help   = {'Select PRT.mat (file containing data/design structure).'};

% ---------------------------------------------------------------------
% model_name Feature set name
% ---------------------------------------------------------------------
model_name         = cfg_entry;
model_name.tag     = 'model_name';
model_name.name    = 'Model name';
model_name.help    = {'Name of a model. Must match your entry in the '...
                      '''Specify model'' batch module.'};
model_name.strtype = 's';
model_name.num     = [1 Inf];

% ---------------------------------------------------------------------
% no_perm No permutation test
% ---------------------------------------------------------------------
no_perm         = cfg_const;
no_perm.tag     = 'no_perm';
no_perm.name    = 'No permutation test';
no_perm.val     = {1};
no_perm.help    = {'Do not perform permutation test'};

% ---------------------------------------------------------------------
% N_perm Number of permutations
% ---------------------------------------------------------------------
N_perm         = cfg_entry;
N_perm.tag     = 'N_perm';
N_perm.name    = 'Number of permutations';
N_perm.help    = {'Enter the number of permutations to perform'};
N_perm.strtype = 'e';
N_perm.val     = {1000};
N_perm.num     = [1 1];

% ---------------------------------------------------------------------
% flag_sw Save the permutations' weights
% ---------------------------------------------------------------------
flag_sw         = cfg_menu;
flag_sw.tag     = 'flag_sw';
flag_sw.name    = 'Save permutations parameters';
flag_sw.help    = {['Set to Yes to save the parameterss obtained from each' ...
    'permutation.']};
flag_sw.labels  = {
               'Yes'
               'No'
}';
flag_sw.values  = {1 0};
flag_sw.val     = {0};


% ---------------------------------------------------------------------
% copy_model_name Name of model to copy permutations from
% ---------------------------------------------------------------------
copy_model_name         = cfg_entry;
copy_model_name.tag     = 'copy_model_name';
copy_model_name.name    = 'Mdel name';
copy_model_name.help    = {'Name of a model. Must match your entry in the '...
                      '''Specify model'' batch module.'};
copy_model_name.strtype = 's';
copy_model_name.num     = [1 Inf];

% ---------------------------------------------------------------------
% copy_perm Do permuatation test
% ---------------------------------------------------------------------
copy_perm         = cfg_branch;
copy_perm.tag     = 'copy_perm';
copy_perm.name    = 'Copy from';
copy_perm.val     = {copy_model_name};
copy_perm.help    = {'Yes, copy permutations from a previous model.'};

% ---------------------------------------------------------------------
% no_copy_perm Do not copy permutations (default)
% ---------------------------------------------------------------------
no_copy_perm         = cfg_const;
no_copy_perm.tag     = 'no_copy_perm';
no_copy_perm.name    = 'No';
no_copy_perm.val     = {1};
no_copy_perm.help    = {'Do not copy permutation from another model.'};

% ---------------------------------------------------------------------
% use_model Copy permutations from another model
% ---------------------------------------------------------------------
use_model         = cfg_choice;
use_model.tag     = 'use_model';
use_model.name    = 'Copy permutations from model';
use_model.help    = {['Set to Yes to copy the permutations from another' ...
    'model. This option should be selected to correct for multiple '...
    'comparisons. The 2 models should contain the exact same samples.']};
use_model.values  = {no_copy_perm copy_perm};
use_model.val     = {no_copy_perm};

% ---------------------------------------------------------------------
% perm_t Do permutation test
% ---------------------------------------------------------------------
perm_t         = cfg_branch;
perm_t.tag     = 'perm_t';
perm_t.name    = 'Permutation test';
perm_t.val     = {N_perm, flag_sw, use_model};
perm_t.help    = {'Perform a permutation test.'};

% ---------------------------------------------------------------------
% detrend Conditions
% ---------------------------------------------------------------------
perm_test        = cfg_choice;
perm_test.tag    = 'perm_test';
perm_test.name   = 'Do permutation test?';
perm_test.values = {no_perm, perm_t};
perm_test.val    = {no_perm};
perm_test.help   = {'Perform a permutation test on accuracy, or not'};

% ---------------------------------------------------------------------
% cv_model Preprocessing
% ---------------------------------------------------------------------
cv_model        = cfg_exbranch;
cv_model.tag    = 'cv_model';
cv_model.name   = 'Run model';
cv_model.val    = {infile model_name perm_test};
cv_model.help   = {...
    ['Trains and tests the predictive machine using the cross-validation ',...
     'structure specified by the model.']};
cv_model.prog   = @prt_run_cv_model;
cv_model.vout   = @vout_data;

%------------------------------------------------------------------------
%% Output function
%------------------------------------------------------------------------
function cdep = vout_data(job)
% Specifies the output from this modules, i.e. the filename of the mat file

cdep(1)            = cfg_dep;
cdep(1).sname      = 'PRT.mat file';
cdep(1).src_output = substruct('.','files');
cdep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
%------------------------------------------------------------------------
