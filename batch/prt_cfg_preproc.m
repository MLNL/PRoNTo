function preproc = prt_cfg_preproc
% Preprocessing of the data.
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J.M.Rondina
% $Id: prt_cfg_preproc.m 79 2011-09-28 09:45:12Z cphillip $


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
% preproc Preprocessing
% ---------------------------------------------------------------------
preproc        = cfg_exbranch;
preproc.tag    = 'preproc';
preproc.name   = 'Preprocessing';
preproc.val    = {infile};
preproc.help   = {'Preprocess data according to the design'};
preproc.prog   = @prt_run_preproc;
preproc.vout   = @vout_data;

%------------------------------------------------------------------------
function cdep = vout_data(job)
% Specifies the output from this modules, i.e. the filename of the mat file

cdep(1)            = cfg_dep;
cdep(1).sname      = 'PRT.mat file';
cdep(1).src_output = substruct('.','files');
cdep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
%------------------------------------------------------------------------
