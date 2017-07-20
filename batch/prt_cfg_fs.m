function fs = prt_cfg_fs
% Data & design configuration file
% This configures the fs construction for each modality.
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by Andre Marquand and J. Schrouff
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
k_file.name    = 'Feature/kernel name';
k_file.help    = {['Target name for kernel matrix. This should contain' ...
                   'only alphanumerical characters or underscores (_).']};
k_file.strtype = 's';
k_file.num     = [1 Inf];

% % ---------------------------------------------------------------------
% % use_mkl Use MKL?
% % ---------------------------------------------------------------------
% use_mkl         = cfg_menu;
% use_mkl.tag     = 'use_mkl';
% use_mkl.name    = 'Generate Multiple Kernels?';
% use_mkl.labels  = {
%                'Yes'
%                'No'
% }';
% use_mkl.values  = {1 0};
% use_mkl.val     = {0};
% use_mkl.help    = {'Do you wish to generate Multiple Kernels?'};

% ---------------------------------------------------------------------
% multkernflag Use multiple modality kernels
% ---------------------------------------------------------------------
% flag_mm         = cfg_menu;
% flag_mm.tag     = 'flag_mm';
% flag_mm.name    = 'Use one kernel per modality';
% flag_mm.help    = {'Select "Yes" to use one kernel per modality.'};
% flag_mm.labels  = {
%     'Yes'
%     'No'
%     }';
% flag_mm.values  = {1 0};
% flag_mm.val     = {0};

% ---------------------------------------------------------------------
% atlasroi Filename(s) of atlas for ROI MKL
% ---------------------------------------------------------------------
atlasroi         = cfg_files;
atlasroi.tag     = 'atlasroi';
atlasroi.name    = 'Use atlas to build ROI specific kernels';
atlasroi.ufilter = '.*';
atlasroi.filter  = 'image';
atlasroi.num     = [0 1];
atlasroi.val     = {{''}};
% atlasroi.def     = @(val)prt_get_defaults('fs.atlasroi', val{:});
atlasroi.help    = {['Select an atlas file to build one kernel per ROI. ', ...
    'The AAL atlas (named ''aal_79x91x69.img'') is available in the ''atlas'' subdirectory of PRoNTo']};
           
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
% % detrend Detrend
% % ---------------------------------------------------------------------
% detrend         = cfg_menu;
% detrend.tag     = 'detrend';
% detrend.name    = 'Detrend';
% detrend.help    = {'Type of temporal detrending to apply'};
% detrend.labels  = {
%                'None'
%                'Linear'
% }';
% detrend.values  = {0 1};
% detrend.val     = {0};

% ---------------------------------------------------------------------
% param_dt Name
% ---------------------------------------------------------------------
param_dt         = cfg_entry;
param_dt.tag     = 'param_dt';
param_dt.name    = 'Cutoff of high-pass filter (second)';
param_dt.help    = {[...
    'The default high-pass filter cutoff is 128 seconds (same as SPM)']};
param_dt.strtype = 'e';
param_dt.val     = {128};
param_dt.num     = [1 1];

% ---------------------------------------------------------------------
% dct_dt DCT
% ---------------------------------------------------------------------
dct_dt      = cfg_branch;
dct_dt.tag  = 'dct_dt';
dct_dt.name = 'Discrete cosine transform';
dct_dt.val  = {param_dt};
dct_dt.help = {'Use a discrete cosine basis set to detrend the data.'};

% ---------------------------------------------------------------------
% no_dt No detrend
% ---------------------------------------------------------------------
no_dt         = cfg_const;
no_dt.tag     = 'no_dt';
no_dt.name    = 'None';
no_dt.val     = {1};
no_dt.help    = {['Do not detrend the data ']};

% ---------------------------------------------------------------------
% paramPoly_dt Name
% ---------------------------------------------------------------------
paramPoly_dt         = cfg_entry;
paramPoly_dt.tag     = 'paramPoly_dt';
paramPoly_dt.name    = 'Order';
paramPoly_dt.help    = {[...
    'Enter the order for polynomial detrend (1 is linear detrend)']};
paramPoly_dt.strtype = 'e';
paramPoly_dt.val     = {1};
paramPoly_dt.num     = [1 1];

% ---------------------------------------------------------------------
% linear_dt Polynomial detrend
% ---------------------------------------------------------------------
linear_dt         = cfg_branch;
linear_dt.tag     = 'linear_dt';
linear_dt.name    = 'Polynomial detrend ';
linear_dt.val     = {paramPoly_dt};
linear_dt.help    = {'Perform a voxel-wise polynomial detrend on the data (1 is linear detrend) '};

% ---------------------------------------------------------------------
% detrend Conditions
% ---------------------------------------------------------------------
detrend        = cfg_choice;
detrend.tag    = 'detrend';
detrend.name   = 'Detrend';
detrend.values = {no_dt, linear_dt, dct_dt};
detrend.val    = {no_dt};
detrend.help   = {...
['Type of temporal detrending to apply']};

% ---------------------------------------------------------------------
% fmask File name
% ---------------------------------------------------------------------
fmask        = cfg_files;
fmask.tag    = 'fmask';
fmask.name   = 'Specify mask file';
fmask.filter = 'image';
fmask.num    = [1 1];
fmask.help   = {'Select a mask for the selected modality.'};

% ---------------------------------------------------------------------
% mod_name Name
% ---------------------------------------------------------------------
mod_name         = cfg_entry;
mod_name.tag     = 'mod_name';
mod_name.name    = 'Modality name';
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
all_voxels.help    = {'Use all voxels in the design mask for this modality'};

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
% all_features All features for .mat
% ---------------------------------------------------------------------
all_features         = cfg_const;
all_features.tag     = 'all_features';
all_features.name    = 'All features';
all_features.val     = {1};
all_features.help    = {'Use all features in the matrix for this modality'};

% ---------------------------------------------------------------------
% fmask File name
% ---------------------------------------------------------------------
matmask        = cfg_files;
matmask.tag    = 'matmask';
matmask.name   = 'Specify mask file';
matmask.filter = 'mat';
matmask.num    = [1 1];
matmask.help   = {'Select a mask for the selected modality.'};

% ---------------------------------------------------------------------
% features 
% ---------------------------------------------------------------------
features        = cfg_choice;
features.tag    = 'features';
features.name   = 'Features to include';
features.values = {all_features, matmask};
features.val    = {all_features};
features.help   = {...
    ['Specify which features from the current modality you would like to include']};

% ---------------------------------------------------------------------
% modality Modality for .mat
% ---------------------------------------------------------------------
matmodality      = cfg_branch;
matmodality.tag  = 'matmodality';
matmodality.name = 'Modality';
matmodality.val  = {mod_name, features};
% matmodality.val  = {mod_name, conditions, voxels, detrend, normalise, atlasroi};
% to update when design will be available
matmodality.help = {'Specify modality, such as name and data.'};

% ---------------------------------------------------------------------
% multkern Average across channels
% ---------------------------------------------------------------------
multkern         = cfg_menu;
multkern.tag     = 'multkern';
multkern.name    = 'Multiple kernels';
multkern.help    = {'Build one kernel per selected feature in this dimension.'...
    ' This will result in e.g. one kernel per channel, per time point, or '...
    'per frequency bin. Choosing multiple kernels on one dimension does not '...
    'exclude the computation of multiple kernels on other dimensions.'};
multkern.labels  = {
               'Yes'
               'No'
}';
multkern.values  = {1 0};
multkern.val     = {0};

% ---------------------------------------------------------------------
% nomult No multiple kernels for time dimension
% ---------------------------------------------------------------------
nomult         = cfg_const;
nomult.tag     = 'nomult';
nomult.name    = 'No';
nomult.val     = {1};
nomult.help    = {'Do not build multiple kernels'};

% ---------------------------------------------------------------------
% multkernonetp Multiple kernels per time point
% ---------------------------------------------------------------------
multkernonetp         = cfg_const;
multkernonetp.tag     = 'multkernonetp';
multkernonetp.name    = 'One kernel per time point';
multkernonetp.val     = {1};
multkernonetp.help    = {'Build one kernel per time point'};

% ---------------------------------------------------------------------
% kerntpwin Window of time for multiple kernels
% ---------------------------------------------------------------------
kerntpwin         = cfg_entry;
kerntpwin.tag     = 'kerntpwin';
kerntpwin.name    = 'Time window (ms)';
kerntpwin.help    = {'Length of time window to consider (in ms). E.g. 10'};
kerntpwin.strtype = 'e';
kerntpwin.num     = [1 1];

% ---------------------------------------------------------------------
% multkernwin Multiple kernels per time point
% ---------------------------------------------------------------------
multkernwin         = cfg_branch;
multkernwin.tag     = 'multkernwin';
multkernwin.name    = 'One kernel per time window';
multkernwin.val     = {kerntpwin};
multkernwin.help    = {'Build one kernel per time window'};

% ---------------------------------------------------------------------
% multkerntp Multiple kernels for time dimension
% ---------------------------------------------------------------------
multkerntp         = cfg_choice;
multkerntp.tag     = 'multkerntp';
multkerntp.name    = 'Multiple kernels';
multkerntp.help    = {'Build one kernel per selected dimension.'};
multkerntp.values  = {nomult,multkernonetp, multkernwin};
multkerntp.val     = {nomult};

% ---------------------------------------------------------------------
% average Average across channels
% ---------------------------------------------------------------------
average         = cfg_menu;
average.tag     = 'average';
average.name    = 'Average';
average.help    = {'Average across selected.'};
average.labels  = {
               'Yes'
               'No'
}';
average.values  = {1 0};
average.val     = {0};

% ---------------------------------------------------------------------
% channels Channel definition for MEEG objects
% ---------------------------------------------------------------------
channels      = cfg_branch;
channels.tag  = 'channels';
channels.name = 'Channels';
channels.val  = {spm_cfg_eeg_channel_selector, average, multkern};

%--------------------------------------------------------------------------
% timewin
%--------------------------------------------------------------------------
timewin         = cfg_entry;
timewin.tag     = 'timewin';
timewin.name    = 'Time window';
timewin.help    = {'Start and stop of the time window (ms).'};
timewin.strtype = 'r';
timewin.num     = [1 2];
timewin.val     = {[-Inf Inf]};

% ---------------------------------------------------------------------
% tp Time point selection for MEEG objects
% ---------------------------------------------------------------------
tp      = cfg_branch;
tp.tag  = 'tp';
tp.name = 'Time points';
tp.val  = {timewin, average, multkerntp};

%--------------------------------------------------------------------------
% freqwin
%--------------------------------------------------------------------------
freqwin         = cfg_entry;
freqwin.tag     = 'freqwin';
freqwin.name    = 'Frequency window';
freqwin.help    = {'Start and stop of the frequency window (Hz).'};
freqwin.strtype = 'r';
freqwin.num     = [1 2];
freqwin.val     = {[-Inf Inf]};

% ---------------------------------------------------------------------
% freq Frequency selection for MEEG objects
% ---------------------------------------------------------------------
freq      = cfg_branch;
freq.tag  = 'freq';
freq.name = 'Frequencies';
freq.val  = {freqwin, average, multkern};

% ---------------------------------------------------------------------
% modality Modality for MEEG objects
% ---------------------------------------------------------------------
MEEGmodality      = cfg_branch;
MEEGmodality.tag  = 'MEEGmodality';
MEEGmodality.name = 'Modality';
MEEGmodality.val  = {mod_name, channels, tp, freq};
MEEGmodality.help = {'Specify modality, such as name and data.'};

% ---------------------------------------------------------------------
% modality Modality for nifti
% ---------------------------------------------------------------------
modality      = cfg_branch;
modality.tag  = 'modality';
modality.name = 'Modality';
modality.val  = {mod_name, conditions, voxels, detrend, normalise, atlasroi};
modality.help = {'Specify modality, such as name and data.'};

% ---------------------------------------------------------------------
% modalities for nifti
% ---------------------------------------------------------------------
niftimod         = cfg_repeat;
niftimod.tag     = 'niftimod';
niftimod.name    = 'Nifti';
niftimod.help    = {'Add modalities in nifti format'};
niftimod.num     = [1 Inf];
niftimod.values  = {modality};

% ---------------------------------------------------------------------
% modalities for MEEG
% ---------------------------------------------------------------------
MEEGmod         = cfg_repeat;
MEEGmod.tag     = 'MEEGmod';
MEEGmod.name    = 'MEEG';
MEEGmod.help    = {'Add modalities in SPM MEEG format'};
MEEGmod.num     = [1 Inf];
MEEGmod.values  = {MEEGmodality};

% ---------------------------------------------------------------------
% modalities for .mat
% ---------------------------------------------------------------------
matmod         = cfg_repeat;
matmod.tag     = 'matmod';
matmod.name    = '.mat';
matmod.help    = {'Add modalities in .mat format'};
matmod.num     = [1 Inf];
matmod.values  = {matmodality};

% ---------------------------------------------------------------------
% Data format
% ---------------------------------------------------------------------
format         = cfg_choice;
format.tag     = 'format';
format.name    = 'Data format';
format.help    = {['Data format for selected modalities. The different input '...
    'files should be in either nifti, SPM MEEG object or .mat format']};
format.values  = {niftimod, MEEGmod, matmod};
format.val     = {niftimod};

% ---------------------------------------------------------------------
% Configure Feature set
% ---------------------------------------------------------------------
fs        = cfg_exbranch;
fs.tag    = 'fs';
fs.name   = 'Feature set/Kernel';
% fs.val    = {infile, k_file, modalities, use_mkl, flag_mm};
fs.val    = {infile, k_file, format};
fs.help   = {'Compute feature set according to the design specified'};
fs.prog   = @prt_run_fs;
fs.vout   = @vout_data;

%------------------------------------------------------------------------
%% Output function
%------------------------------------------------------------------------
function cdep = vout_data(job)
% Specifies the output from this modules, i.e. the filename of the mat file

cdep(1)            = cfg_dep;
cdep(1).sname      = 'PRT.mat file';
cdep(1).src_output = substruct('.','fname');
cdep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
cdep(2)            = cfg_dep;
cdep(2).sname      = 'Feature/kernel name';
cdep(2).src_output = substruct('.','fs_name');
cdep(2).tgt_spec   = cfg_findspec({{'strtype','s'}});

%------------------------------------------------------------------------

