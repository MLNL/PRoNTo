% simple test harness for prt_machine
%
% $Id$

%% test setup
featuresAsKernelMatrix=false;
useMultipleKernels=false;
useSynthData=false;         % use synthetic data
% root of PRT mat
p_PRTroot='/Volumes/cs-research/intelsys/intelsys0/green/pattern/testdata/MoAEpilot/';
fn_PRTtoUse='PRT_featureMatrix.mat'; % which PRT mat we want to use

%% generate data
if useSynthData==true
    Ntr=96;                % number of training vectors
    D=64*64*64;                    % dimensionality of the feature space
    Nte=30;                 % number of testing vectors
    classOffset=0.1;       % higher value = easier problem
    
    if useMultipleKernels==true
        
        t_d.train={[rand(Ntr/2,D); rand(Ntr/2,D)+classOffset]; [randn(Ntr/2,D); randn(Ntr/2,D)+classOffset] };
        t_d.test={[rand(Nte/2,D); rand(Nte/2,D)+classOffset]; [randn(Nte/2,D); randn(Nte/2,D)+classOffset] };
    else
        t_d.train={[rand(Ntr/2,D); rand(Ntr/2,D)+classOffset]};
        t_d.test={[rand(Nte/2,D); rand(Nte/2,D)+classOffset]};
    end
    
    % can also label class1=2 class2=1 to be perverse
    t_d.tr_targets=([ones(Ntr/2,1)*1 ; ones(Ntr/2,1)*2]);
    te_targets=([ones(Nte/2,1)*1 ; ones(Nte/2,1)*2]);
else
    if featuresAsKernelMatrix==true
        error('code not ready to test kernel matrix')
    end
    if length(PRT.group.subject.modality.design.conds)>2
        error('code not ready for >2 class testing')
    end
    
    load(fullfile(p_PRTroot,fn_PRTtoUse));
    % load mask
    VMi=spm_vol(PRT.masks.fname(1:end-2));
    VM=spm_read_vols(VMi);
    % find non-zero voxels (within the mask)
    nzidx=find(VM>0); % no support for logical indexing in file_array :(
    clear VM VMi;
    %nzvx=PRT.file_arrays.Y(nzidx,:);
    T=size(PRT.file_arrays.Y,2);
    
    %%% retrieve scan indices
    % make shortcut
    c1ScansIdx=PRT.group.subject.modality.design.conds(1).scans;
    c2ScansIdx=PRT.group.subject.modality.design.conds(2).scans;
    % flag used scans
    c1Scans=zeros(1,T);
    c2Scans=c1Scans;
    c1Scans(c1ScansIdx)=1;
    c2Scans(c2ScansIdx)=1;
    
    figure; subplot(211); bar(c1Scans); axis tight; xlabel('scans')
    title(['c1 - ' PRT.group.subject.modality.design.conds(1).cond_name]);
    subplot(212); bar(c2Scans); axis tight; xlabel('scans')
    title(['c2 - ' PRT.group.subject.modality.design.conds(2).cond_name]);

    
    %%% lazy feature generation
    X=zeros(length(nzvx),0);
    for t=1:T
        
    end
end

% compute kernel if needed
if featuresAsKernelMatrix==true
    if useMultipleKernels==true
        t_d.test={t_d.test{1}*t_d.train{1}';t_d.test{2}*t_d.train{2}'};
        t_d.train={t_d.train{1}*t_d.train{1}';t_d.train{2}*t_d.train{2}'};
    else
        t_d.test={t_d.test{1}*t_d.train{1}'};
        t_d.train={t_d.train{1}*t_d.train{1}'};
    end
    t_d.usebf=true;
else
    t_d.usebf=false;
end

%% plot dataset
figure;
subplot(221); imagesc(t_d.train{1}); title('TR 1');
subplot(223); imagesc(t_d.test{1}); title('TE 1');
if useMultipleKernels==true
    subplot(222); imagesc(t_d.train{2}); title('TR 2');
    subplot(224); imagesc(t_d.test{2}); title('TE 2');
end


%% prepare machine
myMachine.function='prt_machine_svm_bin';
%myMachine.function='prt_machine_RT_bin';

if ~isempty(strfind(myMachine.function,'svm_bin'))
    if featuresAsKernelMatrix==true
        myMachine.args='-s 0 -t 4';
    else
        myMachine.args='-s 0 -t 0';
    end
else
    myMachine.args=[601];
end

testCov=[];

%% potentially annoy the code
% 1: by removing libSVM, we might causes the code to point at the biostats
%toolbox's version of svmtrain instead
%rmpath('/Users/Richiardi/_skool/matlabTools/libsvm/'); 
% 2: by removing biostats toolbox, we're 
%rmpath('/Applications/_sciEng/MATLAB_R2011a.app/toolbox/bioinfo/biolearning');

%% run
tic
% OLD fomat
%output = prt_machine(train,test,testCov,myLabs,myMachine,featuresAsKernelMatrix);
output = prt_machine(t_d,myMachine);
toc

% eval 
figure; plot(te_targets,'g-','LineWidth',3); hold on;
plot(output.predictions,'k:','LineWidth',2);
plot(output.func_val,'b--','LineWidth',2); 
legend('true labels','hard prediction','soft prediction');
grid on
acc=sum(output.predictions==te_targets)/numel(te_targets)
title([myMachine.function ' - ' num2str(acc,'%2.2f')],'Interpreter','none');