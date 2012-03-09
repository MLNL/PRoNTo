function prt_compute_weights(PRT,in)
% FORMAT prt_compute_weights(PRT,in)
%
% This function calls prt_weights to compute weights 
% Inputs:
%       PRT             - data/design/model structure (it needs to contain
%                         at least one estimated model).
%         in            - structure with specific information to create
%                         weights
%           .model_name - model name (string)
%           .img_name   - (optional) name of the file to be created
%                         (string)
%           .pathdir    - directory path where to save weights (same as the
%                         one for PRT.mat) (string)
% Output:
%       empty           - does not return anything (it creates an .img file)
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by M.J.Rosa
% $Id$

% Find model
% -------------------------------------------------------------------------
nmodel = length(PRT.model);
model_idx = 0;
for i = 1:nmodel
    if strcmp(PRT.model(i).model_name,in.model_name)
        model_idx = i;
    end
end
% Check if model exists
if model_idx == 0, error('prt_compute_weights:ModelNotFound',...
        'Error: model not found in PRT.mat!'); end

% Find machine
% -------------------------------------------------------------------------
mfunc       = PRT.model(model_idx).input.machine.function;
m.args      = [];
m.function  = 'prt_weights_bin_linkernel';

% unfortunately a bug somewhere causes shifts in weight image if
% .nii is used...
switch mfunc
    case 'prt_machine_svm_bin'
        img_mach    = 'svm_weights.img';
    case 'prt_machine_rvr'
        img_mach    = 'rvr_weights.img';
    case 'prt_machine_krr'
        img_mach    = 'krr_weights.img';
        % weights computation not yet supported for RT
    case 'prt_machine_RT_bin'
        error('prt_compute_weights:MachineNotSupported',...
            'Error: weights computation not supported for this machine!');
    case 'prt_machine_gpml'
        img_mach    = 'gpml_weights.img';
    otherwise
        error('prt_compute_weights:MachineNotSupported',...
            'Error: weights computation not supported for this machine!');
end

% Image name
% -------------------------------------------------------------------------

if ~isempty(in.img_name)
    if ~(prt_checkAlphaNumUnder(in.img_name))
        error('prt_compute_weights:NameNotAlphaNumeric',...
            'Error: image name should contain only alpha-numeric elements!');
    end
    in.img_name = [in.img_name,'.img'];
    img_name    = fullfile(in.pathdir,in.img_name);
else
    img_name    = fullfile(in.pathdir,img_mach);
end

% Other info
% -------------------------------------------------------------------------
fs_name  = PRT.model(model_idx).input.fs(1).fs_name;
samp_idx = PRT.model(model_idx).input.samp_idx;
nfold    = length(PRT.model(model_idx).output.fold);

% Find feature set
% -------------------------------------------------------------------------
nfs = length(PRT.fs);
for f = 1:nfs
    if strcmp(PRT.fs(f).fs_name,fs_name)
        fs_idx = f;
    end
end
ID     = PRT.fs(fs_idx).id_mat(PRT.model(model_idx).input.samp_idx,:);
ID_all = PRT.fs(fs_idx).id_mat;

% Find modality
% -------------------------------------------------------------------------
nfas = length(PRT.fas);
mods = {PRT.fs(fs_idx).modality.mod_name};
fas  = zeros(1,nfas);
for i = 1:nfas
    for j = 1:length(mods)
        if strcmpi(PRT.fas(i).mod_name,mods{j})
            fas(i) = 1;
        end
    end
end
fas_idx = find(fas);

% Create image
% -------------------------------------------------------------------------
hdr        = PRT.fas(fas_idx(1)).hdr.private;
img4d      = file_array(img_name,[hdr.dat.dim(1),hdr.dat.dim(2),...
    hdr.dat.dim(3),nfold+1],'float64-le',0,1,0);

zdim    = hdr.dat.dim(3);
xydim   = hdr.dat.dim(1)*hdr.dat.dim(2);
norm3d  = 0;

disp('Computing weights.......>>')

for z = 1:zdim
    
    disp(sprintf('Slice: %d of %d',z,zdim))
    
    img3dav  = zeros(1,xydim); % average weight map
    
    feat_slc = find(PRT.fas(fas_idx(1)).idfeat_img>=(xydim*(z-1)+1) & ...
        PRT.fas(fas_idx(1)).idfeat_img<=(xydim*z));
    
    if isempty(feat_slc)
        
        img4d(:,:,z,:) = zeros(hdr.dat.dim(1),hdr.dat.dim(2),1,nfold+1);
        
    else
        
        for f = 1:nfold
            
            train_idx      = PRT.model(model_idx).input.cv_mat(:,f)==1;
            train          = samp_idx(train_idx);
            train_all      = zeros(size(ID_all,1),1); train_all(train) = 1;
            
            d.coeffs       = PRT.model(model_idx).output.fold(f).alpha;
            
            d.datamat = zeros(length(train), length(feat_slc));
            for i = 1:length(fas_idx)
                % indexes to access the file array
                indm = PRT.fs(fs_idx).fas.im == fas_idx(i) & train_all; 
                ifa  = PRT.fs(fs_idx).fas.ifa(indm);
                
                % index for the target data matrix
                indtr = ID(train_idx,3) == fas_idx(i);
                d.datamat(indtr,:) = PRT.fas(fas_idx(i)).dat(ifa,feat_slc);
            end
            
            % Apply any operations specified during training
            ops = PRT.model(model_idx).input.operations(PRT.model(model_idx).input.operations ~=0 );
            cvdata.train      = {d.datamat};
            cvdata.tr_id      = ID(train_idx,:);
            cvdata.use_kernel = false; % need to apply the operation to the data
            for o = 1:length(ops)
                cvdata = prt_apply_operation(PRT, cvdata, ops(o));
            end
            d.datamat = cvdata.train{:};
            
            wimg           = prt_weights(d,m);
            
            img3d          = zeros(1,xydim);
            
            img3d(PRT.fas(fas_idx(1)).idfeat_img(feat_slc)-xydim*(z-1)) = wimg;
            
            norm3d(f)      = sum(img3d.^2);
            
            img3dav        = img3dav + img3d;
            
            img4d(:,:,z,f) = reshape(img3d,hdr.dat.dim(1),hdr.dat.dim(2),1,1);
            
        end
        
        norm4d(z,:) = norm3d;
        
        % Create average fold
        %--------------------------------------------------------------------------
        img4d(:,:,z,nfold+1) = reshape(img3dav,hdr.dat.dim(1),hdr.dat.dim(2),...
            1,1)/nfold;        
    end
    
end

norm4d = sqrt(sum(norm4d,1));

disp('Normalising weights--------->>')
for f = 1:nfold,
    img4d(:,:,:,f) = img4d(:,:,:,f)./norm4d(1,f);
end

% Create weigths file
%--------------------------------------------------------------------------
disp('Creating image--------->>')
No         = hdr;              % copy header
No.dat     = img4d;            % change file_array
No.descrip = 'Pronto weigths'; % description
create(No);                    % write header
disp('Done.')
