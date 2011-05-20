function out = prt_run_design(varargin)
% PRONTO job execution function
% takes a harvested job data structure and rearranges data into PRT
% data structure, then saves PRT.mat file.
%
% Input:
% job    - harvested job data structure (see matlabbatch help)
% Output:
% out    - filename of saved data structure.
%__________________________________________________________________________
% Copyright (C) 2011, ...

% Written by M.J.Rosa
% $Id: $


% Job variable
% -------------------------------------------------------------------------
job   = varargin{1};

% Directory
% -------------------------------------------------------------------------
fname   = 'PRT.mat';
fname   = fullfile(job.dir_name{1},fname);
PRT.dir = fname;

% Number of group
% -------------------------------------------------------------------------
ngroup    = length(job.group);

% Masks
% -------------------------------------------------------------------------
nmasks    = length(job.fmask);
PRT.masks = job.fmask;


% Make PRT.mat
% -------------------------------------------------------------------------

% Data type
if isfield(job.group(1).select,'modality')
    nmod_scans = length(job.group(1).select.modality);
    for g = 1:ngroup
        nmod = length(job.group(g).select.modality);

        nsub = length(job.group(g).select.modality(1).subjects);

        % Check if the number of masks and conditions is the same
        if nmod ~= nmasks || nmod ~= nmod_scans
            out.files{1} = [];
            msgbox('Error: incorrect number of modalities or masks!')
            return
        else
            % Modalities
            PRT.group(g).gr_name  = job.group(g).gr_name;

            % Subjects
            for s = 1:nsub,
                for m = 1:nmod,
                    ns = length(job.group(g).select.modality(m).subjects);
                    if nsub ~= ns
                        out.files{1} = [];
                        msgbox('Error: incorrect number of subjects!')
                        return
                    else
                        PRT.group(g).subject(s).modality(m).scans{1} = job.group(g).select.modality(m).subjects{s};
                        PRT.group(g).subject(s).modality(m).mod_name = job.group(g).select.modality(m).mod_name;
                        PRT.group(g).subject(s).modality(m).quant    = job.group(g).select.modality(m).quant;
                        PRT.group(g).subject(s).modality(m).design   = 0;
                    end
                end
            end
        end

    end
else
    for g = 1:ngroup,
        nmod_subjs = length(job.group(1).select.subject{1});
        nsubj = length(job.group(g).select.subject);
        for j = 1:nsubj,
            nmod = length(job.group(g).select.subject{j});
            % Check if the number of masks and conditions is the same
            if nmod ~= nmasks || nmod ~= nmod_subjs
                out.files{1} = [];
                msgbox('Error: incorrect number of modalities or masks!')
                return

            else
                for k = 1:nmod,
                    clear design
                    % Load SPM.mat design
                    if isfield(job.group(g).select.subject{j}(k).design,'load_SPM')
                        try
                            load(job.group(g).select.subject{j}(k).design.load_SPM{1});
                        catch
                            error('Cannot load SPM.mat file');
                        end
                        ncond = length(SPM.Sess(1).U);
                        for c = 1:ncond
                            conds(c).cond_name = SPM.Sess(1).U(c).name{1};
                            conds(c).onsets    = SPM.Sess(1).U(c).ons;
                            conds(c).durations = SPM.Sess(1).U(c).dur;
                        end
                        design.conds = conds;
                        design.covar = [];
                        design.TR    = SPM.xX.K.RT;
                    else
                        % No design
                        if isfield(job.group(g).select.subject{j}(k).design,'no_design')
                            design = job.group(g).select.subject{j}(k).design.no_design;
                        else
                            % Create new design
                            if ~isempty(job.group(g).select.subject{j}(k).design.new_design.multi_conds{1})
                                multi_fname = job.group(g).select.subject{j}(k).design.new_design.multi_conds{1};
                                % Multiple conditions
                                try
                                    multicond = load(multi_fname);
                                catch
                                    error('Cannot load %s',multi_fname);
                                end
                                for mc = 1:length(multicond.onsets)
                                    conds(mc).cond_name  = multicond.names{mc};
                                    conds(mc).onsets     = multicond.onsets{mc};
                                    conds(mc).durations  = multicond.durations{mc};
                                end
                                design.conds = conds;
                            else
                                design.conds = job.group(g).select.subject{j}(k).design.new_design.conds;
                            end
                            design.covar = job.group(g).select.subject{j}(k).design.new_design.covar;
                            design.TR    = job.group(g).select.subject{j}(k).design.new_design.TR;
                        end
                    end
                    % Create PRT.mat modalities
                    PRT.group(g).gr_name                       = job.group(g).gr_name;
                    PRT.group(g).subject(j).modality(k)        = job.group(g).select.subject{j}(k);
                    PRT.group(g).subject(j).modality(k).design = design;   
                end

            end
        end
    end
end

% Save PRT.mat file
% -------------------------------------------------------------------------
disp('Saving PRT.mat.......>>')
if spm_matlab_version_chk('7') >= 0
    save(fname,'-V6','PRT');
else
    save(fname,'PRT');
end

% Function output
% -------------------------------------------------------------------------
out.files{1} = fname;
disp('Done')

return