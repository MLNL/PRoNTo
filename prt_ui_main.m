function varargout = prt_ui_main(varargin)
% PRT_UI_MAIN M-file for prt_ui_main.fig
% 
% PRT_UI_MAIN, by itself, creates a new PRT_UI_MAIN or raises the existing
% singleton*.
%
% H = PRT_UI_MAIN returns the handle to a new PRT_UI_MAIN or the handle to
% the existing singleton*.
%
% PRT_UI_MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
% function named CALLBACK in PRT_UI_MAIN.M with the given input arguments.
%
% PRT_UI_MAIN('Property','Value',...) creates a new PRT_UI_MAIN or raises 
% the existing singleton*.  Starting from the left, property value pairs are
% applied to the GUI before prt_ui_main_OpeningFcn gets called.  An
% unrecognized property name or invalid value makes property application
% stop.  All inputs are passed to prt_ui_main_OpeningFcn via varargin.
%
% *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%  instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Schrouff
% $Id$

% Edit the above text to modify the response to help prt_ui_main

% Last Modified by GUIDE v2.5 14-Aug-2018 11:46:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @prt_ui_main_OpeningFcn, ...
    'gui_OutputFcn',  @prt_ui_main_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before prt_ui_main is made visible.
function prt_ui_main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_ui_main (see VARARGIN)

Tag='prtmain';
F = findall(allchild(0),'Flat','Tag',Tag);
if length(F) > 1
    % Multiple Graphics windows - close all but most recent
    close(F(2:end))
    F = F(1);
    uistack(F,'top')
elseif length(F)==1
    uistack(F,'top')
else
    set(handles.figure1,'Tag',Tag)
    set(handles.figure1,'Name','PRoNTo ::')
    
    %set size of the window, taking screen resolution and platform into account
    S0= spm('WinSize','0',1);   %-Screen size (of the current monitor)
    if ispc
        PF='MS Sans Serif';
    else
        PF= spm_platform('fonts');     %-Font names (for this platform)
        PF=PF.helvetica;
    end
    tmp  = [S0(3)/1280 (S0(4))/800];
    ratio=min(tmp)*[1 1 1 1];
    FS = 1 + 0.85*(min(ratio)-1);  %factor to scale the fonts
    x=get(handles.figure1,'Position');
    set(handles.figure1,'DefaultTextFontSize',FS*8,...
        'DefaultUicontrolFontSize',FS*8,...
        'DefaultTextFontName',PF,...
        'DefaultAxesFontName',PF,...
        'DefaultUicontrolFontName',PF)
    set(handles.figure1,'Position',ratio.*x)
    % set(handles.figure1,'Units','normalized')
    set(handles.figure1,'Resize','on')
    
    % Choose the color of the different backgrounds and figure parameters
    color=prt_get_defaults('color');
    set(handles.figure1,'Color',color.bg1)
    aa=get(handles.figure1,'children');
    for i=1:length(aa)
        if strcmpi(get(aa(i),'type'),'uipanel')
            set(aa(i),'BackgroundColor',color.bg2)
            bb=get(aa(i),'children');
            if ~isempty(bb)
                for j=1:length(bb)
                    if strcmpi(get(bb(j),'type'),'uipanel')
                        set(bb(j),'BackgroundColor',color.bg2)
                        cc=get(bb(j),'children');
                        for k=1:length(cc)
                            if ~isempty(find(strcmpi(get(cc(k),'Style'),{'text',...
                                    'radiobutton','checkbox'})))
                                set(cc(k),'BackgroundColor',color.bg2)
                            elseif ~isempty(find(strcmpi(get(cc(k),'Style'),'pushbutton')))
                                set(cc(k),'BackgroundColor',color.fr)
                            end
                            set(cc(k),'FontUnits','pixel')
                            xf=get(cc(k),'FontSize');
                            set(cc(k),'FontSize',ceil(FS*xf),'FontName',PF,...
                                'FontUnits','normalized','Units','normalized')
                        end
                    else
                        if ~isempty(find(strcmpi(get(bb(j),'Style'),{'text',...
                                'radiobutton','checkbox'})))
                            set(bb(j),'BackgroundColor',color.bg2)
                        elseif ~isempty(find(strcmpi(get(bb(j),'Style'),'pushbutton')))
                            set(bb(j),'BackgroundColor',color.fr)
                        end
                        set(bb(j),'FontUnits','pixel')
                        xf=get(bb(j),'FontSize');
                        set(bb(j),'FontSize',ceil(FS*xf),'FontName',PF,...
                            'FontUnits','normalized','Units','normalized')
                    end
                end
            end
        else
            if ~isempty(find(strcmpi(get(aa(i),'Style'),{'text',...
                    'radiobutton','checkbox','listbox'})))
                set(aa(i),'BackgroundColor',color.bg1)
            elseif ~isempty(find(strcmpi(get(aa(i),'Style'),'pushbutton')))
                set(aa(i),'BackgroundColor',color.fr)
            end
        end
        set(aa(i),'FontUnits','pixel')
        xf=get(aa(i),'FontSize');
        set(aa(i),'FontSize',ceil(FS*xf),'FontName',PF,...
            'Units','normalized')
    end

end 
% cc=get(handles.figure1,'Color');
% [A] = imread('PRoNTo_logo.png','BackgroundColor',cc);
% image(A)
% axis off
% Choose default command line output for prt_ui_main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes prt_ui_main wait for user response (see UIRESUME)
% uiwait(handles.figure1)


% --- Outputs from this function are returned to the command line.
function varargout = prt_ui_main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Closing the figure
function figure1_DeleteFcn(hObject,eventdata,handles)
% hObject    handle to datastruct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);

% --- Executes on button press in datastruct: data and design
function datastruct_Callback(hObject, eventdata, handles)
% hObject    handle to datastruct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prt_ui_design;

% --- Executes on button press in fs: compute feature set
function fs_Callback(hObject, eventdata, handles)
% hObject    handle to fs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Load PRT  to see if we need to launch prt_ui_fs_datatype or if only one
% type of data in PRT structure (i.e. either images or MEEG but not both).

PRT     = spm_select(1,'mat','Select PRT.mat',[],pwd,'PRT.mat');
if isempty(PRT)
    disp('No PRT selected')
    return
end
fname = PRT;
pathdir = regexprep(PRT,'PRT.mat', '');
handles.pathdir = pathdir;
handles.prtdir=fileparts(PRT);
load(PRT);
% Get type of data from the masks
nm = length(PRT.masks);
flagim = 0;
flagMEEG = 0;
flagmat = 0;
for i=1:nm
    if isfield(PRT.masks(i),'type') && strcmpi(PRT.masks(i).type,'MEEG')
        flagMEEG = flagMEEG + 1;
        mod_type = 'MEEG';
    elseif isfield(PRT.masks(i),'type') && strcmpi(PRT.masks(i).type,'nifti')
        flagim = flagim + 1;
        mod_type = 'nifti';
    elseif isfield(PRT.masks(i),'type') && strcmpi(PRT.masks(i).type,'.mat')
        flagmat = flagmat +1;
        mod_type = 'mat';
    end
end
if flagMEEG && flagim && flagmat
    prt_ui_fs_alldatatype('UserData',{PRT,fname}) % User chooses whether to build feature set for MEEG or images
elseif (flagMEEG && flagim)||(flagMEEG && flagmat)||(flagim && flagmat)
    prt_ui_fs_datatype('UserData',{PRT,fname})
else
    prt_ui_prepare_data('UserData',{PRT,flagMEEG,fname,mod_type})
end


% --- Executes on button press in crval: model specification
function crval_Callback(hObject, eventdata, handles)
% hObject    handle to crval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prt_ui_model

% --- Executes on button press in copy_model: copy previously specified
% model
function copy_model_Callback(hObject, eventdata, handles)
% hObject    handle to copy_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prt_ui_copy_model

% --- Executes on button press in model: run model
function model_Callback(hObject, eventdata, handles)
% hObject    handle to model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prt_ui_cv_model

% --- Executes on button press in compweights: compute weights
function compweights_Callback(hObject, eventdata, handles)
% hObject    handle to compweights (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prt_ui_compute_weights

% --- Executes on button press in datarev: review data and design
function datarev_Callback(hObject, eventdata, handles)
% hObject    handle to datarev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fname=spm_select(1,'mat','Select PRT.mat',[],pwd,'PRT.mat');
prtdir=fileparts(fname);
try
    load(fname)
    prt_data_review('UserData',{PRT,prtdir});
catch
    beep
    disp('Could not load file')
    return
end

% --- Executes on button press in kerncvrev: review kernel and CV
function kerncvrev_Callback(hObject, eventdata, handles)
% hObject    handle to kerncvrev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fname=spm_select(1,'mat','Select PRT.mat',[],pwd,'PRT.mat');
prtdir=fileparts(fname);
try
    load(fname)
catch
    beep
    disp('Could not load file')
    return
end
prt_ui_reviewmodel('UserData',{PRT,prtdir});

% --- Executes on button press in resrev: display results - stats
function resrev_Callback(hObject, eventdata, handles)
% hObject    handle to resrev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prt_ui_results_stats

% --- Executes on button press in dispweights: display weights
function dispweights_Callback(hObject, eventdata, handles)
% hObject    handle to dispweights (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prt_ui_disp_weights

% --- Executes on button press in batchbutt: open batch interface
function batchbutt_Callback(hObject, eventdata, handles)
% hObject    handle to batchbutt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prt_batch
% [afm] stopped this from closing the main window
%delete(handles.figure1)

% --- Executes on button press in credits.
function credits_Callback(hObject, eventdata, handles)
% hObject    handle to credits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

help('prt_contents.m');
% str = help('Contents.m'));
% fig = figure;
% set(fig,'Position',[73   145   498   1003])
% set(fig,'NumberTitle','off')
% set(fig,'Name','License & Copyright')
% h = axes('Position',[0 0 1 1],'Visible','off');
% 
% text(.025,.5,str,'FontSize',8,'FontName','Courier')
