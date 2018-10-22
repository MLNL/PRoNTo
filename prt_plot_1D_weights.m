function [h] = prt_plot_1D_weights(parent,weights,roimat)
% Function to plot 1D weights from .mat or MEEG modalities
% Inputs: Parent graph handle and weights, the vector of values
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

% Define colormap - setting grey for zero, in the middle
minw = min(weights);
maxw = max(weights);
if minw<0 && maxw>0 % Both negative and positive, diverging colormap
    colneg = cbrewer('seq','Blues',128);
    colpos = cbrewer('seq','Reds',128);
    cols  = [flip(colneg,1);colpos];
    valspos = round((weights(weights>=0) ./ maxw) *127)+1;
    valsneg = -(round((weights(weights<0) ./ minw) *127));
    valsN = weights;
    valsN(weights>=0) = valspos;
    valsN(weights<0) = valsneg;
    valsN = valsN + 128;
    % Colorbar ticks and labels
    newticks = [1 128 256];
    labels = [minw;0;maxw];
elseif minw>=0 && maxw>0 % Only positive, sequential red colormap
    colpos = cbrewer('seq','Reds',256);
    cols  = colpos;
    valsN = round(((weights) ./ (maxw-minw)) .* 255)+1;
    newticks = [1 256];
    labels = [minw;maxw];
elseif minw<0 && maxw<=0 % Only negative, sequential blue colormap
    colneg = cbrewer('seq','Blues',256);
    cols  = flip(colneg,1);
    valsN = round(((weights) ./ (maxw-minw)) .* 255)+1;
    newticks = [1 256];
    labels = [minw;maxw];
elseif (minw==0 && maxw==0) || ...
       isnan(minw) && isnan(maxw) % All zeros, just gray
    weights = zeros(size(weights)); 
    cols = [0.5 0.5 0.5];
    valsN = ones(size(weights));
    newticks = 0;
    labels = 0;
end
colormap(cols);

% Mask weights if a cell was selected in the ROI table
weights = weights(roimat==1);
valsN = valsN(roimat==1);

% Draw axes and x-slider
step = min(1,100/numel(weights));

try 
    axmat = axes(parent,'XLim', [-5 numel(weights)+5], 'units','normalized', ...
        'position',[0.2 0.2 0.6 0.7], 'NextPlot', 'add');
catch % for older Matlab versions
    axmat = axes(parent,'XLim', [-5 numel(weights)+5], 'units','normalized', ...
        'position',[0.2 0.2 0.6 0.7]);
end

% Plot values
valsl = 0;
lowval = floor((valsl)*numel(weights));
minsl = max(lowval,1);
highval = ceil((valsl + (step))*numel(weights));
maxsl = min(highval,length(weights));

h = plot_data(axmat,minsl:maxsl,weights(minsl:maxsl),cols,valsN(minsl:maxsl),[minw maxw]);
hc = colorbar('Units','normalized','Position',[0.85 0.2 0.02 0.7]);
% Change colorbar limites and tick labels
limhc = get(hc,'Limits');
newticksproj = ceil(newticks * (max(limhc)/size(cols,1)));
set(hc,'Ticks',newticksproj);
set(hc,'TickLabelsMode','manual');
set(hc,'TickLabels',labels);


if step<1 % set slider
    slide = uicontrol(parent,'style','slider','units','normalized',...
        'position',[0.2 0.05 0.6 .05],...
        'Min',0,'Max',1,'SliderStep',[step step],...
        'callback',@hscroll_Callback);
    % Pass data to slider
    sliderdata = struct('weights',weights,'axes',axmat,'cols',cols,...
        'valsN',valsN,'range',[minw maxw]);
    set(slide,'UserData',sliderdata);
end


%--------------------------------------------------------------------------
% Subfunctions
%--------------------------------------------------------------------------

function hscroll_Callback(src,evt)
    valsl = get(src,'Value');
    step = get(src,'SliderStep');
    data = get(src,'UserData');
    step = step(1);
    lowval = floor((valsl)*numel(data.weights));
    minsl = max(lowval,1);
    highval = ceil((valsl + (step))*numel(data.weights));
    maxsl = min(highval,length(weights));
    plot_data(data.axes,minsl:maxsl,data.weights(minsl:maxsl),data.cols,data.valsN(minsl:maxsl),data.range);
end
end

function [h] = plot_data(ax,xval,yval,cols,valsN,range)
    h = bar(ax,xval,diag(yval),'stacked'); % Plot true values
    for i=1:length(h)
        rgb = cols(valsN(i),:);
        set(h(i),'FaceColor',rgb);           
    end
    xlim(ax,[min(xval)-1 max(xval)+1])
    if range(2)>range(1)
        ylim(ax,range)
    end
end


