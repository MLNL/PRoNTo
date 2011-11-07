function varargout = prt_ui_compute_weights(varargin)
% PRT_UI_COMPUTE_WEIGHTS M-file for prt_ui_compute_weights.fig
%      PRT_UI_COMPUTE_WEIGHTS, by itself, creates a new PRT_UI_COMPUTE_WEIGHTS or raises the existing
%      singleton*.
%
%      H = PRT_UI_COMPUTE_WEIGHTS returns the handle to a new PRT_UI_COMPUTE_WEIGHTS or the handle to
%      the existing singleton*.
%
%      PRT_UI_COMPUTE_WEIGHTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PRT_UI_COMPUTE_WEIGHTS.M with the given input arguments.
%
%      PRT_UI_COMPUTE_WEIGHTS('Property','Value',...) creates a new PRT_UI_COMPUTE_WEIGHTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before prt_ui_compute_weights_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to prt_ui_compute_weights_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help prt_ui_compute_weights

% Last Modified by GUIDE v2.5 07-Nov-2011 12:08:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prt_ui_compute_weights_OpeningFcn, ...
                   'gui_OutputFcn',  @prt_ui_compute_weights_OutputFcn, ...
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


% --- Executes just before prt_ui_compute_weights is made visible.
function prt_ui_compute_weights_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_ui_compute_weights (see VARARGIN)

% Choose default command line output for prt_ui_compute_weights
handles.output = hObject;
set(handles.compbutt,'Enable','off')
handles.img_name=[];
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes prt_ui_compute_weights wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prt_ui_compute_weights_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_prt_Callback(hObject, eventdata, handles)
% hObject    handle to edit_prt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_prt as text
%        str2double(get(hObject,'String')) returns contents of edit_prt as a double
handles.fname=get(handles.edit_prt,'String');
handles.prtdir=fileparts(handles.fname);
if exist('PRT','var')
    clear PRT
end
try
    load(handles.fname)
    handles.dat=PRT;
catch
    beep
    disp('Could not load file')
    return
end
%fill the list of models
if ~isfield(handles.dat,'model')
    beep
    disp('No model found in this PRT')
    disp('Please specify model first')
    delete(handles.figure1)
end
handles.indm=[];
for i=1:length(handles.dat.model)
    if ~isempty(handles.dat.model.output)
        handles.indm=[handles.indm,i];
    end
end
if isempty(handles.indm)
    beep
    disp('No model computed in this PRT')
    disp('Please specify AND run model before computing weights')
    return
end
list={handles.dat.model(:).model_name};
set(handles.pop_models,'String',list(handles.indm))
set(handles.pop_models,'Value',1)
handles.selmod=handles.indm(1);
set(handles.compbutt,'Enable','on')
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_prt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_prt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in br_prt.
function br_prt_Callback(hObject, eventdata, handles)
% hObject    handle to br_prt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.fname=spm_select(1,'.mat','Select PRT.mat',[],pwd,'PRT.mat');
set(handles.edit_prt,'String',handles.fname)
handles.prtdir=fileparts(handles.fname);
if exist('PRT','var')
    clear PRT
end
try
    load(handles.fname)
    handles.dat=PRT;
catch
    beep
    disp('Could not load file')
    return
end
%fill the list of models
if ~isfield(handles.dat,'model')
    beep
    disp('No model found in this PRT')
    disp('Please specify model first')
    delete(handles.figure1)
end
handles.indm=[];
for i=1:length(handles.dat.model)
    if ~isempty(handles.dat.model.output)
        handles.indm=[handles.indm,i];
    end
end   
list={handles.dat.model(:).model_name};
set(handles.pop_models,'String',list(handles.indm))
set(handles.pop_models,'Value',1)
handles.selmod=handles.indm(1);
set(handles.compbutt,'Enable','on')
% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in pop_models.
function pop_models_Callback(hObject, eventdata, handles)
% hObject    handle to pop_models (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_models contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_models
val=get(handles.pop_models,'Value');
if val==0
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
    set(handles.pop_classes,'Value',1)
    val=1;
end
handles.selmod=handles.indm(val);
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function pop_models_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_models (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_imgname_Callback(hObject, eventdata, handles)
% hObject    handle to edit_imgname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_imgname as text
%        str2double(get(hObject,'String')) returns contents of edit_imgname as a double
handles.img_name=get(handles.edit_imgname,'String');
if ~prt_checkAlphaNumUnder(handles.img_name)
    beep
    disp('Name of the image should be in alphanumeric format (no extension)')
    disp('Please correct')
    return
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_imgname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_imgname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in compbutt.
function compbutt_Callback(hObject, eventdata, handles)
% hObject    handle to compbutt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list={handles.dat.model(:).model_name};
in.model_name=list{handles.selmod};
in.pathdir=handles.prtdir;
in.img_name=handles.img_name;  %for the moment, coming soon
prt_compute_weights(handles.dat,in)
delete(handles.figure1)
