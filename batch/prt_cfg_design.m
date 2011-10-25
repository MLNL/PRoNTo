function data = prt_cfg_design
% Data & design configuration file
% This builds the PRT.mat data and design structure.
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by M.J.Rosa
% $Id$

% ---------------------------------------------------------------------
% covar Covariates
% ---------------------------------------------------------------------
covar         = cfg_entry;
covar.tag     = 'covar';
covar.name    = 'Covariates';
covar.help    = {['Select a matrix/vector containing details '...
                  'of your covariates (i.e. any other data/information '...
                  'you would like to include in your design). If you enter '...
                  'a vector instead of a matrix, the entries of the vector '...
                  'will be repeated to create a matrix with the dimensions: '...
                  'number of scans x number of covariates (or vector '...
                  'entries.']};
covar.strtype = 'e';
covar.val     = {[]};
covar.num     = [Inf Inf];

% ---------------------------------------------------------------------
% rt_subj One per subject/scans
% ---------------------------------------------------------------------
rt_subj         = cfg_entry;
rt_subj.tag     = 'rt_subj';
rt_subj.name    = 'Regression targets (per scans)';
rt_subj.help    = {['Enter one regression target per scans. '...
                     'or enter the name of a variable '...
                     ' This variable should be a vector '...
                     '[Nscans x 1], where Nsubjs is the number of subjects.']};
%Enter a file
% rt_subj.val{1}  = {''};                
% rt_subj.filter  = 'mat';
% rt_subj.ufilter = '.*';
% rt_subj.num     = [0 1];
%Enter values or variable
rt_subj.strtype = 'e';
rt_subj.val     = {[]};
rt_subj.num     = [Inf 0];

% ---------------------------------------------------------------------
% regtrial One per trial
% ---------------------------------------------------------------------
rt_trial         = cfg_entry;
rt_trial.tag     = 'rt_trial';
rt_trial.name    = 'Regression targets (trials)';
rt_trial.help    = {['Enter one regression target per trial. '...
                     'This vector should have the following dimensions: '...
                     '[Ntrials x 1], where Ntrials is the number of trials.']
}';
rt_trial.strtype = 'e';
rt_trial.val     = {[]};
rt_trial.num     = [Inf 0];

% ---------------------------------------------------------------------
% TR Interscan interval
% ---------------------------------------------------------------------
TR         = cfg_entry;
TR.tag     = 'TR';
TR.name    = 'Interscan interval';
TR.help    = {'Specify interscan interval (TR). The units should be seconds.'};
TR.strtype = 'e';
TR.num     = [Inf 1];

% ---------------------------------------------------------------------
% units Units for design
% ---------------------------------------------------------------------
unit         = cfg_menu;
unit.tag     = 'unit';
unit.name    = 'Units for design';
unit.help    = {'The onsets of events or blocks can be specified in either scans or seconds.'};
unit.labels  = {
                'Scans'
                'Seconds'
}';
unit.values  = {0 1};
unit.val     = {1};

% ---------------------------------------------------------------------
% review Review
% ---------------------------------------------------------------------
review         = cfg_menu;
review.tag     = 'review';
review.name    = 'Review';
review.help    = {'Would you like to review the design?.'};
review.labels  = {
               'No'
               'Yes'
}';
review.values  = {0 1};
review.val     = {0};

% ---------------------------------------------------------------------
% mod_name Name
% ---------------------------------------------------------------------
mod_name         = cfg_entry;
mod_name.tag     = 'mod_name';
mod_name.name    = 'Name';
mod_name.help    = {'Name of modality. Example: ''BOLD''.'};
mod_name.strtype = 's';
mod_name.num     = [1 Inf];

% ---------------------------------------------------------------------
% scans Scans
% ---------------------------------------------------------------------
scans         = cfg_files;
scans.tag     = 'scans';
scans.name    = 'Scans';
scans.help    = {['Select scans (images) for this modality. They must '...
                  'all have the same image dimensions, orientation, '...
                  'voxel size etc.']};
scans.filter = 'image';
scans.ufilter = '.*';
scans.num     = [1 Inf];

% ---------------------------------------------------------------------
% subjects Subjects
% ---------------------------------------------------------------------
subjects         = cfg_files;
subjects.tag     = 'subjects';
subjects.name    = 'Scans/beta maps';
subjects.help    = {['Select scans (images) for this modality. They must '...
                  'all have the same image dimensions, orientation, '...
                  'voxel size etc.']};
subjects.filter  = 'image';
subjects.num     = [0 Inf];

% ---------------------------------------------------------------------
% modality Modality
% ---------------------------------------------------------------------
modality      = cfg_branch;
modality.tag  = 'modality';
modality.name = 'Modality';
modality.val  = {mod_name, subjects, rt_subj, covar };
modality.help = {'Specify modality, such as name and data.'};

% ---------------------------------------------------------------------
% images Scans
% ---------------------------------------------------------------------
images        = cfg_repeat;
images.tag    = 'images';
images.name   = 'Scans';
images.values = {modality };
images.help   = {[...
    'Select this option if you have many subjects to spatially ',...
    'normalise, but there is one or a small number of scans for '...
    'each subject.']};

% ---------------------------------------------------------------------
% fmask File name
% ---------------------------------------------------------------------
fmask        = cfg_files;
fmask.tag    = 'fmask';
fmask.name   = 'File';
fmask.filter = 'image';
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
masks.help    = {['Select first-level (pre-processing) mask for each ',...
                  'modality. The name of the modalities should be the same ',...
                  'as the ones entered for subjects/scans.']};
masks.num     = [1 Inf];
masks.values  = {mask };

% ---------------------------------------------------------------------
% load_SPM Load SPM.mat
% ---------------------------------------------------------------------
load_SPM         = cfg_files;
load_SPM.tag     = 'load_SPM';
load_SPM.name    = 'Load SPM.mat';
load_SPM.help    = {['Load design from SPM.mat (if you have previously '...
                    'specified the experimental design with SPM).']};
load_SPM.filter  = '^SPM\.mat$';
load_SPM.num     = [1 1];

% ---------------------------------------------------------------------
% cond_name Name
% ---------------------------------------------------------------------
cond_name         = cfg_entry;
cond_name.tag     = 'cond_name';
cond_name.name    = 'Name';
cond_name.help    = {'Name of condition.'};
cond_name.strtype = 's';
cond_name.num     = [1 Inf];

% ---------------------------------------------------------------------
% onsets Onsets
% ---------------------------------------------------------------------
onsets         = cfg_entry;
onsets.tag     = 'onsets';
onsets.name    = 'Onsets';
onsets.help    = {'Specify a vector of onset times for this condition type. '};
onsets.strtype = 'e';
onsets.num     = [Inf 1];

% ---------------------------------------------------------------------
% durations Durations
% ---------------------------------------------------------------------
durations         = cfg_entry;
durations.tag     = 'durations';
durations.name    = 'Durations';
durations.help    = {['Specify the event durations. Epoch and '...
                      'event-related responses are modeled in exactly '...
                      'the same way but by specifying their different '...
                      'durations.  Events are specified with a duration '...
                      'of 0.  If you enter a single number for the '...
                      'durations it will be assumed that all trials '...
                      'conform to this duration. If you have multiple '...
                      'different durations, then the number must match '...
                      'the number of onset times.']};
durations.strtype = 'e';
durations.num     = [Inf 1];

% ---------------------------------------------------------------------
% conds Condition
% ---------------------------------------------------------------------
conds         = cfg_branch;
conds.tag     = 'conds';
conds.name    = 'Condition';
conds.help    = {'Specify condition: name, onsets and duration.'};
%temporarily remove the rt_trial
conds.val     = {cond_name, onsets, durations};

% ---------------------------------------------------------------------
% conditions Conditions
% ---------------------------------------------------------------------
conditions         = cfg_repeat;
conditions.tag     = 'conditions';
conditions.name    = 'Conditions';
conditions.help    = {['Specify conditions. You are allowed to combine '...
                       'both event- and epoch-related responses in '...
                       'the same model and/or regressor. Any number of '...
                       'condition (event or epoch) types can be '...
                       'specified.  Epoch and event-related responses '...
                       'are modeled in exactly the same way by '...
                       'specifying their onsets [in terms of onset '...
                       'times] and their durations.  Events are specified '...
                       'with a duration of 0.  If you enter a single '...
                       'number for the durations it will be assumed that '...
                       'all trials conform to this duration.For factorial '...
                       'designs, one can later associate these experimental '...
                       'conditions with the appropriate levels of experimental '...
                       'factors.']};
conditions.values  = {conds};

% ---------------------------------------------------------------------
% multi_conds Multiple conditions
% ---------------------------------------------------------------------
multi_conds         = cfg_files;
multi_conds.tag     = 'multi_conds';
multi_conds.name    = 'Multiple conditions';
multi_conds.val{1}  = {''};
multi_conds.help    = {
                 'Select the *.mat file containing details of your multiple experimental conditions. '
                 ''
                 'If you have multiple conditions then entering the details a condition at a time is very inefficient. This option can be used to load all the required information in one go. You will first need to create a *.mat file containing the relevant information. '
                 ''
                 'This *.mat file must include the following cell arrays (each 1 x n): names, onsets and durations. eg. names=cell(1,5), onsets=cell(1,5), durations=cell(1,5), then names{2}=''SSent-DSpeak'', onsets{2}=[3 5 19 222], durations{2}=[0 0 0 0], contain the required details of the second condition. These cell arrays may be made available by your stimulus delivery program, eg. COGENT. The duration vectors can contain a single entry if the durations are identical for all events.'
                 ''
                 'Time and Parametric effects can also be included. For time modulation include a cell array (1 x n) called tmod. It should have a have a single number in each cell. Unused cells may contain either a 0 or be left empty. The number specifies the order of time modulation from 0 = No Time Modulation to 6 = 6th Order Time Modulation. eg. tmod{3} = 1, modulates the 3rd condition by a linear time effect.'
                 ''
                 'For parametric modulation include a structure array, which is up to 1 x n in size, called pmod. n must be less than or equal to the number of cells in the names/onsets/durations cell arrays. The structure array pmod must have the fields: name, param and poly.  Each of these fields is in turn a cell array to allow the inclusion of one or more parametric effects per column of the design. The field name must be a cell array containing strings. The field param is a cell array containing a vector of parameters. Remember each parameter must be the same length as its corresponding onsets vector. The field poly is a cell array (for consistency) with each cell containing a single number specifying the order of the polynomial expansion from 1 to 6.'
                 ''
                 'Note that each condition is assigned its corresponding entry in the structure array (condition 1 parametric modulators are in pmod(1), condition 2 parametric modulators are in pmod(2), etc. Within a condition multiple parametric modulators are accessed via each fields cell arrays. So for condition 1, parametric modulator 1 would be defined in  pmod(1).name{1}, pmod(1).param{1}, and pmod(1).poly{1}. A second parametric modulator for condition 1 would be defined as pmod(1).name{2}, pmod(1).param{2} and pmod(1).poly{2}. If there was also a parametric modulator for condition 2, then remember the first modulator for that condition is in cell array 1: pmod(2).name{1}, pmod(2).param{1}, and pmod(2).poly{1}. If some, but not all conditions are parametrically modulated, then the non-modulated indices in the pmod structure can be left blank. For example, if conditions 1 and 3 but not condition 2 are modulated, then specify pmod(1) and pmod(3). Similarly, if conditions 1 and 2 are modulated but there are 3 conditions overall, it is only necessary for pmod to be a 1 x 2 structure array.'
                 ''
                 'EXAMPLE:'
                 'Make an empty pmod structure: '
                 '  pmod = struct(''name'',{''''},''param'',{},''poly'',{});'
                 'Specify one parametric regressor for the first condition: '
                 '  pmod(1).name{1}  = ''regressor1'';'
                 '  pmod(1).param{1} = [1 2 4 5 6];'
                 '  pmod(1).poly{1}  = 1;'
                 'Specify 2 parametric regressors for the second condition: '
                 '  pmod(2).name{1}  = ''regressor2-1'';'
                 '  pmod(2).param{1} = [1 3 5 7]; '
                 '  pmod(2).poly{1}  = 1;'
                 '  pmod(2).name{2}  = ''regressor2-2'';'
                 '  pmod(2).param{2} = [2 4 6 8 10];'
                 '  pmod(2).poly{2}  = 1;'
                 ''
                 'The parametric modulator should be mean corrected if appropriate. Unused structure entries should have all fields left empty.'
}';
multi_conds.filter  = 'mat';
multi_conds.ufilter = '.*';
multi_conds.num     = [0 1];

% ---------------------------------------------------------------------
% new_design Specify design
% ---------------------------------------------------------------------
new_design         = cfg_branch;
new_design.tag     = 'new_design';
new_design.name    = 'Specify design';
new_design.help    = {'Specify design: scans (data), onsets and durations.'};
new_design.val     = {unit conditions multi_conds covar};

% ---------------------------------------------------------------------
% no_design No design
% ---------------------------------------------------------------------
no_design         = cfg_const;
no_design.tag     = 'no_design';
no_design.name    = 'No design';
no_design.val     = {0};
no_design.help    = {['Do not specify design. This option can be used '...
                     'for modalities (e.g. structural scans) that do not '...
                     'have an experimental design.']};

% ---------------------------------------------------------------------
% design Data & Design
% ---------------------------------------------------------------------
design        = cfg_choice;
design.tag    = 'design';
design.name   = 'Data & Design';
design.help   = {'Specify data and design.'};
design.values = {load_SPM, new_design, no_design };
design.val    = {load_SPM };

% ---------------------------------------------------------------------
% subject Modality
% ---------------------------------------------------------------------
subject      = cfg_branch;
subject.tag  = 'subject';
subject.name = 'Modality';
subject.val  = {mod_name, TR, scans, design };
subject.help = {'Add new data modality.'};

% ---------------------------------------------------------------------
% gr_name Name
% ---------------------------------------------------------------------
gr_name         = cfg_entry;
gr_name.tag     = 'gr_name';
gr_name.name    = 'Name';
gr_name.help    = {'Name of the group. Example: ''Controls''.'};
gr_name.strtype = 's';
gr_name.num     = [1 Inf];

% ---------------------------------------------------------------------
% ind_subj Subject
% ---------------------------------------------------------------------
ind_subj         = cfg_repeat;
ind_subj.tag     = 'ind_subj';
ind_subj.name    = 'Subject';
ind_subj.help    = {'Add new modality for this subject.'};
ind_subj.values  = {subject };

% ---------------------------------------------------------------------
% subjs Subjects
% ---------------------------------------------------------------------
subjs         = cfg_repeat;
subjs.tag     = 'subjs';
subjs.name    = 'Subjects';
subjs.help    = {'Add subjects.'};
subjs.values  = {ind_subj };

% ---------------------------------------------------------------------
% select Select by
% ---------------------------------------------------------------------
select        = cfg_choice;
select.tag    = 'select';
select.name   = 'Select by';
select.values = {subjs, images};
select.help   = {...
['Depending on the type of data at hand, you may have many images (scans) '...
 'per subject, such as a fMRI time series, or you may have many '...
 'subjects with only one or a small number of images (scans) per subject '...
 ', such as PET images. If you have many scans per subject select the '...
 'option ''subjects''. If you have one scan for many subjects select '...
 'the option ''scans''.']};

% ---------------------------------------------------------------------
% group Group
% ---------------------------------------------------------------------
group         = cfg_branch;
group.tag     = 'group';
group.name    = 'Group';
group.help    = {'Specify data and design for the group.'};
group.val     = {gr_name, select };

% ---------------------------------------------------------------------
% groups Groups
% ---------------------------------------------------------------------
groups         = cfg_repeat;
groups.tag     = 'groups';
groups.name    = 'Groups';
groups.help    = {['Add data and design for one group. Click ''new'' '...
                    'or ''repeat'' to add another group.']};
groups.num     = [1 Inf];
groups.values  = {group };

% ---------------------------------------------------------------------
% dir_name Directory
% ---------------------------------------------------------------------
dir_name         = cfg_files;
dir_name.tag     = 'dir_name';
dir_name.name    = 'Directory';
dir_name.help    = {['Select a directory where the PRT.mat file '...
                     'containing the specified design and data matrix '...
                     'will be written.']};
dir_name.filter  = 'dir';
dir_name.ufilter = '.*';
dir_name.num     = [1 1];

% ---------------------------------------------------------------------
% data Data & Design
% ---------------------------------------------------------------------
data        = cfg_exbranch;
data.tag    = 'data';
data.name   = 'Data & Design';
data.val    = {dir_name groups masks review};
data.help   = {'Specify the group(s) of data set.'};
data.prog   = @prt_run_design;
data.vout   = @vout_data;

%------------------------------------------------------------------------
% Output function
%------------------------------------------------------------------------
function cdep = vout_data(job)
% Specifies the output from this modules, i.e. the filename of the mat file

cdep(1)            = cfg_dep;
cdep(1).sname      = 'PRT.mat file';
cdep(1).src_output = substruct('.','files');
cdep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
%------------------------------------------------------------------------
