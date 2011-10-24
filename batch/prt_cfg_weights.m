function weights = prt_cfg_weights
% Preprocessing of the data.
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by M.J.Rosa
% $Id: $

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
% img_name Feature set name
% ---------------------------------------------------------------------
img_name         = cfg_entry;
img_name.tag     = 'img_name';
img_name.name    = 'Image name (optional)';
img_name.help    = {'Name of the file with weights.'};
img_name.strtype = 's';
img_name.num     = [0 Inf];
img_name.val     = {''};

% ---------------------------------------------------------------------
% cv_model Preprocessing
% ---------------------------------------------------------------------
weights        = cfg_exbranch;
weights.tag    = 'weights';
weights.name   = 'Compute weights';
weights.val    = {infile model_name img_name};
weights.help   = {...
    'Compute weights.'};
weights.prog   = @prt_run_weights;
weights.vout   = @vout_data;

%------------------------------------------------------------------------
function cdep = vout_data(job)
% Specifies the output from this modules, i.e. the filename of the mat file

cdep(1)            = cfg_dep;
cdep(1).sname      = 'PRT.mat file';
cdep(1).src_output = substruct('.','files');
cdep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
%------------------------------------------------------------------------
