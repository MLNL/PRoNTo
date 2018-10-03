function img_name = prt_compute_weights_class(PRT,in,model_idx,flag, ibe, flag2)
% FORMAT prt_compute_weights_class(PRT,in,model_idx)
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
%         model_idx     - model index (integer)
%         flag          - compute weight images for each permutation if 1
%         ibe           - which beta to use for MKL and multiple modalities
%         flag2         - build image of weights per region
% Output:
%       img_name        - name of the .img file created
%       + image file created on disk
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by M.J.Rosa, modified by J. Schrouff for MEEG and multiple
% feature sets
% $Id$

% Find type of data (neuroimaging or MEEG) from feature set
% -------------------------------------------------------------------------
fs_idx = in.fs_idx;
fas_idx = in.fas_idx;
mm = in.mm;
mname = PRT.fs(fs_idx).modality(mm(1)).mod_name;
allmods = {PRT.masks(:).mod_name};
im = find(strcmpi(mname,allmods));
flagmeeg = 0;
flagmat = 0;

if isfield(PRT.masks(im),'type') && strcmpi(PRT.masks(im).type,'MEEG') %MEEG data
    ext = '.mat';
    hdr = PRT.fas(fas_idx(1)).hdr;
    nchan = nchannels(hdr);
    if isempty(nchan); dat_dim(1) = 1; else dat_dim(1) = nchan; end
    nfreq = nfrequencies(hdr);
    if isempty(nfreq); dat_dim(2) = 1; else dat_dim(2) = nfreq; end
    ntp = nsamples(hdr);
    if isempty(ntp); dat_dim(3) = 1; else dat_dim(3) = ntp; end
    ndim = numel(PRT.fs(fs_idx).modality(mm(1)).dim_m);
    fin_dim = ones(1,ndim);
    for idim = 1:ndim
        fin_dim(idim) = length(PRT.fs(fs_idx).modality(mm(1)).dim_m{idim});
    end
    flagmeeg = 1;
    idfeat = 1:size(PRT.fas(fas_idx(1)).dat,2);
    appendn = 'tmp';
else
    %.mat data
    if isfield(PRT.masks(im),'type') && strcmpi(PRT.masks(im).type,'.mat')        
        ext = '.mat';
        hdr        = PRT.fas(fas_idx(1)).hdr;
        dat_dim    = hdr.dim;
        idfeat = PRT.fas(fas_idx(1)).idfeat_img;
        flagmat = 1;
        appendn=[];
    % nifti or img file    
    else        
        ext = '.img';
        hdr        = PRT.fas(fas_idx(1)).hdr.private;
        dat_dim    = hdr.dat.dim;
        idfeat = PRT.fas(fas_idx(1)).idfeat_img;
        appendn=[];
        
    end
    
end

% Find machine
% -------------------------------------------------------------------------
mfunc       = PRT.model(model_idx).input.machine.function;
mname       = PRT.model(model_idx).model_name;
mtype       = PRT.model(model_idx).input.type;
switch mtype
    case 'classification'
        nclass      = length(PRT.model(model_idx).input.class);
    case 'regression'
        nclass = 1;
end

% Kernel machine?
if PRT.model(model_idx).input.use_kernel
    kernel = 1;
else
    kernel = 0;
end

if nclass > 2, mfunc = 'multiclass_machine'; end
m.args      = [];

if nargin<5
    ibe=[];
end
if nargin<6
    flag2 = 0;
end

% Compute the number and names of images to create, i.e. number of tasks
% times number of classes
%--------------------------------------------------------------------------
% unfortunately a bug somewhere causes shifts in weight image if
% .nii is used...

 nclass      = length(PRT.model(model_idx).input.class); % number of classes
 
 if isfield(PRT.model(model_idx).input,'models_MTL') &&...
         ~isempty(PRT.model(model_idx).input.models_MTL)
     nmodels = PRT.model(model_idx).input.models_MTL; % number of models for MTL
 else
     nmodels = 1;
 end

if ~isempty(in.img_name) % User has entered image name
    if ~(prt_checkAlphaNumUnder(in.img_name))
        error('prt_compute_weights:NameNotAlphaNumeric',...
            'Error: image name should contain only alpha-numeric elements!');
    end
    basisname = in.img_name;
else
    basisname = ['weights_',mname]; %default name is used otherwise
end

cnt = 1;
img_mach = cell(length(nmodels)*nclass,1);
for imodel = 1:length(nmodels)
    if nmodels>1 %get the name of the task
        img_mach{cnt} = [basisname,'_',PRT.model(nmodels(imodel)).model_name];
    else
        img_mach{cnt} = basisname;
    end
    if nclass>2
        for c=1:nclass %get the name of the class
            img_mach{cnt} = [img_mach{cnt},'_',PRT.model(model_idx).input.class(c).class_name,ext];
            cnt = cnt+1;
        end        
    else
        img_mach{cnt} = [img_mach{cnt},ext];
        cnt = cnt+1;
    end    
end
 
% Get the function to compute the weights for kernel machines
switch mfunc    
    case 'prt_machine_gpclap'
        m.function  = 'prt_weights_gpclap';
    case 'prt_machine_sMKL_cla'
        m.function = 'prt_weights_sMKL_cla';
    case 'prt_machine_wip_cla'
        m.function = 'prt_weights_sMKL_cla';
    case 'prt_machine_RT_bin'
        error('prt_compute_weights:MachineNotSupported',...
            'Error: weights computation not supported for this machine!');        
    otherwise
        m.function  = 'prt_weights_bin_linkernel';
end



% Finalize image names with full path
% -------------------------------------------------------------------------
nimage = length(img_mach);
img_name = cell(nimage,1);
finimg_name = cell(nimage,1);
for c = 1:nimage
    img_name{c}    = fullfile(in.pathdir,[appendn,img_mach{c}]); % Need to create a temporary image for MEEG before discarding NaN weights
    finimg_name{c} = fullfile(in.pathdir,img_mach{c});
end
% 
% if flag2 % weights per region, can only come from MKL that is binary
%     img_name{1}   = fullfile(in.pathdir,[appendn,in.img_name,ext]);
%     finimg_name{1}= fullfile(in.pathdir,[in.img_name,ext]);
% end


% Gather other info
% -------------------------------------------------------------------------
if kernel %get info to retrieve the data
    samp_idx = PRT.model(model_idx).input.samp_idx;
    ID     = PRT.fs(fs_idx).id_mat(PRT.model(model_idx).input.samp_idx,:);
    ID_all = PRT.fs(fs_idx).id_mat;
end
nfold    = length(PRT.model(model_idx).output.fold);

% Get the indexes of the voxels which are in the first/second level mask
% -------------------------------------------------------------------------

idROI = [];
if isempty(PRT.fs(fs_idx).modality(mm(1)).idfeat_fas) % get the 2nd level masking
    idfeat_fas = 1:length(idfeat);
else
    idfeat_fas = PRT.fs(fs_idx).modality(mm(1)).idfeat_fas;
end
if PRT.fs(fs_idx).multkernelROI % Get indices when an atlas is used
    m_train = cell(length(PRT.fs(fs_idx).modality(mm(1)).idfeat_img),1);
    for i = 1:length(PRT.fs(fs_idx).modality(mm(1)).idfeat_img)
        tmp1 = PRT.fs(fs_idx).modality(mm(1)).idfeat_img{i};
        idROI=[idROI;tmp1];
        tmp = idfeat_fas(tmp1);
        m_train{i} = idfeat(tmp);
    end
    id2 = idfeat_fas(sort(idROI));
else
    id2 = idfeat_fas;
end
mask_train = idfeat(id2);
voxtr = find(ismember(idfeat,mask_train));


% Create image
% -------------------------------------------------------------------------

if flag
    %create images for each permutation
    if isfield(PRT.model(model_idx).output,'permutation') && ...
            ~isempty(PRT.model(model_idx).output.permutation)
        maxp = length(PRT.model(model_idx).output.permutation);
    else
        disp('No parameters saved for the permutation, building weight image only')
    end
else
    maxp=0;
end
pthperm = cell(nimage,1);
for p=0:maxp
    if p>0
        for c = 1:nimage
            [pth,nam] = fileparts(img_name{c});
            if p==1
                pthperm{c} = fullfile(pth,['perm_',nam]);
                if ~exist(pthperm{c},'dir')
                    mkdir(pth,['perm_',nam]);
                end
            end
            img_nam{c} = fullfile(pthperm{c},[nam,'_perm',num2str(p),ext]);
        end
        fprintf('Permutation: %d of %d \n',p, ...
            length(PRT.model(model_idx).output.permutation));
    else
        img_nam = img_name;
    end
    
    % check that image does not exist, otherwise, delete
    if exist(finimg_name{1},'file')
        for c = 1:nimage
            delete(finimg_name{c});
            % delete hdr if neuroimaging, dat if MEEG
            [pth,nam] = fileparts(finimg_name{c});
            if ~flagmeeg
                if flagmat
                    hdr_name  = [pth,filesep,nam,'.mat'];
                else
                    hdr_name  = [pth,filesep,nam,'.hdr'];
                end
            else
                hdr_name  = [pth,filesep,nam,'.dat'];
                if exist(img_nam{1},'file')
                    delete(img_nam{c});
                end
            end

            delete(hdr_name)
        end
    end
    
    if length(dat_dim)==2, dat_dim = [dat_dim 1]; end % handling case of 2D image
    
    img4d = cell(nimage,1); % afm
    for c = 1:nimage
        if p==0 %save folds for the 'true' image
            folds_comp=nfold+1;
        else    %save the average across folds only for permutations
            folds_comp=1;
        end
        img4d{c} = file_array(img_nam{c},[dat_dim(1),dat_dim(2),...
            dat_dim(3),folds_comp],'float32-le',0,1,0);
    end
    
    % norm3d  = 0;
    
    disp('Computing weights.......>>')
    zdim    = dat_dim(3);
    xydim   = dat_dim(1)*dat_dim(2);
    % Build by z-slices
    fprintf(['Slice (out of %d):',repmat(' ',1,ceil(log10(zdim))),'%d'],zdim, 1);
        
    for z = 1:zdim
        % Counter of slices to be updated
        if z>1
            for idisp = 1:ceil(log10(z)) % delete previous counter display
                fprintf('\b');
            end
            fprintf('%d',z);
        end
        img3dav = cell(1,nimage);
        for c = 1:nimage
            img3dav{c}  = zeros(1,xydim); % average weight map
        end
        
        if ~isempty(idROI) %get indexes in each slice for each ROI
            feat_slc = mask_train(mask_train>=(xydim*(z-1)+1) & ...
                mask_train<=(xydim*z));
            for ir = 1:length(m_train)
                tmp = m_train{ir}(m_train{ir}>=(xydim*(z-1)+1) & ...
                    m_train{ir}<=(xydim*z));
                m.args.idfeat_img{ir} = find(ismember(feat_slc,tmp));
            end
            feat_slc = find(mask_train>=(xydim*(z-1)+1) & ...
                mask_train<=(xydim*z));
        else
            feat_slc = find(mask_train>=(xydim*(z-1)+1) & ...
                mask_train<=(xydim*z));
            m.args.idfeat_img = {1:length(feat_slc)};
        end
        
        if isempty(feat_slc)
            for c = 1:nimage
                img4d{c}(:,:,z,:) = NaN*zeros(dat_dim(1),dat_dim(2),1,folds_comp);
            end
        else
            
            for f = 1:nfold
                
                if kernel % Kernel method, need to get the data and multiply by coefficients
                    train_idx      = PRT.model(model_idx).input.cv_mat(:,f)==1;
                    train          = samp_idx(train_idx);
                    train_all      = zeros(size(ID_all,1),1); train_all(train) = 1;
                    if p>0
                        d.coeffs   = PRT.model(model_idx).output.permutation(p).fold(f).alpha;
                    else
                        d.coeffs   = PRT.model(model_idx).output.fold(f).alpha;
                    end
                    
                    d.datamat = zeros(length(train), length(feat_slc));
                    for i = 1:length(fas_idx)
                        % indexes to access the file array
                        indm = find(PRT.fs(fs_idx).fas.im == fas_idx(i));
                        if PRT.fs(fs_idx).multkernel
                            indtr = ID(train_idx,3) == fas_idx(1);
                            indm = indm(find(train_all));
                        else
                            indtr = ID(train_idx,3) == fas_idx(i);
                            indm = indm(find(train_all(ID_all(:,3)==fas_idx(i))));
                        end
                        ifa  = PRT.fs(fs_idx).fas.ifa(indm);
                        
                        % index for the target data matrix
                        d.datamat(indtr,:) = PRT.fas(fas_idx(i)).dat(ifa,voxtr(feat_slc));
                    end
                    
                    % Average data matrix along specified dimensions
                    if isfield(PRT.fs(fs_idx).modality(mm(1)),'aver') && ...
                            any(PRT.fs(fs_idx).modality(mm(1)).aver)
                        tmp = d.datamat';
                        tmp = reshape(tmp,[fin_dim length(train)]);
                        dimta = find(PRT.fs(fs_idx).modality(mm(1)).aver); %dimensions to average
                        for iav = 1:length(dimta)
                            tmp = mean(tmp, dimta(iav));
                        end
                        dimav = fin_dim;
                        dimav(find(PRT.fs(fs_idx).modality(mm(1)).aver)) = 1;
                        tmp = reshape(tmp,prod(dimav),length(train));
                        d.datamat = tmp';
                    end
                    
                    % Apply any operations specified during training
                    ops = PRT.model(model_idx).input.operations(PRT.model(model_idx).input.operations ~=0 );
                    % If GLM is one operation, set it to be the first.
                    if any(ismember(ops,5))
                        posglm = find(ops==5);
                        if posglm~=1 % GLM should be the first
                            idxops = 1:length(ops);
                            newidx = setdiff(idxops,posglm);
                            ops=[5,ops(newidx)];
                        end
                    end
                    
                    cvdata.train      = {d.datamat};
                    cvdata.tr_id      = ID(train_idx,:);
                    cvdata.use_kernel = false; % need to apply the operation to the data
                    % Get covariates (all columns) if any
                    if ~isfield(PRT.model(model_idx).input,'covar') || ...
                            isempty(PRT.model(model_idx).input.covar)
                        cvdata.tr_cov = [];
                    else
                        cvdata.tr_cov = PRT.model(model_idx).input.covar(train_idx,:);
                    end
                    for o = 1:length(ops)
                        cvdata = prt_apply_operation(PRT, cvdata, ops(o));
                    end
                    d.datamat = cvdata.train{:};
                    
                    if isfield(PRT.model(model_idx).output.fold(f),'beta') && ...
                            ~isempty(PRT.model(model_idx).output.fold(f).beta)
                        if isempty(ibe)
                            m.args.betas = PRT.model(model_idx).output.fold(f).beta;
                        else
                            m.args.betas = PRT.model(model_idx).output.fold(f).beta(ibe);
                        end
                    end
                    
                    if flag2
                        m.args.flag = 1;
                    end
                    
                    % COMPUTE WEIGHTS
                    wimg      = prt_weights(d,m);
                    
                else
                    % weights saved directly in PRT
                    w = PRT.model(model_idx).output.fold(f).w;
                    
                    for icl = 1:size(w,2) % Loop over tasks or classes (for now it is exclusive)
                        % get slice
                        wimg{icl} = w(feat_slc,icl);
                    end
                    
                end
                
                for c = 1:nimage
                    img3d              = zeros(1,xydim);
                    indi               = mask_train(feat_slc)-xydim*(z-1);
                    indm               = setdiff(1:xydim,indi);
                    img3d(indi)        = wimg{c};
                    norm3d{c}(f)       = sum(img3d.^2);
                    img3d(indm)        = NaN;
                    img3dav{c}         = img3dav{c} + img3d;
                    if p==0
                        img4d{c}(:,:,z,f)  = reshape(img3d,dat_dim(1),dat_dim(2),1,1);
                    end
                end
                
            end
            
            % Create average fold
            %------------------------------------------------------------------
            for c = 1:nimage
                norm4d{c}(z,:)             = norm3d{c};
                img3dav{c}                 = img3dav{c}/nfold; %afm
                img4d{c}(:,:,z,folds_comp) = reshape(img3dav{c},dat_dim(1),dat_dim(2),1,1); %afm
                norm4dav{c}(z,:)           = sum(img3dav{c}(isfinite(img3dav{c})).^2); %afm
            end
        end
        
    end
    
    for c =1:nimage
        norm4d{c}   = sqrt(sum(norm4d{c},1));
        norm4dav{c} = sqrt(sum(norm4dav{c},1)); %average across folds
    end
    fprintf('\n') % new line
    disp('Normalising weights--------->>')
    if p==0
        for f = 1:nfold
            for c = 1:nimage
                if unique(norm4d{c}(1,f))~=0 % If not all weights at zero, normalize
                    img4d{c}(:,:,:,f) = img4d{c}(:,:,:,f)./norm4d{c}(1,f);
                end
            end
        end
    end
    
    for c = 1:nimage % average across folds
        if unique(norm4dav{c})~=0 % If not all weights at zero, normalize
            img4d{c}(:,:,:,folds_comp) = img4d{c}(:,:,:,folds_comp)./norm4dav{c}; %afm
        end
    end %afm
    
    % Create weigths file
    %-------------------------------------------------------------------------
    clear No
    for c = 1:nimage
        fprintf('Creating image %d of %d--------->>\n',c,nimage);
        if flagmeeg % Only save non-NaN weights
            [path,fn] = fileparts(finimg_name{c});
            fnamedat = fullfile(path,[fn,'.dat']);
            aa{1} = PRT.fs(fs_idx).modality(mm(1)).dim_m{1};
            aa{2} = PRT.fs(fs_idx).modality(mm(1)).dim_m{2};
            aa{3} = PRT.fs(fs_idx).modality(mm(1)).dim_m{3};
            if any(PRT.fs(fs_idx).modality(mm(1)).aver) %average across at least 1 dimension
                fin_dim(find(PRT.fs(fs_idx).modality(mm(1)).aver))=1;
                aa{find(PRT.fs(fs_idx).modality(mm(1)).aver)}=aa{find(PRT.fs(fs_idx).modality(mm(1)).aver)}(1);
            end
            if ismember(2,find(fin_dim == 1)) %No frequency or averaged
                fin_dim = [fin_dim(1) fin_dim(3)];
            end
            weightD = clone(hdr,fnamedat,[fin_dim, folds_comp]); 
            tmp = squeeze(img4d{c}(aa{1},aa{2},aa{3},:));
            weightD(:,:,:,:) = reshape(tmp,[fin_dim,folds_comp]);
            delete(img_nam{c});
            % Transfer knowledge about the data into weight object
            if PRT.fs(fs_idx).modality(mm(1)).aver(1) ~= 1
                weightD = chanlabels(weightD,1:length(aa{1}),chanlabels(hdr,aa{1}));
                weightD = chantype(weightD,1:length(aa{1}),chantype(hdr,aa{1}));
                weightD = badchannels(weightD,1:length(aa{1}),badchannels(hdr,aa{1}));
                weightD = coor2D(weightD,1:length(aa{1}),coor2D(hdr,aa{1}));
            else
                weightD = chanlabels(weightD,1,'Average');
                weightD = chantype(weightD,1,chantype(hdr,aa{1}(1)));
            end
            weightD = timeonset(weightD,time(hdr,min(aa{3})));
            if ~isempty(nfrequencies(hdr)) && ...
                    strncmpi(transformtype(weightD), 'TF',2)
                if PRT.fs(fs_idx).modality(mm(1)).aver(2) ~= 1
                    weightD = frequencies(weightD,1:length(aa{2}),frequencies(hdr,aa{2}));
                else
                    weightD = frequencies(weightD,1,frequency(hdr,aa{2}(1)));
                end
            end
            save(weightD);
        else
            if flagmat
                weights     = img4d{c}(:,:,:,:);
                save(img4d{c}.fname,'weights');
            else
                No         = hdr;              % copy header
                No.dat     = img4d{c};         % change file_array
                No.descrip = 'Pronto weigths'; % description
                create(No);                    % write header
            end
        end 
        img_name{c} = finimg_name{c};
    end  
end
disp('Done.')
