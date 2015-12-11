function block = prt_load_blocks(filenames, bs, br)
% Load one or more blocks of data.
% This script is a effectively a wrapper function that for the routines
% that actually do the work (SPM nifti routines)
%
% The syntax is either:
%
% img = prt_load_blocks(filenames, block_size, block_range) just to specify
% continuous blocks of data
%
% or
%
% img = prt_load_blocks(filenames, voxel_index) to access non continuous
% blocks
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A Marquand
% $Id$

if nargin <2 || nargin >3
    disp('Usage: img = prt_load_blocks(filenames, block_size, block_range)');
    disp('or')
    disp('Usage: img = prt_load_blocks(filenames, voxel_indexes)');
    return;
end

% Read the data
flagi = 0;
N = [];
D = [];
[d,dd,ext] = fileparts(filenames(1,:));
if strcmpi(ext,'.mat')
    try
        D = spm_eeg_load(filenames); % read an MEEG object
        dm = size(D);
        if length(dm)==3
            dm = [dm(1) 1 dm(2) dm(3)];
            flagi = 1;
        end % handling non t-f
        n_vol = dm(4) - length(D.badtrials);
        isgood = setdiff([1:dm(4)],badtrials(D));
    catch
        error('prt_load_blocks:CouldNotReadFile','Not a recognized file');
    end 
else
    try
        N  = nifti(filenames); % read the image dimensions from the header
        dm = size(N(1).dat);
        if length(dm)==2, dm = [dm 1]; end % handling case of 2D image
        if length(dm) == 3
            n_vol = 1;
        else
            n_vol = dm(4);
        end
        isgood = 1:n_vol;
    catch
        error('prt_load_blocks:CouldNotReadFile','Not a recognized file');
    end
end
n_vox = prod(dm(1:3));  

% get the data
if nargin==3
    data_range = (br(1)-1)*bs+1:min(br(end)*bs,n_vox);
else
    data_range = bs;
end

block=zeros(length(data_range),n_vol);
if n_vol==1 && ~isempty(N) && isempty(D)
    for i=1:length(N)
        block(:,i) = N(i).dat(data_range);
    end
else
    cnt = 1;
    for i=isgood        
        if ~isempty(N)            
            dat_r = N(1).dat(:,:,:,i);            
        elseif ~isempty(D) && flagi
            dat_r = D(:,:,i); %igt(i)
        elseif ~isempty(D) && ~flagi
            dat_r = D(:,:,:,i); %igt(i)
        end
        block(:,cnt) = dat_r(data_range);
        cnt = cnt+1;
    end
end
return