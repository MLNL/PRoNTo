function output = prt_machine_gpml(d,args)
% Run binary SVM - wrapper for libSVM
% FORMAT output = prt_machine_gpml(d,args)
% Inputs:
%   d         - structure with data information, with mandatory fields:
%     .train      - training data (cell array of matrices of row vectors,
%                   each [Ntr x D]). each matrix contains one representation
%                   of the data. This is useful for approaches such as
%                   multiple kernel learning.
%     .test       - testing data  (cell array of matrices row vectors, each
%                   [Nte x D])
%     .testcov    - testing covariance (cell array of matrices row vectors,
%                   each [Nte x Nte])
%     .tr_targets - training labels (for classification) or values (for
%                   regression) (column vector, [Ntr x 1])
%     .use_kernel - flag, is data in form of kernel matrices (true) of in 
%                form of features (false)
%    args     - argument string, where
%       -h        - optimise hyperparameters (otherwise don't)
%       -l lik    - likelihood function. Currently only lik = 'erf' is
%                   supported
%       -c cov    - covariance function:
%                       'lin'  - simple dot product (no hyperparameters)
%                       'linb' - dot product with bias (one hyperparameter)
%                       
% Output:
%    output  - output of machine (struct).
%     * Mandatory fields:
%      .predictions - predictions of classification or regression [Nte x D]
%     * Optional fields:
%      .type     - which type of machine this is (here, 'classifier')
%      .p        - predictive probabilties
%      .loghyper - log hyperparameters
%      .nlml     - negative log marginal likelihood
%      .alpha    - GP weighting coefficients
%      .sW       - likelihood matrix (see Rasmussen & Williams, 2006)
%      .L        - Cholesky factor
%__________________________________________________________________________
% Copyright (C) 2011 PRoNTo

% Written by A Marquand
% $Id$

SANITYCHECK=true; % can turn off for "speed". Expert only.

if SANITYCHECK==true
    % args should be a string (empty or otherwise)
    if ~ischar(args)
        error('prt_machine_gpml:libSVMargsNotString',['Error: gpml'...
            ' args should be a string. ' ...
            ' SOLUTION: Please do XXX']);
    end
    
    % check we can reach the binary library
    if ~exist('gp','file')
        error('prt_machine_gpml:libNotFound',['Error:'...
            ' libSVM svmtrain function could not be found !' ...
            ' SOLUTION: Please check your path.']);
    end
    % check it is indeed a two-class classification problem
    uTL=unique(d.tr_targets(:));
    nC=numel(uTL);
    if nC>2
        error('prt_machine_gpml:problemNotBinary',['Error:'...
            ' This machine is only for two-class problems but the' ...
            ' current problem has ' num2str(nC) ' ! ' ...
            'SOLUTION: Please select another machine']);
    end
    % check it is indeed labelled correctly (probably should be done 
    if ~all(uTL==[1 2]')
        error('prt_machine_gpml:LabellingIncorect',['Error:'...
            ' This machine needs labels to be in {1,2} ' ...
            ' but they are ' mat2str(uTL) ' ! ' ...
            'SOLUTION: Please relabel your classes by changing the '...
            ' ''tr_targets'' argument to prt_machine_gpml']);
    end
    % are we using a kernel
    if ~d.use_kernel
        error('prt_machine_gpml:LabellingIncorect',['Error:'...
            ' This machine is currently only implemented for kernel data ' ...
            'SOLUTION: Please set use_kernel to true']);
    end
end

% parse input arguments
% -------------------------------------------------------------------------
if ~isempty(regexp(args,'-l\s+erf','once'))
    mode = 'classifier';
else
    error('regression with gps not yet supported');
end

% optimise hyperparameters
if ~isempty(regexp(args,'-h','once'))
    optimise_theta = true;
else
    optimise_theta = false;
end

% Configure data matrices
% -------------------------------------------------------------------------
K   = d.train{1};
Ks  = d.test{1};
Kss = d.testcov{1};

% convert labels to +1/-1
y =  2 * d.tr_targets - 3;

% Train GP model
% -------------------------------------------------------------------------
meanfunc = @meanConst; hyp.mean = 0;
covfunc  = @covLINkernel; b = 1; hyp.cov = log(b);
likfunc  = @likErf;
maxeval  = -100;

% optimise hyperparameters
if optimise_theta
    [hyp nlmls] = minimize(hyp, @prt_gp, maxeval, @infEP, meanfunc, covfunc, likfunc, K, y);    
else
    nlmls = NaN;
end

% make predictions
[a b c d lp post] = prt_gp(hyp, @infEP, meanfunc, covfunc, likfunc, ...
                           K, y, Ks, zeros(size(Ks,1),1), Kss);
                       
% Outputs
% -------------------------------------------------------------------------
p = exp(lp);
output.predictions = real(p > 0.5) + 1;
output.type        = mode;
output.p           = p;
output.loghyper    = hyp;
output.nlml        = min(nlmls);
output.alpha       = post.alpha;
output.sW          = post.sW;
output.L           = post.L;

end

