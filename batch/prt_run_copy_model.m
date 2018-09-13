function out = prt_run_copy_model(varargin)
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
%   This function modifies a model structure according to user needs and
%   saves it under the new model name specified by the user.
%
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by Jessica Schrouff
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
% find model index
model_exists = false;
if isfield(PRT,'model')
    if any(strcmpi(model.model_name,{PRT.model(:).model_name}))
        mid = find(strcmpi(model.model_name,{PRT.model(:).model_name}));
        model_exists = true;
    else
        mid = length(PRT.model)+1;
    end
else
    beep
    disp('No models found in PRT.mat, cannot copy')
    return
end

model.copymodel_name = job.copymodel_name;
if ~(prt_checkAlphaNumUnder(model.copymodel_name))
    beep
    disp('Model name to copy should be entered in alphanumeric format only')
    disp('Please correct')
    return
end

% find model index of model to copy
if isfield(PRT,'model')
    if any(strcmpi(model.copymodel_name,{PRT.model(:).model_name}))
        midtc = find(strcmpi(model.copymodel_name,{PRT.model(:).model_name}));
    else
        beep
        disp('Model not found in PRT.mat, cannot copy')
        return
    end
else
    beep
    disp('No models found in PRT.mat, cannot copy')
    return
end

% For each field, input the values into the new model
if model_exists
    warning('prt_init_model:modelAlreadyInPRT',['Model ''',model.model_name,...
        ''' already exists in PRT.mat. Overwriting...']);
else
    disp(['Model ''',model.model_name,''' not found in PRT.mat. Creating...'])
end
    
% Copy model
PRT.model(mid) = PRT.model(midtc);
PRT.model(mid).output = [];
PRT.model(mid).model_name = model.model_name;

% Get fields for which the user wants to make a change
% -------------------------------------------------------------------------
for i = 1:length(job.modchoices)
    
    % Changes in feature set selection
    %----------------------------------------------------------------------
    if isfield(job.modchoices{i},'fsets')
        % delete previous selection of feature sets
        PRT.model(mid).input.fs = [];
        % insert feature set fields
        if ~isstruct(job.modchoices{i}.fsets)
            PRT.model(mid).input.fs(1).fs_name = job.modchoices{i}.fsets;
        else
            for j = 1:length(job.modchoices{i}.fsets.fs_name)
                PRT.model(mid).input.fs(j).fs_name = job.modchoices{i}.fsets.fs_name{j};
            end
        end
        
    % Changes in machine
    %----------------------------------------------------------------------
    elseif isfield(job.modchoices{i},'model_type')
        % insert machine fields
        %Classification
        if isfield(job.modchoices{i}.model_type,'machine_cl_K')
            if ~strcmpi(PRT.model(mid).input.type,'classification')
                error('prt_run_copy_model:WrongModelType',...
                    'Classification chosen but model was regression, aborting.')
            end
            if isfield(job.modchoices{i}.model_type.machine_cl_K,'mach_cl_nonkernel')
                model.use_kernel = 0;
                jobmach = job.modchoices{i}.model_type.machine_cl_K.mach_cl_nonkernel;
            else
                model.use_kernel = 1;
                jobmach = job.modchoices{i}.model_type.machine_cl_K.mach_cl_kernel;
            end            
            model = prt_get_machine(PRT.model(mid).input,jobmach);
        elseif isfield(job.modchoices{i}.model_type,'machine_rg_K')
            if ~strcmpi(PRT.model(mid).input.type,'regression')
                error('prt_run_copy_model:WrongModelType',...
                    'Regression chosen but model was classification, aborting.')
            end
            if isfield(job.modchoices{i}.model_type.machine_rg_K,'mach_rg_nonkernel')
                model.use_kernel = 0;
                jobmach = job.modchoices{i}.model_type.machine_rg_K.mach_rg_nonkernel;
            else
                model.use_kernel = 1;
                jobmach = job.modchoices{i}.model_type.machine_rg_K.mach_rg_kernel;
            end            
            model = prt_get_machine(PRT.model(mid).input,jobmach);           
        end
        PRT.model(mid).input.machine = model.machine;
        PRT.model(mid).input.use_nested_cv = model.cv.nested;
        PRT.model(mid).input.nested_param = model.cv.nested_param;
        PRT.model(mid).input.cv_type_nested = model.cv.type_nested;
        PRT.model(mid).input.cv_k_nested = model.cv.k_nested;
    
    % Changes in operations
    %----------------------------------------------------------------------
    elseif isfield(job.modchoices{i},'sel_ops')
        % delete previous selection of operations
        PRT.model(mid).input.operations = [];
        % specify operations to apply to the data prior to prediction
        if isfield(job.modchoices{i}.sel_ops.use_other_ops,'data_op')
            ops = [job.modchoices{i}.sel_ops.use_other_ops.data_op{:}];
        elseif isfield(job.modchoices{i}.sel_ops.use_other_ops,'no_op')
            ops = [];
        end
        if job.modchoices{i}.sel_ops.data_op_mc == 1
            PRT.model(mid).input.operations = [3 ops];
        else
            PRT.model(mid).input.operations = ops;
        end
        % Check that operations on features were not selected for kernels
        if any(ismember([6,7],ops))
            if model.use_kernel
                error('prt_run_model:BadOperations',...
                    'Feature operations selected while using kernels, please correct')
            end
        end
    end

end

% Save modified PRT
% -------------------------------------------------------------------------
disp('Updating PRT.mat.......>>')
if spm_check_version('MATLAB','7') >= 0
    save(fname,'-V7','PRT');
else
    save(fname,'-V6','PRT');
end

% Function output
% -------------------------------------------------------------------------
out.files{1} = fname;
out.mname = PRT.model(mid).model_name;
disp('Model configuration complete.')
end


%--------------------------------------------------------------------------
% Private functions
%--------------------------------------------------------------------------
function cv = get_cv_type(cv_struct)

% assemble structure for performing cross-validation
if isfield(cv_struct,'cv_loso')
    cv = struct('type','loso','k',0);
elseif isfield(cv_struct,'cv_lkso')
    cv = struct('type','loso','k',cv_struct.cv_lkso.k_args);
elseif isfield(cv_struct,'cv_losgo')
    cv = struct('type','losgo','k',0);
elseif isfield(cv_struct,'cv_lksgo')
    cv = struct('type','losgo','k',cv_struct.cv_lksgo.k_args);
elseif isfield(cv_struct,'cv_lobo')
    cv = struct('type','lobo','k',0);
elseif isfield(cv_struct,'cv_lkbo')
    cv = struct('type','lobo','k',cv_struct.cv_lkbo.k_args);
elseif isfield(cv_struct,'cv_locbo')
    cv = struct('type','locbo','k',0);
elseif isfield(cv_struct,'cv_lkcbo')
    cv = struct('type','locbo','k',cv_struct.cv_lkcbo.k_args);
elseif isfield(cv_struct,'cv_loro') % currently implemented for MCKR only
    cv = struct('type','loro');
else
    cv = struct('type','custom','k',cv_struct.cv_custom{1},...
        'mat_file',cv_struct.cv_custom{1});
    % Not sure if I should keep the field 'k' here...
end

end
