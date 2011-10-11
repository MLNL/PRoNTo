function cv_model = prt_cfg_cv_model
% Preprocessing of the data.
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A. Marquand
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
model_name.help    = {'Name of a feature set'};
model_name.strtype = 's';
model_name.num     = [1 Inf];

% ---------------------------------------------------------------------
% cv_model Preprocessing
% ---------------------------------------------------------------------
cv_model        = cfg_exbranch;
cv_model.tag    = 'cv_model';
cv_model.name   = 'Run model';
cv_model.val    = {infile model_name};
cv_model.help   = {...
    ['Trains and tests the predictive machine using the cross-validtion ',...
     'structure specified by the model.']};
cv_model.prog   = @prt_run_cv_model;
cv_model.vout   = @vout_data;

%------------------------------------------------------------------------
function cdep = vout_data(job)
% Specifies the output from this modules, i.e. the filename of the mat file

cdep(1)            = cfg_dep;
cdep(1).sname      = 'PRT.mat file';
cdep(1).src_output = substruct('.','files');
cdep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
%------------------------------------------------------------------------
