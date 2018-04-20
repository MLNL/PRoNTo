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

% Written by J.M. Monteiro and J. Schrouff
% $Id$


% Set flag
use_nested_cv = PRT.model(in.mid).input.use_nested_cv;
if use_nested_cv == false
    error('prt_nested_cv function called with use_nested_cv = false');
end

if ~isfield(in,'opt_Rep')
    opt_Rep = 0;
else
    opt_Rep = in.opt_Rep;
end

% Set range of the hyper parameters
switch PRT.model(in.mid).input.machine.function
    case {'prt_machine_svm_bin','prt_machine_sMKL_cla','prt_machine_krr', 'prt_machine_sMKL_reg','prt_machine_L1svm'}
        if ~isempty(PRT.model(in.mid).input.nested_param)
            par = PRT.model(in.mid).input.nested_param;
        else
            d1 = -2 : 3;
            par = 10 .^(d1);
        end
    case {'prt_machine_wip_cla','prt_machine_GMKL_cla'}
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
        if ~isempty(PRT.model(in.mid).input.nested_param)
            par = PRT.model(in.mid).input.nested_param;
        else
            error('Machine not currently supported for nested CV');
        end
        
end

% Gather task info:
% Multiple tasks?
if isfield(in,'midMTL')
    MTLflag = 1;
    in = gather_task_info_MTL(PRT,in);
    nt = numel(in.midMTL);
    nfolds = size(in.CV{1},2);
else
    MTLflag = 0;
    in = gather_task_info_STL(PRT,in);
    nfolds = size(in.CV, 2);
end

out.param = par;
stats_vec = zeros(1, size(par, 2));
cosang = zeros(1,size(par, 2));

% If string parameters were entered for the machine, gather them before
% adding the nested parameter to optimize. This assumes that the last
% string corresponds to which parameter to optimize!
if ~ isempty(PRT.model(in.mid).input.machine.args) && ...
        ischar(PRT.model(in.mid).input.machine.args)
    stringpar = PRT.model(in.mid).input.machine.args;
else
    stringpar = [];
end

% compute model performance based on hyper-parameter range
for i = 1:size(par, 2)
    
    switch PRT.model(in.mid).input.machine.function
        case {'prt_machine_svm_bin','prt_machine_sMKL_cla',...
                'prt_machine_L1svm'}
            if ~isempty(stringpar)    
                PRT.model(in.mid).input.machine.args = [stringpar, num2str(par(i))];
            else
                PRT.model(in.mid).input.machine.args = par(i);
            end
            m.type = 'classifier';
            
        case {'prt_machine_krr', 'prt_machine_sMKL_reg'}
            if ~isempty(stringpar)    
                PRT.model(in.mid).input.machine.args = [stringpar, num2str(par(i))];
            else
                PRT.model(in.mid).input.machine.args = par(i);
            end
            m.type = 'regression';
            
        case {'prt_machine_wip_cla','prt_machine_GMKL_cla'}
            if ~isempty(stringpar)    
                disp('Using default parameters for EN-MKL')
            end
            PRT.model(in.mid).input.machine.args = par(:,i)';
            m.type = 'classifier';
            
        otherwise
            try
                if ~isempty(stringpar)    
                    PRT.model(in.mid).input.machine.args = [stringpar, num2str(par(i))];
                else
                    PRT.model(in.mid).input.machine.args = par(i);
                end
                if strcmpi(PRT.model(in.mid).input.type,'classification')
                    m.type = 'classifier';
                elseif strcmpi(PRT.model(in.mid).input.type,'regression')
                    m.type = PRT.model(in.mid).input.type;
                end
            catch
                error('Machine not currently supported for nested CV');
            end
    end
    
    % compute the model for each fold of the inner CV
    for f = 1:nfolds
        
        fold.ID      = in.ID;
        if MTLflag
            for t=1:nt        
                fold.CV{t}      = in.CV{t}(:,f);
            end
            fold.midMTL = in.midMTL;
        else
            fold.CV      = in.CV(:,f);
        end
        fold.Phi_all = in.Phi_all;
        fold.t       = in.t;
        fold.mid     = in.mid;
        if isfield(in, 'cov') 
            if ~MTLflag && ~ isempty(in.cov)
                fold.cov     = in.cov;
            else
                for t=1:nt
                    if ~isempty(in.cov{t})
                        fold.cov{t} = in.cov{t};
                    end
                end
            end
        end

        [model, targets] = prt_cv_fold(PRT,fold);
        
        %for classification check that for each fold, the test targets have been trained
        if strcmpi(PRT.model(in.mid).input.type,'classification')
            if ~MTLflag && ~all(ismember(unique(targets.test),unique(targets.train)))
                beep
                disp('At least one class is in the test set but not in the training set')
                disp('Abandoning modelling, please correct class selection/cross-validation')
                return
            elseif MTLflag
                for t=1:nt
                    if ~all(ismember(unique(targets.test{t}),unique(targets.train{t})))
                        beep
                        disp(['At least one class is in the test set but not in the training set for task ',num2str(t)])
                        disp('Abandoning modelling, please correct class selection/cross-validation')
                        return
                    end
                end 
            end
        end
        
        % Compute stats
        model.type = m.type;
        stats = prt_stats(model, targets.test, in.nc);
        f_stats(f).targets     = targets.test;
        f_stats(f).predictions = model.predictions;
        f_stats(f).stats       = stats;
        if isfield(model,'beta') && ~isempty(model.beta)
            f_stats(f).beta = model.beta;
        end
        
        
    end
    
%     % Model level statistics (across folds)
%     ttt           = vertcat(f_stats(:).targets);
%     m.predictions = vertcat(f_stats(:).predictions);
%     tstats         = prt_stats(m, ttt(:), in.nc);
    % Model statistics, averaged across folds
    fnamestats = fieldnames(stats);
    tstats = struct;
    if ismember('task_stats',fnamestats)
        its = ismember(fnamestats,'task_stats');
        fnamestats = fnamestats(~its);
    end
    for s=1:length(fnamestats)
        size_stats = size(stats.(fnamestats{s}));
        val = zeros(prod(size_stats),nfolds);
        for j = 1:nfolds
            val(:,j) = f_stats(j).stats.(fnamestats{s})(:);
        end
        av_stats = reshape(nanmean(val,2),size_stats);
        tstats = setfield(tstats,fnamestats{s},av_stats);
    end
    % If classifier, get confusion matrix globally
     if strcmpi(m.type,'classifier') && ~MTLflag
         ttt             = vertcat(f_stats(:).targets);
         m.predictions   = vertcat(f_stats(:).predictions);
         %m.func_val    = [PRT.model(mid).output.fold(:).func_val];
         temp_stats         = prt_stats(m,ttt(:),in.nc);
         tstats.con_mat = temp_stats.con_mat;
     end
    
    % Reproducibility of the weights if MKL
    if isfield(f_stats,'beta') && opt_Rep
%         cosang(i) = compute_reproducibility_ER(f_stats);
        cosang(i) = compute_reproducibility_betas(f_stats);
    end
    
    switch PRT.model(in.mid).input.type
        case 'classification'
            stats_vec(i) = tstats.b_acc;
        case 'regression'
            stats_vec(i) = tstats.nmse;
        otherwise
            error('Type of model not recognised');
    end
    
    
end

% For now, only parameter optimisation. Add flag for feature selection
% Get optimal parameter


if strcmp(PRT.model(in.mid).input.machine.function, 'prt_machine_wip_cla') || ...
        strcmp(PRT.model(in.mid).input.machine.function, 'prt_machine_GMKL_cla')
    
    % Reshape the stats vector into a matrix
    stats_mat = reshape(stats_vec, length(unique(par(2,:))), length(unique(par(1,:))))';
    
    cos_mat = reshape(cosang, length(unique(par(2,:))), length(unique(par(1,:))))';
    if opt_Rep && isfield(f_stats,'beta')        
        w1=1;
        w2=1;
    else
        w1=1;
        w2=0;
    end
    
    switch PRT.model(in.mid).input.type
        case 'classification'
            % Find max
            st = (stats_mat*w1 + cos_mat*w2) / (w1+w2);
            opt_stats_ind = get_opt_stats_ind(st, 2, true);
        case 'regression'
            % Find min
            st = (stats_mat*w1 + (1-cos_mat)*w2) / (w1+w2);
            opt_stats_ind = get_opt_stats_ind(st, 2, false);
    end
    c_max = c(opt_stats_ind(1));
    mu_max = mu(opt_stats_ind(2));
    
    out.opt_param = [c_max, mu_max];
    out.vary_param = stats_mat;
    out.vary_cos = cos_mat;
    
else
    
    if opt_Rep && isfield(f_stats,'beta')
        w1=0;
        w2=1;
    else
        w1=1;
        w2=0;
    end
    
    switch PRT.model(in.mid).input.type
        case 'classification'
            st = (stats_vec*w1 + cosang*w2) / (w1+w2);
            opt_stats_ind = get_opt_stats_ind(st, 1, true);
        case 'regression'
            st = (stats_vec*w1 + (1-cosang)*w2) / (w1+w2);
            opt_stats_ind = get_opt_stats_ind(st, 1, false);
        otherwise
            error('Type of model not recognised');
    end
    
    par_opt = par(opt_stats_ind);
    
    out.opt_param = par_opt;
    out.vary_param = stats_vec;
    out.vary_cos = cosang;
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
                if nconn>1
                    for i = 2:nconn
                        if stats(i).Area>maxar
                            maxar = stats(i).Area;
                            indmax = i;
                        end
                    end
                else
                    indmax = 1;
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

function [in] = gather_task_info_STL(PRT,in)

% Set flag
use_nested_cv = PRT.model(in.mid).input.use_nested_cv;

train_entries = find(in.CV == 1);
in.ID      = in.ID(train_entries, :);
in.t       = in.t(train_entries);
% in.fs      = PRT.fs;
if isfield(in, 'cov') && ~isempty(in.cov)
    in.cov     = in.cov(train_entries,:);
end
if isfield(PRT.model(in.mid).input,'cv_type_nested')
    in.cv.type = PRT.model(in.mid).input.cv_type_nested;
    in.cv.k = PRT.model(in.mid).input.cv_k_nested;
else
    in.cv.type = PRT.model(in.mid).input.cv_type;
    in.cv.k = PRT.model(in.mid).input.cv_k;
end

for i=1:length(in.Phi_all)
    if PRT.model(in.mid).input.use_kernel %Kernel method
        in.Phi_all{i} = in.Phi_all{i}(train_entries, train_entries);
    else %Non-kernel
        in.Phi_all{i} = in.Phi_all{i}(train_entries, :);
    end
end
% generate new CV matrix
in.CV = prt_compute_cv_mat(PRT, in, in.mid, use_nested_cv);
end

function [in] = gather_task_info_MTL(PRT,in)

n_tasks = length(in.midMTL);
% Set flag
use_nested_cv = PRT.model(in.mid).input.use_nested_cv;
m = in.midMTL;

for t=1:n_tasks    
    train_entries = find(in.CV{t} == 1);
    in.ID{t}      = in.ID{t}(train_entries, :);
    in.t{t}       = in.t{t}(train_entries);
    if isfield(in, 'cov') && ~isempty(in.cov{t})
        in.cov{t}     = in.cov{t}(train_entries,:);
    end
    if isfield(PRT.model(m(t)).input,'cv_type_nested')
        in.cv.type = PRT.model(m(t)).input.cv_type_nested;
        in.cv.k = PRT.model(m(t)).input.cv_k_nested;
    else
        in.cv.type = PRT.model(m(t)).input.cv_type;
        in.cv.k = PRT.model(m(t)).input.cv_k;
    end
    
    if PRT.model(in.mid).input.use_kernel %Kernel method
        in.Phi_all{t} = in.Phi_all{t}(train_entries, train_entries);
    else %Non-kernel
        in.Phi_all{t} = in.Phi_all{t}(train_entries, :);
    end

    % generate new CV matrix
    nested.ID = in.ID{t};
    nested.t = in.t{t};
    nested.cv = in.cv;
    if isfield(in,'class')
        nested.class = in.class{t};
    end
    in.CV{t} = prt_compute_cv_mat(PRT, nested, m(t), use_nested_cv);
end
end

function [cosang] = compute_reproducibility_ER(betas)
% Compute 'reproducibility' value from MKL beta weights


% Compute Expected Ranking for model
erwn=zeros(numel(betas(1).beta),length(betas));
for fold = 1:length(betas)
    w_all =[betas(fold).beta]'*100;
    %take 0 columns out of the computation
    mw = min(w_all);
    mxw = max(w_all);
    id0 = find(mw==mxw);
    id0 = id0(mw(id0)==0);
    id = 1:size(w_all,2);
    idtr = setdiff(id,id0);
    if isempty(idtr)   % if a modality has always 0 weights
        erwn=NaN*ones(length(w_all),1);
    else
        w_all = w_all(:,idtr);
        %deal with NaNs
        [d1,d2]=sort(w_all,1,'ascend');
        isn=find(isnan(w_all(:,1)));
        d3=size(d1,1)-length(isn)+1:size(d1,1);
        d4=1:size(d1,1)-length(isn);
        ihn=[d2(d3,:);d2(d4,:)];
        [d1,dwn]=sort(ihn);
        dwn(isn)=0;
        isnu=find((w_all(:,1)==0));
        dwn(isnu)=0;
        erwn(:,fold) = dwn;
%         for i=1:size(w_all,1)
%             for j=1:size(w_all,1)
%                 tmp=length(find(dwn(i,1:end)==j));
%                 erwn(i,fold)=erwn(i,fold)+j*tmp;
%             end
%         end
%         erwn(:,fold)=erwn(:,fold)/length(idtr);
    end   
end

mer = mean(erwn,2);

cosang =zeros(size(erwn,2),1);
for i = 1:length(cosang)
    cosang(i) = (erwn(:,i)'*mer)/ (norm(erwn(:,i)) * norm(mer));
end
cosang = mean(cosang);

end

function [cosang] = compute_reproducibility_betas(betas)
% Compute 'reproducibility' value from MKL beta weights


% Extract beta values for each fold
erwn=zeros(numel(betas(1).beta),length(betas));
for fold = 1:length(betas)
    erwn(:,fold) =[betas(fold).beta]';
end

mer = mean(erwn,2);

%Compute reproducibility for model
cosang =zeros(size(erwn,2),1);
for i = 1:length(cosang)
    cosang(i) = (erwn(:,i)'*mer)/ (norm(erwn(:,i)) * norm(mer));
end
cosang = mean(cosang);

end
