function img_name = prt_compute_weights(PRT,in,flag,flag2)
% FORMAT prt_compute_weights(PRT,in)
%
% This function calls prt_weights to compute weights
% Inputs:
%       PRT             - data/design/model structure (it needs to contain
%                         at least one estimated model).
%       in              - structure with specific information to create
%                         weights
%           .model_name - model name (string)
%           .img_name   - (optional) name of the file to be created
%                         (string)
%           .pathdir    - directory path where to save weights (same as the
%                         one for PRT.mat) (string)
%       flag            - set to 1 to compute the weight images for each
%                         permutation (default: 0)
%       flag2           - set to 1 to build image of weight per ROI
% Output:
%       img_name        - name of the .img file created
%       + image file created on disk
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

mtype = PRT.model(model_idx).input.type;
mname = PRT.model(model_idx).model_name;

% Compute weights for each modality
% -------------------------------------------------------------------
% Get index of feature set
fs_name  = PRT.model(model_idx).input.fs.fs_name;
nfs = length(PRT.fs);
for f = 1:nfs
    if strcmp(PRT.fs(f).fs_name,fs_name)
        fs_idx = f;
    end
end

% Find modality
nfas = length(PRT.fas);
mods = {PRT.fs(fs_idx).modality.mod_name};
fas  = zeros(1,nfas);
mm=zeros(length(mods),nfas);
for i = 1:nfas
    for j = 1:length(mods)
        if strcmpi(PRT.fas(i).mod_name,mods{j})
            fas(i) = 1;
            mm(i,j)= 1;
        end
    end
end
fas_idx = find(fas);

% Loop over the different feature sets if they were considered as separate
% kernels (i.e. one kernel per modality)

if PRT.fs(fs_idx).multkernel && ...   %multiple kernels in feature set
        isfield(PRT.fs(fs_idx).modality(find(mm(1,:))),'idfeat_img')
    mult_kern_ROI = 1;
else
    mult_kern_ROI = 0;
end

%Check inputs for weights per region
if flag2
    if isempty(in.atl_name) && ~mult_kern_ROI
        error('prt_compute_weights:NoAtlas',...
            'Error: Atlas should be provided to compute weights per region')
    end
end

if PRT.fs(fs_idx).multkernel && length(fas_idx)>1 %create one image per modality
    %get image names
    im_name = cell(1,length(fas_idx));
    if ~isempty(in.img_name)
        if ~(prt_checkAlphaNumUnder(in.img_name))
            error('prt_compute_weights:NameNotAlphaNumeric',...
                'Error: image name should contain only alpha-numeric elements!');
        end
        for i = 1:length(fas_idx)
            im_name{i} = [in.img_name,'_',PRT.fas(fas_idx(i)).mod_name];
        end
    else
        for i = 1:length(fas_idx)
            im_name{i} = ['weights_',mname,'_',PRT.fas(fas_idx(i)).mod_name];
        end
    end
    ifa_all = PRT.fs(fs_idx).fas.ifa;
    im_all = PRT.fs(fs_idx).fas.im;
    for i = 1:length(fas_idx)
        in.img_name = im_name{i};
        in.fas_idx = fas_idx(i);
        in.mm = find(mm(i,:));
        %Modify inputs according to file array and modality
        PRT.fs(fs_idx).id_mat(:,3) = in.mm * ones(size(PRT.fs(fs_idx).id_mat,1),1);
        PRT.fs(fs_idx).fas.im = im_all(im_all == fas_idx(i));
        PRT.fs(fs_idx).fas.ifa = ifa_all(im_all == fas_idx(i));
        switch mtype
            case 'classification'
                img_name = prt_compute_weights_class(PRT,in,model_idx,flag,i);
            case 'regression'
                img_name = prt_compute_weights_regre(PRT,in,model_idx,flag,i);
        end
    end
else
    in.fas_idx=fas_idx;
    in.mm = find(mm(1,:));
    switch mtype
        case 'classification'
            img_name = prt_compute_weights_class(PRT,in,model_idx,flag);
            if flag2 % Build image of weights per region
                if mult_kern_ROI
                    disp('Building image of weights per region')
                    in.img_name = ['ROI_',in.img_name];
                    img_name = prt_compute_weights_class(PRT,in,model_idx,flag,[],1);
                else
                    disp('Not implemented yet')
                    %TO do: add call to prt_build_region_weights
                end
            end
        case 'regression'
            img_name = prt_compute_weights_regre(PRT,in,model_idx,flag);
             if flag2 % Build image of weights per region
                if mult_kern_ROI
                    disp('Building image of weights per region')
                    in.img_name = ['ROI_',in.img_name];
                    img_name = prt_compute_weights_regre(PRT,in,model_idx,flag,[],1);
                else
                    disp('Not implemented yet')
                    %TO do: add call to prt_build_region_weights
                end
            end
    end
end




