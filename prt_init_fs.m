function [fid,PRT,tocomp] = prt_init_fs(PRT, in, mids,mask,precmask,headers)
% function to initialise the kernel data structure
% ------------------------------------------------
%
% Inputs:
% -------
% in.fname:     filename for the PRT.mat (string)
% in.kname:     relative path filename for the kernel matrix (string)
% in.normalise: scale the kernel to a unit hypersphere (boolean)
%
% in.mod(m).mod_name:  name of modality to include in this kernel (string)
% in.mod(m).kernel_dt: detrend the kernel (scalar: 0 = none, 1 = linear)
% in.mod(m).mode:      'all_cond' or 'all_scans' (string)
% in.mod(m).mask:      mask file used to create the kernel
%
% Outputs:
% --------
% This function performs the following functions:
%   1. Calls prt_init_fs to populate basic fields in PRT.fs(f). 
%   2. Populates the following fields in PRT.mat:
%       PRT.fs(f).modality(m).mod_name
%       PRT.fs(f).modality(m).mode
%       PRT.fs(f).modality(m).mask 
%       PRT.fs(f).modality(m).feat_idx 
%       PRT.fs(f).modality(m).rf_mat
%   3. Writes PRT.mat
%   4. Writes the kernel matrix to the path indicated by in.kname
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% $Id$

% find index for the new feature set
fs_exists = false;
if isfield(PRT,'fs')
    if any(strcmpi(in.fs_name,{PRT.fs(:).fs_name}))
        fid = find(strcmpi(in.fs_name,{PRT.fs(:).fs_name}));
        fs_exists = true;
    else
        fid = length(PRT.fs)+1;
    end
else
    fid = 1;
end

if nargout == 1
    if fs_exists
        % just display message and exit (returning id)
        disp(['Feature set ''',in.fs_name,''' found in PRT.mat.']);
    else
        error('prt_init_fs:fsNotFoundinPRT',...
            ['Feature set ''',in.fs_name,''' not found in PRT.mat.']);
    end
else
    
    PRT.fs(fid).fs_name = in.fs_name;
    PRT.fs(fid).fs_file = in.fs_name;
    PRT.fs(fid).id_col_names = {'group','subject','modality','condition','block','scan'};
    PRT.fs(fid).fas=struct('im',[],'ifa',[]);
    n_vox=0;
    n_mods=length(mids);
    for m = 1:n_mods
        PRT.fs(fid).modality(m).mod_name = in.mod(mids(m)).mod_name;
        PRT.fs(fid).modality(m).kernel_dt = in.mod(mids(m)).kernel_dt;
        PRT.fs(fid).modality(m).param_dt = in.mod(mids(m)).param_dt;
        %get indexes from mask specified in the data and design step
        vm=spm_vol(mask{m});
        vm=spm_read_vols(vm);
        PRT.fs(fid).modality(m).feat_idx_img = find(vm>0);
        mid=mids(m);
        if m==1
            n_vox=length(find(vm>0));
        end
        if n_vox~=length(find(vm>0))
            error('prt_prepare_data:MasksNotConsistent',...
                'Masks access areas of different sizes across modalities')
        end
        %get subindexes from mask specified in the data prepare step
        if ~isempty(precmask{m})
            vm=spm_vol(precmask{m});
            vm=spm_read_vols(vm);
            [d,PRT.fs(fid).modality(m).idfeat_fas] = intersect(PRT.fs(fid).modality(m).feat_idx_img, find(vm>0));
        else
            PRT.fs(fid).modality(m).idfeat_fas=[];
        end
        PRT.fs(fid).modality(m).normalise=struct('type',[],'scaling',[]);
    end
    
    indm = zeros(n_mods,1);
    szm = zeros(n_mods,1);
    
    % First count the total number of samples. Loops are needed since each
    % subject may have a variable number of scans
    n = 0;
    for gid = 1:length(PRT.group) % group
        for sid = 1:length(PRT.group(gid).subject);  % subject
            for m = 1:n_mods
                mid = mids(m);
                if strcmpi(in.mod(mid).mode,'all_scans');
                    n = n + size(PRT.group(gid).subject(sid).modality(mid).scans,1);
                elseif strcmpi(in.mod(mid).mode,'all_cond')
                    for cid = 1:length(PRT.group(gid).subject(sid).modality(mid).design.conds)    % condition
                        n = n + length(PRT.group(gid).subject(sid).modality(mid).design.conds(cid).scans);
                    end
                end
            end  % modality
        end  % subject
    end  % group
    PRT.fs(fid).id_mat = zeros(n,length(PRT.fs(fid).id_col_names));
    PRT.fs(fid).fas.im = zeros(n,1);
    PRT.fs(fid).fas.ifa= zeros(n,1);
    
    % Count the total number of samples and set sample ids for the kernel
    % Set fas for the file arrays
    sample_range = 0;
    for gid = 1:length(PRT.group) % group
        for sid = 1:length(PRT.group(gid).subject);  % subject
            for m = 1:n_mods
                mid = mids(m);
                
                if strcmpi(in.mod(mid).mode,'all_scans')
                    n_vols_s = size(PRT.group(gid).subject(sid).modality(mid).scans,1);
                    
                    % configure indices
                    sample_range = (1:n_vols_s)+max(sample_range);
                    PRT.fs(fid).id_mat(sample_range,1) = gid;
                    PRT.fs(fid).id_mat(sample_range,2) = sid;
                    PRT.fs(fid).id_mat(sample_range,3) = mid;
                    
                    if isfield(PRT.group(gid).subject(sid).modality(mid).design,'conds')
                        conds = PRT.group(gid).subject(sid).modality(mid).design.conds;
                        for cid = 1:length(conds)
                            scans  = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).scans;
                            blocks = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).blocks;
                            
                            PRT.fs(fid).id_mat(sample_range(scans),4) = cid;
                            PRT.fs(fid).id_mat(sample_range(scans),5) = blocks;
                            PRT.fs(fid).id_mat(sample_range(scans),6) = 1:length(scans);
                        end
                    else
                        scans  = 1:size(PRT.group(gid).subject(sid).modality(mid).scans,1);
                        PRT.fs(fid).id_mat(sample_range,6) = scans;
                    end
                    
                    sctoadd=(1:n_vols_s)+indm(m);
                    PRT.fs(fid).fas.ifa(sample_range)=sctoadd';
                    PRT.fs(fid).fas.im(sample_range)=mid*ones(n_vols_s,1);
                    %configure indices for the file array
                    indm(m)=n_vols_s+max(indm(m));
                elseif strcmpi(in.mod(mid).mode,'all_cond')
                    conds = PRT.group(gid).subject(sid).modality(mid).design.conds;
                    n_vols_s = size(PRT.group(gid).subject(sid).modality(mid).scans,1);
                    
                    % now loop over conditions
                    for cid = 1:length(conds)    % condition
                        scans = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).scans;
                        blocks = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).blocks;
                        n_vol_s_c = length(scans);
                        
                        % configure indices
                        sample_range = (1:n_vol_s_c)+max(sample_range);
                        PRT.fs(fid).id_mat(sample_range,1) = gid;
                        PRT.fs(fid).id_mat(sample_range,2) = sid;
                        PRT.fs(fid).id_mat(sample_range,3) = mid;
                        PRT.fs(fid).id_mat(sample_range,4) = cid;
                        PRT.fs(fid).id_mat(sample_range,5) = blocks;
                        PRT.fs(fid).id_mat(sample_range,6) = 1:length(sample_range);
                        
                        %configure indices for the file array
                        sctoadd=scans+indm(m);
                        PRT.fs(fid).fas.ifa(sample_range)=sctoadd';
                        PRT.fs(fid).fas.im(sample_range)=mid*ones(n_vol_s_c,1);
                    end
                    %configure indices for the file array
                    indm(m)=n_vols_s+max(indm(m));
                end
                szm(m)=szm(m)+size(PRT.group(gid).subject(sid).modality(mid).scans,1);
            end  % modality
        end  % subject
    end  % group
    
    %initialize the file arrays if they do not exist already or if the
    %detrending parameters were modified
    if ~isfield(PRT,'fas');
        for m = 1:n_mods
            PRT.fas(mids(m))=struct('mod_name',[],'dat',[],'detrend',[],'paramd',[],'hdr',[]);
        end
    end
    tocomp=zeros(1,length(in.mod));
    prt_dir=fileparts(in.fname);
    for i=1:n_mods
        %     if ~isfield(PRT,'fas')
        %         PRT.fas=struct();
        %     end
        
        if ~isfield(PRT.fas,'dat') ||   isempty(PRT.fas(mids(i)).dat) || ...
            PRT.fas(mids(i)).detrend ~= in.mod(mids(i)).kernel_dt   %if no file array for that modality
        
            if isfield(PRT.fas(mids(i)).dat,'fname') && ...
               exist(PRT.fas(mids(i)).dat.fname,'file')
                delete(PRT.fas(mids(i)).dat.fname);
            end
            
            tocomp(mids(i))=1;
            PRT.fas(mids(i)).mname = in.mod(mids(i)).mod_name;
            PRT.fas(mids(i)).detrend = in.mod(mids(i)).kernel_dt;
            %PRT.fas(mids(i)).paramd = in.mod(mids(i)).param_dt;
            PRT.fas(mids(i)).headers = headers{i};
            PRT.fas(mids(i)).idfeat_img = PRT.fs(fid).modality(m).feat_idx_img;                % index of voxels in the full image (nifti)
            datname=[prt_dir,filesep,'Data_matrix_',char(in.mod(mids(i)).mod_name),'.dat'];
            PRT.fas(mids(i)).dat = file_array(...
                datname, ...                                          % fname     - filename
                [szm(i),n_vox],...                               % dim       - dimensions (default = [0 0] )
                spm_type('float32'), ...                              % dtype     - datatype   (default = 'float')
                0, ...                                                % offset    - offset into file (default = 0)
                1);                                                   % scl_slope - scalefactor (default = 1)
        end
        %check that the input .mat for the scaling have the right size
        if in.mod(mids(i)).normalise==2
            try
                load(in.mod(mids(i)).matnorm);
            catch
                error('prt_prepare_data:ScalingMatUnloadable',...
                    'Could not load the .mat file containing the scaling')
            end
            try
                szin=length(scaling);
            catch
                error('prt_prepare_data:ScalingNotinFile',...
                    'This file does not contain the "scaling" field required')
            end
            if szin~=szm(i)
                error('prt_prepare_data:Scalingdimensionwrong',...
                    'The dimension of the .mat file does not correspond to the number of scans in that modality')
            end
            PRT.fs(fid).modality(i).normalise.type=2;
            PRT.fs(fid).modality(i).normalise.scaling=reshape(scaling,1,szm(i));
        elseif in.mod(mids(i)).normalise==1
            PRT.fs(fid).modality(i).normalise.type=1;
        else
            PRT.fs(fid).modality(i).normalise.type=0;
        end
    end
    
    PRT.fs(fid).modality=rmfield(PRT.fs(fid).modality,'feat_idx_img');
end
%PRT.fs(fid) = fs;
