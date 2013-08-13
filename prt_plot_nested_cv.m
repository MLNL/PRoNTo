function prt_plot_nested_cv(PRT, model, fold, axes_handle)
% FORMAT prt_plot_nested_cv(PRT, model, fold, axes_handle)
%
% Plots the results of the nested cv that appear on prt_ui_results.
%
%
% Inputs:
%       PRT             - data/design/model structure (it needs to contain
%                         at least one estimated model).
%       model           - the number of the model that will be ploted
%       fold            - the number of the fold
%       axes_handle     - (Optional) axes where the plot will be displayed
%
% Output:
%       None
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Matos Monteiro
% $Id$


% Check machine and set the labels an axes
switch PRT.model(model).input.machine.function
    case {'prt_machine_svm_bin','prt_machine_simpleMKL'}
        x_label = 'C';
        y_label = 'Balanced Accuracy';
        
        %If no axes_handle is given, create a new window
        if ~exist('axes_handle', 'var')
            figure;
            axes_handle = axes('XScale','log','XMinorTick','on');
        else
            % Clear EVERYTHING in the UI before defining the axes
            cla(axes_handle, 'reset');
            set(axes_handle, 'XScale','log','XMinorTick','on');
        end
        box(axes_handle,'on');
        hold(axes_handle,'all');
        
        
    case 'prt_machine_krr'
        x_label = 'Args';
        y_label = 'MSE';
        
        %If no axes_handle is given, create a new window
        if ~exist('axes_handle', 'var')
            figure;
            axes_handle = axes;
        else
            % Clear EVERYTHING in the UI before defining the axes
            cla(axes_handle, 'reset');
            set(axes_handle, 'XScale','linear');
        end
        
                
    otherwise
        error('Machine not currently supported for nested CV');
end


cla(axes_handle)
rotate3d off
set(axes_handle,'Color',[1,1,1])

if fold == 1
    
    nfold = length(PRT.model(model).output.fold);
    
    % Get function values
    x = PRT.model(model).output.fold(fold).param_effect.param;
    f = zeros(nfold, length(x));
    
    % Get mean f values
    for i = 1:nfold
        f(i,:) = PRT.model(model).output.fold(i).param_effect.vary_param;
    end
    
    % Plot
    errorbar(axes_handle, x, mean(f), std(f), 'xk', 'markersize', 7, 'linewidth', 2);
    xlabel(axes_handle, x_label);
    ylabel(axes_handle, y_label);
    
else
    
    % Get all function values
    x = PRT.model(model).output.fold(fold-1).param_effect.param;
    f = PRT.model(model).output.fold(fold-1).param_effect.vary_param;
    
    % Get maximum function values
    x_max = find(f==max(f));

       
    % Plot all points
    hold on
    plot(axes_handle, x, f, 'xk', 'markersize', 7, 'linewidth', 2);
    % Plot the max on top of the original
    max_handle = plot(axes_handle, x(x_max), f(x_max), 'xr', 'markersize', 7, 'linewidth', 2);
    hold off
    
    % Properties
    axis(axes_handle, [min(x) max(x) min(f) max(f)]);
    xlabel(axes_handle, x_label);
    ylabel(axes_handle, y_label);
    legend(max_handle, 'Maximum');
    
end


end
