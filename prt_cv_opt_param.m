function param=prt_cv_opt_param(PRT,ID,CV)
% Function to pass optional parameters into the classifier. This is
% primarily used for complex data prediction methods that need to know
% something about the experimental design that is normally not accessible
% to generic prediction functions (e.g. task onsets or TR). Examples of
% this kind of classifier include multi-class classifier using kernel 
% regression (MCKR) and the machine that implements nested
% cross-validation.
%
% Inputs:
% -------
%   PRT: main data structure
%   ID:  id matrix for the current cross-validation fold
%   CV:  cross-validation structure (current fold only)
%
% Outputs:
% --------
% Provides the following fields for use by the classifier
% param.cv_fold:   the vector from the CV matrix controlling this CV fold
%      .id_fold:   the id matrix for this fold
%      .group:     group data for subjects included in this fold (copied
%                  from PRT)
%      .onsets:    matrix of event onsets (n_events x n_conditions)
%      .durations: matrix of event durations (n_events x n_conditions)
%      .TR:        TR for this group/subject/modality/event
%      .unit:      units for this design 0 = scans, 1 = seconds
%      .ids:       reduced id matrix (group,subject,modality)
%
% N.B.: - The onsets, durations, TR, Unit and ids fields will only be
% populated for subjects that have a design specified that has the same
% number of events for all subjects included. This should probably be
% improved in the future.
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A Marquand 
% $Id: prt_cv_opt_param.m 169 2011-10-19 12:54:55Z amarquan $

param.cv_fold = CV;
param.id_fold = ID;

groups = unique(ID(:,1));
offset = 0;
onsets_all = []; durations_all = []; TR_all = []; unit_all = []; id_all = [];
for g = 1:length(groups)
    gidx = ID(:,1) == groups(g);
    subs = unique(ID(gidx,2));
    
    for s = 1:length(subs)
        sidx = ID(:,1) == groups(g) & ID(:,2) == subs(s);
        mods = unique(ID(sidx,3));
        for m = 1:length(mods)
            % fist check to see if the subject has a design
            if isfield(PRT.group(groups(g)).subject(subs(s)).modality(mods(m)).design,'conds')
                % save all conditions for this subject
                ons = [PRT.group(groups(g)).subject(subs(s)).modality(mods(m)).design.conds(:).onsets];
                dur = [PRT.group(groups(g)).subject(subs(s)).modality(mods(m)).design.conds(:).durations];
                
                % reshape since they are column vectors
                dur = reshape(dur,(size(ons)));
                TR = PRT.group(groups(g)).subject(subs(s)).modality(mods(m)).design.TR;
                unit = PRT.group(groups(g)).subject(subs(s)).modality(mods(m)).design.unit;
                
                param.group(groups(g)).subject(subs(s)) = ...
                    PRT.group(groups(g)).subject(subs(s));
                
                if size(onsets_all,2) == size(ons,2) || isempty(onsets_all)
                    % only populate the fields if there are the same number
                    % of conditions for every subject
                    onsets_all    = [onsets_all; ons+offset];
                    durations_all = [durations_all; dur];
                    TR_all        = [TR_all; repmat(TR, size(ons,1),1)];
                    unit_all      = [unit_all; repmat(unit, size(ons,1),1)];
                    id_all        = [id_all; repmat([groups(g) subs(s) mods(m)], size(ons,1),1)];
                    
                    if unit == 0 % scans
                        offset = offset + size(PRT.group(groups(g)).subject(subs(s)).modality(mods(m)).scans,1);
                    else % seconds
                        offset = offset + TR*size(PRT.group(groups(g)).subject(subs(s)).modality(mods(m)).scans,1);
                    end
                end
            end
        end
    end
end

% populate output fields
if ~isempty(onsets_all)
    param.onsets    = onsets_all;
    param.durations = durations_all;
    param.TR        = TR_all;
    param.unit      = unit_all;
    param.ids       = id_all;
end
end