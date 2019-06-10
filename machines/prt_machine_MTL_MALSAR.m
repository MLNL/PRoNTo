function output = prt_machine_MTL_MALSAR(d,args)
% Function to run Multi-Task Learning. Wrapper for the MALSAR toolbox.
% 
% FORMAT output = prt_machine_MTL_MALSAR(d,args)
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
%    args         - Regularization parameter
% Output:
%    output  - output of machine (struct).
%     * Mandatory fields:
%      .predictions - predictions of classification or regression [Nte x D]
%     * Optional fields:
%      .func_val - value of the decision function
%      .type     - which type of machine this is (here, 'classifier')
%__________________________________________________________________________
% Copyright (C) 2018 Machine Learning & Neuroimaging Laboratory

% Written by J. Schrouff from prt_machine_svm_bin.m
% $Id$

SANITYCHECK=true; % can turn off for "speed". Expert only.

%Regularization parameter
if isempty(args)
    def = prt_get_defaults('model');
    args = def.MTLargs;
end

reg = 0;
if SANITYCHECK==true
    % args should be a string (empty or otherwise)
    if ~ischar(args)
        error('prt_machine_MTL_MATLSAR:ArgsNotString',['Error: MALSAR'...
            ' args should be a string. ' ...
            ' SOLUTION: Please enter a string argument']);
    end
    
    % Check for classification machines
    if ~isempty(regexp(args,'-s\s+[123]','once'))

        % check it is indeed a two-class classification problem
        uTL=unique(d.tr_targets{1}(:));
        nC=numel(uTL);
        if nC>2
            error('prt_machine_MTL_MALSAR:problemNotBinary',['Error:'...
                ' This machine is only for two-class problems but the' ...
                ' current problem has ' num2str(nC) ' ! ' ...
                'SOLUTION: Please select another machine than ' ...
                'prt_machine_MTL_MALSAR in XXX']);
        end
        % check it is indeed labelled correctly (probably should be done) 
        if ~all(uTL==[1 2]')
            error('prt_machine_MTL_MALSAR:LabellingIncorect',['Error:'...
                ' This machine needs labels to be in {1,2} ' ...
                ' but they are ' mat2str(uTL) ' ! ' ...
                'SOLUTION: Please relabel your classes by changing the '...
                ' ''tr_targets'' argument to prt_machine_MTL_MALSAR']);
        end
        output.type = 'classification';
    else
        output.type = 'regression';
        reg = 1;
    end   
end


% Run Multi-Task in MALSAR
%--------------------------------------------------------------------------
nt  = numel(d.tr_targets);

for t = 1:nt
    if ~reg
    %Machine specific inputs

        % Change targets to be +1/-1
        c2 = d.tr_targets{t}==2;
        d.tr_targets{t}(c2) = -1;
    end
    % Add bias
    d.train{t} = [d.train{t}, ones(size(d.train{t},1),1)];
    d.test{t} = [d.test{t}, ones(size(d.test{t},1),1)];
end

opts.init = 0; % compute start point from data.
opts.tFlag = 1; % terminate after objective value does not changes much.
opts.tol = 10^-5; % tolerance.
opts.maxIter = 1500; % maximum iteration number of optimization.

valued_args = args(regexp(args,'-args','once')+5:end);
vals = sscanf(valued_args,'%f');

if isnan(vals(1))
    error('prt_machine_MTL_MALSAR:WrongArguments',...
        'Argument after -args should be numerical and separated by one white space')
end

C = [];
P = [];
Q = [];

% Classification
if ~isempty(regexp(args,'-s\s+[1]','once')) % Lasso classification
    args = vals(1);
    if numel(vals)>1 && ~isnan(vals(2))% rho2 was entered
        opts.rho_L2 = vals(2);
    end
    [W,C] = Logistic_Lasso(d.train,d.tr_targets,args,opts);
elseif ~isempty(regexp(args,'-s\s+[2]','once')) % L2,1 classification
    args = vals(1);
    if numel(vals)>1 && ~isnan(vals(2))% rho2 was entered
        opts.rho_L2 = vals(2);
    end
    [W,C] = Logistic_L21(d.train,d.tr_targets,args,opts);
elseif ~isempty(regexp(args,'-s\s+[3]','once')) %Trace-norm classification
    args = vals(1);
    [W,C] = Logistic_Trace(d.train,d.tr_targets,args,opts);
    
%Regression
elseif ~isempty(regexp(args,'-s\s+[4]','once')) % Lasso regression
    args = vals(1);
    if numel(vals)>1 && ~isnan(vals(2))% rho2 was entered
        opts.rho_L2 = vals(2);
    end
    [W] = Least_Lasso(d.train,d.tr_targets,args,opts);
elseif ~isempty(regexp(args,'-s\s+[5]','once')) % L2,1 regression
    args = vals(1);
    if numel(vals)>1 && ~isnan(vals(2))% rho2 was entered
        opts.rho_L2 = vals(2);
    end
    [W] = Least_L21(d.train,d.tr_targets,args,opts);
elseif ~isempty(regexp(args,'-s\s+[6]','once')) %Trace-norm regression
    args = vals(1);
    [W] = Least_Trace(d.train,d.tr_targets,args,opts);
elseif ~isempty(regexp(args,'-s\s+[7]','once')) %Dirty model regression
    args1 = vals(1);
    if numel(vals)>1 && ~isnan(vals(2))% rho2 was entered
        args2 = vals(2);
    else
        error('prt_machine_MTL_MALSAR:WrongArgumentDirtyModel',...
            '2 arguments need to be provided for the Dirty Model')
    end
    [W,P,Q] = Least_Dirty(d.train,d.tr_targets,args1,args2,opts);
end


% check if training succeeded:
if isempty(W) || ~nnz(W)
    warning('prt_machine_MTL_MALSAR:MALSARtrainUnsuccessful',['Error:'...
        ' MALSAR machine function did not run properly!' ...
        ' This could be a problem with the supplied function arguments'...
        ' ' num2str(args) '']);
end

predictions = cell(1,nt);
func_val = cell(1,nt);
for t = 1:nt
    if ~ reg
        func_val{t} = d.test{t} * W(:, t) + C(t);
        pred = sign(func_val{t});
        % change predictions from 1/-1 to 1/2 
        c1PredIdx               = pred==1; 
        pred(c1PredIdx)  = 1; %positive values = 1 
        pred(~c1PredIdx) = 2; %negative values = 2 
        predictions{t} = pred;
    else
        func_val{t} = d.test{t} * W(:, t);
        predictions{t} = func_val{t};
    end
    
end




% Outputs
%--------------------------------------------------------------------------
output.predictions = predictions;
output.func_val    = func_val;
output.w           = W(1:end-1,:);
output.b           = W(end,:);
% Get extra outputs for specific algorithms
if ~isempty(C)
    output.others.C = C;
end
if ~isempty(P)
    output.others.P = P; 
end
if ~isempty(Q)
    output.others.Q = Q;
end

