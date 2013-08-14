function [out] = prt_nested_cv(PRT, in)
% Function to perform the nested CV
%
% Inputs:
% -------
%   in.nc:          number of classes
%   in.ID:          ID matrix
%   in.mid:         model id
%   in.CV:          cross-validation matrix
%   in.Phi_all:     Kernel
%
% Outputs:
% --------
%   out.opt_param:  optimal hyper-parameter choosen using the stats from
%                   the inner CVs
%   out.vary_param: stats values associated with all the hyper-parameters
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Matos Monteiro
% $Id$


% Set flag
use_nested_cv = PRT.model(in.mid).input.use_nested_cv;
if use_nested_cv == false
    error('prt_nested_cv function called with use_nested_cv = false');
end

train_entries = find(in.CV == 1);

% Change fdata
in.ID      = in.ID(train_entries, :);
in.t       = in.t(train_entries);
in.fs      = PRT.fs;
in.cv.type = PRT.model(in.mid).input.cv_type;
for i=1:length(in.Phi_all)
    in.Phi_all{i} = in.Phi_all{i}(train_entries, train_entries);
end

% Set range of the hyper parameters
switch PRT.model(in.mid).input.machine.function
    case {'prt_machine_svm_bin','prt_machine_simpleMKL'}
        if ~isempty(PRT.model(in.mid).input.nested_param)
            d1 = PRT.model(in.mid).input.nested_param;
        else
            d1 = -2 : 5;
            beep
            warning('No parameter range specified for C, using 10^-2 to 10^5')
        end
        par = 10 .^(d1);
        out.param = par;
        
    case 'prt_machine_krr'
        if ~isempty(PRT.model(in.mid).input.nested_param)
            par = PRT.model(in.mid).input.nested_param;
        else
            par = 0.1:0.1:1;
            beep
            warning('No parameter range specified for K, using 0.1 to 1')
        end
        out.param = par;
        
    case 'prt_machine_ENMKL'
        if ~isempty(PRT.model(in.mid).input.nested_param)
            % Get parameter ranges from PRT
            c = PRT.model(in.mid).input.nested_param{1};
            mu = PRT.model(in.mid).input.nested_param{2};
            % Convert them to a matrix with all the combinations
            [c_mesh,mu_mesh] = meshgrid(c, mu);
            par = [c_mesh(:), mu_mesh(:)]';
        else
            d1 = -2 : 5;
            c = 10 .^(d1);
            mu = 0:0.1:1;
            [c_mesh,mu_mesh] = meshgrid(c, mu);
            par = [c_mesh(:), mu_mesh(:)]';
            beep
            warning('No parameter range specified for C and mu, using 10^-2 to 10^5 and 0 to 1')
        end
        out.param = [c;mu];
        
        
    otherwise
        error('Machine not currently supported for nested CV');
        
end

stats_vec = zeros(1, size(par, 2));

% generate new CV matrix
in.CV = prt_compute_cv_mat(PRT, in, in.mid, use_nested_cv);

% compute model performance based on hyper-parameter range
for i = 1:size(par, 2)
    
    switch PRT.model(in.mid).input.machine.function
        case {'prt_machine_svm_bin','prt_machine_simpleMKL'}
            PRT.model(in.mid).input.machine.args = ['-s 0 -t 4 -c ' num2str(par(i))];
        case 'prt_machine_krr'
            PRT.model(in.mid).input.machine.args = par(i);
        case 'prt_machine_ENMKL'
            PRT.model(in.mid).input.machine.args = par(:,i)';
        otherwise
            error('Machine not currently supported for nested CV');
    end
    
    % compute the model for each fold of the inner CV
    for f = 1:size(in.CV, 2)
        
        fold.ID      = in.ID;
        fold.CV      = in.CV(:,f);
        fold.Phi_all = in.Phi_all;
        fold.t       = in.t;
        fold.mid     = in.mid;
        
        [model, targets] = prt_cv_fold(PRT,fold);
        
        %for classification check that for each fold, the test targets have been trained
        if strcmpi(PRT.model(in.mid).input.type,'classification')
            if ~all(ismember(unique(targets.test),unique(targets.train)))
                beep
                disp('At least one class is in the test set but not in the training set')
                disp('Abandoning modelling, please correct class selection/cross-validation')
                return
            end
        end
        
        
    end
    
    % compute stats
    stats = prt_stats(model, targets.test, in.nc);
    switch PRT.model(in.mid).input.type
        case 'classification'
            stats_vec(i) = stats.b_acc;
        case 'regression'
            stats_vec(i) = stats.mse;
        otherwise
            error('Type of model not recognised');
    end
    
    
end

% For now, only parameter optimisation. Add flag for feature selection
% Get optimal parameter
if strcmp(PRT.model(in.mid).input.machine.function, 'prt_machine_ENMKL')
    
    % Reshape the stats vector into a matrix
    stats_mat = reshape(stats_vec, length(unique(par(2,:))), length(unique(par(1,:))))';
    
    [opt_stats, c_max_ind] = max(max(stats_mat'));
    [opt_stats, mu_max_ind] = max(max(stats_mat));
    
    % Find c max
    if length(stats_mat(c_max_ind,:)) == 1 % No effect of parameter, so get median
        c_max = median(c);
    else
        c_max = c(c_max_ind);
    end
    
    % Find mu max
    if length(stats_mat(:,mu_max_ind)) == 1 % No effect of parameter, so get median
        mu_max = median(mu);
    else
        mu_max = mu(mu_max_ind);
    end
    
    out.opt_param = [c_max, mu_max];
    out.vary_param = stats_mat;
    
    
else
    if length(unique(stats_vec)) == 1 % No effect of parameter, so get median
        par_opt = median(par);
    else
        switch PRT.model(in.mid).input.type
            case 'classification'
                [opt_stats, opt_stats_ind] = max(stats_vec);
            case 'regression'
                [opt_stats, opt_stats_ind] = min(stats_vec);
            otherwise
                error('Type of model not recognised');
        end
        par_opt = par(opt_stats_ind);
    end
    
    out.opt_param = par_opt;
    out.vary_param = stats_vec;
    
end