function prt_compute_weights(PRT,in)
% FORMAT prt_compute_weights(PRT,in)
%
% This function calls prt_weights to compute weights 
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
    img_name = [in.pathdir,in.img_name,'.img'];
else
    img_name = [in.pathdir,img_mach];
end

% Other info
% -------------------------------------------------------------------------
fs_name  = PRT.model(model_idx).input.fs(1).fs_name;
cvmat    = PRT.model(model_idx).input.cv_mat;
samp_idx = PRT.model(model_idx).input.samp_idx;
nfold    = length(PRT.model(model_idx).output.fold);

% Find feature
% -------------------------------------------------------------------------
nfs = length(PRT.fs);
for f = 1:nfs
    if strcmp(PRT.fs(f).fs_name,fs_name)
        fs_idx = f;
    end
end

% Find modality
% -------------------------------------------------------------------------
nfas = length(PRT.fas);
for i = 1:nfas
    if strcmp(PRT.fas(i).mod_name,PRT.fs(fs_idx).modality.mod_name)
        fas_idx = i;
    end
end
idfeat = PRT.fas(fas_idx).idfeat_img;

% Create image
% -------------------------------------------------------------------------
hdr        = PRT.fas(fas_idx).hdr.private;
img4d      = file_array(img_name,[hdr.dat.dim(1),hdr.dat.dim(2),...
             hdr.dat.dim(3),nfold+1],'float64-le',0,1,0);         
nvox       = hdr.dat.dim(1)*hdr.dat.dim(2)*hdr.dat.dim(3);
img3dav    = zeros(1,nvox); % average weight map

for f = 1:nfold
    
    disp(sprintf('Computing weights: fold %d of %d',f,nfold))
    
    train_idx      = cvmat(:,f)==1;
    train          = samp_idx(train_idx);
   
    alphas         = PRT.model(model_idx).output.fold(f).alpha;
    
    d.coeffs       = alphas;
    d.datamat      = PRT.fas(fas_idx).dat(train,:);
    
    wimg           = prt_weights(d,m);
    wimg           = wimg/norm(wimg,2); % normalise weights
    
    img3d          = zeros(1,nvox);
    img3d(idfeat)  = wimg;
    
    img4d(:,:,:,f) = reshape(img3d,hdr.dat.dim(1),hdr.dat.dim(2),...
                     hdr.dat.dim(3),1);      
   
end

% Create average fold
%--------------------------------------------------------------------------
disp('Computing averaged weights')
img4d(:,:,:,f+1) = sum(img4d(:,:,:,:),4)/nfold;

% Create weigths file
%--------------------------------------------------------------------------
disp('Creating image--------->>')
No         = hdr;              % copy header
No.dat     = img4d;            % change file_array
No.descrip = 'Pronto weigths'; % description
create(No);                    % write header

