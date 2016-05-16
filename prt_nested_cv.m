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

% Written by J.M. Monteiro
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
if isfield(PRT.model(in.mid).input,'cv_type_nested')
    in.cv.type = PRT.model(in.mid).input.cv_type_nested;
    in.cv.k = PRT.model(in.mid).input.cv_k_nested;
else
    in.cv.type = PRT.model(in.mid).input.cv_type;
    in.cv.k = PRT.model(in.mid).input.cv_k;
end

for i=1:length(in.Phi_all)
    in.Phi_all{i} = in.Phi_all{i}(train_entries, train_entries);
end

% Set range of the hyper parameters
switch PRT.model(in.mid).input.machine.function
    case {'prt_machine_svm_bin','prt_machine_sMKL_cla','prt_machine_krr', 'prt_machine_sMKL_reg'}
        if ~isempty(PRT.model(in.mid).input.nested_param)
            par = PRT.model(in.mid).input.nested_param;
        else
            d1 = -2 : 3;
            par = 10 .^(d1);
        end
    case 'prt_machine_wip_cla'
        if ~isempty(PRT.model(in.mid).input.nested_param)
            % Get parameter ranges from PRT
            c = PRT.model(in.mid).input.nested_param{1};
            mu = PRT.model(in.mid).input.nested_param{2};
            % Convert them to a matrix with all the combinations
            [c_mesh,mu_mesh] = meshgrid(c, mu);
            par = [c_mesh(:), mu_mesh(:)]';
        else
            d1 = -2 : 3;
            c = 10 .^(d1);
            mu = 0:0.1:1;
            [c_mesh,mu_mesh] = meshgrid(c, mu);
            par = [c_mesh(:), mu_mesh(:)]';
        end
        
    otherwise
        error('Machine not currently supported for nested CV');
        
end

out.param = par;
stats_vec = zeros(1, size(par, 2));

% generate new CV matrix
in.CV = prt_compute_cv_mat(PRT, in, in.mid, use_nested_cv);

% compute model performance based on hyper-parameter range
for i = 1:size(par, 2)
    
    switch PRT.model(in.mid).input.machine.function
        case {'prt_machine_svm_bin','prt_machine_sMKL_cla'}
            PRT.model(in.mid).input.machine.args = par(i);
            m.type = 'classifier';
            
        case {'prt_machine_krr', 'prt_machine_sMKL_reg'}
            PRT.model(in.mid).input.machine.args = par(i);
            m.type = 'regression';
            
        case 'prt_machine_wip_cla'
            PRT.model(in.mid).input.machine.args = par(:,i)';
            m.type = 'classifier';
            
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
        if isfield(in, 'cov')
            fold.cov     = in.cov;
        end
        
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
        
        % Compute stats
        stats = prt_stats(model, targets.test, in.nc);
        f_stats(f).targets     = targets.test;
        f_stats(f).predictions = model.predictions(:);
        f_stats(f).stats       = stats;
        
        
    end
    
    % Model level statistics (across folds)
    ttt           = vertcat(f_stats(:).targets);
    m.predictions = vertcat(f_stats(:).predictions);
    stats         = prt_stats(m, ttt(:), in.nc);
    
    
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
if strcmp(PRT.model(in.mid).input.machine.function, 'prt_machine_wip_cla')
    
    % Reshape the stats vector into a matrix
    stats_mat = reshape(stats_vec, length(unique(par(2,:))), length(unique(par(1,:))))';
    
    % Find max
    opt_stats_ind = get_opt_stats_ind(stats_mat, 2, true);
    c_max = c(opt_stats_ind(1));
    mu_max = mu(opt_stats_ind(2));
    
    out.opt_param = [c_max, mu_max];
    out.vary_param = stats_mat;
    
    
else
    
    switch PRT.model(in.mid).input.type
        case 'classification'
            opt_stats_ind = get_opt_stats_ind(stats_vec, 1, true);
        case 'regression'
            opt_stats_ind = get_opt_stats_ind(stats_vec, 1, false);
        otherwise
            error('Type of model not recognised');
    end
    
    par_opt = par(opt_stats_ind);
    
    out.opt_param = par_opt;
    out.vary_param = stats_vec;
    
end

end



% -------------------------------------------------------------------------
% Private functions
% -------------------------------------------------------------------------
function opt_stats_ind = get_opt_stats_ind(stats, n_par, classification)

switch n_par
    
    case 1
        if classification
            opt_stats = max(stats);
        else
            opt_stats = min(stats);
        end
        
        ind = find(stats == opt_stats);
        if length(ind)>1
            try % if user has the image processing toolbox
                accmap = zeros(size(stats));
                accmap(ind) = 1;
                [L,nconn] = bwlabel(accmap);
                stats = regionprops(L,{'centroid','area'});
                maxar = stats(1).Area;
                for i = 2:nconn
                    if stats(i).Area>maxar
                        maxar = stats(i).Area;
                        indmax = i;
                    end
                end
                opt_stats_ind = floor(stats(indmax).Centroid(1));
            catch
                iopt = floor(median(1:length(ind)));
                opt_stats_ind = ind(iopt);
            end
        else % if only one maximum, report it
            opt_stats_ind = ind;
        end
        
%         opt_stats_ind = ind(1);
%         opt_stats_ind = round(median(ind));
        
    case 2
        if classification
            opt_stats = max(max(stats));
        else
            opt_stats = min(min(stats));
        end
        
        [ind_c, ind_mu] = find(stats==opt_stats);
        indopt = find(stats==opt_stats);
        
        if length(indopt)>1
            try % if user has the image processing toolbox
                accmap = zeros(size(stats));
                accmap(indopt) = 1;
                [L,nconn] = bwlabel(accmap);
                stats = regionprops(L,{'centroid','area'});
                maxar = stats(1).Area;
                indmax = 1;
                for i = 2:nconn
                    if stats(i).Area>maxar
                        maxar = stats(i).Area;
                        indmax = i;
                    end
                end
                opt_stats_ind(1) = floor(stats(indmax).Centroid(2));
                opt_stats_ind(2) = floor(stats(indmax).Centroid(1));
            catch
                iopt = floor(median(1:length(indopt)));
                opt_stats_ind(1) = ind_c(iopt);
                opt_stats_ind(2) = ind_mu(iopt);
            end
        else % if only one maximum, report it
            opt_stats_ind(1) = ind_c;
            opt_stats_ind(2) = ind_mu;
        end
        
        
%         opt_stats_ind(1) = ind_c(1); %smallest value
%         opt_stats_ind(2) = ind_mu(1);
        
%         opt_stats_ind(1) = round(median(ind_c));
%         opt_stats_ind(2) = round(median(ind_mu));
        
    otherwise
        error('The number of parameters to optimise must be <=2')
end


end
