function [fid,PRT,tocomp,n_vols_s] = prt_init_fs_EEG(PRT, in, mids)
% function to initialise the kernel data structure
% ------------------------------------------------
% function will create the feature set in PRT.mat by epoching the data.
% Input:
% ------
% in.fs_name: name for the feature set (string)
% in.fname:   name of PRT.mat
%
% in.mod(m).mod_name:  name of the modality
% in.mod(m).detrend:   type of detrending
% in.mod(m).mode:      'all_scans' or 'all_cond'
% in.mod(m).mask:	   mask used to create the feature set
% in.mod(m).param_dt:  parameters used for detrending (if any)
% in.mod(m).normalise: scale the input scans or not
% in.mod(m).matnorm:   mat file used to scale the input scans
%
%MEEG:
%in.mod(m).op.aver: vector of binary values to average along the
%dimension (1) or not (0).
%
% Output:
% -------
% fid : is the identifier for the model constructed in PRT.mat
%
% Populates the following fields in PRT.mat (copied from above):
%   PRT.fs(f).fs_name
%   PRT.fs(f).fas
%   PRT.fs(f).k_file
% Also computes the following fields:
%   PRT.fs(f).id_mat:       Identifier matrix (useful later)
%   PRT.fs(f).id_col_names: Columns in the id matrix
%
% Note: this function does not write PRT.mat. That should be done by the
%       calling function
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A Marquand and J Schrouff
% $Id: prt_init_fs_EEG.m 781 2013-11-04 16:01:26Z schrouff $

% Find index for the new feature set
fs_exists = false;
if ~(prt_checkAlphaNumUnder(in.fs_name))
    beep
    disp('Feature set name should be entered in alphanumeric format only')
    disp('Please correct')
    return
end
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
    return
else
    
    if fs_exists
        warning('prt_init_fs_EEG:overwriteFsInPRT',...
            ['Feature set ''',in.fs_name,''' found in PRT.mat. Overwriting ...']);
    else
        % doesn't exist. initialise the structure
        disp(['Feature set ''',in.fs_name,''' not found in PRT.mat. Creating...'])
    end
    
    %--------------------------------------------------------------------------
    % Initialise feature set and file array, and decide which FA to build
    %--------------------------------------------------------------------------
    
    % initialise
    pathName=fileparts(in.fname);
    PRT.fs(fid).fs_name = in.fs_name;
    PRT.fs(fid).k_file = in.fs_name;
    PRT.fs(fid).id_col_names = {'group','subject','modality','condition','block','scan'};
    PRT.fs(fid).fas=struct('im',[],'ifa',[]);
    n_mods=length(mids);
    for m = 1:n_mods
        PRT.fs(fid).modality(m).mod_name = in.mod(mids(m)).mod_name;
        PRT.fs(fid).modality(m).aver     = in.mod(mids(m)).aver;
        PRT.fs(fid).modality(m).multkern = in.mod(mids(m)).multkern;
%         PRT.fs(fid).modality(m).smooth   = in.mod(mids(m)).smooth;
%         PRT.fs(fid).modality(m).smoothparam = in.mod(mids(m)).smoothparam;
    end
    
    
    %Initialize fas field and check which files need to be epoched
    if ~isfield(PRT,'fas');
        % initialise all modalities (not just those we're working on)
        for m = 1:length(PRT.masks)
            PRT.fas(m)=struct('mod_name',[],'dat',[],'hdr',[]);
            PRT.fas(m).mod_name = PRT.masks(m).mod_name;
        end
    end
    
    tocomp=zeros(1,length(in.mod));
    for i=1:n_mods
        % check whether we need to recreate the file array
        if mids(i)>length(PRT.fas) ||...
                isempty(PRT.fas(mids(i)).dat) || exist(PRT.fas(mids(i)).dat.fname)==0
            
            if mids(i)>length(PRT.fas) || isempty(PRT.fas(mids(i)).dat)
                disp(['File array does not exist for modality ''',...
                    char(in.mod(mids(i)).mod_name),'''. Creating...'])
            end            
            tocomp(mids(i))=1;
        else
            disp(['Using existing file array for modality ''', ...
                char(in.mod(mids(i)).mod_name),'''.'])
        end
    end
    
    %--------------------------------------------------------------------------
    % Compute ID mat from the total number of samples for this feature set
    %--------------------------------------------------------------------------
    
    % First count the total number of samples. Loops are needed since each
    % subject may have a variable number of trials. Compute the number of
    % features for each subject as well.
    n_vols_s=cell(length(PRT.group),n_mods);
    n_vox=zeros(n_mods,1);
    hdr=zeros(n_mods,3);
    idn = 1;
    n=0;
    
    for gid = 1:length(PRT.group) % group
        for m = 1:n_mods
            n_vols_s{gid,m} = cell(length(PRT.group(gid).subject),1);
            for sid = 1:length(PRT.group(gid).subject);  % subject            
                mid = mids(m);
                dnames = PRT.group(gid).subject(sid).modality(mid).scans(1,:);
                try
                    D = spm_eeg_load(dnames);
                catch
                    error('prt_init_fs_EEG:CouldNotLoadFile',...
                        'Could not load MEEG file');
                end                    
                ndim = size(D);
                n_vols_s{gid,m}{sid} = ndim(end); 
%                 n_vols_s{gid,m}{sid} = ndim(end)-length(D.badtrials); % remove bad trials
                n = n+n_vols_s{gid,m}{sid};
                if length(size(D))==4
                    n_vox(m) = ndim(1)*ndim(2)*ndim(3);  %channels*frequency*time
                    hdr(m,:) = ndim(1:end-1);
                elseif length(size(D))==3
                    n_vox(m) = ndim(1)*ndim(2); %channels*time
                    hdr(m,:) = [ndim(1),1,ndim(2)];
                end
                idn = idn+1;
                clear D

%                 n_vox(m) = size(PRT.fas(mid).dat,2);
%                 hdr(mid,:) = PRT.fas(mid).hdr;
            end  % modality
        end  % subject
    end  % group
    
    PRT.fs(fid).id_mat = zeros(n,length(PRT.fs(fid).id_col_names));
    PRT.fs(fid).fas.im = zeros(n,1);
    PRT.fs(fid).fas.ifa= zeros(n,1);   
    % Set sample ids for the kernel and compute id_matrix
    % Set fas for the file arrays
    indm = zeros(n_mods,1);
    sample_range = 0;
    
    for gid = 1:length(PRT.group) % group
        for sid = 1:length(PRT.group(gid).subject);  % subject
            for m = 1:n_mods
                mid = mids(m);
                all_scans = 1:n_vols_s{gid,m}{sid};
                % configure indices
                sample_range = (1:n_vols_s{gid,m}{sid})+max(sample_range);
                PRT.fs(fid).id_mat(sample_range,1) = gid;
                PRT.fs(fid).id_mat(sample_range,2) = sid;
                PRT.fs(fid).id_mat(sample_range,3) = mid;
                clist = {PRT.group(gid).subject(sid).modality(mid).design.conds(:).cond_name};
                for cid=1:length(clist)
                    indt = PRT.group(gid).subject(sid).modality(mid).design.conds(cid).scans;
                    PRT.fs(fid).id_mat(sample_range(indt),4) = cid;
                    PRT.fs(fid).id_mat(sample_range(indt),5) = ...
                        PRT.group(gid).subject(sid).modality(mid).design.conds(cid).blocks;
                end
                PRT.fs(fid).id_mat(sample_range,6) = all_scans;
                
                sctoadd=(1:n_vols_s{gid,m}{sid})+indm(m);
                PRT.fs(fid).fas.ifa(sample_range)=sctoadd';
                PRT.fs(fid).fas.im(sample_range)=mid*ones(n_vols_s{gid,m}{sid},1);
                %configure indices for the file array
                indm(m)=n_vols_s{gid,m}{sid}+max(indm(m));
            end  % modality
        end  % subject
    end  % group
    
    %--------------------------------------------------------------------------
    %   Initialize the file array if does not exist
    %--------------------------------------------------------------------------
    
    for i=1:n_mods
        % create the file array in the PRT if needed
        if tocomp(mids(i))
            PRT.fas(mids(i)).mod_name = in.mod(mids(i)).mod_name;
            PRT.fas(mids(i)).hdr = hdr(i,:);
            PRT.fas(mids(i)).idfeat_img = [];
            datname=[pathName,filesep,'Feature_set_',char(in.mod(mids(i)).mod_name),'.dat'];
            PRT.fas(mids(i)).dat = file_array(...
                datname, ...                 % fname     - filename
                [indm(i),n_vox(i)],...           % dim       - dimensions (default = [0 0] )
                spm_type('float32'), ...  % dtype     - datatype   (default = 'float')
                0, ...                       % offset    - offset into file (default = 0)
                1);                          % scl_slope - scalefactor (default = 1)% index of voxels in the full image (nifti)
        end
        PRT.fs(fid).modality(i).normalise.type=0;
    end
end



