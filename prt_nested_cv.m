function [out] = prt_nested_cv(PRT, mid, in)
% Function to perform the nested CV
%
% Inputs:
% -------
%
% Outputs:
% --------
%
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Matos Monteiro
% $Id$

% Set flag
use_nested_cv = PRT.model(mid).input.use_nested_cv;
if use_nested_cv == false
    error('prt_nested_cv function called with use_nested_cv = false');
end

train_entries = find(in.CV == 1);

% Change fdata
in.ID      = in.ID(train_entries, :);
in.t       = in.t(train_entries);
in.fs      = PRT.fs;
in.cv.type = PRT.model(mid).input.cv_type;
for i=1:length(in.Phi_all)
    in.Phi_all{i} = in.Phi_all{i}(train_entries, train_entries);
end

% Set range of the hyper parameters
switch PRT.model(mid).input.machine.function
    case {'prt_machine_svm_bin','prt_machine_simpleMKL'}
        if ~isempty(PRT.model(mid).input.nested_param)
            d1 = PRT.model(mid).input.nested_param;
        else
            d1 = -2 : 5;
            beep
            disp('No parameter range specified for C, using 10^-2 to 10^5')
        end
        par = 10 .^(d1);
        
    case 'prt_machine_krr'
        if ~isempty(PRT.model(mid).input.nested_param)
            par = PRT.model(mid).input.nested_param;
        else
            par = 0.1:0.1:1;
            beep
            disp('No parameter range specified for K, using 0.1 to 1')
        end
        
    otherwise
        error('Machine not currently supported for nested CV');
        
end
stats_vec = zeros(size(par));
out.param = par;

% generate new CV matrix
in.CV = prt_compute_cv_mat(PRT, in, mid, use_nested_cv);

% compute model performance based on hyper-parameter range
for i = 1:length(par)
    
    switch PRT.model(mid).input.machine.function
<<<<<<< .mine
        case 'prt_machine_svm_bin'
            PRT.model(mid).input.machine.args = ['-s 0 -t 4 -c ' num2str(par(i))];
            % TODO: I don't know why but this field exists on the PRT for
            % classification. I'm changing the parameter on both fields
            %             % of the PRT struct just to be sure everthing is fine
            %             PRT.model(mid).machine.args = ['-s 0 -t 4 -c ' num2str(par(i))];
            
        case {'prt_machine_krr','prt_machine_simpleMKL'}
=======
        case {'prt_machine_krr','prt_machine_simpleMKL','prt_machine_svm_bin'}
>>>>>>> .r770
            PRT.model(mid).input.machine.args = par(i);
<<<<<<< .mine
            % TODO: I don't know why but this field exists on the PRT for
            % classification. I'm changing the parameter on both fields
            % of the PRT struct just to be sure everthing is fine
            %             PRT.model(mid).machine.args = par(i);
            
=======
            PRT.model(mid).input.machine.args = ['-s 0 -t 4 -c ' num2str(par(i))];
>>>>>>> .r770
        otherwise
            error('Machine not currently supported for nested CV');            
    end
    
    % compute the model for each fold of the inner CV
    for f = 1:size(in.CV, 2)
        
        fold.ID      = in.ID;
        fold.CV      = in.CV(:,f);
        fold.Phi_all = in.Phi_all;
        fold.t       = in.t;
        fold.mid     = mid;
        
        [model, targets] = prt_cv_fold(PRT,fold);
        
        %for classification check that for each fold, the test targets have been trained
        if strcmpi(PRT.model(mid).input.type,'classification')
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
    
    switch PRT.model(mid).input.type
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
if length(unique(stats_vec)) == 1 % No effect of parameter, so get median
    par_opt = median(par);
else
    switch PRT.model(mid).input.type
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