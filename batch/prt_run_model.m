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
%   model.operations: operations to apply before prediction
%
%   model.fs(f).fs_name:     feature set(s) this CV approach is defined for
%   model.fs(f).fs_features: feature selection mode ('all' or 'mask')
%   model.fs(f).mask_file:   mask for this feature set (fs_features='mask')
%
%   model.class(c).class_name
%   model.class(c).group(g).subj(s).num
%   model.class(c).group(g).subj(s).modality(m).mod_name
%   EITHER: model.class(c).group(g).subj(s).modality(m).conds(c).cond_name
%   OR:     model.class(c).group(g).subj(s).modality(m).all_scans
%   OR:     model.class(c).group(g).subj(s).modality(m).all_cond
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
if exist('PRT','var')
    clear PRT
end
load(fname);

% assemble basic fields
model.fname      = fname;
model.model_name = job.model_name;
if ~(prt_checkAlphaNumUnder(model.model_name))
    beep
    disp('Model name should be entered in alphanumeric format only')
    disp('Please correct')
    return
end
model.use_kernel = job.use_kernel;

% insert feature set fields

model.fs(1).fs_name = job.fsets;
fid=prt_init_fs(PRT,model.fs(1));
mods={PRT.fs(fid).modality(:).mod_name};

%get the conditions which are common to all subjects from all groups, only
nm=length(mods);
for i=1:nm
    flag=1;
    for j=1:length(PRT.group)
        for k=1:length(PRT.group(j).subject)
            m2= strcmpi(PRT.fs(fid).modality(nm).mod_name,mods);
            des=PRT.group(j).subject(k).modality(m2).design;
            if isstruct(des) && flag
                if k==1 && nm==1
                    lcond={des.conds(:).cond_name};
                else
                    tocmp={des.conds(:).cond_name};
                    lcond=intersect(lcond,tocmp);
                end
            else
                flag=0;
                lcond={};
            end
        end
    end
end
% Insert fields for generating the labels (ie. translate the fields coming
% from matlabbatch to something more consistent for the prt_model function)
% Note that we cycle through the groups to flatten out the structure, since
% we potentially specify multiple subjects per group
if isfield(job.model_type,'class')
    model.type = 'classification';
    for c = 1:length(job.model_type.class)
        model.class(c).class_name = job.model_type.class(c).class_name;
        
        for g = 1:length(job.model_type.class(c).group)
            scount = 1;
            model.class(c).group(g).gr_name = ...
                job.model_type.class(c).group(g).gr_name;
            
            sids   = job.model_type.class(c).group(g).subj_nums;
            for s = 1:length(sids)
                model.class(c).group(g).subj(scount).num = sids(s);
                for m = 1: length(mods)
                    model.class(c).group(g).subj(scount).modality(m).mod_name=mods{m};
                    if isfield(job.model_type.class(c).group(g).conditions,'all_scans')
                        model.class(c).group(g).subj(scount).modality(m).all_scans = true;
                    elseif isfield(job.model_type.class(c).group(g).conditions,'all_cond')
                        model.class(c).group(g).subj(scount).modality(m).all_cond = true;
                        if isempty(lcond)
                            beep
                            disp('All conditions selected while no conditions were common to all subjects')
                            disp('Please review the selection and/or the data and design')
                            return
                        end
                    else
                        model.class(c).group(g).subj(scount).modality(m).conds = ...
                            job.model_type.class(c).group(g).conditions.conds;
                        for cc=1:length(job.model_type.class(c).group(g).conditions.conds)
                            cname=job.model_type.class(c).group(g).conditions.conds(cc).cond_name;
                            if isempty(intersect({cname},lcond))
                                beep
                                disp('This condition is not common to all subjects')
                                disp('Please remove it from the selection')
                                return
                            end
                        end
                    end
                end
                scount = scount+1;
            end
        end
    end
elseif isfield(job.model_type,'reg_group')
    model.type = 'regression';
    scount = 1;
    for g = 1:length(job.model_type.reg_group)
        model.group(g).gr_name = job.model_type.reg_group(g).gr_name;
        sids   =  job.model_type.reg_group(g).subj_nums;
        for s = 1:length(sids)
            model.group(g).subj(scount).num = sids(s);
            model.group(g).subj(scount).modality.mod_name =  mods;
            scount=scount+1;
        end
    end
else
    error('this is not implemented yet');   
end

% insert machine fields
if isfield(job.machine,'svm')
    model.machine.function = 'prt_machine_svm_bin';
    model.machine.args     = job.machine.svm.svm_args;
elseif isfield(job.machine,'gpc')
    model.machine.function='prt_machine_gpml';
    model.machine.args=job.machine.gpc.gpc_args;
elseif isfield(job.machine,'krr')
    model.machine.function='prt_machine_krr';
    model.machine.args=job.machine.krr.krr_args;
elseif isfield(job.machine,'rvr')
    model.machine.function='prt_machine_rvr';
    model.machine.args=[];
elseif isfield(job.machine,'rt')
    model.machine.function='prt_machine_RT_bin';
    model.machine.args=job.machine.rt.rt_args;
else
    [pat, nam] = fileparts(char(job.machine.custom_machine.machine_func));
    model.machine.function = nam;
    model.machine.args = job.machine.custom_machine.machine_args;
end

% assemble structure for performing cross-validation
if isfield(job.cv_type,'cv_loso')
    model.cv.type = 'loso';
elseif isfield(job.cv_type,'cv_losgo')
    model.cv.type = 'losgo';
elseif isfield(job.cv_type,'cv_lobo')
    model.cv.type = 'lobo';
%     if scount>1
%         beep
%         disp('Leave One Block Out Cross Validation only allowed for within subject modeling')
%         disp('Please correct')
%     end
elseif isfield(job.cv_type,'cv_loro') %currently implemented for MCKR only
    model.cv.type = 'loro';
else
    model.cv.type     = 'custom';
    model.cv.mat_file = job.cv_type;
end

% specify operations to apply to the data prior to prediction
if isfield(job.data_ops,'sel_ops')
    model.operations = [job.data_ops.sel_ops.data_op{:}];
elseif isfield(job.data_ops,'no_op')
    model.operations = [];
end


prt_model(PRT,model);

% Function output
% -------------------------------------------------------------------------
out.files{1} = fname;
out.names{1} = model.model_name;
disp('Model configuration complete.')
end
