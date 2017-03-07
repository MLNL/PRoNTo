function [] = prt_permutation(PRT, n_perm, modelid, path, flag)
% Function to compute permutation test
%
% Inputs:
% -------
% PRT:     PRT structure including model
% n_perm:  number of permutations
% modelid: model ID for model to test and model to copy permutations from
%         (optional). Can hence be of size 1x1 or 1x2.
% path:    path
% flag:    boolean variable. set to 1 to save the outputs for each
%          permutation. default: 0
%
% Outputs:
% --------
%
% for classification
% permutation.c_acc:        Permuted accuracy per class
% permutation.b_acc:        Permuted balanced accuracy
% permutation.pvalue_b_acc: p-value for c_acc
% permutation.pvalue_c_acc: p-value for b_acc
%
% for regression
% permutation.corr: Permuted correlation
% permutation.mse:  Permuted mean square error
% permutation.pval_corr: p-value for corr
% permutation.pval_r2: p-value for r2;
% permutation.pval_mse:  p-value for mse
% permutation.pval_nmse:  p-value for nmse
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Mourao-Miranda, modified by J. Schrouff
% $Id$

prt_dir = path;
def_par = prt_get_defaults('paral');
if nargin<5
    flag=0;
end

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
    CV       = PRT.model(modelid(1)).input.cv_mat;     % CV matrix
    n_folds  = size(CV,2);                      % number of CV folds
    
    % parralel code?
    if def_par.allow
        try
            matlabpool(def_par.ncore)
        catch
            try
                parpool(def_par.ncore)
            catch
                warning('Could not use pool of Matlab processes!')
            end
        end
    end
    
    % targets
    t = PRT.model(modelid(1)).input.targets;
    
    % load data files and configure ID matrix
    if ~isfield(PRT.model(modelid(1)).input,'indmodels')
        indmodels = 0;
    else
        indmodels = PRT.model(modelid(1)).input.indmodels;
    end
    [Phi_all,ID,fid] = prt_getKernelModel(PRT,prt_dir,modelid(1),indmodels);
    
    %get number of classes
    if strcmpi(PRT.model(modelid(1)).input.type,'classification')
        nc=max(unique(t));
    else
        nc=[];
    end
    fdata.nc = nc;
    fdata.class   = PRT.model(modelid(1)).input.class;
    
    % Initialize counts
    % -------------------------------------------------------------------------
    switch PRT.model(modelid(1)).output(1).fold(1).type
        case 'classifier'
            n_class = length(PRT.model(modelid(1)).output(1).fold(1).stats.c_acc);
            total_greater_c_acc = zeros(n_class,1);
            total_greater_b_acc = 0;
            
        case 'regression'
            total_greater_corr = 0;
            total_greater_mse = 0;
            total_greater_nmse = 0;
            total_greater_r2 = 0;
    end
    
    % Run model with permuted labels
    % -------------------------------------------------------------------------
    if indmodels %loop over the kernels and output accuracy for each kernel only
        nk = length(Phi_all);
    else
        nk = 1;
    end
    
    % For each model
    flag_use_perms = 0;
    ids = PRT.fs(fid).id_mat(PRT.model(modelid(1)).input.samp_idx,:);
    for k = 1:nk
        if nk>1
            disp([' > Computing permutations for model: ',num2str(k),' of ',num2str(nk),' ...'])
        end
        if ~isfield(PRT.model(modelid(1)).output(k),'permutation') || ...
                (isfield(PRT.model(modelid(1)).output(k),'permutation') && flag) %Back to empty to save other perm param
            PRT.model(modelid(1)).output(k).permutation=struct('fold',[],...
                'perm_stats',[],'perm_mat',[]);
            if length(modelid) == 2 % model specified to copy permutations from
                if isfield(PRT.model(modelid(2)).output(1),'permutation') &&...
                        isfield(PRT.model(modelid(2)).output(1).permutation,'perm_mat')
                    if length(PRT.model(modelid(2)).output(1).permutation(1).perm_mat) == size(ids,1)
                        if length(PRT.model(modelid(2)).output(1).permutation) ~= n_perm
                            fprintf('Number of permutations %d replaced by number of permutations in model %s',n_perm,PRT.model(modelid(2)).model_name)
                            n_perm = length(PRT.model(modelid(2)).output(1).permutation);
                        end
                        flag_use_perms = 1;
                    else
                        warning('prt_permutation:CannotCopyPermutations',...
                            'Number of selected samples is not consistent between the 2 models to compare')
                        disp('Performing permutations without copying from selected model')
                    end
                end
            end
        end
        
        fprintf(['Permutation (out of %d):',repmat(' ',1,ceil(log10(n_perm))),'%d'],n_perm, 1);
        for p=1:n_perm
            
            % Counter of permutations to be updated
            if p>1
                for idisp = 1:ceil(log10(p)) % delete previous counter display
                    fprintf('\b');
                end
                fprintf('%d',p);
            end
            
            CVperm = zeros(size(CV));
            t_perm = zeros(length(t),1);
            IDperm = zeros(size(ID));
            
            % Find chunks in the data (e.g. temporal correlated samples)
            % -------------------------------------------------------------------------
            
            samp_g=unique(ids(:,1));%number of groups
            
            for gid = 1: length(samp_g)
                
                samp_s=unique(ids(ids(:,1)==samp_g(gid),2)); %number of subjects for specific group
                
                for sid = 1: length(samp_s)
                    
                    samp_m=unique(ids(ids(:,1)==samp_g(gid) & ids(:,2)==samp_s(sid),3)); %number of modality for specific group & subject
                    
                    for mid = 1:length(samp_m)
                        
                        samp_c=unique(ids(ids(:,1)==samp_g(gid) & ids(:,2)==samp_s(sid) & ids(:,3)==samp_m(mid),4)); %number of conditions for specific group & subject & modality
                        
                        ism = find((ids(:,1) == samp_g(gid)) & ...
                            (ids(:,2) == samp_s(sid)) & ...
                            (ids(:,3) == samp_m(mid)));
                        
                        % Multiple images and conditions in the modality, across the
                        % multiple targets: Need to permute within subject
                        % and modality
                        if (strcmpi(PRT.model(modelid(1)).output(1).fold(1).type,'classifier') && ...
                                numel(samp_c)>1 && numel(ism)>numel(samp_c) && length(unique(t(ism)))>1 ) ||... % i.e. there is a design and more than one image per subject in classification
                                (strcmpi(PRT.model(modelid(1)).output(1).fold(1).type,'regression') && ...
                                numel(ism)>1 && all(samp_c~=0))  % i.e. there is more than one image for this subject, coming from a design
                            exchange_subjects = 0;
                            Acrossmod = 0;
                        % Multiple images in the modality, but only one
                        % target: Need to permute within subject but across
                        % modalities
                        elseif strcmpi(PRT.model(modelid(1)).output(1).fold(1).type,'classifier') && ...
                                (numel(samp_c)==1 || length(unique(t(ism)))==1)
                            exchange_subjects = 0;
                            Acrossmod = 1;
                        % Other cases: Typically one image per subject 
                        % selected for model, need to permute across subjects
                        else 
                            exchange_subjects = 1;
                        end
                        if ~ exchange_subjects
                            if ~Acrossmod || (Acrossmod && mid == 1)
                                chunks = {};
                                i=1;
                                offrg = 0;
                            end
                            
                            for cid = 1:length(samp_c)
                                
                                samp_b=unique(ids(ids(:,1)==samp_g(gid) & ids(:,2)==samp_s(sid) & ids(:,3)==samp_m(mid) & ids(:,4)==samp_c(cid),5));  %number of blocks for specific group & subject & modality & conditions
                                
                                for bid = 1:length(samp_b)
                                    
                                    rg = find((ids(ism,4) == samp_c(cid)) & ...
                                        (ids(ism,5) == samp_b(bid)));
                                    
                                    chunks{i} = rg'+offrg;
                                    
                                    i=i+1;
                                end
                            end
                            offrg = max(rg);

                            if ~ Acrossmod
                                if ~flag_use_perms
                                    chunkperm=randperm(numel(chunks));
                                else
                                    chunkperm = PRT.model(modelid(2)).output(k).permutation(p).perm_mat;
                                end
                                chunkpermcv = [];
                                for i=1:length(chunks)
                                    chunkpermcv = [chunkpermcv; chunks{chunkperm(i)}'];  % get permuted indexes for each image in the chunk
                                end
                                pchunk = cell2mat(chunks); % get the permuted indexes for each image in the subject and modality
                                t_perm(ism(pchunk))   = t(ism(chunkpermcv));
                                CVperm(ism(pchunk),:) = CV(ism(chunkpermcv),:); % permute the CV lines corresponding to the subject and modality
                                IDperm(ism(pchunk),:) = ID(ism(chunkpermcv),:); % permute the ID lines corresponding to the subject and modality (for sample averaging)
                            end
                        end
                    end
                    if Acrossmod
                        if ~flag_use_perms
                            chunkperm=randperm(numel(chunks));
                        else
                            chunkperm = PRT.model(modelid(2)).output(k).permutation(p).perm_mat;
                        end
                        iss = find((ids(:,1) == samp_g(gid)) & ...
                            (ids(:,2) == samp_s(sid)));
                        chunkpermcv = [];
                        for i=1:length(chunks)
                            chunkpermcv = [chunkpermcv; chunks{chunkperm(i)}'];  % get permuted indexes for each image in the chunk
                        end
                        pchunk = cell2mat(chunks); % get the permuted indexes for each image in the subject and modality
                        t_perm(iss(pchunk)) = t(iss(chunkpermcv));
                        CVperm(iss(pchunk),:) = CV(iss(chunkpermcv),:); % permute the CV lines corresponding to the subject and modality
                        IDperm(iss(pchunk),:) = ID(iss(chunkpermcv),:); % permute the ID lines corresponding to the subject and modality (for sample averaging)
                    end
                end
            end
            if exchange_subjects % Permute the subjects based on their structure
                i = 1;
                samp_g=unique(ids(:,1));%number of groups
                for gid = 1: length(samp_g) 
                    samp_s=unique(ids(ids(:,1)==samp_g(gid),2)); %number of subjects for specific group
                    for sid = 1: length(samp_s)
                        chunks{i} = find(ids(:,1)==gid & ids(:,2)==sid); % get all the images for this subject
                        i = i+1;
                    end
                end
                if ~flag_use_perms
                    chunkperm=randperm(numel(chunks));
                else
                    chunkperm = PRT.model(modelid(2)).output(k).permutation(p).perm_mat;
                end
                for i=1:length(chunks)
                    chunkpermcv = [chunkpermcv; chunks{chunkperm(i)}'];  % get permuted indexes for each image in the chunk
                end
                pchunk = cell2mat(chunks);
                CVperm(pchunk,:) = CV(chunkperm,:);
                IDperm(pchunk,:) = ID(chunkperm,:);
                t_perm(pchunk)   = t(chunkperm);
            end

            
            for f = 1:n_folds
                % configure data structure for prt_cv_fold
                fdata.ID      = IDperm; %IDperm
                fdata.mid     = modelid(1);
                fdata.CV      = CVperm(:,f);
                if nk>1
                    fdata.Phi_all = Phi_all(k); %selected kernel for independent modelling
                else
                    fdata.Phi_all = Phi_all; %all kernels
                end
                fdata.t       = t_perm;
                fdata.cov     = PRT.model(modelid).input.covar;
            
                
                % Nested CV for hyper-parameter optimisation or feature selection
                if isfield(PRT.model(modelid(1)).input,'use_nested_cv')
                    if PRT.model(modelid(1)).input.use_nested_cv
                        [out] = prt_nested_cv(PRT, fdata);
                        PRT.model(modelid(1)).input.machine.args = out.opt_param;
                    end
                end
                
                [temp_model, targets] = prt_cv_fold(PRT,fdata);
                
                % save the weights per fold to further compute ranking distance
                if flag
                    PRT.model(modelid(1)).output(k).permutation(p).fold(f).alpha=temp_model.alpha;
                    PRT.model(modelid(1)).output(k).permutation(p).fold(f).pred=temp_model.predictions;
                end
                
                model.output.fold(f).predictions = temp_model.predictions;
                model.output.fold(f).targets     = targets.test;
                
            end
            
            % Model level statistics (across folds)
            tp             = vertcat(model.output.fold(:).targets);
            m.type        = PRT.model(modelid(1)).output(k).fold(1).type;
            m.predictions = vertcat(model.output.fold(:).predictions);
            perm_stats         = prt_stats(m,tp,tp);
            
            
            switch PRT.model(modelid(1)).output(k).fold(1).type
                
                case 'classifier'
                    
                    permutation.b_acc(p)=perm_stats.b_acc;
                    n_class = length(PRT.model(modelid(1)).output(k).fold(1).stats.c_acc);
                    
                    if (perm_stats.b_acc >= PRT.model(modelid(1)).output(k).stats.b_acc)
                        total_greater_b_acc=total_greater_b_acc+1;
                    end
                    
                    for c=1:n_class
                        permutation.c_acc(c,p)=perm_stats.c_acc(c);
                        if (perm_stats.c_acc(c) >= PRT.model(modelid(1)).output(k).stats.c_acc(c))
                            total_greater_c_acc(c)=total_greater_c_acc(c)+1;
                        end
                    end
                    
                case 'regression'
                    permutation.corr(p)=perm_stats.corr;
                    if (perm_stats.corr >= PRT.model(modelid(1)).output(k).stats.corr)
                        total_greater_corr=total_greater_corr+1;
                    end
                    permutation.mse(p)=perm_stats.mse;
                    if (perm_stats.mse <= PRT.model(modelid(1)).output(k).stats.mse)
                        total_greater_mse=total_greater_mse+1;
                    end
                    permutation.nmse(p)=perm_stats.nmse;
                    if (perm_stats.nmse <= PRT.model(modelid(1)).output(k).stats.nmse)
                        total_greater_nmse=total_greater_nmse+1;
                    end
                    permutation.r2(p)=perm_stats.r2;
                    if (perm_stats.r2 >= PRT.model(modelid(1)).output(k).stats.r2)
                        total_greater_r2=total_greater_r2+1;
                    end
                    
                    
            end
            
            if flag
                PRT.model(modelid(1)).output(k).permutation(p).perm_mat = reshape(chunkperm, numel(chunkperm),1); % put in column
                PRT.model(modelid(1)).output(k).permutation(p).perm_stats = perm_stats;
            end
        end
        fprintf('\n') % new line after each model
        
        
        switch PRT.model(modelid(1)).output(k).fold(1).type
            case 'classifier'
                
                pval_b_acc = (total_greater_b_acc+1) / (n_perm+1);
                
                pval_c_acc=zeros(n_class,1);
                for c=1:n_class
                    pval_c_acc(c) = (total_greater_c_acc(c)+1) / (n_perm+1);
                end
                
                permutation.pvalue_b_acc = pval_b_acc;
                permutation.pvalue_c_acc = pval_c_acc;
                
            case 'regression'
                
                pval_corr = (total_greater_corr+1) / (n_perm+1);
                
                pval_mse = (total_greater_mse+1) / (n_perm+1);
                
                pval_nmse = (total_greater_nmse+1) / (n_perm+1);
                
                pval_r2 = (total_greater_r2+1) / (n_perm+1);
                
                
                permutation.pval_corr = pval_corr;
                permutation.pval_mse = pval_mse;
                permutation.pval_nmse = pval_nmse;
                permutation.pval_r2 = pval_r2;
        end
        
        
        
        %update PRT
        PRT.model(modelid(1)).output(k).stats.permutation = permutation;
        
        % Save PRT containing machine output
        % -------------------------------------------------------------------------
        outfile = fullfile(path,'PRT.mat');
        disp('Updating PRT.mat.......>>')
        if spm_check_version('MATLAB','7') < 0
            save(outfile,'-V6','PRT');
        else
            save(outfile,'PRT');
        end
        disp('Permutation test done.')
    end
    
end

