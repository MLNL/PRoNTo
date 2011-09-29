function varargout = prt(varargin)
% Pattern Recognition for Neuroimaging Toolbox, PRoNTo.
%
% This function initializes things for PRoNTo and provide some low level
% functionalities
%
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by Christophe Phillips
% $Id$

%-Format arguments
%-----------------------------------------------------------------------
if nargin == 0,
    Action = 'StartUp';
else
    Action = varargin{1};
end

switch lower(Action)
        %==================================================================
    case 'startup'                                    % Startup teh toolbox
        %==================================================================
        
        % Welcome message
        prt('ASCIIwelcome');
        
        % check installation of toolbox and that of SPM8
        check_installation;
        
        % add appropriate path, if necessary
        % in particular SPM's directories: matlabbatch
        if ~exist('cfg_util','file')
            addpath(fullfile(spm('Dir'),'matlabbatch'));
        end
        
        % intialize the matlabbatch system, if necessary
        cfg_get_defaults('cfg_util.genscript_run', @genscript_run);
        cfg_util('initcfg');
        
        % launch the main GUI
        prt_ui_main;
        
        % print present working directory
        fprintf('PRoNTo present working directory:\n\t%s\n',pwd)
        
        
        %==================================================================
    case 'asciiwelcome'                       %-ASCII PRoNTo banner welcome
        %==================================================================
        disp( '                                                    ');
        disp( '     ____  ____        _   ________                 ');
        disp( '    / __ \/ __ \____  / | / /_  __/_                ');
        disp( '   / /_/ / /_/ / __ \/  |/ / / / __ \               ');
        disp( '  / ____/ _, _/ /_/ / /|  / / / /_/ /               ');
        disp( ' /_/   /_/ |_|\____/_/ |_/ /_/\____/                ');
        disp( '                                                    ');
        disp( ' PRoNTo - http://www.mlnl.cs.ucl.ac.uk/pronto       ');
        fprintf('\n');
        
        %==================================================================
    case 'dir'                          %-Identify specific (SPM) directory
        %==================================================================
        % prt('Dir',Mfile)
        %------------------------------------------------------------------
        if nargin<2,
            Mfile='prt';
        else
            Mfile=varargin{2};
        end
        PRTdir = which(Mfile);
        
        if isempty(PRTdir)             %-Not found or full pathname given
            if exist(Mfile,'file')==2  %-Full pathname
                PRTdir = Mfile;
            else
                error(['Can''t find ',Mfile,' on MATLABPATH']);
            end
        end
        PRTdir    = fileparts(PRTdir);
        varargout = {PRTdir};
        
        %==================================================================
    otherwise                                       %-Unknown action string
        %==================================================================
        error('Unknown action string');
        
end

return

%=======================================================================
%% SUBFUNCTIONS
%=======================================================================

function ok = check_installation
% function to check installation state of toolbox,
% particullarly the path setup

ok=1;

return


