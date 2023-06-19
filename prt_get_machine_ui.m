function [machine] = prt_get_machine_ui(is_class,is_kernel,name)
% Function to gather the machine name and arguments (string and values) for a specific machine name, whether kernel or non-kernel.
%inputs:
% - is_class: 1 for classification, 0 for regression
% - is_kernel: 1 for kernel machines, 0 for non-kernel
% - name: name of the machine in the GUI
%--------------------------------------------------------------------------
% Written by J. Schrouff for PRoNTo

def = prt_get_defaults('model');
machine.s_args = '';
machine.args = [];

% Classification
% ---------------
if is_class
    
    % Kernel machines
    %-----------------
    if is_kernel
        
        % LIBSVM SVM
        if any(strfind(name,'Binary support'))
            machine.function='prt_machine_svm_bin';
            machine.args= def.libsvmargs;
            machine.s_args = def.libsvm_sargs;
            
        % Binary GPC
        elseif any(strfind(name,'Binary Gaussian'))
            machine.function='prt_machine_gpml';
            machine.s_args= def.gpc_sargs;
            
        % Multiclass GPC
        elseif any(strfind(name,'Multiclass GPC'))
            machine.function='prt_machine_gpclap';
            machine.s_args = def.gpclap_sargs;
            
        % simple MKL
        elseif any(strfind(name,'Multi-Kernel'))
            machine.function='prt_machine_sMKL_cla';
            machine.args = def.libsvmargs;
        % ENMKL
            if any(strfind(name,'Elastic-net'))
                machine.function='prt_machine_ENMKL_SVM';
                machine.args = def.enmklargs;
            end
            
        % Logistic Regression
        elseif any(strfind(name,'Logistic'))
            machine.function='prt_machine_liblinearsvm';
            machine.s_args = def.libl2KLR_sargs;
            machine.args = def.libsvmargs;
        end
        
    % Non-Kernel machines
    %---------------------
    else
        % L2 - SVM
        if any(strfind(name,'L2-SVM'))
            machine.function='prt_machine_liblinearsvm';
            machine.s_args = def.libl2svm_sargs;
            machine.args = def.libsvmargs;
            
        % L1-SVM
        elseif any(strfind(name,'L1-SVM'))
            machine.function='prt_machine_liblinearsvm';
            machine.s_args = def.libl1svm_sargs;
            machine.args = def.libsvmargs;
        
        % L2-Logistic
        elseif any(strfind(name,'L2-Logistic'))
            machine.function='prt_machine_liblinearsvm';
            machine.s_args = def.libl2LR_sargs;
            machine.args = def.libsvmargs;
        
        % L1-Logistic
        elseif any(strfind(name,'L1-Logistic'))
            machine.function='prt_machine_liblinearsvm';
            machine.s_args = def.libl1LR_sargs;
            machine.args = def.libsvmargs;
        
        % Multiclass SVM
        elseif any(strfind(name,'Multiclass SVM'))
            machine.function='prt_machine_liblinearsvm';
            machine.s_args = def.libmulticlsvm_sargs;
            machine.args = def.libsvmargs;
        
        % Random Trees
        elseif any(strfind(name,'Random'))
            machine.function='prt_machine_RT_bin';
            machine.args = def.rtargs;
        end
    end
    
% Regression machines
%---------------------
else
    
    % Kernel machines
    %-----------------
    if is_kernel
        
        % epsilon-SVR
        if any(strfind(name,'epsilon'))
            machine.function='prt_machine_svm_bin';
            machine.args= def.libsvmargs;
            machine.s_args = def.libeSVR_sargs;
            
        % Kernel Ridge Regression
        elseif any(strfind(name,'Ridge'))
            machine.function='prt_machine_krr';
            machine.args = def.libsvmargs;
        
        %Relevance Vector Machine
        elseif any(strfind(name,'Relevance'))
            machine.function='prt_machine_rvr';

        % Gaussian process
        elseif any(strfind(name,'Process Regression'))
            machine.function='prt_machine_gpr';
            machine.s_args= def.gpr_sargs;
            
        % simpleMKL
        elseif any(strfind(name,'Multi-Kernel'))
            machine.function='prt_machine_sMKL_reg';
            machine.args= def.libsvmargs;
        % ENMKL
            if any(strfind(name,'Elastic-net'))
                machine.function='prt_machine_ENMKL_KRR';
                machine.args = def.enmklargs;
            end
        end
        
    % Non-Kernel machines
    %---------------------    
    else
        % epsilon-SVR
        if any(strfind(name,'epsilon'))
            machine.function='prt_machine_liblinearsvm';
            machine.args= def.libsvmargs;
            machine.s_args = def.libl2SVR_sargs;
        end
    end
end