function fs = prt_cfg_fs
% Data & design configuration file
% This configures the fs construction for each modality.
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by Andre Marquand
% $Id$

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
% k_file Name
% ---------------------------------------------------------------------
k_file         = cfg_entry;
k_file.tag     = 'k_file';
k_file.name    = 'Name';
k_file.help    = {'Target filename for kernel matrix'};
k_file.strtype = 's';
k_file.num     = [1 Inf];

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
conditions.name   = 'Scans / Conditions';
conditions.values = {all_scans, all_cond};
conditions.val    = {all_scans};
conditions.help   = {...
['Which task conditions do you want to include in the kernel matrix? '...
 'Select conditions: select specific conditions from the timeseries. ', ...
 'All conditions: include all conditions extracted from the timeseries. ', ...
 'All scans: include all scans for each subject. This may be used for ', ...
 'modalities with only one scan per subject (e.g. PET), ', ... 
 'if you want to include all scans from an fMRI timeseries (assumes you ',...
 'have not already detrended the timeseries and extracted task components)']};

% ---------------------------------------------------------------------
% detrend Detrend
% ---------------------------------------------------------------------
detrend         = cfg_menu;
detrend.tag     = 'detrend';
detrend.name    = 'Detrend';
detrend.help    = {'Type of temporal detrending to apply'};
detrend.labels  = {
               'None'
               'Linear'
}';
detrend.values  = {0 1};
detrend.val     = {0};

% ---------------------------------------------------------------------
% param_dt Name
% ---------------------------------------------------------------------
param_dt         = cfg_entry;
param_dt.tag     = 'param_dt';
param_dt.name    = 'Detrend parameters';
param_dt.help    = {[...
    'Enter any parameters for the detrending operation (e.g. bases for DCT)']};
param_dt.strtype = 's';
param_dt.val     = {'1'};
param_dt.num     = [1 Inf];

% ---------------------------------------------------------------------
% fmask File name
% ---------------------------------------------------------------------
fmask        = cfg_files;
fmask.tag    = 'fmask';
fmask.name   = 'Specify mask file';
fmask.filter = 'img';
fmask.ufilter = '^*.img';
fmask.num    = [1 1];
fmask.help   = {'Select a mask for the selected modality.'};

% ---------------------------------------------------------------------
% mod_name Name
% ---------------------------------------------------------------------
mod_name         = cfg_entry;
mod_name.tag     = 'mod_name';
mod_name.name    = 'Name';
mod_name.help    = {'Name of modality. Example: ''BOLD''. Must match design specification'};
mod_name.strtype = 's';
mod_name.num     = [1 Inf];

% ---------------------------------------------------------------------
% no_gms No normalisation
% ---------------------------------------------------------------------
no_gms         = cfg_const;
no_gms.tag     = 'no_gms';
no_gms.name    = 'No scaling';
no_gms.val     = {1};
no_gms.help    = {'Do not scale the input scans'};

% ---------------------------------------------------------------------
% mat_norm File name
% ---------------------------------------------------------------------
mat_gms        = cfg_files;
mat_gms.tag    = 'mat_gms';
mat_gms.name   = 'Specify from *.mat';
mat_gms.filter = 'mat';
mat_gms.ufilter = '^*.mat';
mat_gms.num    = [1 1];
mat_gms.help   = {[...
    'Specify a mat file containing the scaling parameters for each modality.']};

% ---------------------------------------------------------------------
% normalise 
% ---------------------------------------------------------------------
normalise        = cfg_choice;
normalise.tag    = 'normalise';
normalise.name   = 'Scale input scans';
normalise.values = {no_gms, mat_gms};
normalise.val    = {no_gms};
normalise.help   = {...
    ['Do you want to scale the input scans to have a fixed mean '...
    '(i.e. grand mean scaling)?']};

% ---------------------------------------------------------------------
% all_voxels All voxels
% ---------------------------------------------------------------------
all_voxels         = cfg_const;
all_voxels.tag     = 'all_voxels';
all_voxels.name    = 'All voxels';
all_voxels.val     = {1};
all_voxels.help    = {'Use all voxels in this modality'};

% ---------------------------------------------------------------------
% voxels 
% ---------------------------------------------------------------------
voxels        = cfg_choice;
voxels.tag    = 'voxels';
voxels.name   = 'Voxels to include';
voxels.values = {all_voxels, fmask};
voxels.val    = {all_voxels};
voxels.help   = {...
    ['Specify which voxels from the current modality you would like to include']};




% ---------------------------------------------------------------------
% modality Modality
% ---------------------------------------------------------------------
modality      = cfg_branch;
modality.tag  = 'modality';
modality.name = 'Modality';
modality.val  = {mod_name conditions, voxels, detrend, param_dt, normalise};
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
% Configure Feature set
% ---------------------------------------------------------------------
fs        = cfg_exbranch;
fs.tag    = 'fs';
fs.name   = 'Feature set / Kernel';
fs.val    = {infile, k_file, modalities};
fs.help   = {'Compute feature set according to the design specified'};
fs.prog   = @prt_run_fs;
fs.vout   = @vout_data;

%------------------------------------------------------------------------
% Output function
%------------------------------------------------------------------------
function cdep = vout_data(job)
% Specifies the output from this modules, i.e. the filename of the mat file

cdep(1)            = cfg_dep;
cdep(1).sname      = 'PRT.mat file';
cdep(1).src_output = substruct('.','fname');
cdep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
%------------------------------------------------------------------------

