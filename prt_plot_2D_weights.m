function [h] = prt_plot_2D_weights(parent,weights,weights_D)
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
    if strcmp(gch(i).Tag,'uipanelmat_topoplots')
        continue
    end
    delete(gch(i));
end

% Draw axes (properties depend on Matlab version)
try
    axmat = axes(parent,'units','normalized', ...
        'position',[0.037 0.17 0.585 0.7], 'NextPlot', 'add');
catch
    axmat = axes('units','normalized', 'NextPlot', 'add', ...
        'position',[0.037 0.17 0.585 0.7],'parent',parent);
end

% Define colormap
minw = min(min(weights));
minw = min(minw,0);
maxw = max(max(weights));
maxw = max(maxw,0);

if minw<0 && maxw>0 % Both negative and positive, diverging colormap
    colneg = cbrewer('seq','Blues',128,'PCHIP');
    colpos = cbrewer('seq','Reds',128,'PCHIP');
    cols  = [flip(colneg,1);colpos];
elseif minw>=0 && maxw>0 % Only positive, sequential red colormap
    cols = cbrewer('seq','Reds',256,'PCHIP');
elseif minw<0 && maxw<=0 % Only negative, sequential blue colormap
    colneg= cbrewer('seq','Blues',256,'PCHIP');
    cols  = flip(colneg,1);
elseif minw==0 && maxw==0 % All zeros, just gray
    cols = [0.5 0.5 0.5];
elseif isnan(minw) && isnan(maxw)
    weights = zeros(size(weights));
    cols = [0.5 0.5 0.5];
end

colormap(cols);
try
    h = imagesc(axmat,weights);
catch
    set(gcf,'CurrentAxes',axmat)
    h = imagesc(weights);
end

xlim([1 size(weights,2)])
ylim([1 size(weights,1)])


xaxmat = weights_D.ftraw.time{1,length(weights_D.ftraw.time)};
xaxmat = round(xaxmat,5);
xaxmat = xaxmat';
xaxmat = xaxmat*1000;
zero_ind = find(xaxmat==0);


dummy_var2 = [zero_ind];
while max(dummy_var2) < length(weights_D.time)
    i = max(dummy_var2)+20;
    dummy_var2 = [dummy_var2 i];
end

xticks(dummy_var2)

dummy_var = ones(1,length(xaxmat));
xaxmat = mat2cell(xaxmat,dummy_var);
xaxmat = xaxmat';
xticklabels(xaxmat(dummy_var2));



try
    hc = colorbar(axmat,'Units','normalized','Position',[0.638 0.17 0.02 0.7]);
catch
    hc = colorbar('peer',axmat,'Units','normalized','Position',[0.638 0.17 0.02 0.7]);
end
% Change colorbar limits to ensure centered white if positive and negative
if minw<0 && maxw>0
    try
        limhc = get(hc,'Limits');
        limw = max(abs(limhc));
    catch
        absw = abs(weights);
        limw = max(max(absw));
    end
    caxis(limw * [-1 1]);
end


