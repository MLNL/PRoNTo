function varargout = prt(varargin)
% Pattern Recognition for Neuroimaging Toolbox, PRoNTo.
%
% This function initializes things for PRoNTo and provides some low level
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
    case 'startup'                                    % Startup the toolbox
        %==================================================================
        
        % check installation of toolbox and that of SPM8
        ok = check_installation;
        if ~ok
            beep
            fprintf('INSTALLATION PROBLEM!');
            return
        end
        
        % Welcome message
        prt('ASCIIwelcome');
        
        % add appropriate paths, if necessary
        % batch dir
        if ~exist('prt_batch','file')
            addpath(fullfile(prt('Dir'),'batch'));
        end
        % machines
        if ~exist('prt_machine','file')
            pth_machines = fullfile(prt('Dir'),'machines');
            addpath(pth_machines);
            % add each machine sub-directory
            ls_machinedir = list_subdir(pth_machines);
            for ii=1:numel(ls_machinedir)
                addpath(fullfile(pth_machines,ls_machinedir{ii}))
            end
        end
        % utils - dirty check for the moment
        if ~exist('prt_checkAlphaNumUnder','file')
            addpath(fullfile(prt('Dir'),'utils'));
        end
        
        
        % in particular SPM's directories: matlabbatch
        if ~exist('cfg_util','file')
            addpath(fullfile(spm('Dir'),'matlabbatch'));
        end
        
        % intialize the matlabbatch system
        cfg_get_defaults('cfg_util.genscript_run', @genscript_run);
        cfg_util('initcfg');
        clear prt_batch;
        
        % launch the main GUI
        prt_ui_main;
        
        % print present working directory
        fprintf('PRoNTo present working directory:\n\t%s\n',pwd)
        
        
        %==================================================================
    case 'asciiwelcome'                       %-ASCII PRoNTo banner welcome
        %==================================================================
        disp( '                                                      ');
        disp( '     ____  ____        _   ________                   ');
        disp( '    / __ \/ __ \____  / | / /_  __/_         ___ ___  ');
        disp( '   / /_/ / /_/ / __ \/  |/ / / / __ \   _  _<  // _ \ ');
        disp( '  / ____/ _, _/ /_/ / /|  / / / /_/ /  | |/ / // // / ');
        disp( ' /_/   /_/ |_|\____/_/ |_/ /_/\____/   |___/_(_)___/  ');
        disp( '                                                      ');
        disp( '  PRoNTo v1.0 - http://www.mlnl.cs.ucl.ac.uk/pronto   ');
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

%=======================================================================
function ok = check_installation
% function to check installation state of toolbox,
% particullarly the SPM path setup

ok=1;

if exist('spm.m','file')
    if ~strcmpi(spm('ver'),'spm8')
        beep
        fprintf('\nERROR:\n')
        fprintf('\tSPM8 should be installed on your computer, and\n')
        fprintf('\tbe available on MATLABPATH!\n\n')
        ok = 0;
    end
else
    beep
    fprintf('\nERROR:\n')
    fprintf('\tSPM8 should be installed on your computer, and\n')
    fprintf ('\tbe available on MATLABPATH!\n\n')
    ok = 0;
end

return

%=======================================================================
function lsdir = list_subdir(pth_dir,rejd)
% function that returns the list of subdirectories of a directory,
% rejection those beginning with some characters ('.', '@' and '_' by 
% default) 

if nargin<2
    rejd = '.@_';
end
if nargin<1
    pth_dir = pwd;
end

tmp = dir(pth_dir);
ld = find([tmp.isdir]); ld([1 2]) = [];
lsdir = {tmp(ld).name};
if ~isempty(rejd)
    for ii=1:numel(rejd)
        lrej = find(strncmp(rejd(ii),lsdir,1));
        if ~isempty(lrej)
            lsdir(lrej) = [];
        end
    end
end
    
return
