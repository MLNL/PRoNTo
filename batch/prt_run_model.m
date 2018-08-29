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

% Written by A Marquand and J. Schrouff
% $Id$

def = prt_get_defaults;

% Job variable
% -------------------------------------------------------------------------
job   = varargin{1};

% Load PRT.mat
% -------------------------------------------------------------------------
fname = char(job.infile);
if exist('PRT','var')
    clear PRT
end
PRT=prt_load(fname);
if ~isempty(PRT)
    handles.dat=PRT;
else
    beep
    disp('Could not load file')
    return
end

% assemble basic fields
model.fname      = fname;
model.model_name = job.model_name;
if ~(prt_checkAlphaNumUnder(model.model_name))
    beep
    disp('Model name should be entered in alphanumeric format only')
    disp('Please correct')
    return
end


% insert feature set fields
if ~isstruct(job.fsets)
    model.fs(1).fs_name = job.fsets;
else
    for i = 1:length(job.fsets.fs_name)
        model.fs(i).fs_name = job.fsets.fs_name{i};
    end
end

% Select modalities in the model to define targets based on the first
% feature set (they all have the same ID matrix)
fid = prt_init_fs(PRT,model.fs(1));
mods = [PRT.fs(fid).modality(:).mod_name];
if ~iscellstr(mods) % Compatibility with version 1
    mods = cellstr(char(PRT.fs(fid).modality(:).mod_name));
end

% if isstruct(job.fsets)
%     model.indmodels = job.fsets.indmodels;
% end

% get the conditions which are common to all subjects from all groups
nm = length(mods);
for i=1:nm
    flag=1;
    for j=1:length(PRT.group)
        for k=1:length(PRT.group(j).subject)
            m2= find(strcmpi(mods{i},{PRT.group(j).subject(k).modality(:).mod_name}));
            if isempty(m2)
                m2= find(strcmpi(mods{1},{PRT.group(j).subject(k).modality(:).mod_name}));
            end
            des=PRT.group(j).subject(k).modality(m2).design;
            if isfield(PRT.group(j).subject(k).modality(m2),'rt_subj')
                rt_subj=PRT.group(j).subject(k).modality(m2).rt_subj;
            else
                rt_subj = [];
            end
            if isstruct(des) && flag
                if k==1 && j == 1
                    lcond={des.conds(:).cond_name};
                else
                    tocmp={des.conds(:).cond_name};
                    lcond=intersect(lower(lcond),lower(tocmp));
                end
                handles.rt_subj = [];
            elseif ~isstruct(des) && length(rt_subj)>=1 % regression per subject
                if k==1 && j == 1
                    lcond={rt_subj(:).name};
                else
                    tocmp={rt_subj(:).name};
                    lcond=intersect(lower(lcond),lower(tocmp));
                end
                handles.rt_subj = rt_subj;
            else
                flag=0;
                lcond={};
            end
        end
    end
end


if isfield(job.model_type,'classification')
    model.type = 'classification';
    
    % Build 'in.class' that accessess the requested subjects and
    % conditions. It will be used by prt_model to compute samp_idx
    %----------------------------------------------------------------------
    for c = 1:length(job.model_type.classification.class)
        model.class(c).class_name = job.model_type.classification.class(c).class_name;

        for g = 1:length(job.model_type.classification.class(c).group)
            scount = 1;
            model.class(c).group(g).gr_name = ...
                job.model_type.classification.class(c).group(g).gr_name;

            sids   = job.model_type.classification.class(c).group(g).subj_nums;
            for s = 1:length(sids)
                model.class(c).group(g).subj(scount).num = sids(s);
                for m = 1: length(mods)
                    model.class(c).group(g).subj(scount).modality(m).mod_name=mods(m);
                    if isfield(job.model_type.classification.class(c).group(g).conditions,'all_scans')
                        model.class(c).group(g).subj(scount).modality(m).all_scans = true;
                    elseif isfield(job.model_type.classification.class(c).group(g).conditions,'all_cond')
                        model.class(c).group(g).subj(scount).modality(m).all_cond = true;
                        if isempty(lcond)
                            beep
                            disp('All conditions selected while no conditions were common to all subjects')
                            disp('Please review the selection and/or the data and design')
                            return
                        end
                    elseif isfield(job.model_type.classification.class(c).group(g).conditions,'target')
                        beep
                        disp('Target is not a valid option for classification')
                        return
                    else
                        model.class(c).group(g).subj(scount).modality(m).conds = ...
                            job.model_type.classification.class(c).group(g).conditions.conds;
                        for cc=1:length(job.model_type.classification.class(c).group(g).conditions.conds)
                            cname=job.model_type.classification.class(c).group(g).conditions.conds(cc).cond_name;
                            if isempty(intersect(lower({cname}),lower(lcond)))
                            end
                        end
                    end
                end
                scount = scount+1;
            end
        end
    end
    
    % Gather machine information - classification
    % ---------------------------------------------------------------------
    
    if isfield(job.model_type.classification.machine_cl_K,'mach_cl_nonkernel')
        model.use_kernel = 0;
        jobmach = job.model_type.classification.machine_cl_K.mach_cl_nonkernel;
    else
        model.use_kernel = 1;
        jobmach = job.model_type.classification.machine_cl_K.mach_cl_kernel;
    end
    
    model = prt_get_machine(model,jobmach);
    
    % Flag to subsample the classes according to lowest number of examples
    if isfield(job.model_type.classification,'subsample')
        model.subsample = job.model_type.classification.subsample;
    end

% Regression    
elseif isfield(job.model_type,'regression')
    model.type = 'regression';
    
    % Build 'in.group' to access selected subjects and targets in
    % prt_model. 
    % ---------------------------------------------------------------------
    for g = 1:length(job.model_type.regression.reg_group)
        scount = 1;
        model.group(g).gr_name = job.model_type.regression.reg_group(g).gr_name;
        sids   =  job.model_type.regression.reg_group(g).subj_nums;
        for s = 1:length(sids)
            model.group(g).subj(scount).num = sids(s);
            for m = 1: length(mods)
                model.group(g).subj(scount).modality(m).mod_name=mods(m);
                if isfield(job.model_type.regression.reg_group(g).conditions,'all_scans')
                    model.group(g).subj(scount).modality(m).all_scans = true;
                elseif isfield(job.model_type.regression.reg_group(g).conditions,'all_cond')
                    model.group(g).subj(scount).modality(m).all_cond = true;
                    if isempty(lcond)
                        beep
                        disp('All conditions selected while no conditions were common to all subjects')
                        disp('Please review the selection and/or the data and design')
                        return
                    end
                elseif isfield(job.model_type.regression.reg_group(g).conditions,'target')
                    model.group(g).subj(scount).modality(m).conds.cond_name = ...
                        job.model_type.regression.reg_group(g).conditions.target.target_name;
                    cname=job.model_type.regression.reg_group(g).conditions.target(1).target_name;
                    if isempty(intersect(lower({cname}),lower(lcond)))
                        beep
                        disp('This target cannot be found.')
                        disp('Please correct!')
                        return
                    end
                else
                    model.group(g).subj(scount).modality(m).conds = ...
                        job.model_type.regression.reg_group(g).conditions.conds;
                    for cc=1:length(job.model_type.regression.reg_group(g).conditions.conds)
                        cname=job.model_type.regression.reg_group(g).conditions.conds(cc).cond_name;
                        if isempty(intersect(lower({cname}),lower(lcond)))
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
    
    % Gather machine information
    % ---------------------------------------------------------------------
    if isfield(job.model_type.regression.machine_rg_K,'mach_rg_nonkernel')
        model.use_kernel = 0;
        jobmach = job.model_type.regression.machine_rg_K.mach_rg_nonkernel;
    else
        model.use_kernel = 1;
        jobmach = job.model_type.regression.machine_rg_K.mach_rg_kernel;
    end
    
    model = prt_get_machine(model,jobmach);
    
else
    error('this is not implemented yet');
end

% assemble structure for performing cross-validation
mainCV = prt_get_cv_type(job.cv_type);
% Copy new values to model.cv
fn = fieldnames(mainCV);
for fi = 1:length(fn)
    model.cv.(fn{fi}) = mainCV.(fn{fi});
end

model.include_allscans = job.include_allscans;

% specify operations to apply to the data prior to prediction
if isfield(job.sel_ops.use_other_ops,'data_op')
    ops = [job.sel_ops.use_other_ops.data_op{:}];
elseif isfield(job.sel_ops.use_other_ops,'no_op')
    ops = [];
end
% Add mean centering in first position if requested
if job.sel_ops.data_op_mc == 1
    model.operations = [3 ops];
else
    model.operations = ops;
end

prt_model(PRT,model);

% Function output
% -------------------------------------------------------------------------
out.files{1} = fname;
out.mname = model.model_name;
disp('Model configuration complete.')
end
