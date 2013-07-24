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
in.CV      = in.CV(train_entries);
in.Phi_all{1} = Phi(samp_idx,samp_idx); % TODO: I'm not sure this is correct. CHECK!
in.t       = in.t(train_entries);

in.fs = PRT.fs;
in.cv.type = PRT.model(mid).input.cv_type;

% Set range of the hyper parameters
switch PRT.model.input.machine.function
    case 'prt_machine_svm_bin'
        c = 1:5;
        bacc = zeros(size(c));
        
    otherwise
        error('Machine not currently supported for nested CV');
        
end

% generate new CV matrix
[CV,~] = prt_compute_cv_mat(PRT, in, mid, use_nested_cv);
in.CV = CV;


for i = 1:length(c)
    
    switch PRT.model.input.machine.function
        case 'prt_machine_svm_bin'
            PRT.model(mid).machine.args = ['-s 0 -t 4 -c ' int2str(c(i))];
            
        otherwise
            error('Machine not currently supported for nested CV');
            
    end
    
    % compute the model for this CV fold
    
    for f = 1:size(CV, 2)
        
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
        
        % compute stats
        stats = prt_stats(model, targets.test, targets.train);
        
    end
    
    
    
end


end