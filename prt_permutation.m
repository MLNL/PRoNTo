function [] = prt_permutation(PRT, n_perm, modelid, path)
% Function to compute permutation test
%
% Inputs:
% -------
% PRT: PRT structured including model
% n_permu: number of permutations
% modelid: model ID
%
% Outputs:
% --------
%
% for classification
% permutation.c_acc: Permuted accuracy per class
% permutation.b_acc: Permuted balanced accuracy
% permutation.pvalue_b_acc: p-value for c_acc
% permutation.pvalue_c_acc: p-value for b_acc
%
% for regression
% permutation.corr: Permuted correlation
% permutation.mse: Permuted mean square error
% permutation.corr: p-value for corr
% permutation.mse: p-value for mse
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Mourao-Miranda
% $ID: $

prt_dir = [path];

% % prt_dir = char(regexprep(in.fname,'PRT.mat', ''));

if ~isfield(PRT,'model')
    beep
    disp('No model found in this PRT.mat');
    return
else
    if ~isfield(PRT.model,'output')
        beep
        disp('No model output found in this PRT.mat')
        return
        
    end
    
    % configure some variables
    CV       = PRT.model(modelid).input.cv_mat;     % CV matrix
    n_folds  = size(CV,2);                      % number of CV folds
    n_Phi    = length(PRT.model(modelid).input.fs); % number of data matrices
    samp_idx = PRT.model(modelid).input.samp_idx;   % which samples are in the model
    
    
    % targets
    t = PRT.model(modelid).input.targets;
    
    % load data files and configure ID matrix
    Phi_all = cell(1,n_Phi);
    for i = 1:size(PRT.fs,1)
        if i == 1
            ID = PRT.fs(i).id_mat(PRT.model(modelid).input.samp_idx,:);
        end
        
        if PRT.model(modelid).input.use_kernel
            load(fullfile(prt_dir, PRT.fs(i).k_file));
            Phi_all{i} = Phi(samp_idx,samp_idx);
        else
            error('training with features not implemented yet');
            % this should be improved (e.g. need to load feat_idx)
            vname = whos('-file', [prt_dir,PRT.fs(fid).fs_file]);
            eval(['Phi_all{',num2str(i),'}=',vname,'(samp_idx,:);']);
        end
        
    end
    
    
    % Find chunks in the data (e.g. temporal correlated samples)
    % -------------------------------------------------------------------------
    
    ids = PRT.fs.id_mat(PRT.model(modelid).input.samp_idx,:);
    i=1;
    samp_g=unique(ids(:,1));%number of groups
    for gid = 1: length(samp_g)
        
        samp_s=unique(ids(ids(:,1)==samp_g(gid),2)); %number of subjects for specific group
        
        for sid = 1: length(samp_s)
            
            samp_m=unique(ids(ids(:,1)==samp_g(gid) & ids(:,2)==samp_s(sid),3)); %number of modality for specific group & subject
            
            for mid = 1:length(samp_m)
                
                samp_c=unique(ids(ids(:,1)==samp_g(gid) & ids(:,2)==samp_s(sid) & ids(:,3)==samp_m(mid),4)); %number of conditions for specific group & subject & modality
                
                for cid = 1:length(samp_c)
                    
                    samp_b=unique(ids(ids(:,1)==samp_g(gid) & ids(:,2)==samp_s(sid) & ids(:,3)==samp_m(mid) & ids(:,4)==samp_c(cid),5));  %number of blocks for specific group & subject & modality & conditions
                    
                    for bid = 1:length(samp_b)
                        
                        rg = find((ids(:,1) == samp_g(gid)) & ...
                            (ids(:,2) == samp_s(sid)) & ...
                            (ids(:,3) == samp_m(mid)) & ...
                            (ids(:,4) == samp_c(cid)) & ...
                            (ids(:,5) == samp_b(bid)));
                        
                        chunks{i} =rg;
                        
                        i=i+1;
                    end
                end
            end
        end
    end
    
    
    % Initialize counts
    % -------------------------------------------------------------------------
    switch PRT.model(modelid).output.fold(1).type
        case 'classifier'
            n_class = length(PRT.model(modelid).output.fold(1).stats.c_acc);
            total_greater_c_acc = zeros(n_class,1);
            total_greater_b_acc = 0;
            
        case 'regression'
            total_greater_corr = 0;
            total_greater_mse = 0;
    end
    
    % Run model with permuted labels
    % -------------------------------------------------------------------------
    
    for p=1:n_perm
        
        % permute labels
        chunkperm=randperm(length(chunks));
        for i=1:length(chunks)
            t(chunks{i},1)= unique(PRT.model(modelid).input.targets(chunks{chunkperm(i)}));
        end
        
        %t=PRT.model(modelid).input.targets(randperm(length(PRT.model(modelid).input.targets))); %this should take into account the correlation structure
        
        
        for f = 1:n_folds
            % configure training and test indices
            tr_idx = CV(:,f) == 1;
            te_idx = CV(:,f) == 2;
            
            [Phi_tr, Phi_te, Phi_tt] = ...
                split_data(Phi_all, tr_idx, te_idx, PRT.model(modelid).input.use_kernel);
            
            %Centre kernel
            %[Phi_tr, Phi_te, Phi_tt] = prt_centre_kernel(Phi_tr, Phi_te, Phi_tt);
            
            % Assemble data structure to supply to machine
            cvdata.train      = Phi_tr;
            cvdata.test       = Phi_te;
            if PRT.model(modelid).input.use_kernel
                cvdata.testcov    = Phi_tt;
            end
            cvdata.tr_targets = t(tr_idx,:);
            cvdata.te_targets = t(te_idx,:);
            cvdata.tr_id      = ID(tr_idx,:);
            cvdata.te_id      = ID(te_idx,:);
            cvdata.use_kernel = PRT.model(modelid).input.use_kernel;
            cvdata.pred_type  = PRT.model(modelid).input.type;
            % additional parameters (e.g. for MCKR)
            cvdata.tr_param  = prt_cv_opt_param(PRT, ID(tr_idx,:), CV(tr_idx,f));
            cvdata.te_param  = prt_cv_opt_param(PRT, ID(te_idx,:), CV(te_idx,f));
            
            % Apply any operations specified
            ops = PRT.model(modelid).input.operations(PRT.model(modelid).input.operations ~=0 );
            for o = 1:length(ops)
                cvdata = prt_apply_operation(PRT, cvdata, ops(o));
            end
            
            % train the prediction model
            temp_model = prt_machine(cvdata, PRT.model(modelid).input.machine);
            model.output.fold(f).targets     = cvdata.te_targets;
            model.output.fold(f).predictions = temp_model.predictions;
            
            
            
        end
        
        %Model level statistics
        t=[model.output.fold(:).targets];
        m.type=PRT.model(modelid).output.fold(1).type;
        m.predictions=[model.output.fold(:).predictions];
        m.predictions=m.predictions(:);
        t=t(:);
        perm_stats=prt_stats(m,t,'model');
        %permutation.perm_stats(p)=stats;
        %end
        
        switch PRT.model(modelid).output.fold(1).type
            
            case 'classifier'
                
                permutation.b_acc(p)=perm_stats.b_acc;
                n_class = length(PRT.model(modelid).output.fold(1).stats.c_acc);
                
                if (perm_stats.b_acc > PRT.model.output.stats.b_acc)
                    total_greater_b_acc=total_greater_b_acc+1;
                end
                
                for c=1:n_class
                    permutation.c_acc(c,p)=perm_stats.c_acc(c);
                    if (perm_stats.c_acc(c) > PRT.model(modelid).output.stats.c_acc(c))
                        total_greater_c_acc(c)=total_greater_c_acc(c)+1;
                    end
                end
                
            case 'regression'
                permutation.corr(p)=perm_stats.corr;
                if (perm_stats.corr > PRT.model(modelid).output.stats.corr)
                    total_greater_corr=total_greater_corr+1;
                end
                permutation.mse(p)=perm_stats.mse;
                if (perm_stats.mse < PRT.model(modelid).output.stats.mse)
                    total_greater_mse=total_greater_mse+1;
                end
                
                
        end
        
        
        
        
        
    end
    
    
    switch PRT.model(modelid).output.fold(1).type
        case 'classifier'
            
            pval_b_acc = total_greater_b_acc / n_perm;
            if pval_b_acc == 0
                pval_b_acc = 1./n_perm;
            end
            
            pval_c_acc=zeros(n_class,1);
            for c=1:n_class
                pval_c_acc(c) = total_greater_c_acc(c) / n_perm;
                if pval_c_acc(c) == 0
                    pval_c_acc(c) = 1./n_perm;
                end
            end
            
            permutation.pvalue_b_acc = pval_b_acc;
            permutation.pvalue_c_acc = pval_c_acc;
            
        case 'regression'
            
            pval_corr = total_greater_corr / n_perm;
            if pval_corr == 0
                pval_corr = 1./n_perm;
            end
            
            pval_mse = total_greater_mse / n_perm;
            if pval_mse == 0
                pval_mse = 1./n_perm;
            end
            
            permutation.pval_corr = pval_corr;
            permutation.pval_mse = pval_mse;
            
            
    end
    
    
    
    %update PRT
    PRT.model(modelid).output.stats.permutation = permutation;
    
    % Save PRT containing machine output
    % -------------------------------------------------------------------------
    outfile = fullfile(path,'PRT.mat');
    disp('Updating PRT.mat.......>>')
    if spm_matlab_version_chk('7') >= 0
        save(outfile,'-V6','PRT');
    else
        save(outfile,'PRT');
    end
    disp('Permutation test done.')
end

end
% -------------------------------------------------------------------------
% Private functions
% -------------------------------------------------------------------------

function [Phi_tr Phi_te Phi_tt] = split_data(Phi_all, tr_idx, te_idx, usebf)
% function to split the data matrix into training and test

n_mat = length(Phi_all);

% training
Phi_tr = cell(1,n_mat);
for i = 1:n_mat;
    if usebf
        cols_tr = tr_idx;
    else
        cols_tr = size(Phi_all{i},2);
    end
    
    Phi_tr{i} = Phi_all{i}(tr_idx,cols_tr);
end

% test
Phi_te  = cell(1,n_mat);
Phi_tt = cell(1,n_mat);
if usebf
    cols_tr = tr_idx;
    cols_te = te_idx;
else
    cols_tr = size(Phi_all{i},2);
    %cols_te = size(Phi_all{i},2);
end

for i = 1:length(Phi_all)
    Phi_te{i} = Phi_all{i}(te_idx, cols_tr);
    if usebf
        Phi_tt{i} = Phi_all{i}(te_idx, cols_te);
    else
        Phi_tt{i} = [];
    end
end
end
