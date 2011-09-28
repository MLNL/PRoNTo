function varargout = prt_text_input(varargin)
% PRT_TEXT_INPUT M-file for prt_text_input.fig
%      PRT_TEXT_INPUT, by itself, creates a new PRT_TEXT_INPUT or raises the existing
%      singleton*.
%
%      H = PRT_TEXT_INPUT returns the handle to a new PRT_TEXT_INPUT or the handle to
%      the existing singleton*.
%
%      PRT_TEXT_INPUT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PRT_TEXT_INPUT.M with the given input arguments.
%
%      PRT_TEXT_INPUT('Property','Value',...) creates a new PRT_TEXT_INPUT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before prt_text_input_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to prt_text_input_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J.Schrouff
% $Id$

% Edit the above text to modify the response to help prt_text_input

% Last Modified by GUIDE v2.5 24-Aug-2011 15:32:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prt_text_input_OpeningFcn, ...
                   'gui_OutputFcn',  @prt_text_input_OutputFcn, ...
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


% --- Executes just before prt_text_input is made visible.
function prt_text_input_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_text_input (see VARARGIN)

% Choose default command line output for prt_text_input
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

if ~isempty(varargin) && strcmpi(varargin{1},'Title')
    set(gcf,'Name',varargin{2});
    if length(varargin)>3 && strcmpi(varargin{3},'UserData')
        set(handles.edit1,'String',varargin{4})
        handles.output = get(handles.edit1,'String');
    end
end

% Update handles structure
guidata(hObject, handles);

%UIWAIT makes prt_text_input wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prt_text_input_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in okbutton.
function okbutton_Callback(hObject, eventdata, handles)
% hObject    handle to okbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);

% --- Executes on button press in cancelbutton.
function cancelbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
handles.output=[];
uiresume(handles.figure1);
