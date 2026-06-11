% Load atlas to access the mask
prepath = '***\tutorials_v3_with_data\Multimodal_SPM_preprocessed\data\';
addpath(prepath);
load('EEG_atlas.mat')
id = find(mask);

% Atlas info for display and summarization
labs = {'OF','LF','CF','RF','LC','CC','RC','LP','CP','RP','O'};
OF = [2,4:8];
LF=[9:11,18:21];
CF=[12:14,22:24];
RF=[15:17,25:28];
LC=[29:32,41:43];
CC=[33:35,44:46];
RC=[36:39,47:49];
LP=[40,51:53,62,63];
CP=[54:58,64];
RP=[50,59,60,61,65,66];
O=[1,3,67:70];
ind = {OF,LF,CF,RF,LC,CC,RC,LP,CP,RP,O};

% load weights and access the average fold
% (this file should be in the same folder as your PRT.mat)
load('ROI_weights_ConnEEG_atlas_MKL.mat')
w_av = squeeze(weights(:,:,:,end));

% Weights, reconstructed on the original matrix
or_weights = zeros(size(mask,1),size(mask,2));
or_weights(id) = w_av;

% Summarize weights in each ROI as a single value for plotting
sum_weights = zeros(length(ind),length(ind));
w_sym = or_weights + or_weights';
for i = 1:length(ind)
    for j=1:length(ind)
        sum_weights(i,j) = max(max(w_sym(ind{i},ind{j})));
    end
end

% Imagesc matrix
cc = cbrewer('seq','Reds',200);
figure;
imagesc(sum_weights);
if min(min(sum_weights))==0 %if some weights are perfectly 0
    cc(1,:)=[0.8 0.8 0.8];
end
colormap(cc);
colorbar;
set(gca,'XTick',1:numel(labs))
set(gca,'YTick',1:numel(labs))
set(gca,'XTickLabel',labs)
set(gca,'YTickLabel',labs)

% Use modified version of schemaball to plot the summarized weights
schemaball_JS(sum_weights,labs,cc,[0 1 1])