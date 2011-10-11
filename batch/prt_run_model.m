function out = prt_run_model(varargin)
%
% PRoNTo job execution function
% takes a harvested job data structure and rearrange data into "proper"
% data structure, then save do what it has to do...
% Here simply the harvested job structure in a mat file.
%
% INPUT
%   job    - harvested job data structure (see matlabbatch help)
%
% OUTPUT
%   out    - filename of saved data structure.
%
%   This function assembles a model structure with following fields:
%   
%   model.fname:      filename for PRT.mat
%   model.model_name: name for this cross-validation structure
%   model.type:       'classification' or 'regression'
%   model.use_kernel: does this model use kernels or features?
%
%   model.fs(f).fs_name:     feature set(s) this CV approach is defined for
%   model.fs(f).fs_features: feature selection mode ('all' or 'mask')
%   model.fs(f).mask_file:   mask for this feature set (fs_features='mask')
%
%   model.class(c).class_name
%   model.class(c).group(g).subj(s).num
%   model.class(c).group(g).subj(s).modality(m).mod_name
%   model.class(c).group(g).subj(s).modality(m).conds(c).cond_name
%
%   model.cv.type:     type of cross-validation ('loso','losgo','custom')
%   model.cv.mat_file: file specifying CV matrix (if type = 'custom');
%
%   FIXME: add a more flexible interface for specifying custom CV
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A Marquand
% $Id$

% Job variable
% -------------------------------------------------------------------------
job   = varargin{1};

% Load PRT.mat
% -------------------------------------------------------------------------
fname = char(job.infile);
load(fname);

% assemble basic fields
model.fname      = fname;
model.model_name = job.model_name;
model.use_kernel = job.use_kernel;

% insert feature set fields
for f = 1:length(job.fset)
    model.fs(f).fs_name = job.fset(f).fs_name;
%     if isfield(job.fset(f).sel_features,'all_features')
%         model.fs(f).fs_features = 'all';
%     else
%         model.fs(f).fs_features = 'mask';
%         model.fs(f).mask_file   = char(job.fset.sel_features.mask.fmask);
%     end
end


% Insert fields for generating the labels (ie. translate the fields coming
% from matlabbatch to something more consistent for the prt_model function)
% Note that we cycle through the groups to flatten out the structure, since
% we potentially specify multiple subjects per group
if isfield(job.model_type,'class')
    model.type = 'classification'; 
    for c = 1:length(job.model_type.class)
        model.class(c).class_name = job.model_type.class(c).class_name;
       
        scount = 1;
        for g = 1:length(job.model_type.class(c).group)
            model.class(c).group(g).gr_name = ...
                job.model_type.class(c).group(g).gr_name;
            
            sids   = job.model_type.class(c).group(g).subj_nums;
            for s = 1:length(sids)
                model.class(c).group(g).subj(scount).num = sids(s);
                
                model.class(c).group(g).subj(scount).modality.mod_name = ...
                    job.model_type.class(c).group(g).modality.mod_name;
                
                model.class(c).group(g).subj(scount).modality.conds = ...
                    job.model_type.class(c).group(g).modality.conditions.conds;
                
                scount = scount+1;
            end
        end
    end
else
    error('regression not implemented yet');
end

% insert machine fields
if isfield(job.machine,'svm')
    model.machine.function = 'prt_machine_svm_bin';
    model.machine.args     = job.machine.svm.svm_args;
else
    [pat, nam] = fileparts(char(job.machine.custom_machine.machine_func));
    model.machine.function = job.machine.custom_machine.machine_args;
end

% assemble structure for performing cross-validation
if isfield(job.cv_type,'cv_loso') 
    model.cv.type = 'loso';
elseif isfield(job.cv_type,'cv_losgo')
    model.cv.type = 'losgo';
else
    model.cv.type     = 'custom';
    model.cv.mat_file = job.cv_type;
end

prt_model(PRT,model);

% Function output
% -------------------------------------------------------------------------
out.files{1} = fname;
disp('Model configuration complete.')
end
