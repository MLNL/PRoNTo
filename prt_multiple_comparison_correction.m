function out = prt_multiple_comparison_correction(filename,models,value)

% Function to compare two models based on the results of identical
% permutations
%
% Inputs:
% -------
% filename: PRT file name
% models  : names of models to correct for, cell array of strings
% value   : which value to compare the models on, string, e.g. 'b_acc'
%
% Outputs:
% --------
% out: corrected p-values for each model
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Schrouff
% $Id$

% Check inputs
if nargin<1 || isempty(filename)
    filename = spm_select(1,'mat','Select PRT.mat',{},pwd,'PRT.mat');
end
try
    load(filename)
catch
    error('prt_multiple_comparison_correction:CannotLoadPRT',...
        'Cannot load PRT.mat')
end
    
if nargin< 2 || length(models)<2
    beep
    disp('At least 2 models should be selected for correction')
    return
end

if ~isfield(PRT,'model')
    beep
    disp('No model found in this PRT.mat');
    return
else
    modelid = zeros(length(models),1);
    for i = 1:length(models)
        in.model_name = models{i};
        modelid(i) = prt_init_model(PRT,in);
        if ~isfield(PRT.model(modelid(i)),'output')
            beep
            fprintf('No output found  for model %d in this PRT.mat',modelid(i));
            return           
        end
    end
    if nargin<3 && strcmpi(PRT.model(modelid(1)).input.type,'classification')
        value = 'b_acc';
    elseif nargin<3 && strcmpi(PRT.model(modelid(1)).input.type,'regression')
        value = 'r2';
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
            perm1 = [PRT.model(modelid(i)).output.permutation(:).perm_mat];         
        end
        permid = [PRT.model(modelid(i)).output.permutation(:).perm_mat];
        if length(find(perm1==permid)) ~= numel(perm1)
            error('prt_multiple_comparison_correction:PermutationsNotIdentical',...
                'The estimated permutations are not consistent across models')
        end
        try
            for j = 1:length(PRT.model(modelid(i)).output.permutation)
                perm(j,i) = PRT.model(modelid(i)).output.permutation(j).perm_stats.(value);
            end
        catch
            error('prt_multiple_comparison_correction:DimensionsDoNotAgree',...
                'The estimated permutations do not have consistent dimensions across models')
        end
    end
    true_vals(i) = PRT.model(modelid(i)).output.stats.(value);
end

% Compute max null distribution and corrected p-values
p_values = zeros(length(modelid),1);

%max distribution
null = max(perm,[],2);
for i = 1: length(modelid)
    p_values(i) = (length(find(null>=true_vals(i)))+1)/(numel(null)+1);
end
out = p_values;
        
        
        
        