function [Phi_all,ID,fid] = prt_getFeatureModel(PRT,mid)

% Function to load the kernels according to the samples considered in a
%given model. These kernels will be added if the machine is a single kernel
%technique.
%
% Inputs:
% -------
% PRT:            data structure
% mid :           index of model in the data structure/ PRT.mat
%
% Output:
% --------
% Phi_all :  cell array with one feature set per cell
%            with the samples considered in the
%            specified model, as defined by the class/regression selection.
% ID :       the ID matrix for the considered samples
% fid :      index of feature set in data structure / PRT.mat
%
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J Schrouff
% $Id: prt_getFeatureModel.m 855 2014-05-27 09:35:15Z schrouff $

% load data files and configure ID matrix
disp('Loading data files.....>>');

samp_idx = PRT.model(mid).input.samp_idx;   % which samples are in the model

nfid = numel(PRT.model(mid).input.fs);
Phi_all=[];

for ifid = 1:nfid
    fid = prt_init_fs(PRT, PRT.model(mid).input.fs(ifid));
    
    ID_all = PRT.fs(fid).id_mat;
    ID = PRT.fs(fid).id_mat(samp_idx,:); % Reduce ID mat to selected samples
    
    % Check that all feature sets have the same ID matrix
    if ifid==1
        ID1 = ID;
    else
        cols = [1,2,4,5];
        if any(any(ID1(:,cols)~=ID(:,cols)))
            error('prt_get_FeatureModel:CannotCombineFS',...
                'Multiple feature sets selected but they do not have the same ID matrix')
        end
    end
    
    % Find modality/modalities in feature set and corresponding file arrays
    mods = [PRT.fs(fid).modality(:).mod_name];
    modnames = {PRT.fas(:).mod_name};
    fas  = zeros(1,numel(modnames));
    mm=zeros(length(mods),numel(modnames));
    for i = 1:numel(modnames)
        for j = 1:length(mods)
            if strcmpi(PRT.fas(i).mod_name,mods{j})
                fas(i) = 1;
                mm(i,j)= 1;
            end
        end
    end
    fas_idx = find(fas);
    if ~ isempty(PRT.fs(fid).modality(1).idfeat_fas)
        ifeat = numel(PRT.fs(fid).modality(1).idfeat_fas); %all concatenated modalities have the same size
    else
        ifeat = PRT.fas(fas_idx(1)).dat.dim(2);
    end
    
    % Averaging of the feature on onr or more dimensions?
    if isfield(PRT.fs(fid).modality(1),'aver') && ...
            any(PRT.fs(fid).modality(1).aver)
        ndim = numel(PRT.fs(fid).modality(1).dim_m);
        fin_dim = ones(1,ndim);
        for idim = 1:ndim
            fin_dim(idim) = length(PRT.fs(fid).modality(1).dim_m{idim});
        end
        dimav = fin_dim;
        dimav(find(PRT.fs(fid).modality(1).aver)) = 1;
        ifeat = prod(dimav);
    end
    
    d.datamat = zeros(length(samp_idx), ifeat);
    for i = 1:length(fas_idx)
        
        mf = find(mm(fas_idx(i),:));
        if ~ isempty(PRT.fs(fid).modality(mf(1)).idfeat_fas)
            feats = PRT.fs(fid).modality(mf(1)).idfeat_fas; %all concatenated modalities have the same size
        else
            feats = 1:PRT.fas(fas_idx(i)).dat.dim(2);
        end
        indm = ID(:,3) == fas_idx(i);
        samp_all = zeros(size(ID_all,1),1);
        samp_all(samp_idx) = 1;
        inds = find(samp_all(ID_all(:,3)==fas_idx(i)));
        if isempty(inds) %Modality not selected in this model
            continue;
        else
            ifa  = PRT.fs(fid).fas.ifa(inds);
        end
                
        % Average data matrix along specified dimensions
        if isfield(PRT.fs(fid).modality(mf(1)),'aver') && ...
                any(PRT.fs(fid).modality(mf(1)).aver)
            tmp = PRT.fas(fas_idx(i)).dat(ifa,feats)';
            ndim = numel(PRT.fs(fid).modality(mf(1)).dim_m);
            fin_dim = ones(1,ndim);
            for idim = 1:ndim
                fin_dim(idim) = length(PRT.fs(fid).modality(mf(1)).dim_m{idim});
            end
            tmp = reshape(tmp,[fin_dim length(ifa)]);
            dimta = find(PRT.fs(fid).modality(mf(1)).aver); %dimensions to average
            for iav = 1:length(dimta)
                tmp = mean(tmp, dimta(iav));
            end
            dimav = fin_dim;
            dimav(find(PRT.fs(fid).modality(mf(1)).aver)) = 1;
            tmp = reshape(tmp,prod(dimav),length(ifa));
            d.datamat(indm,:) = tmp';
        else
            % index for the target data matrix
            d.datamat(indm,:) = PRT.fas(fas_idx(i)).dat(ifa,feats);
        end
    end
    
    try
        Phi_all = [Phi_all, d.datamat];
    catch
        error('prt_get_KernelFeature:CannotCombineFS',...
            'Could not combine feature sets, potentially too large data set')
    end
    clear d
    
end

% Gather outputs
%-----------------

fid = prt_init_fs(PRT, PRT.model(mid).input.fs(1)); %As everything is based on 1st feature set
ID = ID1;
Phi_all = {Phi_all};









