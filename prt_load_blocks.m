function block = prt_load_blocks(varargin)
% Load one or more blocks of data.
% This script is a effectively a wrapper function that for the routines  
% that actually do the work. At present, spm supplies this functionality, 
% but in practice any toolbox could be used. 
%
% The syntax is:
% 
% img = prt_load_blocks(filenames, block_size, block_range, [mask])
%
% where:
%   mask is a 3d matrix. If none is specified the routine will
%   return all voxels in the field of view.
%    
%   reshape_img is a boolean flag and if set to true, the routine will 
%   return a set of vectors suitable for pattern recognition. If false,
%   the routine will instead return an n-d volume of the appropriate size.
%
%_______________________________________________________________________
% Copyright (C) 2011, 

if nargin < 3 || nargin > 3 
    disp('Usage: img = prt_load_blocks(filenames, block_size, block_range, [mask])');
    return;
end

filenames = varargin{1};

N  = nifti(filenames);
dm = size(N(1).dat);
n_vox = prod(dm(1:3));

if length(dm) == 3
    n_volumes = 1; 
else
    n_volumes = dm(4);
end

% defaults
%try,
    bs = varargin{2};  %catch, bs = 1024*128; end
%try, 
br = varargin{3};  %catch, br = 1;        end

data_range = (br(1)-1)*bs+1:min(br(end)*bs,n_vox); 

try, 
    mask = varargin{4}; 
    if isempty(mask)
        use_mask = false;
    else
        use_mask = true; 
    end
    mask_r = reshape(mask,prod(dm),1) > 0;
	n_voxels = sum(mask_r);
catch,  
    use_mask = false; 
    n_voxels = length(data_range);
end

%data_r = cell(1,n_volumes);
block = zeros(length(data_range),n_volumes);
if n_voxels > 0 % only do anything if there are voxels within the mask
    for i=1:n_volumes,
        %i
        %data_r{i} = reshape(N.dat(:,:,:,i),[prod(dm(1:3)),1]);
        %block(:,i) = data_r{i}(data_range);
        
        data_vec = reshape(N.dat(:,:,:,i),prod(dm(1:3)),1);
        if use_mask
            data_vec = data_vec .* mask_r;
        end
        block(:,i) = data_vec(data_range);
    end
end




