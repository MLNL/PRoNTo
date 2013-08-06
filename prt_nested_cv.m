function [PRT] = prt_nested_cv(PRT, mid, in, Phi, samp_idx)
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

% Change samp_idx
samp_idx = samp_idx(train_entries);

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
    case 'prt_machine_svm_bin'
        par = logspace(-2, 5);
        stats_vec = zeros(size(par));
        
    case 'prt_machine_krr'
        par = 0.1:0.1:1;
        stats_vec = zeros(size(par));
        
    otherwise
        error('Machine not currently supported for nested CV');
        
end

% generate new CV matrix
in.CV = prt_compute_cv_mat(PRT, in, mid, use_nested_cv);

% compute model performance based on hyper-parameter range
for i = 1:length(par)
    
    switch PRT.model(mid).input.machine.function
        case 'prt_machine_svm_bin'
            PRT.model(mid).input.machine.args = ['-s 0 -t 4 -c ' num2str(par(i))];
            % TODO: I don't know why but this field exists on the PRT for
            % classification. I'm changing the parameter on both fields
            % of the PRT struct just to be sure everthing is fine
            PRT.model(mid).machine.args = ['-s 0 -t 4 -c ' num2str(par(i))];
            
        case 'prt_machine_krr'
            PRT.model(mid).input.machine.args = par(i);
            % TODO: I don't know why but this field exists on the PRT for
            % classification. I'm changing the parameter on both fields
            % of the PRT struct just to be sure everthing is fine
            PRT.model(mid).machine.args = par(i);
            
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
    results(i).par = par(i);
    results(i).stats = prt_stats(model, targets.test, targets.train);
    
    switch PRT.model(mid).input.machine.function
        case 'prt_machine_svm_bin'
            stats_vec(i) = results(i).stats.b_acc;
        case 'prt_machine_krr'
            % The smaller, the better. Thus, negative is stored
            stats_vec(i) = -results(i).stats.mse;
            
        otherwise
            error('Machine not currently supported for nested CV');
    end
    
    
end



% Get optimal parameter
[max_stats, max_stats_ind] = max(stats_vec);
par_max = par(max_stats_ind);

% Save best parameter in the PRT
PRT.model(mid).input.machine.opt_par = [PRT.model(mid).input.machine.opt_par, par_max];
PRT.model(mid).machine.opt_par = [PRT.model(mid).machine.opt_par, par_max];

% Save all the stats
PRT.model(mid).input.machine.stats = [PRT.model(mid).input.machine.stats, stats_vec'];
PRT.model(mid).machine.stats = [PRT.model(mid).machine.stats, stats_vec'];

end