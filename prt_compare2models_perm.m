function out = prt_compare2models_perm(PRT,modelid,value)

% Function to compare two models based on the results of identical
% permutations
%
% Inputs:
% -------
% PRT    : loaded PRT structure
% modelid: indexe of the 2 models to compare, vector of size 1x2
% value  : which value to compare the models on, string, e.g. 'b_acc'
%
% Outputs:
% --------
% out: p value that the 2 models have a difference in accuracy that could
% be observed by chance
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Schrouff
% $Id$

% Check inputs
if nargin< 2 || length(modelid)<2
    beep
    disp('At least 2 models should be selected for comparison')
    return
end

if ~isfield(PRT,'model')
    beep
    disp('No model found in this PRT.mat');
    return
else
    for i = 1:length(modelid)
        if ~isfield(PRT.model(modelid(i)),'output')
            beep
            fprintf('No output found  for model %d in this PRT.mat',modelid(i));
            return           
        end
        if nargin<3 && strcmpi(PRT.model(modelid(i)).input.type,'classification')
            value = 'b_acc';
        elseif nargin<3 && strcmpi(PRT.model(modelid(i)).input.type,'regression')
            value = 'r2';
        end
    end
end


% Get the estimated permutation values of interest for each model
true_vals = zeros(length(modelid),1);
for  i = 1:length(modelid)
    if ~isfield(PRT.model(modelid(i)).output,'permutation') || ...
            ~isfield(PRT.model(modelid(i)).output.permutation(1),'perm_stats')
        beep
        fprintf('No permutations saved for model %d',modelid(i));
    else
        if i == 1
            perm = zeros(length(PRT.model(modelid(i)).output.permutation),...
                length(modelid));
        end
        try
            for j = 1:length(PRT.model(modelid(i)).output.permutation)
                eval(['perm(j,i) = PRT.model(modelid(i)).output.permutation(j).perm_stats.',value,';'])
            end
        catch
            error('prt_compare2models_perm:DimensionsDoNotAgree',...
                'The estimated permutations do not have consistent dimensions across models')
        end
    end
    eval(['true_vals(i) = PRT.model(modelid(i)).output.stats.',value,';'])
end

% Compare the difference between the models to the difference in
% permutations
p_values = zeros((length(modelid)*(length(modelid)-1))/2,1);
idxpval = 1;
for i = 1: length(modelid)-1
    for j = i+1: length(modelid)
        model1 = [perm(:,i);true_vals(i)];
        model2 = [perm(:,j);true_vals(j)];
        diffmodperm = abs(model1 - model2);
        diffmod = abs(true_vals(i) - true_vals(j));
        p_values(idxpval) = length(find(diffmodperm>=diffmod))/(length(diffmodperm));
        idxpval = idxpval + 1;
    end
end

out = p_values;
        
        
        
        