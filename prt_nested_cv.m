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
% $Id: $

% Set flag
use_nested_cv = PRT.model.input.use_nested_cv;
if use_nested_cv == false
    error('prt_nested_cv function called with use_nested_cv = false');
end

train_entries = find(in.CV == 1);

% Change samp_idx (used for the kernel)
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
switch PRT.model.input.machine.function
    case 'prt_machine_svm_bin'
        c = 0.1:0.1:10;
        b_acc = zeros(size(c));
        
    otherwise
        error('Machine not currently supported for nested CV');
        
end

% generate new CV matrix
in.CV = prt_compute_cv_mat(PRT, in, mid, use_nested_cv);

% compute model performance based on hyper-parameter range
for i = 1:length(c)
    
    switch PRT.model.input.machine.function
        case 'prt_machine_svm_bin'
            PRT.model(mid).machine.args = ['-s 0 -t 4 -c ' int2str(c(i))];
            
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
    par(i).c = c(i);
    par(i).stats = prt_stats(model, targets.test, targets.train);
    b_acc(i) = par(i).stats.b_acc;
    
end


% Copy the optimal parameter to PRT
[max_b_acc, max_b_acc_ind] = max(b_acc);
c_max = c(max_b_acc_ind);

if ~isfield(PRT.model.machine, 'opt_par')
    PRT.model.machine.opt_par = [];
end
PRT.model.machine.opt_par = [PRT.model.machine.opt_par, c_max];



end