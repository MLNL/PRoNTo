function prt_create_topoplots(weights_mat, time_min, time_max, time_window)

num_plots = ceil((time_max-time_min)/time_window);
time_min = time_min/1000; time_max = time_max/1000;

% First check if Brewermap toolbox is installed and on the path
ft_hastoolbox('brewermap', 1, 0);

% Import data from SPM and convert to Fieldtrip format:
D = spm_eeg_load(weights_mat);
data = D.ftraw;
clear D

% if time_min<round(min(data.time{1,5}),10) || time_max>round(max(data.time{1,5}),10)
%     error(['Time range [' num2str(time_min*1000) ',' num2str(time_max*1000) ']ms out of bounds.'])
% end

xping = 0;

% Only for EEG data: define the layout (for MEG it is done automatically).
if contains(data.label{1},'EEG')
    try
        data = rmfield(data, 'grad');
    catch
        cfg = [];
        cfg.elec = data.elec;
        layout = ft_prepare_layout(cfg, data.elec);
        xping = 1;
    end
end


dims_trial = size(data.trial);
dims_time = size(data.time);

if dims_trial ~= dims_time
    disp('dims_trial ~= dims_time')
end

% time_min = min(data.time{max(dims_trial)});
% time_max = max(data.time{max(dims_trial)});


scale_min = min(min(data.trial{1,max(dims_trial)}));
scale_max = max(max(data.trial{1,max(dims_trial)}));
scalex = max([abs(scale_min) abs(scale_max)]);

% Topoplot Fieldtrip
cfg = [];
cfg.zlim = [-scalex scalex]; % Scale
cfg.comment            = 'no';
if xping
    cfg.layout = layout;
end

cfg.xlim = [time_min time_min+time_window/1000];

% warning('off', 'all') % doesn't work for some reason
for i = 1:num_plots
    
    if abs(cfg.xlim)<0.000001
        ind = abs(cfg.xlim)<0.000001;
        cfg.xlim(ind) = floor(cfg.xlim(ind));
    end
    
    if i ~= 1
        cfg.xlim = cfg.xlim+time_window/1000; % Time window
    end
    
    if i == num_plots
        cfg.xlim(2) = time_max;
    end
    
    figure;
    % subplot(2,3,i);
    ft_topoplotTFR(cfg,data); colorbar
    colormap(flipud(brewermap(64,'RdBu'))); % change the colormap
    title(['Time ' num2str(1000*cfg.xlim(1)) 'ms to time ' num2str(1000*cfg.xlim(2)) 'ms']);
end




end

