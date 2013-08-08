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
    case 'prt_machine_svm_bin'
        x_label = 'C';
        y_label = 'Balanced Accuracy';
        
        %If no axes_handle is given, create a new window
        % TODO: See if there is a better way of doing this
        % Check if it works when it's called from prt_ui_results
        if ~exist('axes_handle', 'var')
            figure;
            axes_handle = axes('XScale','log','XMinorTick','on');
            box(axes_handle,'on');
            hold(axes_handle,'all')
        end
        
        
    case {'prt_machine_krr','prt_machine_simpleMKL'}
        x_label = 'Args';
        y_label = 'MSE';
        
        %If no axes_handle is given, create a new window
        if ~exist('axes_handle', 'var')
            figure;
            axes_handle = axes;
        end
        
    otherwise
        error('Machine not currently supported for nested CV');
end


cla(axes_handle);
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
    
    % Create axes
    errorbar(x, mean(f), std(f), '*k');
    xlabel(x_label);
    ylabel(y_label);
    
    
else
    
    % Get function values
    x = PRT.model(model).output.fold(fold).param_effect.param;
    f = PRT.model(model).output.fold(fold).param_effect.vary_param;
    
    % Plot
    plot(axes_handle, x, f, '*k');
    xlabel(x_label);
    ylabel(y_label);
    
end



end