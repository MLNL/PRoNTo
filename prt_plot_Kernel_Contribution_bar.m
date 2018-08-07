function [h] = prt_plot_Kernel_Contribution_bar(graph_handle,contrib)
% Function to plot kernel weights from ROIs or modalities.
% Inputs: Parent graph handle and contrib, the vector of kernel
% contributions.
% Output: Handle to obtained plot
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Schrouff
% $Id$

set(graph_handle,'visible','on')
h = bar(graph_handle,contrib,'FaceColor','black');
set(get(graph_handle,'XLabel'),'FontWeight','demi')
set(get(graph_handle,'XLabel'),'String','Index in Table')
set(get(graph_handle,'YLabel'),'String','Kernel weights')
set(get(graph_handle,'YLabel'),'FontWeight','demi')