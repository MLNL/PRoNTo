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
for i = 1:nmodel
    if strcmp(PRT.model(i).model_name,in.model_name)
        model_idx = i;
    end
end

% Find machine
% -------------------------------------------------------------------------
mfunc       = PRT.model(model_idx).input.machine.function;
m.args      = [];
m.function  = 'prt_weights_bin_linkernel';

switch mfunc
    case 'prt_machine_svm_bin' 
        img_mach    = 'svm_weights.img';
    case 'prt_machine_rvr'
        img_mach    = 'rvr_weights.img';
    case 'prt_machine_krr'
        img_mach    = 'krr_weights.img';
    case 'prt_machine_RT_bin'
        img_mach    = 'rt_weights.img';
    otherwise
        error('prt_compute_weights:MachineNotSupported',...
            'Error: weights computation not supported for this machine!');
end

if ~isempty(in.img_name)
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

% Find mask
% -------------------------------------------------------------------------
nmod = length(PRT.masks);
for i=1:nmod
    if strcmp(PRT.masks(i).mod_name,PRT.fas(fas_idx).mod_name)
        idx_mask = i;
    end
end

% Create image
% -------------------------------------------------------------------------
hdr        = nifti(char(PRT.masks(idx_mask).fname));
img4d      = file_array(img_name,[hdr.dat.dim(1),hdr.dat.dim(2),...
             hdr.dat.dim(3),nfold],'float64-le',0,1,0);         
nvox       = hdr.dat.dim(1)*hdr.dat.dim(2)*hdr.dat.dim(3);
 
for f = 1:nfold
    
    disp(sprintf('Computing weights: fold %d of %d',f,nfold))
    
    train_idx      = cvmat(:,f)==1;
    train          = samp_idx(train_idx);
   
    alphas         = PRT.model(model_idx).output.fold(f).alpha;

    datamat        = PRT.fas(fas_idx).dat(train,:);
    
    d.coeffs       = alphas;
    d.datamat      = datamat;
    
    wimg           = prt_weights(d,m);
    
    img3d          = zeros(1,nvox);
    img3d(idfeat)  = wimg;
    
    img3d          = reshape(img3d,hdr.dat.dim(1),hdr.dat.dim(2),...
                     hdr.dat.dim(3),1);      

    img4d(:,:,:,f) = img3d;
    
end

% Create weigths file
%--------------------------------------------------------------------------
No         = hdr;              % copy header
No.dat     = img4d;            % change file_array
No.descrip = 'Pronto weigths'; % description
create(No);                    % write header

return


