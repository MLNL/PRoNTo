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
% $Id$

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
    for i = 1:length(PRT.model(modelid).input.fs)
        if i == 1
            ID = PRT.fs(i).id_mat(PRT.model(modelid).input.samp_idx,:);
        end
        fid=find(strcmp({PRT.fs(:).fs_name},PRT.model(modelid).input.fs(i).fs_name));
        
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
    
    ids = PRT.fs(fid).id_mat(PRT.model(modelid).input.samp_idx,:);
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
        
        disp(sprintf('Permutation %d out of %d >>>>>>',p,n_perm));
        
        % permute labels
        chunkperm=randperm(length(chunks));
        for i=1:length(chunks)
            t(chunks{i},1)= unique(PRT.model(modelid).input.targets(chunks{chunkperm(i)}));
        end
        
        for f = 1:n_folds
            % configure data structure for prt_cv_fold
            fdata.ID      = ID;
            fdata.mid     = modelid;
            fdata.CV      = CV(:,f);
            fdata.Phi_all = Phi_all;
            fdata.t       = t;
            
            [temp_model, targets] = prt_cv_fold(PRT,fdata);
            
            model.output.fold(f).predictions = temp_model.predictions;
            model.output.fold(f).targets     = targets.test;
            
        end
        
        % Model level statistics (across folds)
        t             = vertcat(model.output.fold(:).targets);
        m.type        = PRT.model(modelid).output.fold(1).type;
        m.predictions = vertcat(model.output.fold(:).predictions);
        perm_stats         = prt_stats(m,t,t);
        
        
        switch PRT.model(modelid).output.fold(1).type
            
            case 'classifier'
                
                permutation.b_acc(p)=perm_stats.b_acc;
                n_class = length(PRT.model(modelid).output.fold(1).stats.c_acc);
                
                if (perm_stats.b_acc > PRT.model(modelid).output.stats.b_acc)
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
                if (abs(perm_stats.corr) > abs(PRT.model(modelid).output.stats.corr))
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
