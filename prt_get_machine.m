function [model] = prt_get_machine(model,jobmach)
% Function to gather the machine functions and parameters, with potential
% hyper-parameter optimization
% inputs:
% -model being constructed
% -machine as in job
%--------------------------------------------------------------------------
% Written by J. Schrouff


%Gather machine function
% -------------------------------------------------------------------------
opt = [];

% Kernel machines for classification
% -------------------------------------------------------------------------

%SVM
if isfield(jobmach,'svm')
    model.machine.function = 'prt_machine_svm_bin';
    model.machine.s_args     = jobmach.svm.svm_sargs;
    opt = jobmach.svm.svm_opt;
  
% Gaussian Processes
elseif isfield(jobmach,'gpc')
    model.machine.function='prt_machine_gpml';
    model.machine.s_args     = jobmach.gpc.gpc_sargs;
    
% Multiclass Gaussian Processes
elseif isfield(jobmach,'gpclap')
    model.machine.function='prt_machine_gpclap';
    model.machine.s_args     = jobmach.gpclap.gpclap_sargs;
    
% Simple-MKL
elseif isfield(jobmach,'sMKL_cla')
    model.machine.function='prt_machine_sMKL_cla';
    model.machine.s_args='';
    opt = jobmach.sMKL_cla.svm_opt;
    
% ENMKL
elseif isfield(jobmach,'ENMKL_cla')
    model.machine.function='prt_machine_ENMKL_SVM';
    model.machine.s_args='';
    opt = jobmach.ENMKL_cla.enmkl_opt;
    
% L2 Logistic Regression
elseif isfield(jobmach,'libl2KLR')
    model.machine.function='prt_machine_liblinearsvm';
    model.machine.s_args     = jobmach.libl2KLR.libl2KLR_sargs;
    opt = jobmach.libl2KLR.svm_opt;
    
% Non-kernel machines for classfication
%--------------------------------------------------------------------------
    
% L1-SVM from Liblinear
elseif isfield(jobmach,'libl1svm')
    model.machine.function = 'prt_machine_liblinearsvm';
    model.machine.s_args     = jobmach.libl1svm.libl1svm_sargs;
    opt = jobmach.libl1svm.svm_opt;
    
% L2-SVM from Liblinear
elseif isfield(jobmach,'libl2svm')
    model.machine.function = 'prt_machine_liblinearsvm';
    model.machine.s_args     = jobmach.libl2svm.libl2svm_sargs;
    opt = jobmach.libl2svm.svm_opt;
    
% Multi-class SVM from Liblinear
elseif isfield(jobmach,'libmulticlsvm')
    model.machine.function = 'prt_machine_liblinearsvm';
    model.machine.s_args     = jobmach.libmulticlsvm.libmulticlsvm_sargs;
    opt = jobmach.libmulticlsvm.svm_opt;

% L2-Logistic Regression from Liblinear
elseif isfield(jobmach,'libl2LR')
    model.machine.function = 'prt_machine_liblinearsvm';
    model.machine.s_args     = jobmach.libl2LR.libl2LR_sargs;
    opt = jobmach.libl2LR.svm_opt;

% L1-Logistic Regression from Liblinear
elseif isfield(jobmach,'libl1LR')
    model.machine.function = 'prt_machine_liblinearsvm';
    model.machine.s_args     = jobmach.libl1LR.libl1LR_sargs;
    opt = jobmach.libl1LR.svm_opt;
    
% Regression machines - dual
% -------------------------------------------------------------------------
% Kernel Ridge Regression
elseif isfield(jobmach,'krr')
    model.machine.function = 'prt_machine_krr';
    model.machine.s_args     = '';
    opt = jobmach.krr.svm_opt;
  
% % New Machine  
% elseif isfield(jobmach,'new_machine')
%     model.machine.function = 'prt_new_machine';
%     model.machine.s_args     = '';
%     opt = jobmach.krr.svm_opt;
    
% Relevance Vector Regression
elseif isfield(jobmach,'rvr')
    model.machine.function='prt_machine_rvr';
    model.machine.s_args     = '';
	% K.T. Edit 03/2019
	model.machine.args     = [];
    
% Gaussian Processes regression
elseif isfield(jobmach,'gpr')
    model.machine.function='prt_machine_gpr';
    model.machine.s_args     = jobmach.gpr.gpr_sargs;
    
% Simple MKL regression
elseif isfield(jobmach,'sMKL_reg')
    model.machine.function='prt_machine_sMKL_reg';
    model.machine.s_args     = '';
    opt = jobmach.sMKL_reg.svm_opt;
    
% ENMKL
elseif isfield(jobmach,'ENMKL_reg')
    model.machine.function='prt_machine_ENMKL_KRR';
    model.machine.s_args='';
    opt = jobmach.ENMKL_reg.enmkl_opt;

% epsilon-SVR
elseif isfield(jobmach,'libeSVR')
    model.machine.function = 'prt_machine_svm_bin';
    model.machine.s_args = jobmach.libeSVR.libeSVR_sargs;
    opt = jobmach.libeSVR.svm_opt;
    
% Non-kernel machines for regression
% -------------------------------------------------------------------------
elseif isfield(jobmach,'libl2SVR')
    model.machine.function = 'prt_machine_liblinearsvm';
    model.machine.s_args = jobmach.libl2SVR.libl2SVR_sargs;
    opt = jobmach.libl2SVR.svm_opt;
    
% Other machines
% -------------------------------------------------------------------------

% Random Forest (currently not in use)
elseif isfield(jobmach,'rt')
    model.machine.function='prt_machine_RT_bin';
    opt = jobmach.rt.rt_opt;
    
% Custom machine
else
    [pat, nam] = fileparts(char(jobmach.custom_machine.machine_func));
    model.machine.function = nam;
    if isfield(jobmach.custom_machine,'machine_sargs')
        model.machine.s_args     = jobmach.custom_machine.machine_sargs;
    else
        model.machine.s_args  = '';
    end
    
    if isfield(jobmach.custom_machine.machine_opt, 'machine_no_opt')
        model.machine.args  = jobmach.custom_machine.machine_opt.machine_no_opt;
    else
    opt = jobmach.custom_machine.machine_opt;
    end
end

% Get optimization and parameters
% -------------------------------------------------------------------------
cv_tmp = [];
if ~isempty(opt)
    if isfield(opt,'svm_opt_C') % Most machines use the same Log parameter
        model.cv.nested = 1;
        model.cv.nested_param = opt.svm_opt_C.svm_args;
        cv_tmp = prt_get_cv_type(opt.svm_opt_C.cv_type_nested);
        model.machine.args = [];        
    elseif isfield(opt,'svm_no_opt')
        model.cv.nested = 0;
        model.machine.args = opt.svm_no_opt;
        model.cv.nested_param = [];
    elseif isfield(opt,'rt_opt_T') % Random Forest optimizes trees
        model.cv.nested = 1;
        model.cv.nested_param = opt.rt_opt_T.rt_args;
        cv_tmp = prt_get_cv_type(opt.rt_opt_T.cv_type_nested);
        model.machine.args = [];        
    elseif isfield(opt,'rt_no_opt')
        model.cv.nested = 0;
        model.machine.args = opt.rt_no_opt;
        model.cv.nested_param = [];
    elseif isfield(opt,'machine_opt_p') % custom machine
        model.cv.nested = 1;
        model.cv.nested_param = opt.machine_opt_p.machine_args;
        cv_tmp = prt_get_cv_type(opt.machine_opt_p.cv_type_nested); %machine_cv_type_nested
        model.machine.args = [];        
    elseif isfield(opt,'rt_no_opt')
        model.cv.nested = 0;
        model.machine.args = opt.machine_no_opt;
        model.cv.nested_param = [];
    elseif isfield(opt,'enmkl_opt_p') % ENMKL
        model.cv.nested = 1;
        model.cv.nested_param = opt.enmkl_opt_p.enmkl_args;
        cv_tmp = prt_get_cv_type(opt.enmkl_opt_p.cv_type_nested);
        model.machine.args = [];
    elseif isfield(opt,'enmkl_no_opt') % ENMKL
        model.cv.nested = 0;
        model.machine.args = opt.enmkl_no_opt;
        model.cv.nested_param = [];
    end
else
    model.cv.nested = 0;
    model.cv.nested_param = [];
end

if ~isempty(cv_tmp)
    model.cv.type_nested = cv_tmp.type;
    model.cv.k_nested = cv_tmp.k;
else
    model.cv.type_nested = '';
    model.cv.k_nested = 0;
end
