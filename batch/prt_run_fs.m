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
load(fname);
fs_name=job.k_file;

mod=struct();
allmod={PRT.masks(:).mod_name};
modchos={job.modality(:).mod_name};
%maskchos={job.mask(:).mod_name};
maskchos={job.modality(:).mod_name};

if ~isempty(setdiff(modchos,allmod))
    error(['Couldn''t find modality "',target,'" in PRT.mat']);
end

for i=1:length(PRT.masks)
    if any(strcmpi(modchos,allmod{i}))
        mod(i).mod_name=allmod{i};
        ind=find(strcmpi(modchos,allmod{i}));
        
        %mod(i).detrend=job.modality(ind).detrend;
        %mod(i).param_dt=job.modality(ind).param_dt;
        if isfield(job.modality(ind).detrend,'linear_dt')
            mod(i).detrend=1;
            mod(i).param_dt=1;
        elseif isfield(job.modality(ind).detrend,'no_dt')
            mod(i).detrend=0;
            mod(i).param_dt=[];
        else
            error('DCT not supported yet');
        end        
        
        if isfield(job.modality(ind).normalise,'no_gms')
            mod(i).normalise = 0;
            mod(i).matnorm = [];
        elseif isfield(job.modality(ind).normalise,'mat_gms')
            mod(i).normalise=2;
            mod(i).matnorm = char(job.modality(ind).normalise.mat_gms);
        end
        
        if isfield(job.modality(ind).conditions,'all_cond')
            mod(i).mode='all_cond';
        elseif isfield(job.modality(ind).conditions,'all_scans')
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
        if isfield(job.modality(indm).voxels,'fmask')
            mod(i).mask = char(job.modality(indm).voxels.fmask);
        else
            mod(i).mask = [];
        end
            
    else
        mod(i).mod_name=[];%allmod{i};
        mod(i).detrend=nan;
        mod(i).mode=nan;
        mod(i).mask=[];
    end
end

input=struct();
input.fname=fname;
input.fs_name=fs_name;
input.mod=mod;
    
prt_fs(PRT,input);

out.fname{1} = fname;
disp('Kernel construction done.')
end





