function [Vout,fn_labels] = prt_create_meegAtlas(Vin,fn_out, blocks,labels,dorder)
% Creating NIfTI atlas for multi-kernel learnin in M/EEG data
%
% This function creates ad hoc atlas for channel x time x frequency M/EEG
% data analysis with MKL.
%
% INPUT
% Vin       : header information (see 'spm_vol') of one typical data image
% fn_out    : base name for the generated files, atlas & labels
% blocks    : structure defining the way data are blocked per channels,
%             time-window and frequency-band.
%   .chans  : [Ncg x 1] cell array of channels grouping, each cell contains
%             the list of channels to group together.
%             Shortcuts, use 0 for all channels together, i.e. one group,
%             and 1 for each channel separately, i.e. Nch groups.
%   .twind  : [Ntw x 2] array with time-window boundaries
%   .fband  : [Nfb x 2] array with frequency-band boundaries
% labels    : structure with the corresponding labels for channels,
%             time-windows, and frequency-bands. If not provided, then
%             labels will be built based on the index of channel group,
%             time-window, freq-band.
%   .chans  \
%   .twind  | cell array with labels.
%   .fband  /
% dorder    : ordering of the data as a string made of 'c' -> channels,
%             'f' -> frequency, 't' -> time. Default 'cft'.
%
% OUTPUT
% Vout      : header information (see 'spm_vol') of the created atlas
% fn_labels : filename of the atlas "regions", following this pattern :
%               'region index' 'channel_freq_time'
%
% Operation description:
% For simplicity the whole atlas is built into memory before being written
% on disk in an uint16 (spm_type(512)) which allows number in [0 65535]
%
% NOTE
% ****
% Be careful
% - the time-window and freq-band boundaries as they should NOT overlap and
%   should be in increasing order, e.g. [2 10 ; 11 20 ; 25 35]
%   They will be rounded to the actual 'voxel' size though
% - provided labels should be short and informative plus be just letter and
%   numbers WITHOUT blank spaces or fancy chars.
% - the number of labels should match the number of channel groups,
%   time-windows, and freq-bands.
%
%__________________________________________________________________________
% Copyright (C) 2020 Machine Learning & Neuroimaging Laboratory


% Written by Christophe Phillips
% Cyclotron Research Centre, Liege University, Belgium

%% Deal with input

% Labels output filename
fn_labels = spm_file(fn_out,'prefix','Labels_','ext','tsv');

% Check ordering of the data
if nargin<5
    dorder = 'cft';
    fprintf('\nAssuming axes are ordered as frequency, time, channels.\n');
end
ind_chan = strfind(dorder,'c');
ind_freq = strfind(dorder,'f');
ind_time = strfind(dorder,'t');
ind_cft = [ind_chan ind_freq ind_time];

% Check blocks -> extract the number of elements Ncg, Nfb, and Ntw.
% Creating flag 'fl_chans_altog' = 1 if all channels considered together
fl_chans_altog = 0;
if iscell(blocks.chans)
    Ncg = numel(blocks.chans);
else
    if blocks.chans==0
        % Put all channels together
        Ncg = 1;
        fl_chans_altog = 1;
    else
        % Put each channel separately
        Ncg = Vin.dim(ind_chan);
        % recreate the cell array of indexes
        blocks.chans = cell(Ncg,1);
        for ii = 1:Ncg, blocks.chans{ii} = ii; end
    end
end
Nfb = size(blocks.fband,1);
Ntw = size(blocks.twind,1);

% Check labels.
if nargin<4
    if fl_chans_altog
        lab_chans = {'AllCh'}; % when put altogether...
    else
        lab_chans = spm_create_labels(struct('base','Ch','n',Ncg));
    end
else
    if size(labels.chans,1)==Ncg && ~fl_chans_altog
        lab_chans = labels.chans;
    else
        lab_chans = spm_create_labels(struct('base','Ch','n',Ncg));
    end
    if size(labels.fband,1)==Nfb
        lab_fband = labels.fband;
    else
        lab_fband = spm_create_labels(struct('base','Fb','n',Nfb));
    end
    if size(labels.twind,1)==Ntw
        lab_twind = labels.twind;
    else
        lab_twind = spm_create_labels(struct('base','Tw','n',Ntw));
    end
end

%% Prepare output & bins in voxel space
% Copy image header but need to
% - set format to uint16 & adjust scaling
% - change filename
Vout = Vin;
Vout.dt(1) = 512; % use uint16
Vout.pinfo(1:2) = [1 0];
Vout.fname = fn_out;
Vout = spm_create_vol(Vout);

% Worry about the bins expressed in voxel space and actual ms/Hz.
% - frequency
tmp = blocks.fband'; f_bins_Hz_O = tmp(:)';
[f_bins_vx,f_bins_Hz] = check_bins(f_bins_Hz_O,ind_freq,Vin.mat,Vin.dim(ind_freq));
f_bins_vx = reshape(f_bins_vx, size(blocks.fband'))';
f_bins_Hz = reshape(f_bins_Hz, size(blocks.fband'))';
% - time
tmp = blocks.twind'; t_bins_ms_O = tmp(:)';
[t_bins_vx,t_bins_ms] = check_bins(t_bins_ms_O,ind_time,Vin.mat,Vin.dim(ind_time));
t_bins_vx = reshape(t_bins_vx, size(blocks.twind'))';
t_bins_ms = reshape(t_bins_ms, size(blocks.twind'))'; %#ok<*NASGU>

%% Create the atlas & labels
% Create empty atlas matrix
M_dim = Vout.dim;
M_atlas = zeros(M_dim);
M_atlas_cft = permute(M_atlas,ind_cft); % that will actually be filled!
M_dim_cft = M_dim(ind_cft);
N_roi = Ncg * Nfb * Ntw;
Labels = cell(N_roi,2);

i_ROI = 0; % start at 0, and add 1 every time a new ROI needs to be created
for i_cg = 1:Ncg
    l_cg = blocks.chans{i_cg}; % list of chans
    for i_fb = 1:Nfb
        l_fb = f_bins_vx(i_fb,1):f_bins_vx(i_fb,2); % list of freq
        for i_tw = 1:Ntw
            l_tw = t_bins_vx(i_tw,1):t_bins_vx(i_tw,2); % list of time points
            % Keeping the count or ROIs
            i_ROI = i_ROI+1;
            % Get list of indices
            l_vx = get_indices(l_cg,l_fb,l_tw,M_dim_cft);
            % Fill matrix
            M_atlas_cft(l_vx) = i_ROI;
            % Write the labels
            Labels{i_ROI,1} = i_ROI;
            Labels{i_ROI,2} = sprintf('%s_%s_%s', ...
                lab_chans{i_cg}, lab_fband{i_fb}, lab_twind{i_tw});
        end
    end
end

% Reorder dims as in original data
tmp = 1:3; ind_orig = tmp(ind_cft);
M_atlas = permute(M_atlas_cft,ind_orig);

%% Wrap up & goodbye
% Write volume
Vout = spm_write_vol(Vout,M_atlas);
% Write labels file
spm_save(fn_labels,Labels)


end

%% SUBFUNCTIONS
function [bins_out_vx,bins_out] = check_bins(bins_in,indx,vx2rw,Msz)
% Checking the bins expressed in real world such that they end up as 
% integer voxel indexes to build the atlas matrix.
%
% Operations:
% - realword to voxel conversion
% - round the 1st one -> voxel index
% - check the next bin is at least +1 larger than previous one
% - then convert back into real world the (rounded) voxel indexes
%
% INPUT
% - original bins,
% - index of dimension
% - voxel-to-realworld matrix
% - maximum size, i.e. max index value

Nbins = numel(bins_in);

% Convert into voxel
tmp = zeros(4,numel(bins_in));
tmp(4,:) = 1 ; tmp(indx,:) = bins_in;
tmp2 = vx2rw\tmp;
bins_out_vx = tmp2(indx,:);

% No index <=0
bins_out_vx(bins_out_vx<=0) = 1;
% No index >size
bins_out_vx(bins_out_vx>Msz) = Msz;

% Round 1st one then check next
bins_out_vx(1) = round(bins_out_vx(1));
for ii=2:Nbins
    tmp = round(bins_out_vx(ii));
    if tmp<=bins_out_vx(ii-1)
        % if same (or lower) add +1
        bins_out_vx(ii) = bins_out_vx(ii-1)+1;
    else
        % otherwise keep rounded value
        bins_out_vx(ii) = tmp;
    end
end
bins_out_vx(bins_out_vx<=0) = 1;

% Gets them back into realword
tmp = zeros(4,numel(bins_in));
tmp(4,:) = 1 ; tmp(indx,:) = bins_out_vx;
tmp2 = vx2rw*tmp;
bins_out = tmp2(indx,:);

end

%%
function l_vx = get_indices(l_1,l_2,l_3,M_dim)
% Calculate the list of indices for the current ROI, as defined by the
% 3 lists of voxels (l_1,l_2,l_3).

N_123 = [numel(l_1) numel(l_2) numel(l_3)];
N_vx = prod(N_123);
l_vx = zeros(N_vx,1) - 1; % -1 to easily check it's all filled up

% 2D case
tmp2 = zeros(prod(N_123(1:2)),1)-1;
for i_2 = 1:N_123(2)
    tmp = l_1 + (l_2(i_2)-1)*M_dim(1);
    tmp2((i_2-1)*N_123(1)+(1:N_123(1))) = tmp;
end
% 3D case
for i_3 = 1:N_123(3)
    tmp3 = tmp2 + (l_3(i_3)-1)*M_dim(1)*M_dim(2);
    l_vx((i_3-1)*N_123(1)*N_123(2)+(1:N_123(1)*N_123(2))) = tmp3;
end

end

