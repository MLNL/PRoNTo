function out = prt_run_kernel_construction(varargin)
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
% $Id: prt_run_kernel_construction.m 79 2011-09-28 09:45:12Z cphillip $

% Job variable
% -------------------------------------------------------------------------
job   = varargin{1};
fname = char(job.infile);
load(fname);
kname=job.kernel_filename;

mod=struct();
allmod={PRT.masks(:).mod_name};
modchos={job.modality(:).mod_name};
maskchos={job.mask(:).mod_name};

if ~isempty(setdiff(modchos,allmod))
    error(['Couldn''t find modality "',target,'" in PRT.mat']);
end

for i=1:length(PRT.masks)
    if any(strcmpi(modchos,allmod{i}))
        mod(i).mod_name=allmod{i};
        ind=find(strcmpi(modchos,allmod{i}));
        mod(i).kernel_dt=job.modality(ind).kernel_dt;
        if isfield(job.modality(ind).conditions,'all_cond')
            mod(i).mode='all_cond';
        elseif isfield(job.modality(ind).conditions,'all_scans')
            mod(i).mode='all_scans';
        else
            error('Wrong mode selected: choose either all scans or all conditions')
        end            
        indm=find(strcmpi(maskchos,allmod{i}));
        if isempty(indm)
            error(['No mask selected for ',allmod{i}])
        else
            mod(i).mask=char(job.mask(indm).fmask);
        end
    else
        mod(i).mod_name=allmod{i};
        mod(i).kernel_dt=nan;
        mod(i).mode=nan;
        mod(i).masks=[];
    end
end

input=struct();
input.fname=fname;
input.kname=kname;
input.mod=mod;
input.normalise=job.normalise;
    
outfile=prt_kernel_construction(PRT,input);
out.fname{1} = outfile;
disp('Kernel construction done.')
end





