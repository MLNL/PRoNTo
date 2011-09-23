function kernel = prt_cfg_kernel_construction
% Data & design configuration file
% This configures the kernel construction for each modality.
%_______________________________________________________________________
% Copyright (C) 2011, ...

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
% kernel_filename Name
% ---------------------------------------------------------------------
kernel_filename         = cfg_entry;
kernel_filename.tag     = 'kernel_filename';
kernel_filename.name    = 'Name';
kernel_filename.help    = {'Target filename (will be saved as kernel_xxx.mat'};
kernel_filename.strtype = 's';
kernel_filename.num     = [1 Inf];

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
conditions.name   = 'Conditions';
conditions.values = {all_cond, all_scans};
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
modality.val  = {mod_name conditions, kernel_dt};
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
% % mask Mask
% % ---------------------------------------------------------------------
% mask        = cfg_files;
% mask.tag    = 'mask';
% mask.name   = 'Kernel masks';
% mask.filter = 'image';
% %mask.ufilter = '.*';
% mask.num    = [1 Inf];
% mask.help   = {'Select kernel masks for each modality included in the kernel.'};
%   

% ---------------------------------------------------------------------
% fmask File name
% ---------------------------------------------------------------------
fmask        = cfg_files;
fmask.tag    = 'fmask';
fmask.name   = 'File';
fmask.filter = 'img';
fmask.ufilter = '.*';
fmask.num    = [1 1];
fmask.help   = {'Select one mask for each modality.'};
% ---------------------------------------------------------------------
% mask Modality
% ---------------------------------------------------------------------
mask         = cfg_branch;
mask.tag     = 'mask';
mask.name    = 'Modality';
mask.help    = {'Specify name of modality and file for each mask.'};
mask.val     = {mod_name, fmask };
            
% ---------------------------------------------------------------------
% masks Masks
% ---------------------------------------------------------------------
masks         = cfg_repeat;
masks.tag     = 'masks';
masks.name    = 'Masks';
masks.help    = {['Select kernel mask for each ',...
                  'modality. The name of the modalities should be the same ',...
                  'as the ones entered for subjects/scans.']};
masks.num     = [1 Inf];
masks.values  = {mask };

% ---------------------------------------------------------------------
% Configure Kernel
% ---------------------------------------------------------------------
kernel        = cfg_exbranch;
kernel.tag    = 'kernel';
kernel.name   = 'Kernels';
%kernel.val    = {infile, kernel_filename, groups, mask, normalise};
kernel.val    = {infile, kernel_filename, modalities, masks, normalise};
kernel.help   = {'Compute kernel matrices according to the design specified'};
kernel.prog   = @prt_run_kernel_construction;
kernel.vout   = @vout_data;

% Output function
%------------------------------------------------------------------------
function cdep = vout_data(job)
% Specifies the output from this modules, i.e. the filename of the mat file

cdep(1)            = cfg_dep;
cdep(1).sname      = 'Kernel file';
cdep(1).src_output = substruct('.','fname');
cdep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
%------------------------------------------------------------------------

