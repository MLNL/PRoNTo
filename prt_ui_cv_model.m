function varargout = prt_ui_cv_model(varargin)
% PRT_UI_CV_MODEL M-file for prt_ui_cv_model.fig
%      PRT_UI_CV_MODEL, by itself, creates a new PRT_UI_CV_MODEL or raises the existing
%      singleton*.
%
%      H = PRT_UI_CV_MODEL returns the handle to a new PRT_UI_CV_MODEL or the handle to
%      the existing singleton*.
%
%      PRT_UI_CV_MODEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PRT_UI_CV_MODEL.M with the given input arguments.
%
%      PRT_UI_CV_MODEL('Property','Value',...) creates a new PRT_UI_CV_MODEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before prt_ui_cv_model_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to prt_ui_cv_model_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help prt_ui_cv_model

% Last Modified by GUIDE v2.5 04-Nov-2011 18:47:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prt_ui_cv_model_OpeningFcn, ...
                   'gui_OutputFcn',  @prt_ui_cv_model_OutputFcn, ...
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


% --- Executes just before prt_ui_cv_model is made visible.
function prt_ui_cv_model_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_ui_cv_model (see VARARGIN)

% Choose default command line output for prt_ui_cv_model
handles.output = hObject;

set(handles.figure1,'Name','PRoNTo :: Run model')

set(handles.unslist,'Enable','off')
set(handles.sellist,'Enable','off')
set(handles.selallbutt,'Enable','off')
set(handles.runbutt,'Enable','off')

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes prt_ui_cv_model wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prt_ui_cv_model_OutputFcn(hObject, eventdata, handles) 
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
list={handles.dat.model(:).model_name};
set(handles.unslist,'String',list)
set(handles.sellist,'String',{''})
handles.models=cell(1,2);
handles.models{1}=1:length(list);
handles.models{2}=[];
set(handles.unslist,'Enable','on')
set(handles.sellist,'Enable','on')
set(handles.selallbutt,'Enable','on')

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
    return
end
list={handles.dat.model(:).model_name};
set(handles.unslist,'String',list)
set(handles.sellist,'String',{''})
handles.models=cell(1,2);
handles.models{1}=1:length(list);
handles.models{2}=0;
set(handles.unslist,'Enable','on')
set(handles.sellist,'Enable','on')
set(handles.selallbutt,'Enable','on')

% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in unslist.
function unslist_Callback(hObject, eventdata, handles)
% hObject    handle to unslist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns unslist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from unslist
val=get(handles.unslist,'Value');
if ~any(handles.models{2})
    handles.models{2}=handles.models{1}(val);
else
    handles.models{2}=[handles.models{2},handles.models{1}(val)];
end
indm=handles.models{1}(val);
handles.models{1}=setxor(handles.models{1},indm);
list={handles.dat.model(:).model_name};
if isempty(handles.models{1})
    handles.models{1}=0;
    listu={''};
else
    listu=list(handles.models{1});
end

lists=list(handles.models{2});
set(handles.unslist,'String',listu)
set(handles.sellist,'String',lists)
set(handles.runbutt,'Enable','on')
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function unslist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to unslist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sellist.
function sellist_Callback(hObject, eventdata, handles)
% hObject    handle to sellist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns sellist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sellist
val=get(handles.sellist,'Value');
if ~any(handles.models{1})
    handles.models{1}=handles.models{2}(val);
else
    handles.models{1}=[handles.models{1},handles.models{2}(val)];
end
indm=handles.models{2}(val);
handles.models{2}=setxor(handles.models{2},indm);
list={handles.dat.model(:).model_name};
if isempty(handles.models{2})
    handles.models{2}=0;
    lists={''};
else
    lists=list(handles.models{2});
end
listu=list(handles.models{1});
set(handles.unslist,'String',listu)
set(handles.sellist,'String',lists)
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sellist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sellist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in selallbutt.
function selallbutt_Callback(hObject, eventdata, handles)
% hObject    handle to selallbutt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
list={handles.dat.model(:).model_name};
handles.models{1}=0;
handles.models{2}=1:length(list);
listu={''};
lists=list(handles.models{2});
set(handles.unslist,'String',listu)
set(handles.sellist,'String',lists)
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in runbutt.
function runbutt_Callback(hObject, eventdata, handles)
% hObject    handle to runbutt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~any(handles.models{2})
    beep
    disp('Select a model to run')
    return
end
PRT=handles.dat;
list={PRT.model(:).model_name};
for i=1:length(handles.models{2})
    in.fname      = handles.fname;
    in.model_name = list{handles.models{2}(i)};
    disp('--------------------------------------------------------')
    disp(['Running model ',char(in.model_name)])
    disp('--------------------------------------------------------')
    mid = prt_init_model(PRT, in);
    % Special cross-validation for MCKR
    if strcmp(PRT.model(mid).input.machine.function,'prt_machine_mckr')
        prt_cv_mckr(PRT,in);
    else
        prt_cv_model(PRT, in);
    end
    disp('--------------------------------------------------------')
    disp(['Model ',char(in.model_name),' run completed'])
    disp('--------------------------------------------------------')
end
delete(handles.figure1)
