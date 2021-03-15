
function [out] = prt_permute_MTL(PRT,mid,fname,p_start,maxnp)
% Function to compute permutations for MTL models based on the single task model permutations.
%
% Before using this code, ensure you have run permutations on the tasks
% independently and have saved the permutation parameters for each.
%
% Inputs:
% PRT       : PRT structure after loading
% mid       : index of model to permute
% fname     : full path and name of PRT.mat file
% maxnp     : maximum number of permutations. If the sub-models were run
% with a lot of permutations, this value will cap it to the first maxnp
% permutations.
% 
% Output:
% full path to updated PRT structure containing p-values for each stat.
% -------------------------------------------------------------------------
% Written by J. Schrouff for PRoNTo, Copyright 2011 MLNL, UCL.
 
maxnp_new = maxnp;

 
models = PRT.model(mid).input.models_MTL;
 
path = spm_fileparts(fname);
 
nperm = +Inf;
for i=1:length(models)
    perm_mod = numel(PRT.model(models(i)).output.permutation);
    if perm_mod<nperm
        nperm = perm_mod;
    end
end
if maxnp<nperm
    nperm = maxnp;
end
 
tokeep = cell(length(models),1);
trueperf = PRT.model(mid).output;
 
in.model_name = PRT.model(mid).model_name;
in.models_MTL = {PRT.model(models).model_name};
in.fname = fname;
in.savePRT = 0;
 
 
 
in.perm_mode = 1;
 
 
 
 
 
switch PRT.model(mid).output.fold(1).type
    case {'classifier','classification'}
        n_class = length(PRT.model(mid).output.fold(1).stats.c_acc);
        total_greater_c_acc = zeros(n_class,1);
        total_greater_b_acc = 0;
        total_greater_auc = 0;
        total_greater_bacc_task = zeros(length(models),1);
        
    case 'regression'
        total_greater_corr = 0;
        total_greater_mse = 0;
        total_greater_nmse = 0;
        total_greater_r2 = 0;
        total_greater_r2_task = zeros(length(models),1);
end
 
   
    if exist('incomplete_across_perms.mat') == 2
        load('incomplete_across_perms.mat');
%         p_start = p+1; clear p
%         p_start = 3; % HAVE TO SET IT MANUALLY EACH TIME.
        
        
        clear r2_task_temp;   
%         nperm = maxnp_new;
        
    else
        p_start = 1;
        for i = 1:length(models)
            tokeep{i} = PRT.model(models(i)).input.targets;
        end
        total_greater_r2_task_1=0;
        total_greater_r2_task_2=0;
%         total_greater_r2_task_3=0;
%         total_greater_r2_task_4=0;
%         total_greater_r2_task_5=0;
 
    end
    
    
    timer2 = tic;
 
 
parfor p = p_start:nperm
    
    rng(p);
    pause(200*rand);
    
    PRT_temp = PRT;
    timer1 = tic;
    
    % Counter of permutations to be updated
    disp(['Compute for permutation ',num2str(p),' of ',num2str(nperm)])
    disp('---------------------------------------------------')
    
    % Change the targets in the model input to the permuted targets
    for i=1:length(models)
        perms = PRT.model(models(i)).output.permutation(p).perm_mat;
        CV = PRT.model(models(i)).input.cv_mat;
        tars = tokeep{i};
        
        temp_perms(1,p).perms = perms;
        temp_CV(1,p).CV = CV;
        
%         if i == 1
%         temp_tars_1(1,p).tars = tars(perms);
%         else
%         temp_tars_2(1,p).tars = tars(perms);
%         end
        
        
        
        
        PRT_temp.model(models(i)).input.targets = tars(perms);
        
        
        
        
        
        
        
        PRT_temp.model(models(i)).input.CVperm = CV(perms,:); % ???????? WHY DO I NEED THIS?
    end
    
    
    
    
    
    
    
    
    
    % Run MTL on permuted targets from all tasks
    PRT_temp = prt_cv_MTL(PRT_temp,in);
    
    temp_PRT(1,p).PRT = PRT_temp;
    
    perm_stats = PRT_temp.model(mid).output.stats;
    
        temp_perm_stats(1,p).perm_stats = perm_stats;
    
    % Compare stats from permuted model to 'true' stats
    switch PRT_temp.model(mid).output.fold(1).type
        
%         case {'classifier','classification'}
%             permutation.b_acc(p)=perm_stats.b_acc;
%             
%             if (perm_stats.b_acc >= trueperf.stats.b_acc)
%                 total_greater_b_acc=total_greater_b_acc+1;
%             end
%             
%             if isnan(perm_stats.auc)
%                 permutation.auc(p)=NaN;
%             elseif ~isempty(perm_stats.auc)
%                 permutation.auc(p)=perm_stats.auc;
%             else
%                 permutation.auc(p)=NaN; % Initialize
%                 permutation.auc(p)=[];
%             end
%             
%             if (perm_stats.auc >= trueperf.stats.auc)
%                 total_greater_auc=total_greater_auc+1;
%             end
%             
%             
%             for c=1:n_class
%                 permutation.c_acc(c,p)=perm_stats.c_acc(c);
%                 if (perm_stats.c_acc(c) >= trueperf.stats.c_acc(c))
%                     total_greater_c_acc(c)=total_greater_c_acc(c)+1;
%                 end
%             end
%             
%             for c=1:length(models)
%                 permutation.bacc_task(c,p)=perm_stats.task_bacc(c);
%                 if (perm_stats.task_bacc(c) >= trueperf.stats.task_bacc(c))
%                     total_greater_bacc_task(c)=total_greater_bacc_task(c)+1;
%                 end
%             end
            
        case 'regression'
%             permutation.corr(p)=perm_stats.corr;
            corr_temp(p)=perm_stats.corr;
            
            if (perm_stats.corr >= trueperf.stats.corr)
                total_greater_corr=total_greater_corr+1;
            end
%             permutation.mse(p)=perm_stats.mse;
            mse_temp(p)=perm_stats.mse;
            
            if (perm_stats.mse <= trueperf.stats.mse)
                total_greater_mse=total_greater_mse+1;
            end
%             permutation.nmse(p)=perm_stats.nmse;
            nmse_temp(p)=perm_stats.nmse;
            
            if (perm_stats.nmse <= trueperf.stats.nmse)
                total_greater_nmse=total_greater_nmse+1;
            end
%             permutation.r2(p)=perm_stats.r2;
            r2_temp(p)=perm_stats.r2;
            
            if (perm_stats.r2 >= trueperf.stats.r2)
                total_greater_r2=total_greater_r2+1;
            end
            
            for c=1:length(models)
%                 permutation.r2_task(c,p)=perm_stats.task_r2(c);
%                 r2_task_temp(c,p)=perm_stats.task_r2(c);
                
                if c==1
                r2_task_temp_1(1,p)=perm_stats.task_r2(c);
                elseif c==2
                  r2_task_temp_2(1,p)=perm_stats.task_r2(c);  
%                 elseif c==3
%                   r2_task_temp_3(1,p)=perm_stats.task_r2(c);  
%                 elseif c==4
%                   r2_task_temp_4(1,p)=perm_stats.task_r2(c);  
%                 elseif c==5
%                   r2_task_temp_5(1,p)=perm_stats.task_r2(c);  
                end
                
                  
                if (perm_stats.task_r2(c) >= trueperf.stats.task_r2(c))
                    
                    if c==1 % NEEDS CHANGING
                        total_greater_r2_task_1=total_greater_r2_task_1+1;
                    elseif c==2
                        total_greater_r2_task_2=total_greater_r2_task_2+1;
%                     elseif c==3
%                         total_greater_r2_task_3=total_greater_r2_task_3+1;
%                     elseif c==4
%                         total_greater_r2_task_4=total_greater_r2_task_4+1;
%                     elseif c==5
%                         total_greater_r2_task_5=total_greater_r2_task_5+1;
                    end
                                            
                                            
%                     total_greater_r2_task(c)=total_greater_r2_task(c)+1;
 
 
                end
            end
    end
    
    % Save Permutation Parameters (excluding w due to big size) in a temp for Re-Use
     temp(1,p).fold = PRT_temp.model(mid).output.fold;
%      temp(1,p).fold = rmfield(temp(1,p).fold,'w');
     temp(1,p).perm_stats = perm_stats;
     
  temp_timer(1,p).timer = toc(timer1);
 
end
fprintf('\n') % new line
 
total_timer = toc(timer2);
save('temp_timer.mat','temp_timer','total_timer');
 
 
for p = p_start:nperm
    temp(1,p).fold = rmfield(temp(1,p).fold,'w');
end
 
total_greater_r2_task(1,:)=total_greater_r2_task_1;
total_greater_r2_task(2,:)=total_greater_r2_task_2;
% total_greater_r2_task(3,:)=total_greater_r2_task_3;
% total_greater_r2_task(4,:)=total_greater_r2_task_4;
% total_greater_r2_task(5,:)=total_greater_r2_task_5;
 
r2_task_temp(1,:)=r2_task_temp_1;
r2_task_temp(2,:)=r2_task_temp_2;
% r2_task_temp(3,:)=r2_task_temp_3;
% r2_task_temp(4,:)=r2_task_temp_4;
% r2_task_temp(5,:)=r2_task_temp_5;
 
permutation.corr=corr_temp;
permutation.mse=mse_temp;
permutation.nmse=nmse_temp;
permutation.r2=r2_temp;
permutation.r2_task=r2_task_temp;
 
 
     save('incomplete_across_perms.mat');
 
 
%Compute p-values
switch PRT.model(mid).output.fold(1).type
    case {'classifier','classification'}
        
        pval_b_acc = (total_greater_b_acc+1) / (nperm+1);        
        if isnan(total_greater_auc)
            pval_auc = NaN;
        elseif ~isempty(total_greater_auc)
            pval_auc = (total_greater_auc+1) / (nperm+1);
        else
            pval_auc = [];
        end
        
        pval_c_acc=zeros(n_class,1);
        for c=1:n_class
            pval_c_acc(c) = (total_greater_c_acc(c)+1) / (nperm+1);
        end
        
        pval_bacc_task=zeros(length(models),1);
        for c=1:length(models)
            pval_bacc_task(c) = (total_greater_bacc_task(c)+1) / (nperm+1);
        end
        
        permutation.pvalue_b_acc = pval_b_acc;
        permutation.pvalue_c_acc = pval_c_acc;
        permutation.pvalue_auc = pval_auc;
        permutation.pvalue_bacc_task = pval_bacc_task;
        
    case 'regression'
        
        pval_corr = (total_greater_corr+1) / (nperm+1);        
        pval_mse = (total_greater_mse+1) / (nperm+1);        
        pval_nmse = (total_greater_nmse+1) / (nperm+1);        
        pval_r2 = (total_greater_r2+1) / (nperm+1);
        
        pval_r2_task=zeros(length(models),1);
        for c=1:length(models)
            pval_r2_task(c) = (total_greater_r2_task(c)+1) / (nperm+1);
        end
        
        permutation.pval_corr = pval_corr;
        permutation.pval_mse = pval_mse;
        permutation.pval_nmse = pval_nmse;
        permutation.pval_r2 = pval_r2;
        permutation.pval_r2_task = pval_r2_task;
end
 
% Restore tasks' true targets
for i=1:length(models)
    PRT.model(models(i)).input.targets = tokeep{i};
end
 
% Restore model output
PRT.model(mid).output = trueperf;
 
% Update PRT
PRT.model(mid).output.stats.permutation = permutation;
PRT.model(mid).output.permutation = temp;
 
% Save PRT containing permutation output
% -------------------------------------------------------------------------
outfile = fullfile(path,'PRT.mat');
disp('Updating PRT.mat.......>>')
if spm_check_version('MATLAB','7') < 0
    save(outfile,'-V6','PRT');
else
    try %For files larger than 2Gb
        save(outfile,'PRT','-v7.3','-nocompression');
    catch %For older versions of Matlab
        save(outfile,'PRT');
    end
end
disp('Permutation test done.')
