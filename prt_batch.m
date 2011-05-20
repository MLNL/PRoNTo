function prt_batch
% Pattern Recognition for Neuroimaging Toolbox, PRONTO.
% This function prepares and launches the batch system.
% This builds the whole tree for the various tools and their GUI at the
% first call to this script.
%_______________________________________________________________________
% Copyright (C) 2011, ...

% Christophe Phillips
% $Id:$

persistent batch_initialize

if isempty(batch_initialize) || ~batch_initialize
    % Whole initialisation of SPM batch system
    spm('defaults','fMRI')
    spm_jobman('initcfg')
    % PRONTO config tree
    prt_gui = prt_cfg_batch;
    % Adding PRONTO config tree to the SPM tools
    cfg_util('addapp', prt_gui)
    % No need to do it again for this session
    batch_initialize = 1;
end

% Launching the batch system
cfg_ui

return