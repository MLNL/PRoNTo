function [outfile]=prt_cv_model(PRT,in)
% Function to run a cross-validation structure on a given model
%
% Inputs:
% -------
% PRT:             data structure
% in.fname:        filename for PRT.mat (string)
% in.model_name:   name for this model (string)
%
% Outputs:
% --------
% Writes the following fields in the PRT data structure:
%
% PRT.model(m).output.fold(i).targets:     targets for fold(i)
% PRT.model(m).output.fold(i).predictions: predictions for fold(i)
% PRT.model(m).output.fold(i).stats:       statistics for fold(i)
% PRT.model(m).output.fold(i).{custom}:    optional fields
%
% Notes:
% ------
% The PRT.model(m).input fields are set by prt_init_model, not by
% this function
%
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A Marquand
% $Id$

prt_dir = char(regexprep(in.fname,'PRT.mat', ''));

% Get index of specified model
mid = prt_init_model(PRT, in);

% configure some variables
CV       = PRT.model(mid).input.cv_mat;     % CV matrix
n_folds  = size(CV,2);                      % number of CV folds
samp_idx = PRT.model(mid).input.samp_idx;   % which samples are in the model

% targets
if isfield(PRT.model(mid).input,'include_allscans') && ...
        PRT.model(mid).input.include_allscans
    t = PRT.model(mid).input.targ_allscans;
else
    t = PRT.model(mid).input.targets;
end

%get number of classes
if strcmpi(PRT.model(mid).input.type,'classification')
    nc=max(unique(t));
else
    nc=[];
end
fdata.nc = nc;


% load data files and configure ID matrix
disp('Loading data files.....>>');
for i = 1:length(PRT.model(mid).input.fs)
    %Backwards compatibility with v0 and v1: transform kernel into cell if needed
    if PRT.model(mid).input.use_kernel
        fid = prt_init_fs(PRT, PRT.model(mid).input.fs(i));
        load(fullfile(prt_dir, PRT.fs(fid).k_file));
        if ~iscell(Phi)
            Phi = {Phi};
        end
    end
    
    %first case: combine feature sets
    if length(PRT.model(mid).input.fs)>1
        n_Phi = length(PRT.model(mid).input.fs);
        Phi_all=[];
        
        if i == 1
            ID = PRT.fs(fid).id_mat(PRT.model(mid).input.samp_idx,:);
        end
        
        if PRT.model(mid).input.use_kernel
            for j = 1:length(Phi)
                Phi_all = [Phi_all, {Phi{j}(samp_idx,samp_idx)}]; % in case one feature set comprises multiple kernels already
            end
        else
            error('training with features not implemented yet');
            %vname = whos('-file', [prt_dir,PRT.fs(fid).fs_file]);
            %eval(['Phi_all{',num2str(i),'}=',vname,'(samp_idx,:);']);
        end
    else
        %If only one feature set, load kernel to see which case
        if PRT.model(mid).input.use_kernel
            ID = PRT.fs(fid).id_mat(samp_idx,:);
            if length(Phi)==1
                Phi_all{1} = Phi{1}(samp_idx,samp_idx);
            else
                %Check that if multiple kernels, MKL was selected,
                %otherwise add the kernels (normalized)
                if isempty(strfind(PRT.model(mid).input.machine.function,'MKL'))
                    warning('prt_cv_model:AddKernels',...
                        'Multiple kernels but machine cannot deal with them, adding the kernels');
                    Phi_tmp = zeros(length(samp_idx));
                    for j=1:length(Phi)
                        try
                            %normalize each kernel before adding
                            tp = Phi{j}(samp_idx,samp_idx);
%                             tp =
%                             prt_normalise_kernel(Phi{j}(samp_idx,samp_idx));
                            Phi_tmp=Phi_tmp + tp;
                        catch
                            error('prt_cv_model:KernelsWithDifferentDimensions', ...
                                'Kernels cannot be added since they have different dimensions')
                        end
                    end
                    Phi_all{1} = Phi_tmp;
                    clear Phi_tmp
                else
                    Phi_all=cell(1,length(Phi));
                    for j=1:length(Phi)
                        Phi_all{j}=Phi{j}(samp_idx,samp_idx);
%                         Phi_all{j}=prt_normalise_kernel(Phi{j}(samp_idx,s
%                         amp_idx));
                    end
                end
            end
        else
            error('training with features not implemented yet');
            %vname = whos('-file', [prt_dir,PRT.fs(fid).fs_file]);
            %eval(['Phi_all{',num2str(i),'}=',vname,'(samp_idx,:);']);
        end
    end
end
clear Phi

% Begin cross-validation loop
% -------------------------------------------------------------------------
PRT.model(mid).output=struct();
PRT.model(mid).output.fold = struct();
for f = 1:n_folds
    disp ([' > running CV fold: ',num2str(f),' of ',num2str(n_folds),' ...'])
    % configure data structure for prt_cv_fold
    fdata.ID      = ID;
    fdata.mid     = mid; %index of model
    fdata.CV      = CV(:,f);
    fdata.Phi_all = Phi_all; %kernel(s)
    fdata.t       = t; %targets
    
    % Nested CV for hyper-parameter optimisation or feature selection
    if isfield(PRT.model(mid).input,'use_nested_cv')
        if PRT.model(mid).input.use_nested_cv
            [out] = prt_nested_cv(PRT, fdata);
            PRT.model(mid).output.fold(f).param_effect = out;
        end
    end
    
    % compute the model for this CV fold
    [model, targets] = prt_cv_fold(PRT,fdata);
    
    %for classification check that for each fold, the test targets have been trained
    if strcmpi(PRT.model(mid).input.type,'classification')
        if ~all(ismember(unique(targets.test),unique(targets.train)))
            beep
            disp('At least one class is in the test set but not in the training set')
            disp('Abandoning modelling, please correct class selection/cross-validation')
            return
        end
    end
    
    % compute stats
    stats = prt_stats(model, targets.test, nc); %targets.train
    
    % update PRT
    PRT.model(mid).output.fold(f).targets     = targets.test;
    PRT.model(mid).output.fold(f).predictions = model.predictions(:);
    PRT.model(mid).output.fold(f).stats       = stats;
    % copy other fields from the model
    flds = fieldnames(model);
    for fld = 1:length(flds)
        fldnm = char(flds(fld));
        if ~strcmpi(fldnm,'predictions')
            PRT.model(mid).output.fold(f).(fldnm)=model.(fldnm);
        end
    end
end


% Model level statistics (across folds)
ttt             = vertcat(PRT.model(mid).output.fold(:).targets);
m.type        = PRT.model(mid).output.fold(1).type;
m.predictions = vertcat(PRT.model(mid).output.fold(:).predictions);
%m.func_val    = [PRT.model(mid).output.fold(:).func_val];
stats         = prt_stats(m,ttt(:),nc);

PRT.model(mid).output.stats=stats;


% Save PRT containing machine output
% -------------------------------------------------------------------------
outfile = [prt_dir, filesep,'PRT.mat'];
disp('Updating PRT.mat.......>>')
if spm_check_version('MATLAB','7') < 0
    save(outfile,'-V6','PRT');
else
    save(outfile,'PRT');
end
end

