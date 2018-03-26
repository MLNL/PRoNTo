function out = prt_run_design(varargin)
%
% PRoNTo job execution function
% takes a harvested job data structure and rearranges data into PRT
% data structure, then saves PRT.mat file.
%
% INPUT
%   job    - harvested job data structure (see matlabbatch help)
%
% OUTPUT
%   out    - filename of saved data structure.
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory
%
% Written by M.J.Rosa & J. Schrouff
% $Id$


% Job variable
% -------------------------------------------------------------------------
job   = varargin{1};

% Directory
% -------------------------------------------------------------------------
fname   = 'PRT.mat';
fname   = fullfile(job.dir_name{1},fname);

% Number of group
% -------------------------------------------------------------------------
ngroup    = length(job.group);

% Masks
% -------------------------------------------------------------------------
nmasks     = length(job.mask);
dd = prt_get_defaults('datad');

% Back compatibility (at least trying to...)
if isfield(job,'hrfover')  % old setup, with HRF parameters in main branch
    hrfover = job.hrfover;
    hrfdel  = job.hrfdel;
elseif isfield(job,'fmri_des')
    hrfover = job.fmri_des.hrfover;
    hrfdel = job.fmri_des.hrfdel;
else
    hrfover = dd.hrfw;
    hrfdel = dd.hrfd;
end

for i = 1:nmasks
    mod_names{i}      = job.mask(i).mod_name;
    masks(i).mod_name = mod_names{i};
    masks(i).type     = job.mask(i).tmask;
    if isfield(masks(i).type, 'niftimask')
        masks(i).type     = 'nifti';
        masks(i).fname    = char(job.mask(i).tmask.niftimask.fmask);
        if isfield(job.mask(i),'hrfover')
            hrfover = job.mask(i).hrfover;
            hrfdel = job.mask(i).hrfdel;
        end
    elseif isfield(masks(i).type, 'MEEGmask')
        masks(i).type     = 'MEEG';
        masks(i).fname    = [];
    elseif isfield(masks(i).type, 'matmask')
        masks(i).type     = '.mat';
        masks(i).fname    = [];
    end
    masks(i).hrfoverlap = hrfover;
    masks(i).hrfdelay = hrfdel;
end

mod_names_uniq = unique(mod_names);

if nmasks ~= length(mod_names_uniq)
    out.files{1} = [];
    beep;
    sprintf('Names of mask modalities repeated! Please correct!')
    return
end

% Make PRT.mat
% -------------------------------------------------------------------------

% Data type
datformat = {'nifti','MEEG','.mat'};
if isfield(job.group(1).select,'modality')
    % selection by "images" in a modality
    nmod_scans = length(job.group(1).select.modality);
    for g = 1:ngroup
        
        clear mod_names_mod
        nmod   = length(job.group(g).select.modality);
        nsub   = length(job.group(g).select.modality(1).subjects);
        
        % Check if the number of masks and conditions is the same
        if nmod ~= nmod_scans
            out.files{1} = [];
            beep;
            sprintf('Numbers of modalities in groups 1 and %d differ!',g)
            disp('Please correct!')
            return
        else
            if nmod ~= nmasks
                out.files{1} = [];
                beep;
                sprintf('Number of modalities in group %d different from number of masks!',g)
                disp('Please correct!')
                return               
            else
                % Modalities
                PRT.group(g).gr_name  = job.group(g).gr_name;
                % Subjects
                for s = 1:nsub
                    subj_name = sprintf('S%d',s);
                    for m = 1:nmod
                        modnm   = job.group(g).select.modality(m).mod_name;
                        ns      = length(job.group(g).select.modality(m).subjects);
                        if ~isempty(job.group(g).select.modality(m).rt_subj)
                                rt_subj = job.group(g).select.modality(m).rt_subj(:);
                                if length(rt_subj) ~= ns
                                    out.files{1} = [];
                                    beep
                                    sprintf('Number of regression targets must be the number of subjects/scans! ')
                                    disp('Please correct!')
                                    return
                                else
                                    PRT.group(g).subject(s).modality(m).rt_subj = rt_subj(s);
                                end
                        else
                            PRT.group(g).subject(s).modality(m).rt_subj = [];
                        end
                        if ~isempty(job.group(g).select.modality(m).covar{1})
                            try
                                load(char(job.group(g).select.modality(m).covar{1}));
                                if exist('R','var')
                                    if size(R,1)==ns
                                        PRT.group(g).subject(s).modality(m).covar  = R(s,:);
                                    else
                                        out.files{1} = [];
                                        beep
                                        sprintf('Number of covariates must be the number of subjects/scans! ')
                                        disp('Please correct!')
                                        return
                                    end
                                else
                                    out.files{1} = [];
                                    beep
                                    sprintf('Covariates file must contain ''R'' variable! ')
                                    disp('Please correct!')
                                    return
                                end
                            catch
                                beep
                                sprintf('Could not load %s file!',char(job.group(g).select.modality(m).covar{1}))
                                out.files{1} = [];
                                return
                            end
                        else
                            PRT.group(g).subject(s).modality(m).covar  = [];
                        end
                        mod_names_mod{m} = modnm;
                        if isempty(intersect(mod_names_uniq,modnm))
                            out.files{1} = [];
                            beep
                            sprintf('Incorrect modality name %s for subject %d group %d! ',modnm,s,g)
                            disp('Please correct!')
                            return
                        end
                        if nsub ~= ns
                            out.files{1} = [];
                            beep
                            sprintf('Number of subjects in modality %d and 1 of group %d are different! ',m,g)
                            disp('Please correct!')
                            return
                        else
                            PRT.group(g).subject(s).subj_name            = subj_name;
                            PRT.group(g).subject(s).modality(m).mod_name = job.group(g).select.modality(m).mod_name;
                            PRT.group(g).subject(s).modality(m).design   = 0;
                            PRT.group(g).subject(s).modality(m).scans    = char(job.group(g).select.modality(m).subjects{s});
                            PRT.group(g).subject(s).modality(m).type     = datformat{job.group(g).select.modality(m).format};
                        end
                    end
                    if nmod ~= length(unique(mod_names_mod))
                        out.files{1} = [];
                        beep;
                        sprintf('Names of modalities in group %d repeated! Please correct!',g)
                        return
                    end
                end
            end
        end
    end
else
    % selection by subject
    for g = 1:ngroup  
        
        nmod_subjs = length(job.group(1).select.subject{1});
        nsubj  = length(job.group(g).select.subject);
        nsubj1 = length(job.group(1).select.subject);
        
        if nsubj ~= nsubj1
            disp('Warning: unbalanced groups.')
        end
        for j = 1:nsubj
            clear mod_names_subj
            subj_name = sprintf('S%d',j);
            nmod = length(job.group(g).select.subject{j});
            % Check if the number of masks and conditions is the same
            if nmod ~= nmod_subjs
                out.files{1} = [];
                beep
                sprintf('Numbers of modalities in subjects 1 and %d from group %d differ!',j,g)
                disp('Please correct!')
                return
            else
                if nmod ~= nmasks
                    out.files{1} = [];
                    beep
                    sprintf('Number of modalities in group %d subject %d different from number of masks!',g,j)
                    disp('Please correct!')
                    return
                else
                    for k = 1:nmod
                        modnm    = job.group(g).select.subject{j}(k).mod_name;
                        TR       = job.group(g).select.subject{j}(k).TR;
                        mod_names_subj{k} = modnm;
                        modtype  = datformat{job.group(g).select.subject{j}(k).format};
                        if isempty(intersect(mod_names_uniq,modnm))
                            out.files{1} = [];
                            beep
                            sprintf('Incorrect modality name %s for subject %d group %d! ',modnm,j,g)
                            disp('Please correct!')
                            return
                        end
                        clear design
                        imask=ismember(mod_names,modnm); %get which mask for HRF info
                        if strcmpi(modtype,'nifti') && ...
                                isfield(job.group(g).select.subject{j}(k).design,'load_SPM')
                            % Load SPM.mat design
                            try
                                load(job.group(g).select.subject{j}(k).design.load_SPM{1});
                            catch
                                out.files{1} = [];
                                beep
                                disp('Could not load SPM.mat file!')
                                return
                            end
                            switch lower(SPM.xBF.UNITS)
                                case 'scans'
                                    unit   = 0;
                                case 'seconds'
                                    unit   = 1;
                                case 'secs'
                                    unit   = 1;
                            end        
                            nscans  = length(job.group(g).select.subject{j}(k).scans);
                            ncond   = length(SPM.Sess(1).U);
                            for c = 1:ncond
                                conds(c).cond_name = SPM.Sess(1).U(c).name{1}; %#ok<*AGROW>
                                conds(c).onsets    = SPM.Sess(1).U(c).ons;
                                conds(c).durations = SPM.Sess(1).U(c).dur;
                            end                        
                            checked_conds = prt_check_design(conds,TR,unit,masks(imask).hrfoverlap,masks(imask).hrfdelay);
                            design.conds  = checked_conds.conds;
                            design.stats  = checked_conds.stats;
                            design.TR     = TR;
                            design.unit   = unit;
                            maxcond       = max([design.conds(:).scans]);
                            if nscans>1 && nscans < maxcond
                                sprintf('Design of subject %d, group %d, modality %d, exceeds time series!',j,g,k)
                                disp('Corresponding events were discarded')
                                for l = 1:length(design.conds)
                                    ovser = find(design.conds(l).scans > nscans);
                                    inser = find(design.conds(l).scans <= nscans);
                                    design.conds(l).discardedscans = [design.conds(l).discardedscans, design.conds(l).scans(ovser)];
                                    design.conds(l).scans = design.conds(l).scans(inser);
                                    design.conds(l).blocks = design.conds(l).blocks(inser);
                                end
                            end
                        elseif (~strcmpi(modtype,'nifti') && ...
                                isfield(job.group(g).select.subject{j}(k).design,'load_SPM')) || ...
                                (~strcmpi(modtype,'nifti') && ...
                                isfield(job.group(g).select.subject{j}(k).design,'new_design'))
                            beep
                            disp('Design options can only be specified for nifti inputs')
                            out.files{1} = [];
                            return
                        elseif ~strcmpi(modtype,'MEEG')
                            if isfield(job.group(g).select.subject{j}(k).design,'no_design')
                                % No design
                                design = 0;
                                
                                % One covariate vector per subject?
                                if isfield(job.group(g).select.subject{j}(k).design.no_design,'covarcond') && ...
                                        ~isempty(job.group(g).select.subject{j}(k).design.no_design.cov_trial)
                                    try
                                        load(job.group(g).select.subject{j}(k).design.no_design.cov_trial{1});
                                        if exist('R','var')
                                            if size(R,1)==1
                                                PRT.group(g).subject(j).modality(k).covar  = R(1,:);
                                            else
                                                out.files{1} = [];
                                                beep
                                                sprintf('Number of covariates must be the number of subjects/scans! ')
                                                disp('Please correct!')
                                                return
                                            end
                                        else
                                            out.files{1} = [];
                                            beep
                                            sprintf('Covariates file must contain ''R'' variable! ')
                                            disp('Please correct!')
                                            return
                                        end
                                    catch
                                        beep
                                        sprintf('Could not load %s file!',char(job.group(g).select.subject{j}(k).design.no_design.cov_trial))
                                        out.files{1} = [];
                                        return
                                    end
                                end
                                % One regression target per subject?
                                if ~isempty(job.group(g).select.subject{j}(k).design.no_design.rt_trial)
                                    rt_cond = job.group(g).select.subject{j}(k).design.no_design.rt_trial;
                                    if length(rt_cond) ~= 1
                                        out.files{1} = [];
                                        beep
                                        sprintf('Number of regression targets must be the number of subjects, i.e. 1! ')
                                        disp('Please correct!')
                                        return
                                    else
                                        PRT.group(g).subject(j).modality(k).rt_subj = rt_cond;
                                    end
                                else
                                    PRT.group(g).subject(j).modality(k).rt_subj = [];
                                end
                                
                            else
                                % Manual design
                                nscans = length(job.group(g).select.subject{j}(k).scans);
                                unit   = job.group(g).select.subject{j}(k).design.new_design.unit;
                                % Create new design
                                if ~isempty(job.group(g).select.subject{j}(k).design.new_design.multi_conds{1})
                                    multi_fname = job.group(g).select.subject{j}(k).design.new_design.multi_conds{1};
                                    % Multiple conditions
                                    try
                                        load(multi_fname);
                                    catch
                                        beep
                                        sprintf('Could not load %s file!',multi_fname)
                                        out.files{1} = [];
                                        return
                                    end
                                    try
                                        multicond.names = names;
                                    catch
                                        beep
                                        disp('No "names" found in the .mat file, please select another file!')
                                        out.files{1} = [];
                                        return
                                    end
                                    try
                                        multicond.durations = durations;
                                    catch
                                        beep
                                        disp('No "durations" found in the .mat file, please select another file!')
                                        out.files{1} = [];
                                        return
                                    end
                                    try
                                        multicond.onsets = onsets;
                                    catch
                                        beep
                                        disp('No "onsets" found in the .mat file, please select another file!')
                                        out.files{1} = [];
                                        return
                                    end
                                    try
                                        multicond.rt_trial = rt_trial;
                                    catch
                                        multicond.rt_trial = cell(length(multicond.onsets),1);
                                    end
                                    try
                                        multicond.cov_trial = R;
                                    catch
                                        multicond.cov_trial = cell(length(multicond.onsets),1);
                                    end
                                    for mc = 1:length(multicond.onsets)
                                        conds(mc).cond_name  = multicond.names{mc};
                                        conds(mc).onsets     = multicond.onsets{mc};
                                        conds(mc).durations  = multicond.durations{mc};
                                        conds(mc).rt_trial   = multicond.rt_trial{mc};
                                        conds(mc).cov_trial  = multicond.cov_trial{mc};
                                        lons = length(conds(mc).onsets);
                                        if isfield(conds(mc),'rt_trial') && ...
                                                ~isempty(conds(mc).rt_trial)
                                            lreg = length(conds(mc).rt_trial);
                                            if  lreg ~= lons
                                                out.files{1} = [];
                                                beep
                                                sprintf('Number of regression targets must be the number of trials!')
                                                disp('Please correct')
                                                return
                                            end
                                        end
                                        if isfield(conds(mc),'cov_trial') && ...
                                                ~isempty(conds(mc).cov_trial)
                                            lcov = size(conds(mc).cov_trial,1);
                                            if  lcov ~= lons
                                                out.files{1} = [];
                                                beep
                                                sprintf('Number of covariates must be the number of trials!')
                                                disp('Please correct')
                                                return
                                            end
                                        end
                                    end
                                    design.conds = conds;
                                    covar = [];
                                else
                                    design.conds = job.group(g).select.subject{j}(k).design.new_design.conds;
                                    covar = []; % No covariates if design, to be updated in v3.0
                                ncond = length(design.conds);
                                for c = 1:ncond
                                    lons = length(design.conds(c).onsets);
                                    ldur = length(design.conds(c).durations);
                                    if ldur == 1
                                        design.conds(c).durations = repmat(design.conds(c).durations, 1, lons);
                                        ldur = length(design.conds(c).durations);
                                    end
                                    if ldur ~= lons
                                        out.files{1} = [];
                                        beep
                                        sprintf('The onsets and durations of condition %d do not have the same size!', c)
                                        disp('Please correct')
                                        return
                                    end
                                    if isfield(design.conds(c),'rt_trial') && ~isempty(design.conds(c).rt_trial)
                                        lreg = length(design.conds(c).rt_trial);
                                        if lreg ~= lons
                                            out.files{1} = [];
                                            beep
                                            sprintf('Number of regression targets must be the number of trials!')
                                            disp('Please correct')
                                            return
                                        end
                                    elseif ~isfield(design.conds(c),'rt_trial')
                                        design.conds(c).rt_trial=[];
                                    end
                                    if isfield(design.conds(c),'cov_trial') && ~isempty(design.conds(c).cov_trial)
                                        try
                                            load(design.conds.cov_trial{1});
                                            if exist('R','var')
                                                if size(R,1)== lons
                                                    design.conds(c).cov_trial  = R;
                                                else
                                                    out.files{1} = [];
                                                    beep
                                                    sprintf('Number of covariates must be the number of trials! ')
                                                    disp('Please correct!')
                                                    return
                                                end
                                            else
                                                out.files{1} = [];
                                                beep
                                                sprintf('Covariates file must contain ''R'' variable! ')
                                                disp('Please correct!')
                                                return
                                            end
                                        catch
                                            beep
                                            sprintf('Could not load %s file!',char(design.conds(c).cov_trial))
                                            out.files{1} = [];
                                            return
                                        end
                                    end
                                end
                                end  
                                
                                checked_conds = prt_check_design(design.conds,TR,unit,masks(imask).hrfoverlap,masks(imask).hrfdelay);
                                design.conds  = checked_conds.conds;
                                design.stats  = checked_conds.stats;
                                design.TR     = checked_conds.TR;
                                design.unit   = unit;
                                design.covar  = covar;
                                maxcond       = max([design.conds(:).scans]);
                                if nscans>1 && nscans < maxcond
                                    sprintf('Design of subject %d, group %d, modality %d, exceeds time series!',j,g,k)
                                    disp('Corresponding events were discarded')                                  
                                    for l = 1:length(design.conds)
                                        ovser = find(design.conds(l).scans > nscans);
                                        inser = find(design.conds(l).scans <= nscans);
                                        design.conds(l).discardedscans = [design.conds(l).discardedscans, design.conds(l).scans(ovser)];
                                        design.conds(l).scans = design.conds(l).scans(inser);
                                        design.conds(l).blocks = design.conds(l).blocks(inser);   
                                    end
                                end
                            end
                        elseif strcmpi(modtype,'MEEG')
                            scan = char(job.group(g).select.subject{j}(k).scans);
                            D = spm_eeg_load(scan(1,:));
                            desn = prt_get_design_MEEG(D);
                            desn.covar = [];
                            design=desn;
                            clist = {design.conds(:).cond_name};
                            % Add regression targets or covariates for each
                            % class if user specified
                            if isfield(job.group(g).select.subject{j}(k).design,'MEEGevents') && ...  % All the way down to each class
                                isfield(job.group(g).select.subject{j}(k).design.MEEGevents,'addregcov') && ...
                                  isfield(job.group(g).select.subject{j}(k).design.MEEGevents.addregcov,'condsadd') && ...
                                   isstruct(job.group(g).select.subject{j}(k).design.MEEGevents.addregcov.condsadd)
                               addconds = job.group(g).select.subject{j}(k).design.MEEGevents.addregcov;
                               for c = 1:length(addconds)
                                   cond_name = addconds.condsadd(c).cond_name;
                                   ic = find(ismember(clist,cond_name));
                                   if isfield(addconds.condsadd(c),'rt_trial') && ~isempty(addconds.condsadd(c).rt_trial)
                                       % Check that regression targets were
                                       % entered for every onset
                                       reg = addconds.condsadd(c).rt_trial;
                                       if length(design.conds(ic).onsets) == length(reg)
                                           design.conds(ic).rt_trial = reg;
                                       else
                                            out.files{1} = [];
                                            beep
                                            sprintf('Number of regression targets must be the number of trials, including bad trials!')
                                            disp('Please correct')
                                       end
                                   end
                                    if isfield(addconds.condsadd(c),'cov_trial') && ~isempty(addconds.condsadd(c).cov_trial)
                                        try
                                            load(addconds.condsadd.cov_trial{1});
                                            if exist('R','var')
                                                % Take out 'bad trials' from regression targets
                                                if length(design.conds(ic).onsets) == size(R,1)
                                                    design.conds(ic).cov_trial  = R;
                                                else
                                                    out.files{1} = [];
                                                    beep
                                                    sprintf('Number of covariates must be the number of trials, including bad trials! ')
                                                    disp('Please correct!')
                                                    return
                                                end
                                            else
                                                out.files{1} = [];
                                                beep
                                                sprintf('Covariates file must contain ''R'' variable! ')
                                                disp('Please correct!')
                                                return
                                            end
                                        catch
                                            beep
                                            sprintf('Could not load %s file!',char(addconds.condsadd.cov_trial))
                                            out.files{1} = [];
                                            return
                                        end
                                    end
                               end
                            end
                        end
                        % Create PRT.mat modalities
                        PRT.group(g).gr_name                        = job.group(g).gr_name;
                        PRT.group(g).subject(j).subj_name           = subj_name;
                        PRT.group(g).subject(j).modality(k).mod_name= job.group(g).select.subject{j}(k).mod_name;
                        PRT.group(g).subject(j).modality(k).TR      = job.group(g).select.subject{j}(k).TR;
                        PRT.group(g).subject(j).modality(k).design  = design;
                        PRT.group(g).subject(j).modality(k).scans   = char(job.group(g).select.subject{j}(k).scans);
                        PRT.group(g).subject(j).modality(k).type    = modtype;
                        % For MEEG inputs, only one file allowed
                        % per subject and modality
                        if strcmpi(modtype,'MEEG')
                            nscans = size(PRT.group(g).subject(j).modality(k).scans,1);
                            if nscans>1
                                beep
                                disp('Only one MEEG input file per subject and per modality is allowed')
                                disp('Please correct.')
                                out.files{1} = [];
                                return
                            end
                        end
                        
                    end
                end
            end
            if nmod ~= length(unique(mod_names_subj));
                out.files{1} = [];
                beep;
                sprintf('Names of modalities in subject %d group %d repeated! Please correct!',j,g)
                return
            end
        end
    end
end

% Save masks at the end
% -------------------------------------------------------------------------
PRT.masks  = masks;

% Save PRT.mat file
% -------------------------------------------------------------------------
disp('Saving PRT.mat.......>>')
if spm_check_version('MATLAB','7') < 0
    save(fname,'-V6','PRT');
else
    save(fname,'PRT');
end

% Review
% -------------------------------------------------------------------------
if job.review
    prt_data_review('UserData',{PRT,job.dir_name{1}});
end
    
% Function output
% -------------------------------------------------------------------------
out.files{1} = fname;
% get the group_names
for g = 1:ngroup
    out.(sprintf('gr_name%d',g)) = PRT.group(g).gr_name;
end
% get the mod_names -> use the ones from the masks!
for m = 1:numel(mod_names_uniq)
    out.(sprintf('mod_name%d',m)) = mod_names_uniq{m};
end

disp('Done')

return

% Old code to deal with covariates per trial
% if ~isempty(job.group(g).select.subject{j}(k).design.new_design.covar{1})
%     try
%         load(char(job.group(g).select.subject{j}(k).design.new_design.covar{1}));
%         if exist('R','var')
%             if size(R,1) == nscans
%                 covar = R;
%             else
%                 out.files{1} = [];
%                 beep
%                 sprintf('Number of covariates must be the number of scans! ')
%                 disp('Please correct!')
%                 return
%             end
%         else
%             out.files{1} = [];
%             beep
%             sprintf('Covariates file must contain ''R'' variable! ')
%             disp('Please correct!')
%             return
%         end
%     catch
%         beep
%         sprintf('Could not load %s file!',char(job.group(g).select.subject{j}(k).design.new_design.covar{1}))
%         out.files{1} = [];
%         return
%     end
% else
%     
% end
