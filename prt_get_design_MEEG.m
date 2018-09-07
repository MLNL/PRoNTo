function desn = prt_get_design_MEEG(D)
% Fill the design with the events extracted from the MEEG file. No need to
% check the design for overlap. We assume that the user has defined his/her
% epochs correctly/according to his/her needs.
% Input: 
%           - D:   loaded SPM MEEG object
% Output: design structure desn with fields:
%           - conds: with name, onsets (in s), durations (in s), associated
%           scans/epochs and discarded scans (trials marked as bad).
%           - stats: information about overlap between events. Here zero in
%           most cases.
%           - TR: here corresponding to the sampling rate.
%           - unit: 1 for seconds, 0 for scans. Here seconds.
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory
% Written by J. Schrouff

ncond = D.nconditions;
desn = struct();
conds=struct();
cname = D.condlist;
% allons = [];
alldisc = [];
allscans = [];
for c=1:ncond
    conds(c).cond_name = cname{c};
    indt = indtrial(D,cname{c}); % get trial index for each condition
    conds(c).onsets = trialonset(D,indt); %get the onsets
    conds(c).blocks = 1:length(conds(c).onsets); % compute the 'blocks' (here = epochs)
    conds(c).durations = repmat(D.nsamples/D.fsample,1,length(indt));
    
    % Estimate 'good' trials and scans
    conds(c).scans = [indtrial(D,cname{c},'good')];
    allscans = [allscans, conds(c).scans];
    badtr = indtrial(D,cname{c},'bad');
    conds(c).discardedscans = reshape(badtr,1,numel(badtr));
    alldisc = [alldisc, conds(c).discardedscans];
    conds(c).hrfdiscardedscans = [];
    goodb = ismember(indt,conds(c).scans);
    conds(c).blocks = conds(c).blocks(goodb);
    
    % Initialize covariate and RT fields
    conds(c).rt_trial = [];
    conds(c).cov_trial = [];
end
stats = struct();
% Compute overlap between events in seconds
% allons = sort(allons,'ascend');
% stats.overlap = allons(2:end)-(allons(1:end-1)+D.nsamples/D.fsample);
% stats.overlap(stats.overlap>=0) = 0;
% stats.overlap = abs(stats.overlap);
% Compute overlap in epochs (assuming epochs were defined correctly)
stats.overlap = diff(sort(allscans));
stats.goodscans = allscans;
stats.discscans = alldisc;
stats.meanovl = mean(stats.overlap);
stats.stdovl = std(stats.overlap);
stats.mgoodovl = mean(stats.overlap);
stats.sgoodovl = std(stats.overlap);
stats.goodovl = stats.overlap;
desn.conds = conds;
desn.stats = stats;
desn.TR = 1/D.fsample;
desn.unit = 1;