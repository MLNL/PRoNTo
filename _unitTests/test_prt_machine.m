% simple test harness for prt_machine
%
% $Id$

%% test setup
featuresAsKernelMatrix=true;
useMultipleKernels=false;

%% generate data

Ntr=100;                % number of training vectors
D=1000;                    % dimensionality of the feature vectors
Nte=30;                 % number of testing vectors
classOffset=0.06;

if useMultipleKernels==true
    
    t_d.train={[rand(Ntr/2,D); rand(Ntr/2,D)+classOffset]; [randn(Ntr/2,D); randn(Ntr/2,D)+classOffset] };
    t_d.test={[rand(Nte/2,D); rand(Nte/2,D)+classOffset]; [randn(Nte/2,D); randn(Nte/2,D)+classOffset] };
else
    t_d.train={[rand(Ntr/2,D); rand(Ntr/2,D)+classOffset]};
    t_d.test={[rand(Nte/2,D); rand(Nte/2,D)+classOffset]};
end

t_d.tr_targets=([ones(Ntr/2,1) ; ones(Ntr/2,1)*2]);
te_targets=([ones(Nte/2,1) ; ones(Nte/2,1)*2]);

if featuresAsKernelMatrix==true
    if useMultipleKernels==true
        t_d.test={t_d.test{1}*t_d.train{1}';t_d.test{2}*t_d.train{2}'};
        t_d.train={t_d.train{1}*t_d.train{1}';t_d.train{2}*t_d.train{2}'};
    else
        t_d.test={t_d.test{1}*t_d.train{1}'};
        t_d.train={t_d.train{1}*t_d.train{1}'};
    end
end

figure;
subplot(221); imagesc(t_d.train{1}); title('TR 1');
subplot(223); imagesc(t_d.test{1}); title('TE 1');
if useMultipleKernels==true
    subplot(222); imagesc(t_d.train{2}); title('TR 2');
    subplot(224); imagesc(t_d.test{2}); title('TE 2');
end

if featuresAsKernelMatrix==true
    t_d.usebf=true;
else
    t_d.usebf=false;
end

%% prepare machine
myMachine.function='prt_machine_svm_bin';
if featuresAsKernelMatrix==true
    myMachine.args='-s 0 -t 4';
else
    myMachine.args='-s 0 -t 0';
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

%% eval 
figure; plot([output.func_val te_targets]);
legend('soft prediction','true labels');