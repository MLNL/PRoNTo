function img_name = prt_compute_weights(PRT,in,flag,flag2)
% Function to call prt_weights to compute weights (v3).
%
% FORMAT prt_compute_weights(PRT,in)
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
%           .atl_name   - name of the atlas for post-hoc local averages of
%       flag            - set to 1 to compute the weight images for each
%                         permutation (default: 0)
%       flag2           - set to 1 to build image of weight per ROI
%                         weights according to atlas
% Output:
%       img_name        - name of the .img file created
%       + image file created on disk
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by M.J.Rosa and J.Schrouff
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


% Initialize for loop over feature sets
fs_name = cell(length(PRT.model(model_idx).input.fs),1);
nfas = length(PRT.fas);
count = 0;
if isfield(PRT.model(model_idx).output.fold(1),'beta') % MKL type machine used
    added = 0;
else
    added = 1; % feature sets were added
end

PRT.model(model_idx).output.weight_ROI = [];
PRT.model(model_idx).output.weight_MOD = [];
PRT.model(model_idx).output.weight_idfeatroi =[];
PRT.model(model_idx).output.weight_atlas =[];
PRT.model(model_idx).output.weight_img =[];
im_name = cell(length(PRT.model(model_idx).input.fs),1);

atlas = in.atl_name;
in.atl_name = cell(length(PRT.model(model_idx).input.fs),1);
for ifs=1:length(PRT.model(model_idx).input.fs)
    if ~isempty(in.img_name)
        if ~(prt_checkAlphaNumUnder(in.img_name))
            error('prt_compute_weights:NameNotAlphaNumeric',...
                'Error: image name should contain only alpha-numeric elements!');
        end
        im_name{ifs} = [in.img_name,'_',PRT.model(model_idx).input.fs(ifs).fs_name];
    else
        im_name{ifs} = ['weights_',mname,'_',PRT.model(model_idx).input.fs(ifs).fs_name];
    end
    try
        in.atl_name{ifs} = atlas{ifs};
    end
end


for ifs=1:length(PRT.model(model_idx).input.fs)
    
    % Initialize: get feature set and modality index(es) and deal with MK
    fs_name{ifs}  = PRT.model(model_idx).input.fs(ifs).fs_name;
    fs_idx = find(strcmpi(fs_name{ifs},{PRT.fs(:).fs_name}));
    in.fs_idx = fs_idx;
    
    % Find modality/modalities in feature set
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
    
    % Get the indexes of each modality in terms of model parameters
    ibeta_mod = cell(length(fas_idx),1);
    if PRT.fs(fs_idx).multkernelROI   %multiple ROI kernels in feature set
        mult_kern_ROI = 1;
        if PRT.fs(fs_idx).multkernel || length(PRT.model(model_idx).input.fs)>1 % Multiple modalities treated separately
            % get the indexes of the betas for each modality
            for i=1:length(fas_idx)
                numk = length(PRT.fs(fs_idx).modality(i).igood_kerns);
                ibeta_mod{i} = (1:numk)+count;
                count = count + numk;
            end
        else % Multiple modalities concatenated or only one modality
            ibeta_mod{1} = count+1: count+length(PRT.fs(fs_idx).modality(1).igood_kerns);
            count = count + length(PRT.fs(fs_idx).modality(1).igood_kerns);
        end
        nim = length(fas_idx);
    else
        if PRT.fs(fs_idx).multkernel || length(PRT.model(model_idx).input.fs)>1 % Multiple modalities treated separately
            for i=1:length(fas_idx)
                ibeta_mod{i} = count + i;
            end
            nim = length(fas_idx);
            count = count + nim;
        else
            nim = 1;
            count = count + 1;
        end
        mult_kern_ROI = 0;
    end
    
    if isempty(in.atl_name{ifs}) && mult_kern_ROI
        if iscell(PRT.fs(fs_idx).atlas_name)
            in.atl_name{ifs} = PRT.fs(fs_idx).atlas_name{1};
        else
            in.atl_name{ifs} = PRT.fs(fs_idx).atlas_name;
        end
    end

    % Compute the total number of images to be computed
    switch mtype
        case 'classification'
            nc = size(PRT.model(model_idx).output.stats.con_mat, 2);
        case 'regression'
            nc = 1;
    end
    if nc > 2
        nim = nim*nc;
    end


    % Build weights
    %--------------------------------------------------------------------------
    if (PRT.fs(fs_idx).multkernel && length(fas_idx)>1)||...
            length(fs_name)>1 % Need to loop over the features sets and/or modalities
        summroi  = 0;
        %get/set image names by appending the modality name at the end
        im_namefs = cell(1,length(fas_idx));
        if length(fas_idx)>1
            for i = 1:length(fas_idx)
                im_namefs{i} = [im_name{ifs},'_',PRT.fas(fas_idx(i)).mod_name];
            end
        else
            im_namefs{1} = im_name{ifs};
        end
        
        % Get the indexes in the feature set and ID mat for each modality
        ifa_all = PRT.fs(fs_idx).fas.ifa;
        im_all = PRT.fs(fs_idx).fas.im;
        name_fin = [];
        
        % Prepare outputs
        output.weight_ROI = cell(nim,1);
        output.weight_idfeatroi = cell(nim,1);
        output.weight_atlas = cell(nim,1);
        if nc<=2
            output.weight_MOD = cell(nim,1);
        else
            output.weight_MOD = cell(nim/nc,1);
        end
        imgcnt = 1;

        for i = 1:length(fas_idx)
            in.img_name = im_namefs{i};
            in.fas_idx = fas_idx(i);
            in.mm = find(mm(fas_idx(i),:));
            %Modify inputs according to file array and modality
            tokeep = unique(PRT.fs(fs_idx).id_mat(:,3));
            PRT.fs(fs_idx).id_mat(:,3) = in.fas_idx * ones(size(PRT.fs(fs_idx).id_mat,1),1);
            PRT.fs(fs_idx).fas.im = im_all(im_all == fas_idx(i));
            PRT.fs(fs_idx).fas.ifa = ifa_all(im_all == fas_idx(i));
            MEEGfound = 0;

            switch mtype
                case 'classification'

                    % Compute image of voxel weights
                    img_name = prt_compute_weights_class(PRT,in,model_idx,flag,ibeta_mod{i});

                    % Get the image names (multiple classes possible)
                    name_f = cell(length(img_name),1);
                    for j=1:size(name_f,1)
                        [du,name_f{j}] = spm_fileparts(img_name{j});
                    end

                    % Build image of weights per region if asked for (flag2==1)
                    if exist('flag2','var') && flag2

                        if mult_kern_ROI && ~added % Kernels built from an atlas directly
                            disp('Building image of weights per region')
                            if length(name_f)>1 % multiple classes
                                in.img_name = ['ROI_',name_f{j}(1:end-2)];
                            else
                                in.img_name = ['ROI_',name_f{1}];
                            end
                            prt_compute_weights_class(PRT,in,model_idx,flag,ibeta_mod{i},1);

                        elseif ~isempty(in.atl_name{ifs}) % Need to summarize the weights per region, if an atlas was provided
                            % Option not available for MEEG files
                            [a,b,ext] = spm_fileparts(img_name{1});
                            if strcmpi(ext,'.mat')
                                V = load(img_name{1});
                                if ~isfield(V,'weights') || isfield(V,'D') % found MEEG
                                    beep; fprintf('Summarization of weights not available for MEEG');
                                    MEEGfound = 1;
                                    in.atl_name{ifs} = [];
                                end
                            end
                            if ~MEEGfound
                                disp('Building image of weights per region')
                                in.flag = flag;
                                summroi  = 1;
                                nimage = size(name_f,1); % Multiclass?
                                for c = 1:nimage
                                    if c>1
                                        imgcnt = imgcnt + 1;
                                    end
                                    [NW, idfeatroi] = prt_build_region_weights(img_name(c),in.atl_name{ifs},1,in.flag);
                                    output.weight_ROI(imgcnt) = {NW};
                                    output.weight_idfeatroi(imgcnt) = {idfeatroi};
                                end
                            end
                        end
                        output.weight_atlas{imgcnt} = in.atl_name{ifs};
                    end
                case 'regression'
                    % Compute image of voxel weights
                    img_name = prt_compute_weights_regre(PRT,in,model_idx,flag,ibeta_mod{i});

                    % Get the image names
                    [du,name_f{1}] = spm_fileparts(img_name{1});

                    % Build image of weights per region if asked for (flag2==1)
                    if exist('flag2','var') && flag2 

                        if mult_kern_ROI  && ~added % Kernels built from an atlas directly
                            disp('Building image of weights per region')
                            in.img_name = ['ROI_',name_f{1}];
                            prt_compute_weights_regre(PRT,in,model_idx,flag,ibeta_mod{i},1);

                        elseif ~isempty(in.atl_name{ifs}) % Need to summarize the weights per region
                            % Option not available for MEEG files
                            [a,b,ext] = spm_fileparts(img_name{1});
                            if strcmpi(ext,'.mat')
                                V = load(img_name{1});
                                if ~isfield(V,'weights') || isfield(V,'D') % found MEEG
                                    beep; fprintf('Summarization of weights not available for MEEG');
                                    MEEGfound = 1;
                                    in.atl_name{ifs} = [];
                                end
                            end
                            if ~MEEGfound
                                disp('Building image of weights per region')
                                in.flag = flag;
                                summroi = 1;
                                [NW, idfeatroi] = prt_build_region_weights(img_name,in.atl_name{ifs},1,in.flag);
                                output.weight_ROI(imgcnt) = {NW};
                                output.weight_idfeatroi(imgcnt) = {idfeatroi};
                            end
                        end
                        output.weight_atlas{imgcnt} = in.atl_name{ifs};
                    end
            end
            if ~iscell(img_name)
                img_name={img_name};
            end
            name_fin = [name_fin, img_name];
            imgcnt = imgcnt + 1;
        end
        PRT.fs(fs_idx).fas.ifa = ifa_all;
        PRT.fs(fs_idx).fas.im = im_all;
        PRT.fs(fs_idx).id_mat(:,3) = tokeep* ones(size(PRT.fs(fs_idx).id_mat,1),1);

        % Used for the display of the weights per modality in
        % prt_ui_disp_weights
        if (PRT.fs(fs_idx).multkernel || length(fs_name)>1) ...
                && ~summroi && ~added    %create one image per modality, from MKL learning
            for i=1:length(name_fin)
                if ~mult_kern_ROI && length(fs_name)==1
                    idb = 1:length(fas_idx);
                else
                    idb = ibeta_mod{i};
                end
                tmp = zeros(length(idb),length(PRT.model(model_idx).output.fold));
                for j = 1:length(PRT.model(model_idx).output.fold)
                    tmp(:,j) = [PRT.model(model_idx).output.fold(j).beta(idb)]';
                end
                betas = [tmp, mean(tmp,2)];
                output.weight_ROI(i) = {betas}; 
                output.weight_MOD(i) = {sum(betas,1)}; % sum the betas across regions for each modality
            end
        else
            if (PRT.fs(fs_idx).multkernel || length(fs_name)>1)...
                    && summroi && ~added
                for i=1:length(name_fin)
                    idb = ibeta_mod{i};
                    tmp = zeros(length(idb),length(PRT.model(model_idx).output.fold));
                    for j = 1:length(PRT.model(model_idx).output.fold)
                        tmp(:,j) = [PRT.model(model_idx).output.fold(j).beta(idb)]';
                    end
                    betas = [tmp, mean(tmp,2)];
                    output.weight_MOD(i) = {betas}; %average of a multiple kernel on modalities
                end
            end
        end
        for i=1:length(name_fin)
            [du,name_fin{i},ext{i}] = spm_fileparts(name_fin{i}); %get rid of path
        end

    % Only one modality or they have been concatenated
    else
        in.fas_idx=fas_idx;
        in.mm = [];
        for i=1:length(fas_idx)
            in.mm = [in.mm, find(mm(fas_idx(i),:))];
        end
        output.weight_ROI = cell(nim,1);
        output.weight_idfeatroi = cell(nim,1);
        output.weight_atlas = cell(nim,1);
        if nc<=2
            output.weight_MOD = cell(nim,1);
        else
            output.weight_MOD = cell(nim/nc,1);
        end
        switch mtype
            case 'classification'
                img_name = prt_compute_weights_class(PRT,in,model_idx,flag);
                name_fin = cell(length(img_name),1);
                for i=1:length(name_fin)
                    [du,name_fin{i},ext{i}] = spm_fileparts(img_name{i});
                end
                if exist('flag2','var') && flag2 % Build image of weights per region
                    disp('Building image of weights per region')

                    if mult_kern_ROI && ...
                            isfield(PRT.model(model_idx).output.fold(1),'beta') && ...
                            ~isempty(PRT.model(model_idx).output.fold(1).beta)

                        if length(name_fin)>1 % multiple classes
                            in.img_name = ['ROI_',name_fin{j}(1:end-2)];
                        else
                            in.img_name = ['ROI_',name_fin{1}];
                        end
                        prt_compute_weights_class(PRT,in,model_idx,flag,[],1);
                        % Get the weights per region, which are the same for
                        % each class
                        tmp = [PRT.model(model_idx).output.fold(:).beta];
                        tmp = reshape(tmp,length(PRT.model(model_idx).output.fold(1).beta),...
                            length(PRT.model(model_idx).output.fold));
                        betas = [tmp, mean(tmp,2)];
                        for i = 1:size(name_fin,1)
                            output.weight_ROI(i) = {betas};
                        end
                    elseif ~isempty(in.atl_name{ifs})
                        % Option not available for MEEG files
                        [a,b,ext] = spm_fileparts(img_name{1});
                        if strcmpi(ext,'.mat')
                            V = load(img_name{1});
                            if ~isfield(V,'weights') || isfield(V,'D') % found MEEG
                                beep; fprintf('Summarization of weights not available for MEEG');
                                MEEGfound = 1;
                                in.atl_name{ifs} = [];
                            end
                        end
                        if ~MEEGfound
                            in.flag = flag;
                            nimage = size(name_fin,1); % Multiclass?
                            PRT.model(model_idx).output.weight_ROI = cell(nimage,1);
                            for c = 1:nimage
                                [NW idfeatroi] = prt_build_region_weights(img_name(c),in.atl_name{ifs},1,in.flag);
                                output.weight_ROI(c) = {NW};
                            end
                            output.weight_idfeatroi{1} = idfeatroi;
                        end
                    end
                    output.weight_atlas{1} = in.atl_name{ifs};
                end
            case 'regression'
                img_name = prt_compute_weights_regre(PRT,in,model_idx,flag);
                name_fin = cell(length(img_name),1);
                for i=1:length(name_fin)
                    [du,name_fin{i},ext{i}] = spm_fileparts(img_name{i});
                end
                if exist('flag2','var') && flag2 % Build image of weights per region
                    if mult_kern_ROI && ...
                            isfield(PRT.model(model_idx).output.fold(1),'beta') && ...
                            ~isempty(PRT.model(model_idx).output.fold(1).beta)
                        disp('Building image of weights per region')
                        in.img_name = ['ROI_',name_fin{1}];
                        prt_compute_weights_regre(PRT,in,model_idx,flag,[],1);
                        tmp = [PRT.model(model_idx).output.fold(:).beta];
                        tmp = reshape(tmp,length(PRT.model(model_idx).output.fold(1).beta),...
                            length(PRT.model(model_idx).output.fold));
                        betas = [tmp, mean(tmp,2)];
                        output.weight_ROI(1) = {betas}; %only one class for now
                    elseif ~isempty(in.atl_name{ifs})
                        % Option not available for MEEG files
                        [a,b,ext] = spm_fileparts(img_name{1});
                        if strcmpi(ext,'.mat')
                            V = load(img_name{1});
                            if ~isfield(V,'weights') || isfield(V,'D') % found MEEG
                                beep; fprintf('Summarization of weights not available for MEEG');
                                MEEGfound = 1;
                                in.atl_name{ifs} = [];
                            end
                        end
                        if ~MEEGfound
                            disp('Building image of weights per region')
                            in.flag = flag;
                            [NW idfeatroi] = prt_build_region_weights(img_name,in.atl_name{ifs},1,in.flag);
                            output.weight_ROI(1) = {NW};
                            output.weight_idfeatroi{1} = idfeatroi;
                        end
                    end
                    output.weight_atlas{1} = in.atl_name{ifs};
                end
        end
    end

    if ~iscell(name_fin)
        name_fin = {name_fin};
    end

    for i = 1:length(name_fin)
        if isempty(ext{i})
            ext = '.img'; %For older PRTs, nifti is the default
        end
        name_fin{i} = [name_fin{i},ext{i}]; % Keep extension to have data format
    end

    if ifs == 1
        PRT.model(model_idx).output.weight_ROI = output.weight_ROI;
        PRT.model(model_idx).output.weight_MOD = output.weight_MOD;
        PRT.model(model_idx).output.weight_idfeatroi = output.weight_idfeatroi;
        PRT.model(model_idx).output.weight_atlas = output.weight_atlas;
        PRT.model(model_idx).output.weight_img = name_fin;
    else
        PRT.model(model_idx).output.weight_ROI = [PRT.model(model_idx).output.weight_ROI; output.weight_ROI];
        PRT.model(model_idx).output.weight_MOD = [PRT.model(model_idx).output.weight_MOD; output.weight_MOD];
        PRT.model(model_idx).output.weight_idfeatroi = [PRT.model(model_idx).output.weight_idfeatroi; output.weight_idfeatroi];
        PRT.model(model_idx).output.weight_atlas = [PRT.model(model_idx).output.weight_atlas; output.weight_atlas];
        PRT.model(model_idx).output.weight_img = [PRT.model(model_idx).output.weight_img; name_fin];
    end
end



% Save the updated PRT
%--------------------------------------------------------------------------
outfile = fullfile(in.pathdir, 'PRT.mat');
disp('Updating PRT.mat.......>>')
if spm_check_version('MATLAB','7') < 0
    save(outfile,'-V6','PRT');
else
    save(outfile,'PRT');
end
end


