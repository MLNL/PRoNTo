function [h] = prt_plot_2D_weights(parent,weights)
% Function to plot 2D weights from .mat or MEEG modalities
% Inputs: Parent graph handle and weights, the 2D matrix of values
% Output: Handle to obtained plot
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Schrouff
% $Id$

% Remove figure axes and plots
gch = get(parent,'Children');
for i=1:numel(gch)
    delete(gch);
end

% Draw axes
axmat = axes(parent,'units','normalized', ...
     'position',[0.2 0.2 0.6 0.7], 'NextPlot', 'add');

% Define colormap
minw = min(min(weights));
minw = min(minw,0);
maxw = max(max(weights));
maxw = max(maxw,0);

if minw<0 && maxw>0 % Both negative and positive, diverging colormap
    colneg = cbrewer('seq','Blues',128);
    colpos = cbrewer('seq','Reds',128);
    cols  = [flip(colneg,1);colpos];
elseif minw>=0 && maxw>0 % Only positive, sequential red colormap
    cols = cbrewer('seq','Reds',256);
elseif minw<0 && maxw<=0 % Only negative, sequential blue colormap
    colneg= cbrewer('seq','Blues',256);
    cols  = flip(colneg,1);
elseif minw==0 && maxw==0 % All zeros, just gray
    cols = [0.5 0.5 0.5];
elseif isnan(minw) && isnan(maxw)
    weights = zeros(size(weights));
    cols = [0.5 0.5 0.5];
end
    
colormap(cols);
h = imagesc(axmat,weights);
xlim([1 size(weights,2)])
ylim([1 size(weights,1)])
hc = colorbar('Units','normalized','Position',[0.85 0.2 0.02 0.7]);
% Change colorbar limits to ensure centered white if positive and negative
if minw<0 && maxw>0
    limhc = get(hc,'Limits');
    caxis(max(abs(limhc)) * [-1 1]);
end


