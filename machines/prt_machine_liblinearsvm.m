function output = prt_machine_liblinearsvm(d,args)
% Run binary SVM - wrapper for LIBLINEAR
% FORMAT output = prt_machine_liblinearsvm(d,args)
% Inputs:
%   d         - structure with data information, with mandatory fields:
%     .train      - training data (cell array of matrices of row vectors,
%                   each [Ntr x D]). each matrix contains one representation
%                   of the data. This is useful for approaches such as
%                   multiple kernel learning.
%     .test       - testing data  (cell array of matrices row vectors, each
%                   [Nte x D])
%     .tr_targets - training labels (for classification) or values (for
%                   regression) (column vector, [Ntr x 1])
%     .te_targets - testing labels (for classification) or values (for
%                   regression) (column vector, [Ntr x 1])
%    args     - libSVM arguments
% Output:
%    output  - output of machine (struct).
%     * Mandatory fields:
%      .predictions - predictions of classification or regression [Nte x D]
%     * Optional fields:
%      .func_val - value of the decision function
%      .type     - which type of machine this is (here, 'classifier')
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by Tong Wu and J. Schrouff
% $Id$


SANITYCHECK=true; % can turn off for "speed". Expert only.


if SANITYCHECK==true
    % args should be a string (empty or otherwise)
    if ~ischar(args)
        error('prt_machine_liblinearsvm:liblinearargsNotString',['Error: liblinear'...
            ' args should be a string. ' ...
            ' SOLUTION: Please enter string arguments and check LIBLINEAR Read me']);
    end
    
    % check we can reach the binary library
    if ~exist('train','file')
        error('prt_machine_liblinearsvm:libNotFound',['Error:'...
            ' liblinear train function could not be found !' ...
            ' SOLUTION: Please check your path or recompile.']);
    end
    
    if ~isempty(regexp(args,'-s\s+[01234567]','once')) && ...% Classification machines
            isempty(regexp(args,'-s\s+10','once')) && ... % Not a regression machine
            isempty(regexp(args,'-s\s+11','once')) && ...
            isempty(regexp(args,'-s\s+12','once'))
        % check if it is a two-class or a multiclass classification problem    
        uTL=unique(d.tr_targets(:));
        nC=numel(uTL);
        if nC==2
            % check it is indeed labelled correctly (probably should be done)
            if ~all(uTL==[1 2]')
                error('prt_machine_liblinearsvm:LabellingIncorect',['Error:'...
                    ' This is a binary classification problem, hence the machine needs labels to be in {1,2} ' ...
                    ' but they are ' mat2str(uTL) ' ! ' ...
                    'SOLUTION: Please relabel your classes by changing the '...
                    ' ''tr_targets'' argument to prt_machine_liblinearsv']);
            end
        else
            % check it is indeed labelled correctly (probably should be done)
            if ~all(uTL==[1:nC]')
                error('prt_machine_liblinearsvm:LabellingIncorect',['Error:'...
                    ' This is a multiclass classification problem, hence the machine needs labels to be in {1,2,3,.., #classes selected} ' ...
                    ' but they are ' mat2str(uTL) ' ! ' ...
                    'SOLUTION: Please relabel your classes by changing the '...
                    ' ''tr_targets'' argument to prt_machine_liblinearsvm']);
            end     
        end
        % Adjust weights for each class
        wi = [];
        wi_args = [];
        n_tr_targets = length(d.tr_targets);
        s = ' ';
        for i = 1:nC
            wi(1,i) = sum(d.tr_targets==i)/n_tr_targets;
            wi(1,i) = 1; % Only for now, will be changed in future
            wi_args = [wi_args,'-w',num2str(i),s,num2str(wi(1,i)),s];
        end
        
        args = [args ' ' wi_args];
        output.type        = 'classification';
    else
        output.type = 'regression';
    end
end


% Run SVM
%-------------------------------------------------------------------------
model = train(d.tr_targets,sparse(d.train{:}),args);

% check if training succeeded:
if isempty(model)
    if (ischar(args))
        args_str = args;
    else
        args_str = '';
    end
    error('prt_machine_liblinearsvm:liblineartrainUnsuccessful',['Error:'...
        ' liblinear train function did not run properly!' ...
        ' This could be a problem with the supplied function arguments'...
        ' ' args_str '']);
end


[predictions,liblinear_acc,func_val] = predict(d.te_targets,sparse(d.test{:}),model,'-q');

% Get SV coefficients (alpha) in the original order and the bias term (b) 
if ~isempty(model.Label)
    sgn   = -1*(2 * model.Label(1) - 3); %variable to account for label convention in PRoNTo
else
    sgn = 1;
end
if strcmpi(output.type,'classification')
    output.func_val    = sgn*func_val;
% K.T. Edit 03/2019
else
    output.func_val    = func_val;	
end

% Outputs
%--------------------------------------------------------------------------
output.predictions = predictions;

if ~d.use_kernel
    %Weights for primal
    if ~any(size(model.w)==1) %Multiclass problem
        output.w           = model.w(:,1:end-1)';
        output.b           = model.w(:,end);
    else
        output.w           = model.w(1:end-1)';
        output.b           = model.w(end);
    end
else
    if ~any(size(model.w)==1) %Multiclass problem
        output.alpha       = model.w(:,1:end-1)';
        output.b           = model.w(:,end);
    else
        output.alpha       = model.w(1:end-1)';
        output.b           = model.w(end);
    end
end





