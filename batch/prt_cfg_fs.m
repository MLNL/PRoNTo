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
infile.name   = 'Data structure file';
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

% % ---------------------------------------------------------------------
% % no_dt Linear detrend
% % ---------------------------------------------------------------------
% no_dt         = cfg_const;
% no_dt.tag     = 'no_dt';
% no_dt.name    = 'None';
% no_dt.val     = {1};
% no_dt.help    = {'No detrend'};
% 
% % ---------------------------------------------------------------------
% % linear_dt Linear detrend
% % ---------------------------------------------------------------------
% linear_dt         = cfg_const;
% linear_dt.tag     = 'linear_dt';
% linear_dt.name    = 'Linear';
% linear_dt.val     = {1};
% linear_dt.help    = {'Linear detrend'};
%                  
% % ---------------------------------------------------------------------
% % kernel_dt Kernel detrend
% % ---------------------------------------------------------------------
% kernel_dt        = cfg_choice;
% kernel_dt.tag    = 'kernel_dt';
% kernel_dt.name   = 'Kernel detrend';
% kernel_dt.values = {no_dt linear_dt};
% kernel_dt.help   = {'Perform detrending in the kernel'};

% ---------------------------------------------------------------------
% kernel_dt Review
% ---------------------------------------------------------------------
kernel_dt         = cfg_menu;
kernel_dt.tag     = 'kernel_dt';
kernel_dt.name    = 'Kernel detrend';
kernel_dt.help    = {'Perform detrending in the kernel.'};
kernel_dt.labels  = {
               'None'
               'Linear'
}';
kernel_dt.values  = {0 1};
kernel_dt.val     = {0};


% ---------------------------------------------------------------------
% fmask File name
% ---------------------------------------------------------------------
fmask        = cfg_files;
fmask.tag    = 'fmask';
fmask.name   = 'Mask file';
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
% modality Modality
% ---------------------------------------------------------------------
modality      = cfg_branch;
modality.tag  = 'modality';
modality.name = 'Modality';
modality.val  = {mod_name conditions, fmask, kernel_dt};
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

% % ---------------------------------------------------------------------
% % mask Modality
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
% masks.name    = 'Masks';
% masks.help    = {['Select mask for each ',...
%                   'modality. The name of the modalities should be the same ',...
%                   'as the ones entered for subjects/scans.']};
% masks.num     = [1 Inf];
% masks.values  = {mask };

% ---------------------------------------------------------------------
% Configure Feature set
% ---------------------------------------------------------------------
fs        = cfg_exbranch;
fs.tag    = 'fs';
fs.name   = 'Feature set / Kernel';
fs.val    = {infile, k_file, modalities, normalise};
fs.help   = {'Compute feature set according to the design specified'};
fs.prog   = @prt_run_fs;
fs.vout   = @vout_data;

%------------------------------------------------------------------------
% Output function
%------------------------------------------------------------------------
function cdep = vout_data(job)
% Specifies the output from this modules, i.e. the filename of the mat file

cdep(1)            = cfg_dep;
cdep(1).sname      = 'Kernel file';
cdep(1).src_output = substruct('.','fname');
cdep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
%------------------------------------------------------------------------

