function [h] = prt_plot_Kernel_Contribution_box(graph_handle, data, labels, multi)
% Plot the per-modality kernel weights as a HYBRID box-and-jitter figure:
%   * modalities with more than one kernel  -> a box plot (median, 25-75%
%     interquartile box, Tukey whiskers) with the individual kernel weights
%     overlaid as jittered points, so both the summary and the raw spread of
%     the kernels are visible;
%   * modalities with a single kernel        -> a single marker at its weight
%     (a "distribution" of one value is meaningless), with a stem to baseline
%     so its magnitude is comparable to the neighbouring boxes.
%
% This is an alternative to prt_plot_Kernel_Contribution_bar, which shows a
% single bar with the SUM of the kernel weights per modality and therefore
% hides how the weights are spread within each modality. Compared with a
% violin plot it copes much better with the strongly right-skewed kernel
% weights produced by MKL (most kernels small, a few large).
%
% It needs no toolbox: quartiles are computed with the local helper
% local_prctile, and the jittered points are drawn directly.
%
% Inputs:
%   graph_handle : parent axes handle (e.g. handles.axes1)
%   data         : cell array of length nMod; data{i} is the vector of kernel
%                  weights (e.g. in %) for modality i
%   labels       : optional cell array of nMod modality names (x-tick labels)
%   multi        : optional logical vector of length nMod; multi(i) is true if
%                  modality i has more than one kernel (-> box+jitter). If
%                  omitted, it is inferred from the number of values in data{i}.
% Output:
%   h            : array of graphics handles created in the axes, so the
%                  caller can toggle their 'Visible' property exactly like
%                  the handle returned by prt_plot_Kernel_Contribution_bar
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written for PRoNTo
% $Id$

if nargin < 3
    labels = [];
end

nG = numel(data);

% If the caller did not say which modalities are multi-kernel, infer it from
% the number of values supplied for each modality.
if nargin < 4 || isempty(multi)
    multi = false(1, nG);
    for i = 1:nG
        multi(i) = numel(data{i}) > 1;
    end
end

set(graph_handle, 'visible', 'on')
cla(graph_handle)

% One colour per modality for readability
palette = lines(max(nG, 1));

hw = 0.18;   % half-width of the boxes
jw = 0.22;   % full width over which the jittered points are spread
ptsz = 28;   % jitter dot size (scatter marker area, in points^2)

% Draw everything on the same axes; keep hold on across the loop so the boxes,
% points, whiskers and singleton markers accumulate.
hold(graph_handle, 'on')
hasbox = false;   % becomes true once at least one box has been drawn
for k = 1:nG
    c = palette(k, :);
    d = data{k}(:);
    if multi(k) && numel(d) > 1
        % ---- Box: median, interquartile range and Tukey whiskers ----------
        q1 = local_prctile(d, 25);
        q2 = median(d);
        q3 = local_prctile(d, 75);
        iqr = q3 - q1;
        loFence = q1 - 1.5 * iqr;       % Tukey fences
        hiFence = q3 + 1.5 * iqr;
        loWhisk = min(d(d >= loFence)); if isempty(loWhisk), loWhisk = min(d); end
        hiWhisk = max(d(d <= hiFence)); if isempty(hiWhisk), hiWhisk = max(d); end

        % Interquartile box (semi-transparent so the points show through)
        patch(graph_handle, [k-hw, k+hw, k+hw, k-hw], [q1, q1, q3, q3], c, ...
            'FaceAlpha', 0.35, 'EdgeColor', 'k', 'LineWidth', 1);
        % Median line
        plot(graph_handle, [k-hw, k+hw], [q2, q2], 'k-', 'LineWidth', 2);
        % Whiskers (vertical) with small horizontal caps
        plot(graph_handle, [k, k], [q3, hiWhisk], 'k-', 'LineWidth', 1);
        plot(graph_handle, [k, k], [q1, loWhisk], 'k-', 'LineWidth', 1);
        plot(graph_handle, [k-hw/2, k+hw/2], [hiWhisk, hiWhisk], 'k-', 'LineWidth', 1);
        plot(graph_handle, [k-hw/2, k+hw/2], [loWhisk, loWhisk], 'k-', 'LineWidth', 1);

        % ---- Jitter: every kernel weight as a point, nudged sideways -------
        xj = k + (rand(numel(d), 1) - 0.5) * jw;
        try
            % semi-transparent fill so dense clusters near the bottom read well
            scatter(graph_handle, xj, d, ptsz, c, 'filled', ...
                'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'none');
        catch
            % older MATLAB without scatter alpha: plain dots (MarkerSize is a
            % diameter in points, so scale it from the scatter area ptsz)
            plot(graph_handle, xj, d, '.', 'Color', c, 'MarkerSize', sqrt(ptsz)+4);
        end
        hasbox = true;
    else
        % ---- Single-kernel modality ---------------------------------------
        % A "distribution" of one value is meaningless, so draw a single marker
        % at its weight with a stem to the baseline (so its magnitude is
        % comparable to the neighbouring boxes). The title note added below
        % clarifies this when both styles are present.
        if isempty(d)
            continue
        end
        v = d(1);
        plot(graph_handle, [k, k], [0, v], '-', 'Color', c, 'LineWidth', 1.5)
        plot(graph_handle, k, v, 'o', 'Color', c, 'MarkerFaceColor', c, ...
            'MarkerEdgeColor', 'k', 'MarkerSize', 8)
    end
end
hold(graph_handle, 'off')

% Tidy axes: one tick per modality, with names
set(graph_handle, 'XTick', 1:nG)
set(graph_handle, 'XLim', [0.5, nG + 0.5])
% Show modality names literally: by default MATLAB interprets the tick labels
% as TeX, so an underscore in a name (e.g. 'fMRI_AAL') would be rendered as a
% subscript. Setting the interpreter to 'none' keeps the names as typed.
try
    set(graph_handle, 'TickLabelInterpreter', 'none')
end
if ~isempty(labels)
    set(graph_handle, 'XTickLabel', labels)
else
    set(graph_handle, 'XTickLabel', cellstr(num2str((1:nG)')))
end

set(get(graph_handle, 'XLabel'), 'String', 'Modality')
set(get(graph_handle, 'XLabel'), 'FontWeight', 'demi')
set(get(graph_handle, 'YLabel'), 'String', 'Kernel weights (%)')
set(get(graph_handle, 'YLabel'), 'FontWeight', 'demi')

% Note the meaning of the single-kernel marker when both styles are present
if any(~multi) && hasbox
    title(graph_handle, 'Single-kernel modalities shown as a marker', ...
        'FontWeight', 'normal', 'FontSize', 8)
end

% Return all handles in the axes so the caller can hide them (set 'Visible')
h = get(graph_handle, 'Children');


% --- Linear-interpolated percentile (no Statistics Toolbox required).
% -------------------------------------------------------------------------
function q = local_prctile(x, p)
% Return the p-th percentile(s) of x (p in [0,100]) using the common linear
% interpolation definition, so the boxes can be drawn without 'prctile' or
% 'quantile' (which live in the Statistics Toolbox).
x = sort(x(:));
n = numel(x);
if n == 0
    q = nan(size(p));
    return
elseif n == 1
    q = repmat(x, size(p));
    return
end
pos  = (p(:) / 100) * (n - 1) + 1;   % 1-based fractional index
lo   = min(max(floor(pos), 1), n);
hi   = min(max(ceil(pos),  1), n);
frac = pos - floor(pos);
q    = x(lo) + frac .* (x(hi) - x(lo));
q    = reshape(q, size(p));
