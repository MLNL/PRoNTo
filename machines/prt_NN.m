function y_pred = prt_NN(X_train,y_train,X_test,y_test,args)
% Function for running Fully Connected Neural Network

% w = prt_NN(X,y,args)
%__________________________________________________________________________
% Copyright (C) 2020 Machine Learning & Neuroimaging Laboratory

% Written by Cemre Zor & James Chapman
% $Id$

%Change array to categoricals
y_train_cat=categorical(y_train);

y_test_cat=categorical(y_test);

[num_categories,~]=size(categories(y_train_cat));

[n,p] = size(X_train);

layers = [ ...
    imageInputLayer([p 1 1])
    %convolution2dLayer([1000,1],5)
    %convolution2dLayer([1000,1],5)
    %imageInputLayer(p)
    %maxPooling2dLayer(2,'Stride',2)
    %fullyConnectedLayer(1000)
    %reluLayer
    fullyConnectedLayer(1000)
    reluLayer
    fullyConnectedLayer(num_categories); %, 'WeightInitializer','he')
    softmaxLayer
    classificationLayer];

options = trainingOptions('adam', ...
    'L2Regularization', 10, ...
    'LearnRateDropFactor',0.1, ...
    'LearnRateDropPeriod',10, ...
    'ValidationData',{reshape(X_test,[p 1 1 size(X_test,1)]),reshape(y_test_cat,[1 size(y_test,1)])}, ...
    'ValidationFrequency',1, ...
    'ValidationPatience',inf, ...
    'Plots','training-progress', ...
    'MaxEpochs',100, ...
    'MiniBatchSize',20);
 
%'InitialLearnRate',0.0001
   % 'LearnRateSchedule','piecewise', ...
   % 'InitialLearnRate',0.001, ...
   % 'LearnRateDropFactor',1, ...
   % 'LearnRateDropPeriod',50000, ...
   % 'MaxEpochs',100, ...
   % 'MiniBatchSize',20, ...
   
FCN = trainNetwork(reshape(X_train,[p 1 1 n]),reshape(y_train_cat,[1 n]),layers,options);

y_pred = transpose(predict(FCN,transpose(X_test)));


return