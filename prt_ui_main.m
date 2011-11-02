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

% Last Modified by GUIDE v2.5 20-Oct-2011 12:50:28

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

cc=get(handles.figure1,'Color');
[A] = imread('PRoNTo_logo.png','BackgroundColor',cc);
image(A)
axis off

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

% --- Executes on button press in datastruct.
function datastruct_Callback(hObject, eventdata, handles)
% hObject    handle to datastruct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prt_ui_design;

% --- Executes on button press in fs.
function fs_Callback(hObject, eventdata, handles)
% hObject    handle to fs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prt_ui_prepare_data


% --- Executes on button press in crval.
function crval_Callback(hObject, eventdata, handles)
% hObject    handle to crval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prt_ui_model

% --- Executes on button press in model.
function model_Callback(hObject, eventdata, handles)
% hObject    handle to model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% prt_ui_run_model

% --- Executes on button press in appmod.
function appmod_Callback(hObject, eventdata, handles)
% hObject    handle to appmod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in datarev.
function datarev_Callback(hObject, eventdata, handles)
% hObject    handle to datarev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fname=spm_select(1,'mat','Select PRT.mat',[],pwd,'PRT.mat');
try
    load(fname)
    prt_data_review('UserData',PRT);
catch
    beep
    disp('Could not load file')
    return
end

% --- Executes on button press in kerncvrev.
function kerncvrev_Callback(hObject, eventdata, handles)
% hObject    handle to kerncvrev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in resrev.
function resrev_Callback(hObject, eventdata, handles)
% hObject    handle to resrev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in batchbutt.
function batchbutt_Callback(hObject, eventdata, handles)
% hObject    handle to batchbutt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prt_batch
delete(handles.figure1)

% --- Executes on button press in credits.
function credits_Callback(hObject, eventdata, handles)
% hObject    handle to credits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

help('Contents.m');
% str = help('Contents.m'));
% fig = figure;
% set(fig,'Position',[73   145   498   1003])
% set(fig,'NumberTitle','off')
% set(fig,'Name','License & Copyright')
% h = axes('Position',[0 0 1 1],'Visible','off');
% 
% text(.025,.5,str,'FontSize',8,'FontName','Courier')
