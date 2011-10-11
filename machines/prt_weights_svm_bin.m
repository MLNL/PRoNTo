function weights = prt_weights_svm_bin (PRT,model)
% Run function to compute weights for binary SVM
% FORMAT weights = prt_weights_svm_bin (PRT,model)
% Inputs:
%       PRT     - PRT data structure (struct)
%       model   - index of model to be used (integer)
% Output:
%       weights - filename of 4d image with weights (string)
%__________________________________________________________________________
% Copyright (C) 2011 PRoNTo

%--------------------------------------------------------------------------
% Written by J.Mourao-Miranda and M.J.Rosa
% $Id$

SANITYCHECK = true; % turn off for speed

% Initial checks
%--------------------------------------------------------------------------
if SANITYCHECK == true
    if ~isfield(PRT.model(model).input,'cv_mat')
        error('prt_weights_svm_bin:CVmatNotField',['Error: ''cv_mat'' '...
            'should exist as a field of ''PRT.model.input''.']);
    end
    if ~isfield(PRT.model(model).input,'fs_sub_idx')
        error('prt_weights_svm_bin:fssubidxNotField',['Error: ''fs_sub_idx'' '...
            'should exist as a field of ''PRT.model.input''.']);
    end
    if isfield(PRT.model(model).input,'fs_name')
        if ~iscell(PRT.model(model).input.fs_name)
            error('prt_weights_svm_bin:fsnameNotCell',['Error: ''fs_name'' '...
                'should be a cell array of strings.']);
        end
    else
        error('prt_weights_svm_bin:fsnameNotField',['Error: ''fs_name'' '...
            'should exist as a field of ''PRT.model.input''.']);
    end
    if isfield(PRT.model(model).output,'fold')
        if ~isfield(PRT.model(model).output.fold(1),'alpha')
            error('prt_weights_svm_bin:alphaNotField',['Error: ''alpha'' '...
                'should exist as a field of ''PRT.model.output.fold''.']);
        end
    else
        error('prt_weights_svm_bin:foldNotField',['Error: ''fold'' '...
            'should exist as a field of ''PRT.model.output''.']);
    end
end

% Find feature set and mask
%--------------------------------------------------------------------------
cvmat     = PRT.model(model).input.cv_mat;
nfolds    = size(cvmat,2);
fs_model  = PRT.model(model).input.fs_sub_idx;

% find feature used for the model
nfs = length(PRT.fs);
for i = 1:nfs
    if strcmp(PRT.model(model).input.fs_name{i},PRT.fs(i).fs_name)
       idx_fs = i;
    end
end
idmat = PRT.fs(idx_fs).id_mat;

% find mask used for the model
mod = PRT.fs(idx_fs).fs_mod; 
for i=1:length(PRT.masks)
    if strcmp(PRT.masks(i).mod_name,mod)
        idx_mask = i;
    end
end

% create new header from mask
sample_img = nifti(char(PRT.masks(idx_mask).fname));
filename   = [PRT.model(model).model_name,'_weights.img'];
img4d      = file_array(filename,[sample_img.dat.dim(1),...
    sample_img.dat.dim(2),sample_img.dat.dim(3),nfolds],'float64-le',...
    0,1,0); 

% Begin cross-validation loop
%--------------------------------------------------------------------------
for f = 1:nfolds
    
    disp(sprintf('Computing weights for fold %d of %d............>>',...
        f,nfolds));
    
    % get features
    idx_train = 1:size(cvmat,1);
    fold      = cvmat(:,f);
    idx_train = idx_train(fs_model(fold(fs_model)==2));
    nalpha    = length(idx_train);
    % get alphas
    idx_alpha = 1:nalpha;
    alphas    = PRT.model(model).output.fold(f).alpha;
    % get alphas different from zero
    idx_alpha = idx_alpha(alphas ~= 0);
    nalpha    = length(idx_alpha);
    
    % compute weigths
    for i=1:nalpha
        
        fname     = [prt_get_filename(idmat(idx_train(idx_alpha(i)),1:4)),...
            '.img'];
        traindata = nifti(fname);
        
        tmp1      = single(reshape(traindata.dat(:,:,:,idmat(idx_train(idx_alpha(i)),5)),...
            1,traindata.dat.dim(1)*traindata.dat.dim(2)*traindata.dat.dim(3)));% train example i
        tmp2      = single(alphas(idx_alpha(i)));
        
        if i==1
            img1d = zeros(size(tmp1),'single');
        else
            img1d = img1d + tmp1 * tmp2;
        end
        
    end
    
    img3d = reshape(img1d,sample_img.dat.dim(1),sample_img.dat.dim(2),...
        sample_img.dat.dim(3),1);
    img4d(:,:,:,f) = img3d;
    
end

disp(sprintf('File %s created.',filename));

% Create weigths file
%--------------------------------------------------------------------------
No         = sample_img;       % copy header
No.dat     = img4d;            % change file_array
No.descrip = 'Pronto weigths'; % description
create(No);                    % write header

weights    = filename;
