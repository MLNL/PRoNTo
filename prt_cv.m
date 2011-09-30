function [outfile]=prt_cv(PRT,in)
% Main cross-validation script
%
% Input structure:
% ----------------
% in.fname:      filename for PRT.mat
% in.model_name: name for this model
% in.targets:    labels for the whole dataset
% in.usebf:      use a kernel (basis functions) or features? 
%
% in.fs.fs_name: name for this feature set
% in.fs.fs_file: location for data matrices / kernels
% in.fs.mask:    masks used to create the data (indices)
%
% in.cv.cv_name: cross-validation approach to use
% in.cv.cv_mat:  cross-validation matrix
% in.cv.indices: sample indices of the data set
%
% in.machine.function: function for classification or regression (string)       
% in.machine.args:     function arguments (string, matrix, or struct).
%
% Outputs the following fields in the PRT data structure:
% -------------------------------------------------------
% PRT.fs(f).fs_name
% PRT.fs(f).fs_file
% PRT.fs(f).mask
%
% PRT.cv(c).cv_name
% PRT.cv(c).cv_mat
% PRT.cv(c).indices
%
% PRT.model(m).model_name:    name of this model
% PRT.model(m).input.fs_name: feature set used  % was index
% PRT.model(m).input.cv_name: CV structure used % was index
% PRT.model(m).input.targets: Prediction targets
% PRT.model(m).input.usebf:   Use basis functions or features?
% PRT.model(m).input.machine: machine used for the model (see above)
% 
% PRT.model(m).output.fold(i).predictions: predictions for fold(i)
% PRT.model(m).output.fold(i).{custom}:    optional fields
%__________________________________________________________________________
% Copyright (C) 2011

% Written by A Marquand

prt_dir = regexprep(in.fname,'PRT.mat', '');

[PRT, id] = update_prt_static(PRT, in);

% configure some variables
C       = PRT.cv(id.c).cv_mat;  % CV matrix
n_folds = size(C,2);             % number of CV folds
n_Phi   = size(PRT.fs(id.f),1); % number of data matrices

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
for f = 1:n_folds
    % configure training and test indices (validation is done later)
    fold  = C(:,f);
    train = fold == 1;
    test  = fold == 2;
        
    [Phi_tr, Phi_te] = split_data(Phi, train, test, PRT.model(id.m).input.usebf);
      
    model = prt_machine(Phi_tr, Phi_te, [], t(train), PRT.model(id.m).input.machine);
    
    if ~any(strcmpi(fieldnames(model(:)),'predictions'))
        error(['prt_cv:machineDoesNotGivePredictions',...
               'Machine ''',PRT.model(id.m).input.machine.function,...
               ''' did not produce a predictions field']);
    end
    
    % update PRT
    PRT.model(id.m).output.fold(f) = model(:);
end

% Save PRT containing classifier output
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

function [PRT, id] = update_prt_static(PRTin, in)
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

% update feature set
fs_exists = false;
if isfield(PRT,'feature_set')
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
    disp(['Feature set ''',in.fs.fs_name,''' not found in PRT.mat. Creating.'])
    PRT.fs(id.f).fs_name = in.fs.fs_name;
    PRT.fs(id.f).fs_file = in.fs.fs_file; 
    PRT.fs(id.f).mask    = in.fs.mask;
else
    disp(['Feature set ''',in.model_name,''' found in PRT.mat.']);
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
    disp(['Model ''',in.model_name,''' not found in PRT.mat. Creating.'])
    PRT.cv(id.c).cv_name = in.cv.cv_name;
    PRT.cv(id.c).cv_mat  = in.cv.cv_mat;
    PRT.cv(id.c).indices = in.cv.indices;
else
    disp(['CV structure ''',in.model_name,''' found in PRT.mat.']);
end

end
        
function [Phi Phi_s Phi_ss] = split_data(Phi_all, train, test, usebf)
% function to split the data matrix into training and test

n_mat = length(Phi_all);

Phi = cell(1,n_mat);
for i = 1:n_mat;
    if usebf
        cols_tr = train;
    else
        cols_tr = size(Phi_all{i},2);
    end
    
    Phi{i} = Phi_all{i}(train,cols_tr);
end

Phi_s  = cell(1,n_mat);
Phi_ss = cell(1,n_mat);

if usebf
    cols_tr = train;
    cols_te = test;
else
    cols_tr = size(Phi_all{i},2);
    cols_te = size(Phi_all{i},2);
end

for i = 1:length(Phi_all)
    Phi_s{i} = Phi_all{i}(train, cols_tr);
    Phi_ss{i} = Phi_all{i}(test, cols_te);
end

end

