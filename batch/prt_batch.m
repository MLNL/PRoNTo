function prt_batch
% Pattern Recognition for Neuroimaging Toolbox, PRoNTo.
%
% This function prepares and launches the batch system.
% This builds the whole tree for the various tools and their GUI at the
% first call to this script.
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by Christophe Phillips
% $Id: prt_batch.m 79 2011-09-28 09:45:12Z cphillip $

persistent batch_initialize

if isempty(batch_initialize) || ~batch_initialize
    % Whole initialisation of SPM batch system
    try
        spm('defaults','fMRI')
        spm_jobman('initcfg')
    catch
        error('Can''t run SPM. Please check it''s in the search path');
    end
    
    % Add path to nifti toolbox
    addpath([prt_get_defaults('global.install_dir'),'/LIB/NII_lib']);
    
    % PRONTO config tree
    prt_gui = prt_cfg_batch;
    % Adding PRoNTo config tree to the SPM tools
    cfg_util('addapp', prt_gui)
    % No need to do it again for this session
    batch_initialize = 1;
end

% Launching the batch system
cfg_ui

return