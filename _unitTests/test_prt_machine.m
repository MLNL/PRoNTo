% simple test harness for prt_machine
%
% $Id$

%% test setup
featuresAsKernelMatrix=false;
useMultipleKernels=false;

%% generate data

Ntr=100;                % number of training vectors
D=3;                    % dimensionality of the feature vectors
Nte=30;                 % number of testing vectors

if useMultipleKernels==true
    
    t_d.train={rand(Ntr,D); randn(Ntr,D) };
    t_d.test={rand(Nte,D); randn(Nte,D)};
else
    t_d.train={rand(Ntr,D)};
    t_d.test={rand(Nte,D)};
end

t_d.tr_targets=round(rand(Ntr,1));

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
    myMachine.args='-t 4';
else
    myMachine.args='-t 1';
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