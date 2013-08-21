function weights = prt_weights_simpleMKL (d,args)
% Run function to compute weights for binary SVM
% FORMAT weights = prt_weights_svm_bin (d,args)
% Inputs:
%       d               - data structure
%           .datamat    - data matrix [Nfeatures x Nexamples]
%           .coeffs     - coefficients vector [Nexamples x 1]
%       args            - function arguments (can be left empty)
%           .betas      - kernel weights
%           .idfeat_img - cell with indece
% Output:
%       weights         - vector with weights [Nfeatures x 1]
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J.Mourao-Miranda

SANITYCHECK = true; % turn off for speed

% initial checks
%--------------------------------------------------------------------------
if SANITYCHECK == true
    if isempty(d)
        error('prt_weights_simpleMKL:DataEmpty',...
            'Error: ''data'' cannot be empty!');
    else
        if ~isfield(d,'datamat')
            error('prt_weights_simpleMKL:noDatamatField',...
                ['Error: ''data'' struct must contain a ''datamat'' '...
                ' field!']);
        end
        if isfield(d,'coeffs')
            if ~isvector(d.coeffs)
                error('prt_weights_simpleMKL:CoeffsnoVector',...
                    'Error: ''coeffs'' must be a vector!');
            else
                ncoeffs = length(d.coeffs);
            end
        else
            error('prt_weights_simpleMKL:noCoeffsField',...
                ['Error: ''data'' struct must contain ''coeffs'' '...
                ' field!']);
        end
        if isempty(args)
            error('prt_weights_simpleMKL:noArgsField',...
                'Error: ''Args'' cannot be empty');
        else
            if ~isfield(args,'betas')
                error('prt_weights_simpleMKL:noBetasField',...
                ['Error: ''args'' struct must contain ''betas'' '...
                ' field!']);
            end
            if ~isfield(args,'idfeat_img')
                error('prt_weights_simpleMKL:noIdField',...
                ['Error: ''args'' struct must contain ''idfeat_img'' '...
                ' field!']);
            elseif ~iscell(args.idfeat_img)
                error('prt_weights_simpleMKL:IdNoCell',...
                'Error: ''idfeat_img'' must be a cell');
            end
        end   
    end
end

% create 1D image
%--------------------------------------------------------------------------


% compute weigths

img1d     = zeros(size(d.datamat(1,:)),'single');

for k=length(d.betas)
    
    index_k = d.idfeat_img{k};
    if isempty(index_k)
        index_k = 1:length(d.datamat,2);
    end
    
    for i=1:ncoeffs
        
        tmp1 = single(d.datamat(i,index_k));
        tmp2 = single(d.coeffs(i));
        
        img1d(index_k) = img1d(index_k) + tmp1 * tmp2;
        
    end
    
    betas = single(d.betas(k));
    
    img1d(index_k) = betas * img1d(index_k);
end

% weigths
weights  = img1d;