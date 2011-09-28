function block = prt_load_blocks(filenames, bs, br)
% Load one or more blocks of data.
% This script is a effectively a wrapper function that for the routines  
% that actually do the work (SPM nifti routines)
%
% The syntax is:
% 
% img = prt_load_blocks(filenames, block_size, block_range)
%
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A Marquand
% $Id$

if nargin ~= 3
    disp('Usage: img = prt_load_blocks(filenames, block_size, block_range)');
    return;
end

% read the image dimensions from the header
N  = nifti(filenames);
dm = size(N(1).dat);
n_vox = prod(dm(1:3));

if length(dm) == 3
    n_vol = 1; 
else
    n_vol = dm(4);
end

% get the data
data_range = (br(1)-1)*bs+1:min(br(end)*bs,n_vox); 
dat_r = reshape(N.dat,prod(dm(1:3)),n_vol);
block = dat_r(data_range,:);
end