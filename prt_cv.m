function [outfile]=prt_cv(PRT,in)
% Main cross-validation script
%
% Input structure:
% ----------------
% in.fname:      filename for PRT.mat (string)
% in.model_name: name for this model (string)
% in.targets:    labels for the whole dataset (n x nClass matrix)
% in.usebf:      use a kernel (basis functions) or features? (boolean)
%
% in.fs.fs_name: name for this feature set (string)
% in.fs.fs_file: location for data matrices / kernels (string)
% in.fs.mask:    masks used to create the data (vector of indices)
%
% in.cv.cv_name: cross-validation approach to use (string)
% in.cv.cv_mat:  cross-validation matrix (n x nFold matrix)
% in.cv.indices: sample indices of the data set (vector of indices)
%
% in.machine.function: function for classification or regression (string)       
% in.machine.args:     function arguments (string, matrix, or struct).
%
% Writes the following fields in the PRT data structure:
% ------------------------------------------------------
% PRT.fs(f).fs_name
% PRT.fs(f).fs_file
% PRT.fs(f).mask 
% *PRT.fs(f).ids.group
% *PRT.fs(f).ids.subject
% *PRT.fs(f).ids.modality
% *PRT.fs(f).ids.cond
% *PRT.fs(f).ids.scan
%
% PRT.cv(c).cv_name
% PRT.cv(c).cv_mat
% *PRT.cv(c).fs_name
% *PRT.cv(c).fs_indices
% 
% PRT.model(m).model_name:    name of this model
% -PRT.model(m).input.fs_name: feature set used 
% PRT.model(m).input.cv_name: CV structure used 
% PRT.model(m).input.targets: Prediction targets (all samples)
% PRT.model(m).input.usebf:   Use basis functions or features?
% PRT.model(m).input.machine: machine used for the model (see above)
% 
% PRT.model(m).output.fold(i).targets:     targets for fold(i)
% PRT.model(m).output.fold(i).predictions: predictions for fold(i)
% PRT.model(m).output.fold(i).stats:       statistics for fold(i)
% PRT.model(m).output.fold(i).{custom}:    optional fields
%__________________________________________________________________________
% Copyright (C) 2011

% Written by A Marquand

prt_dir = regexprep(in.fname,'PRT.mat', '');

[PRT, id] = copy_input_prt(PRT, in);

% configure some variables
CV      = PRT.cv(id.c).cv_mat;  % CV matrix
n_folds = size(CV,2);            % number of CV folds
n_Phi   = size(PRT.fs(id.f),1);  % number of data matrices

% targets
t  = PRT.model(id.m).input.targets;

% load data files
disp('Loading data files.....>>');
Phi = cell(1,n_Phi);
for i = 1:size(PRT.fs,1)
    load(fullfile(prt_dir,PRT.fs(id.f).fs_file));
    
    if PRT.model(id.m).input.usebf
        Phi{i} = kernel.K;
    else
        % this should be improved
        vname = whos('-file', [prt_dir,PRT.fs(id.f).fs_file]);
        eval(['Phi{',num2str(i),'}=',vname,';']);
    end
end

% Begin cross-validation loop
% -------------------------------------------------------------------------
PRT.model(id.m).output.fold = struct();
for f = 1:n_folds
    % configure training and test indices (validation is done later)
    tr_idx = and(CV(:,f) == 1, in.targets ~= 0);
    te_idx = and(CV(:,f) == 2, in.targets ~= 0);    
    
    [Phi_tr, Phi_te, Phi_tt] = ...
        split_data(Phi, tr_idx, te_idx, PRT.model(id.m).input.usebf);
      
    % Assemble data structure
    cvdata.train      = Phi_tr;
    cvdata.test       = Phi_te;
    cvdata.tr_targets = t(tr_idx,:);
    cvdata.usebf      = PRT.model(id.m).input.usebf;
    %if PRT.model(id.m).input.usebf
    %    cvdata.testcov    = Phi_tt;
    %end
    
    % train the prediction model
    model = prt_machine(cvdata, PRT.model(id.m).input.machine);
        
    % compute stats
    stats = prt_stats(model, t(te_idx,:));
    
    % update PRT
    PRT.model(id.m).output.fold(f).targets = t(te_idx,:);
    % copy fields model
    flds = fieldnames(model);
    for fld = 1:length(flds)
        fldnm = char(flds(fld));
        eval(['PRT.model(id.m).output.fold(f).',fldnm,'=model.',fldnm,';']);
    end
    %PRT.model(id.m).output.fold(f)      = model(:);
    PRT.model(id.m).output.fold(f).stats = stats;
end

% Save PRT containing machine output
% -------------------------------------------------------------------------

outfile = [prt_dir, 'PRT'];
disp(['Updating PRT.mat.......>>'])
if spm_matlab_version_chk('7') >= 0
    save(outfile,'-V6','PRT');
else
    save(outfile,'PRT');
end

end

% -------------------------------------------------------------------------
% Private functions
% -------------------------------------------------------------------------

function [PRT, id] = copy_input_prt(PRTin, in)
% Function to copy the input data to the PRT structure

PRT = PRTin;

% update model
model_exists = false;
if isfield(PRT,'model')
    if any(strcmpi(in.model_name,{PRT.model(:).model_name}))
        id.m = find(strcmpi(in.model_name,{PRT.model(:).model_name}));
        model_exists = true;
    else
        id.m = length(PRT.model)+1;
    end
else
    id.m = 1;
end
if model_exists
    warning('prt_cv:modelAlreadyInPRT',['Model ''',in.model_name,...
        ''' already exists in PRT.mat. Overwriting.']);
else
    disp(['Model ''',in.model_name,''' not found in PRT.mat. Creating.'])
end
% always overwrite the model
PRT.model(id.m).model_name    = in.model_name;
PRT.model(id.m).input.fs_name = in.fs.fs_name;
PRT.model(id.m).input.cv_name = in.cv.cv_name;
PRT.model(id.m).input.targets = in.targets;
PRT.model(id.m).input.usebf   = in.usebf;
PRT.model(id.m).input.machine = in.machine;

 update feature set
fs_exists = false;
if isfield(PRT,'fs')
    if any(strcmpi(in.fs.fs_name,{PRT.fs(:).fs_name}))
        id.f = find(strcmpi(in.fs.fs_name,{PRT.fs(:).fs_name}));
        fs_exists = true;
    else
        id.f = length(PRT.cv)+1;
    end
else
    id.f = 1;
end
if fs_exists
    disp(['Feature set ''',in.fs.fs_name,''' found in PRT.mat.']);
else
    disp(['Feature set ''',in.fs.fs_name,''' not found in PRT.mat. Creating.'])
    PRT.fs(id.f).fs_name = in.fs.fs_name;
    PRT.fs(id.f).fs_file = in.fs.fs_file; 
    PRT.fs(id.f).mask    = in.fs.mask;
end

% update cross-validation structure
cv_exists = false;
if isfield(PRT,'cv')
    if any(strcmpi(in.cv.cv_name,{PRT.cv(:).cv_name}))
        id.c = find(strcmpi(in.cv.cv_name,{PRT.cv(:).cv_name}));
        cv_exists = true;
    else
        id.c = length(PRT.cv)+1;
    end
else
    id.c = 1;
end

if cv_exists
    disp(['CV structure ''',in.cv.cv_name,''' found in PRT.mat.']);
else
    disp(['CV structure ''',in.cv.cv_name,''' not found in PRT.mat. Creating.'])
    PRT.cv(id.c).cv_name = in.cv.cv_name;
    PRT.cv(id.c).cv_mat  = in.cv.cv_mat;
    PRT.cv(id.c).indices = in.cv.indices;
end

end
        
function [Phi Phi_te Phi_tt] = split_data(Phi_all, tr_idx, te_idx, usebf)
% function to split the data matrix into training and test

n_mat = length(Phi_all);

Phi = cell(1,n_mat);
for i = 1:n_mat;
    if usebf
        cols_tr = tr_idx;
    else
        cols_tr = size(Phi_all{i},2);
    end
    
    Phi{i} = Phi_all{i}(tr_idx,cols_tr);
end

Phi_te  = cell(1,n_mat);
Phi_tt = cell(1,n_mat);

if usebf
    cols_tr = tr_idx;
    cols_te = te_idx;
else
    cols_tr = size(Phi_all{i},2);
    %cols_te = size(Phi_all{i},2);
end

for i = 1:length(Phi_all)
    Phi_te{i} = Phi_all{i}(te_idx, cols_tr);
    if usebf
        Phi_tt{i} = Phi_all{i}(te_idx, cols_te);
    else
        Phi_tt{i} = [];
    end
end

end

