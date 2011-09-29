% simple test harness for prt_machine
%
% $Id$

%% test setup
featuresAsKernelMatrix=true;
useMultipleKernels=false;

%% generate data

Ntr=100;                 % number of training vectors
D=3;                    % dimensionality of the feature vectors
Nte=30;                 % number of testing vectors

if useMultipleKernels==true
    
    myTR={rand(Ntr,D); randn(Ntr,D) };
    myTE={rand(Nte,D); randn(Nte,D)};
else
    myTR={rand(Ntr,D)};
    myTE={rand(Nte,D)};
end

myLabs=round(rand(Ntr,1));

if featuresAsKernelMatrix==true
    if useMultipleKernels==true
        myTE={myTE{1}*myTR{1}';myTE{2}*myTR{2}'};
        myTR={myTR{1}*myTR{1}';myTR{2}*myTR{2}'};
    else
        myTE={myTE{1}*myTR{1}'};
        myTR={myTR{1}*myTR{1}'};
    end
end

figure;
subplot(221); imagesc(myTR{1}); title('TR 1');
subplot(223); imagesc(myTE{1}); title('TE 1');
if useMultipleKernels==true
    subplot(222); imagesc(myTR{2}); title('TR 2');
    subplot(224); imagesc(myTE{2}); title('TE 2');
end

%% prepare machine
myMachine.function='prt_machine_svm_bin';
if featuresAsKernelMatrix==true
    myMachine.args='-t 4';
else
    myMachine.args='-t 1';
end
testCov=[];

%% run
output = prt_machine(myTR,myTE,testCov,myLabs,myMachine,featuresAsKernelMatrix);