function out = prt_run_fs(varargin)
% PRONTO job execution function
% takes a harvested job data structure and rearrange data into "proper"
% data structure, then save do what it has to do...
% Here simply the harvested job structure in a mat file.
%
% INPUT
%   job    - harvested job data structure (see matlabbatch help)
%
% OUTPUT
%   out    - filename of saved data structure.
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A Marquand and J Schrouff
% $Id$

% Job variable
% -------------------------------------------------------------------------
job   = varargin{1};
fname = char(job.infile);
if exist('PRT','var')
    clear PRT
end
load(fname);
fs_name = job.k_file;

% Check for multimodal MKL flag
% if isfield(job, 'flag_mm')
%     flag_mm = job.flag_mm;
% else
%     flag_mm = 0;
% end

mod      = struct();
allmod   = {PRT.masks(:).mod_name};

if isfield(job.format,'modality')
    modchos  = {job.format.modality(:).mod_name};
    maskchos = {job.format.modality(:).mod_name};
    format =1; % nifti
elseif isfield(job.format,'MEEGmodality')
    modchos  = {job.format.MEEGmodality(:).mod_name};
    format =2; % MEEG
elseif isfield(job.format,'matmodality')
    modchos  = {job.format.matmodality(:).mod_name};
    maskchos = {job.format.matmodality(:).mod_name};
    format =3; % mat
end

if ~isempty(setdiff(modchos,allmod))
    error(['Couldn''t find modality "',cell2mat(modchos),'" in PRT.mat']);
end

flagMEEG = 0;
for i=1:length(PRT.masks)
    if any(strcmpi(modchos,allmod{i}))
        mod(i).mod_name=allmod(i);
        ind=find(strcmpi(modchos,allmod{i}));
        
        %mod(i).detrend=job.modality(ind).detrend;
        %mod(i).param_dt=job.modality(ind).param_dt;
        switch format
            case 1% nifti
                if isfield(job.format.modality(ind).detrend,'linear_dt')
                    mod(i).detrend=1;
                    mod(i).param_dt=job.format.modality(ind).detrend.linear_dt.paramPoly_dt;
                elseif isfield(job.format.modality(ind).detrend,'no_dt')
                    mod(i).detrend=0;
                    mod(i).param_dt=[];
                else
                    mod(i).detrend=2;
                    mod(i).param_dt=job.format.modality(ind).detrend.dct_dt.param_dt;
                end
                
                if isfield(job.format.modality(ind).normalise,'no_gms')
                    mod(i).normalise = 0;
                    mod(i).matnorm = [];
                elseif isfield(job.format.modality(ind).normalise,'mat_gms')
                    mod(i).normalise=2;
                    mod(i).matnorm = char(job.format.modality(ind).normalise.mat_gms);
                end
                
                if isfield(job.format.modality.conditions,'all_cond')
                    mod(i).mode='all_cond';
                elseif isfield(job.format.modality(ind).conditions,'all_scans')
                    mod(i).mode='all_scans';
                else
                    error('Wrong mode selected: choose either all scans or all conditions')
                end
                indm=find(strcmpi(maskchos,allmod{i}));
                %         if isempty(indm)
                %             error(['No mask selected for ',allmod{i}])
                %         else
                %             mod(i).mask=char(job.modality(indm).fmask);
                %         end
                if isfield(job.format.modality(indm).voxels,'fmask')
                    mod(i).mask = char(job.format.modality(indm).voxels.fmask);
                else
                    mod(i).mask = [];
                end
                
                if isfield(job.format.modality(ind),'atlasroi')
                    mod(i).atlasroi = job.format.modality(ind).atlasroi{1};
                    if ~isempty(mod(i).atlasroi)
                        mod(i).multroi = 1;
                    else
                        mod(i).multroi = 0;
                    end
                else
                    mod(i).multroi = 0;
                end
            case 2 % MEEG
                flagMEEG = 1;
                % Options not available for MEEG modalities - defaults
                mod(i).detrend=0;
                mod(i).param_dt=[];
                mod(i).normalise = 0;
                mod(i).matnorm = [];
                mod(i).mode='all_scans';
                % Specific for MEEG
                mod(i).aver = [0 0 0];
                mod(i).multkern = [0 0 0];
                mod(i).multkernparam = {};
                sc = [];
                % Load the first file for that modality to get info or load
                % hdr from fas if present
                if isfield(PRT,'fas')
                    faslist = [PRT.fas(:).mod_name];
                    indfas = find(ismember(faslist,mod(i).mod_name));
                    if ~isempty(indfas) && ~isempty(PRT.fas(indfas).hdr) % file array already built
                        D = PRT.fas(indfas).hdr;
                        getD = 0;
                    else
                        getD = 1;
                    end
                else
                    getD = 1;
                end
                if getD
                   for g = 1:length(PRT.group)
                        for s = 1:length(PRT.group(g).subject)
                            mnames={PRT.group(g).subject(s).modality(:).mod_name};
                            indmod = find(ismember(mnames,mod(i).mod_name));
                            if ~isempty(indmod)
                                sc = PRT.group(g).subject(s).modality(indmod).scans(1,:);
                                break
                            end
                        end
                        if ~isempty(sc)
                            break
                        end
                    end
                    try
                        D = spm_eeg_load(sc);
                    catch
                        error('prt_ui_prepare_dataMEEG:CouldNotLoadFile',...
                            'Could not load MEEG file, please correct in data and design.');
                    end
                end
                % channel selection and options
                chanind = D.selectchannels(spm_cfg_eeg_channel_selector(job.format.MEEGmodality(ind).channels.channels));
                mod(i).ich = chanind;
                if job.format.MEEGmodality(ind).channels.average
                    mod(i).aver(1) = 1;
                    if job.format.MEEGmodality(ind).channels.multkern
                        beep
                        disp('Averaging and multiple kernels cannot be selected together.')
                        return
                    end
                end
                if job.format.MEEGmodality(ind).channels.multkern
                    mod(i).multkern(1) = 1;
                end
                % time point selection and options
                t_start = job.format.MEEGmodality(ind).tp.timewin(1)/1000;
                t_stop = job.format.MEEGmodality(ind).tp.timewin(2)/1000;
                mod(i).itp = indsample(D,t_start):indsample(D,t_stop); 
                if job.format.MEEGmodality(ind).tp.average
                    mod(i).aver(3) = 1;
                    if ~isfield(job.format.MEEGmodality(ind).tp.multkerntp,'nomult') || ...
                            ~job.format.MEEGmodality(ind).tp.multkerntp.nomult
                        beep
                        disp('Averaging and multiple kernels cannot be selected together.')
                        return
                    end
                end
                if isfield(job.format.MEEGmodality(ind).tp.multkerntp,'multkernonetp') ||...
                        isfield(job.format.MEEGmodality(ind).tp.multkerntp,'multkernwin')
                    mod(i).multkern(3) = 1;
                    if isfield(job.format.MEEGmodality(ind).tp.multkerntp,'multkernwin') && ...
                            isfield(job.format.MEEGmodality(ind).tp.multkerntp.multkernwin,'kerntpwin') && ...
                            ~isempty(job.format.MEEGmodality(ind).tp.multkerntp.multkernwin.kerntpwin)
                        mod(i).multkernparam{3} = (job.format.MEEGmodality(ind).tp.multkerntp.multkernwin.kerntpwin / 1000) *...
                            D.fsample;
                    else
                        mod(i).multkernparam{3} = 1;
                    end
                end
                % frequency band selection and options
                if numel(size(D))==3
                    % No frequency in this dataset
                    mod(i).ifr = [];
                elseif numel(size(D)) == 4
                    f_start = job.format.MEEGmodality(ind).freq.freqwin(1);
                    f_stop = job.format.MEEGmodality(ind).freq.freqwin(2);
                    mod(i).ifr = indfrequency(D,f_start):indfrequency(D,f_stop);
                    if job.format.MEEGmodality(ind).freq.average
                        mod(i).aver(2) = 1;
                        if job.format.MEEGmodality(ind).freq.multkern
                            beep
                            disp('Averaging and multiple kernels cannot be selected together.')
                            return
                        end
                    end
                    if job.format.MEEGmodality(ind).freq.multkern
                        mod(i).multkern(2) = 1;
                    end
                end
                
                
                
            case 3 % .mat (similar to nifti but without detrend and other mask type)
                
                % Normalize options
                 if isfield(job.format.matmodality(ind).normalise,'no_gms')
                    mod(i).normalise = 0;
                    mod(i).matnorm = [];
                elseif isfield(job.format.matmodality(ind).normalise,'mat_gms')
                    mod(i).normalise=2;
                    mod(i).matnorm = char(job.format.matmodality(ind).normalise.mat_gms);
                end
                % Condition options
                if isfield(job.format.matmodality.conditions,'all_cond')
                    mod(i).mode='all_cond';
                elseif isfield(job.format.matmodality(ind).conditions,'all_scans')
                    mod(i).mode='all_scans';
                else
                    error('Wrong mode selected: choose either all scans or all conditions')
                end
                % 2nd level mask
                indm=find(strcmpi(maskchos,allmod{i}));
                if isfield(job.format.matmodality(indm).features,'matmask')
                    mod(i).mask = char(job.format.matmodality(indm).features.matmask);
                else
                    mod(i).mask = [];
                end
                % atlas
                if isfield(job.format.matmodality(ind),'atlasmat')
                    mod(i).atlasroi = job.format.modality(ind).atlasmat{1};
                    if ~isempty(mod(i).atlasroi)
                        mod(i).multroi = 1;
                    else
                        mod(i).multroi = 0;
                    end
                else
                    mod(i).multroi = 0;
                end
                % Options not available for .mat modalities
                mod(i).detrend=0;
                mod(i).param_dt=[];             
        end
        
    else
        mod(i).mod_name=[];%allmod{i};
        mod(i).detrend=nan;
        mod(i).mode=nan;
        mod(i).mask=[];
    end
end

input = struct( ...
    'fname',fname, ...
    'fs_name',fs_name, ...
    'mod',mod, ...
    'flag_mm', 0); % Do not allow for MKL at feature set level

if flagMEEG
    prt_fs_EEG(PRT,input);
else
    prt_fs(PRT,input);
end

out.fname{1} = fname;
out.fs_name  = fs_name;
disp('Done.')
end





