function img_name = prt_compute_weights_regre(PRT,in,model_idx,flag, ibe, flag2)
% Function to call prt_weights to compute weights for regression problems (v2).
%
% FORMAT prt_compute_weights_regre(PRT,in,model_idx)
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

% Written by M.J.Rosa and J. Schrouff
% $Id$

% Find type of data (nifti, MEEG or .mat) from feature set
% -------------------------------------------------------------------------
fs_idx = in.fs_idx;
fas_idx = in.fas_idx;
mm = in.mm;
mname = PRT.fs(fs_idx).modality(mm(1)).mod_name;
allmods = {PRT.masks(:).mod_name};
im = find(strcmpi(mname,allmods));
flagmeeg = 0;
flagmat = 0;

if isfield(PRT.masks(im),'type') && strcmpi(PRT.masks(im).type,'MEEG')
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
    
    if strcmpi(PRT.masks(im).type,'.mat')
        
        ext = '.mat';
        hdr        = PRT.fas(fas_idx(1)).hdr;
        dat_dim    = hdr.dim;
        idfeat = PRT.fas(fas_idx(1)).idfeat_img;
        flagmat = 1;
        appendn=[];
        
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
m.args      = [];

if nargin<5
    ibe=[];
end
if nargin<6
    flag2 = 0;
end

if PRT.model(model_idx).input.use_kernel
    kernel = 1;
else
    kernel = 0;
end


% Compute number of images to build and get their names
% ------------------------------------------------------
if ~isempty(in.img_name)
    if ~(prt_checkAlphaNumUnder(in.img_name))
        error('prt_compute_weights:NameNotAlphaNumeric',...
            'Error: image name should contain only alpha-numeric elements!');
    end
    basisname = in.img_name;
else
    basisname = ['weights_',mname];
end

if isfield(PRT.model(model_idx).input,'models_MTL') &&...
        ~isempty(PRT.model(model_idx).input.models_MTL)
    nmodels = PRT.model(model_idx).input.models_MTL; % number of models for MTL
else
    nmodels = 1;
end

cnt = 1;
nimage = length(nmodels);
if nimage>1 %get the name of the task and append the task name
    for imodel = 1:length(nmodels)
        img_mach{cnt} = [basisname,'_',PRT.model(nmodels(imodel)).model_name,ext];
        cnt = cnt+1;
    end
else
    img_mach{cnt} = [basisname,ext]; % just one image otherwise
end

% Get function to compute weights for kernel machines
% -------------------------------------------------------------------------
switch mfunc
    case 'prt_machine_sMKL_reg'
        m.function = 'prt_weights_sMKL_reg';
    case 'prt_machine_RT_bin'
        error('prt_compute_weights:MachineNotSupported',...
            'Error: weights computation not supported for this machine!');
    otherwise
        m.function  = 'prt_weights_bin_linkernel';
end


% Image name
% -------------------------------------------------------------------------
img_name = cell(nimage,1);
finimg_name = cell(nimage,1);
nimage = length(img_mach);
for c = 1:nimage
    img_name{c}    = fullfile(in.pathdir,[appendn,img_mach{c}]);
    finimg_name{c} = fullfile(in.pathdir,img_mach{c});
end


% Other info
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
if PRT.fs(fs_idx).multkernelROI
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
            [pth,nam] = fileparts(nametokeep{c});
            if p==1
                pthperm{c} = fullfile(pth,['perm_',nam]);
                if ~exist(pthperm{c},'dir')
                    mkdir(pth,['perm_',nam]);
                end
            end
            img_nam{c} = fullfile(pthperm{c},[appendn,nam,'_perm',num2str(p),ext]);
            finimg_name{c} = fullfile(pthperm{c},[nam,'_perm',num2str(p),ext]);
        end
        fprintf('Permutation: %d of %d \n',p, ...
            length(PRT.model(model_idx).output.permutation));
    else
        img_nam = img_name;
        nametokeep = finimg_name;
    end
    
    % check that image does not exist, otherwise, delete
    if exist(finimg_name{1},'file')
        for c = 1:nimage
            delete(finimg_name{c});
            % delete hdr if neuroimaging, dat if MEEG
            [pth,nam] = fileparts(finimg_name{c});
            if ~flagmeeg
                if ~flagmat
                    hdr_name  = [pth,filesep,nam,'.hdr'];
                end
            else
                hdr_name  = [pth,filesep,nam,'.dat'];
                if exist(img_nam{c},'file')
                    delete(img_nam{c});
                end
            end
            
            % K.T. Edit 03/2019
			if ~flagmat
				delete(hdr_name)
			end
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
    
    zdim    = dat_dim(3);
    xydim   = dat_dim(1)*dat_dim(2);
    % norm3d  = 0;
    
    disp('Computing weights.......>>')
    
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
                
                if kernel % Compute weights for kernel machines, includes getting the data back
                    
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
                    
                    if strcmpi(mfunc,'prt_machine_sMKL_reg') || ...
                            strcmpi(mfunc,'prt_machine_wip_reg')
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
                    
%                     Compute latent space for the Trace-norm MTL
%                     A = PRT.model(model_idx).output.fold(f).others.A;
%                     [U,S] = svd(A);
%                     threshold = 1e-3;
%                     S(S<threshold) = 0;
%                     S(S>0) = S(S>0).^(-1);
%                     B = U*sqrt(S);
%                     Z = w*B;
%                     w = Z;
                    
                    for icl = 1:size(w,2) % Loop over tasks in MTL if present
                        % get slice
                        wimg{icl} = w(voxtr(feat_slc),icl);
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
                img3dav{c}                 = img3dav{c}/nfold; %average across folds
                img4d{c}(:,:,z,folds_comp) = reshape(img3dav{c},dat_dim(1),dat_dim(2),1,1); %afm
                norm4dav{c}(z,:)           = sum(img3dav{c}(isfinite(img3dav{c})).^2); %afm
            end
        end
        
    end
    
    for c =1:nimage
        norm4d{c}   = sqrt(sum(norm4d{c},1));
        norm4dav{c} = sqrt(sum(norm4dav{c},1)); %afm
    end
    fprintf('\n') % new line
    disp('Normalising weights--------->>')
    if p==0
        for f = 1:nfold
            for c = 1:nimage
                if unique(norm4d{c}(1,f))~=0 % if not all weights at zero, normalize
                    img4d{c}(:,:,:,f) = img4d{c}(:,:,:,f)./norm4d{c}(1,f);
                end
            end
        end
    end
    
    for c = 1:nimage %average across folds
        if unique(norm4dav{c})~=0 % if not all weights at zero, normalize
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
            if ~isempty(nfrequencies(hdr))
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
        
        % K.T. Edit 03/2019
        if p == 0
            img_name{c} = finimg_name{c};
        end
        
    end
    disp('Done.')
end

