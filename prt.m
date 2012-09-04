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

% TODO: 
% - fix which subdirectories from all themachines are necessary, and only
%   add these to Matlab path.

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
        
        % Welcome message
        prt('ASCIIwelcome');

        % add appropriate paths, if necessary
        %   - batch dir
        if ~exist('prt_batch','file')
            addpath(fullfile(prt('Dir'),'batch'));
        end
        %   - machines
        if ~exist('prt_machine','file')
            pth_machines = fullfile(prt('Dir'),'machines');
            addpath(pth_machines);
            % add each machine's sub-directory 
            % and ALL its subdirectories recursively
            ls_machinedir = list_subdir(pth_machines);
            for ii=1:numel(ls_machinedir)
                addpath(genpath(fullfile(pth_machines,ls_machinedir{ii})))
            end
        end
        
        % utils - dirty check for the moment
        if ~exist('prt_checkAlphaNumUnder','file')
            addpath(fullfile(prt('Dir'),'utils'));
        end
        
        % check installation of machines and that of SPM8
        ok = check_installation;
        if ~ok
            beep
            fprintf('INSTALLATION PROBLEM!');
            return
        end
        
        % Add SPM's directories: matlabbatch
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
        disp( '   / /_/ / /_/ / __ \/  |/ / / / __ \   _  _<  /<  /  ');
        disp( '  / ____/ _, _/ /_/ / /|  / / / /_/ /  | |/ / / / /   ');
        disp( ' /_/   /_/ |_|\____/_/ |_/ /_/\____/   |___/_(_)_/    ');
        disp( '                                                      ');
        disp( '  PRoNTo v1.1 - http://www.mlnl.cs.ucl.ac.uk/pronto   ');
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
    case 'ver'                                             %-PRoNTo version
        %==================================================================
        % [ver, rel] = prt('Ver',Mfile,ReDo)
        %------------------------------------------------------------------
        % NOTE:
        % This bit of code is largely inspired/copied from SPM8!
        % See http://www.fil.ion.ucl.ac.uk/spm for details.
        
        if nargin ~= 3,
            ReDo = false;
        else
            ReDo = logical(varargin{3});
        end
        if nargin == 1 || (nargin > 1 && isempty(varargin{2}))
            Mfile = '';
        else
            Mfile = which(varargin{2});
            if isempty(Mfile)
                error('PRoNTo:UnknownFile','Can''t find %s on MATLABPATH.',varargin{2});
            end
        end
        
        v = get_version(ReDo);
        
        if isempty(Mfile)
            varargout = {v.Release v.Version};
        else
            unknown = struct('file',Mfile,'id','???','date','','author','');
            fp  = fopen(Mfile,'rt');
            if fp == -1, error('Can''t read %s.',Mfile); end
            str = fread(fp,Inf,'*uchar');
            fclose(fp);
            str = char(str(:)');
            r = regexp(str,['\$Id: (?<file>\S+) (?<id>[0-9]+) (?<date>\S+) ' ...
                '(\S+Z) (?<author>\S+) \$'],'names','once');
            if isempty(r), r = unknown; end
            varargout = {r(1).id v.Release};
        end
        
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
%=======================================================================
% Function to check installation state of machines and SPM

ok = true;

% Check SPM installation
if exist('spm.m','file')
    [SPMver, SPMrel] = spm('Ver');
    if ~(strcmpi(SPMver,'spm8') && str2double(SPMrel)>8.5)
        beep
        fprintf('\nERROR:\n')
        fprintf('\tThe *latest* version of SPM8 should be installed on your computer,\n')
        fprintf('\tand be available on MATLABPATH!\n\n')
        ok = false;
    end
else
    beep
    fprintf('\nERROR:\n')
    fprintf('\tThe *latest* version of SPM8 should be installed on your computer,\n')
    fprintf('\tand be available on MATLABPATH!\n\n')
    ok = false;
end


% Check for compiled routines
%============================
% - svm
dumb = which('svmtrain');
% if ~isempty(findstr('libsvm',dumb))
if ~isempty(strfind(dumb,'libsvm'))
    disp('SVM path OK')
else
    beep
    warning('PRoNTo:SVMcompilation', ...
        ['SVM path not recognized. Please check that: \n', ...
        '- PRoNTo was added with all subfolders \n',...
        '- PRoNTo is above the biostats Matlab toolbox \n',...
        'Otherwise, the routines surely need to be re-compiled for your OS \n',...
        'Please look on the web or ask on the mailing list for assistance'])
end

% - GP
dumb = which('solve_chol');
if ~isempty(dumb) && ~isempty(strfind(dumb,'.mex'))
    disp('GP path: OK')
else
    beep
    disp('GP not compiled: routines will work but be slower')
end

% - RF
dumb = which('rtenslearn_c');
if ~isempty(dumb) || ~isempty(strfind(dumb,'.mex'))
    disp('RF path OK')
else
    beep
    warning('PRoNTo:RFcompilation', ...
        ['RF path not recognized. Please check that \n', ...
        'PRoNTo was added with all subfolders \n',...
        'Otherwise, the routines surely need to be re-compiled for your OS \n',...
        'Please look on the web or ask on the mailing list for assistance'])
end

return

%=======================================================================
function lsdir = list_subdir(pth_dir,rejd)
%=======================================================================
% function that returns the list of subdirectories of a directory,
% rejecting those beginning with some characters ('.', '@' and '_' by
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

%=======================================================================
function v = get_version(ReDo)                 %-Retrieve PRoNTo version
%=======================================================================
persistent PRoNTo_VER;
v = PRoNTo_VER;
if isempty(PRoNTo_VER) || (nargin > 0 && ReDo)
    v = struct('Name','','Version','','Release','','Date','');
    try
        vfile = fullfile(prt('Dir'),'Contents.m');
        fid = fopen(vfile,'rt');
        if fid == -1, error(str); end
        l1 = fgetl(fid); l2 = fgetl(fid);
        fclose(fid);
        l1 = strtrim(l1(2:end)); l2 = strtrim(l2(2:end));
        t  = textscan(l2,'%s','delimiter',' '); t = t{1};
        v.Name = l1; v.Date = t{4};
        v.Version = t{2}; v.Release = t{3}(2:end-1);
    catch %#ok<CTCH>
        error('PRoNTo:getversion', ...
            'Can''t obtain PRoNTo Revision information.');
    end
    PRoNTo_VER = v;
end
