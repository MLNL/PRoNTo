% simple test harness for prt_machine

%% generate data
featuresAsKernelMatrix=true;
Ntr=100;                 % number of training vectors
D=3;                    % dimensionality of the feature vectors
Nte=50;                 % number of testing vectors
myTR={rand(Ntr,D)};
myTE={rand(Nte,D)};
myLabs=round(rand(Ntr,1));

if featuresAsKernelMatrix==true
    myTE={myTE{:}*myTR{:}'};
    myTR={myTR{:}*myTR{:}'};
end

figure;
subplot(121); imagesc(myTR{:}); title('TR'); 
subplot(122); imagesc(myTE{:}); title('TE'); 

%% prepare machine
myMachine.function='prt_machine_svm_bin';
if featuresAsKernelMatrix==true
    myMachine.args='-t 4';
else
    myMachine.args='-t 1';
end

%% run
output = prt_machine(myTR,myTE,myLabs,myMachine);