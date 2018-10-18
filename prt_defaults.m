function prt_defaults
% Sets the defaults which are used by the Pattern Recognition for
% Neuroimaging Toolbox, aka. PRoNTo.
%
% FORMAT prt_defaults
%_______________________________________________________________________
%
% This file can be customised to any the site/person own setup.
% Individual users can make copies which can be stored on their own
% matlab path. Make sure your 'prt_defaults' is the first one found in the
% path. See matlab documentation for details on setting path.
%
% Care must be taken when modifying this file!
%
% The structure and content of this file are largely inspired by SPM:
% http://www.fil.ion.ucl.ac.uk/spm
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by Christophe Phillips
% $Id$

%%
global prt_def

% Global defaults
% prt_loc = which('prt_batch');
% prt_def.global.install_dir = fileparts(prt_loc);
prt_def.global.install_dir = prt('dir');

% Default colors of the different elements
%-----------------------------------------------
% prt_def.color.bg1=[0 0.8 1];
% prt_def.color.bg2=[0.9,0.6,0.3];
% prt_def.color.fr=[1,0.5,0.7];
% prt_def.color.high=[0.2,0.2,0.8];

prt_def.color.bg1  = [0.83,0.83,0.83];
prt_def.color.bg2  = [0.88,0.88,0.88];
prt_def.color.fr   = [0.92,0.92,0.92];
prt_def.color.high = [0.8 0 0];
prt_def.color.black = [0 0 0];

% Parameters for the data and design
%-----------------------------------------------
prt_def.datad.hrfd = 0; % HRF delay in seconds
prt_def.datad.hrfw = 0; % HRF FWHM, used to compute the overlap between conditions

prt_def.prep.default_mask  = fullfile(prt('dir'),'masks', ...
                                'SPM_mask_noeyes.hdr');% default mask

% Preprocessing defaults
%------------------------------------------------
% memory limit for kernel/file arrays construction
prt_def.fs.mem_limit = 256*1024*1024;  % bytes of memory to use
prt_def.fs.writeraw  = 0;              % flag to write the data detrended (default) or raw (to set to 1).

% Default atlas for ROI defintion
prt_def.fs.atlasroi  = cellstr(fullfile(prt('dir'),'atlas', ...
    'aal_79x91x69.img')); 

% Design specification default
prt_def.dspec.use3 = [1 2];


% Machine lists for GUI
%------------------------------------------------------------

prt_def.machine.class_K = {'Binary support vector machine',...
    'Binary Gaussian Process Classification',...
        'Multiclass GPC'};
%         'L2-Logistic Regression', ...      
prt_def.machine.MK = {'L1 Multi-Kernel Learning'};
% handles.MK = {'L1 Multi-Kernel Learning','wip','GMKL'};
prt_def.machine.class_NK = {'Binary L2-SVM',...
    'Binary L1-SVM',...
    'Multiclass SVM',...
    'L2-Logistic Regression',...
    'L1-Logistic Regression'};
prt_def.machine.reg_K = {'Kernel Ridge Regression',...
        'Relevance Vector Regression','Gaussian Process Regression',...
        'epsilon-SVR'};
prt_def.machine.reg_NK = {'epsilon-SVR'};

% Specify model: String parameters of the different machines
%------------------------------------------------------------
% GPML toolbox
prt_def.model.gpc_sargs       = '-l erf -h';%-h 
prt_def.model.gpclap_sargs    = '-h'; %'-h';
prt_def.model.gpr_sargs       = '-l gauss -h'; % -h

%LIBSVM machines
% Classification - dual
prt_def.model.libsvm_sargs    = '-q -s 0 -t 4 -c '; %L2 SVM
% Regression - dual
prt_def.model.libeSVR_sargs    = '-q -s 3 -t 4 -c '; % e-SVR

%LIBLINEAR machines
% Classification - primal (i.e. non-kernel)
prt_def.model.libl2LR_sargs  = '-q -s 0 -B 1 -c '; % L2-regularized logistic regression
prt_def.model.libl1LR_sargs  = '-q -s 6 -B 1 -c '; % L2-regularized logistic regression
prt_def.model.libl2svm_sargs  = '-q -s 2 -B 1 -c '; % L2-regularized L2-loss support vector classification
prt_def.model.libl1svm_sargs  = '-q -s 5 -B 1 -c '; % L1-regularized L2-loss support vector classification
prt_def.model.libmulticlsvm_sargs  = '-q -s 4 -B 1 -c '; % Multiclass support vector classification by Crammer and Singer
% Classification - dual (i.e. kernel)
prt_def.model.libl2KLR_sargs  = '-q -s 7 -B 1 -c '; % L2-regularized logistic regression
% Regression - primal
prt_def.model.libl2SVR_sargs  = '-q -s 11 -B 1 -c '; % L2-regularized epsilon-support vector regression

% Multi-Task Learning - MALSAR
prt_def.model.MTL_sargs       = '';

% Specify model: Default parameter values of the different machines
%-------------------------------------------------------------------
prt_def.model.rtargs        = 601;
prt_def.model.l1MKLmaxitr   = 250;
prt_def.model.wipargs       = [1 0.5];

%LIBSVM and LIBLINEAR defaults
prt_def.model.libsvmargs    = 1; 

% MALSAR - Multi-Task Learning
prt_def.model.MTLargs       = 1;

% Specify model: Default optimization parameter values of the different machines
%--------------------------------------------------------------------------------
prt_def.model.rt_optargs        = 101:100:1001;
%LIBSVM and LIBLINEAR defaults
prt_def.model.libsvm_optargs    = 10.^[-2:3]; 

% MALSAR - Multi-Task Learning
prt_def.model.MTL_optargs       = 1;

% Parralelization of the code
%--------------------------------------------------
prt_def.paral.allow     = true; % use (or not) 'parfor' loops
prt_def.paral.ncore     = 6;     % number of cores that can be used.

return
