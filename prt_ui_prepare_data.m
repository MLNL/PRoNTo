function varargout = prt_ui_prepare_data(varargin)
% PRT_UI_KERNEL MATLAB code for prt_ui_kernel.fig
% 
% PRT_UI_KERNEL, by itself, creates a new PRT_UI_KERNEL or raises the 
% existing singleton*.
%
% H = PRT_UI_KERNEL returns the handle to a new PRT_UI_KERNEL or the handle
% to the existing singleton*.
%
% PRT_UI_KERNEL('CALLBACK',hObject,eventData,handles,...) calls the local
% function named CALLBACK in PRT_UI_KERNEL.M with the given input arguments.
%
% PRT_UI_KERNEL('Property','Value',...) creates a new PRT_UI_KERNEL or 
% raises the existing singleton*.  Starting from the left, property value 
% pairs are applied to the GUI before prt_ui_kernel_OpeningFcn gets called.
% An unrecognized property name or invalid value makes property application
% stop.  All inputs are passed to prt_ui_kernel_OpeningFcn via varargin.
%
% *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%  instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Schrouff
% $Id$

% Edit the above text to modify the response to help prt_ui_kernel

% Last Modified by GUIDE v2.5 28-Sep-2011 17:30:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prt_ui_prepare_data_OpeningFcn, ...
                   'gui_OutputFcn',  @prt_ui_prepare_data_OutputFcn, ...
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


% --- Executes just before prt_ui_kernel is made visible.
function prt_ui_prepare_data_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_ui_kernel (see VARARGIN)

% Choose default command line output for prt_ui_kernel
handles.output = hObject;
set(handles.sel_mod,'Enable','off')
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes prt_ui_kernel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prt_ui_prepare_data_OutputFcn(hObject, eventdata, handles) 
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
fname=get(handles.edit_prt,'String');
try
    load(fname)
    handles.dat=PRT;
catch
    beep
    disp('Could not load file')
    return
end
%if only one modality, than fill some fields automatically
n_mod=length(PRT.group(1).subject(1).modality);
handles.modnames={PRT.masks(:).mod_name};
if n_mod==1
    set(handles.num_mod,'Value',1)
    set(handles.num_mod,'String',1)
    set(handles.sel_mod,'String',{PRT.masks(1).mod_name})
    handles.mod=prt_ui_prepare_datamod('UserData',{PRT,1});
end
handles.fname=fname;
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
fname=spm_select(1,'.mat','Select PRT.mat',[],pwd,'PRT.mat');
try
    load(fname)
    handles.dat=PRT;
    set(handles.edit_prt,'String',fname);
catch
    beep
    disp('Could not load file')
    return
end
%if only one modality, than fill some fields automatically
n_mod=length(PRT.group(1).subject(1).modality);
handles.modnames={PRT.masks(:).mod_name};
if n_mod==1
    set(handles.num_mod,'Value',1)
    set(handles.num_mod,'String',1)
    set(handles.sel_mod,'String',{PRT.masks(1).mod_name})
    handles.mod=prt_ui_prepare_datamod('UserData',{PRT,1});
end
handles.fname=fname;
% Update handles structure
guidata(hObject, handles);


function edit_kname_Callback(hObject, eventdata, handles)
% hObject    handle to edit_kname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_kname as text
%        str2double(get(hObject,'String')) returns contents of edit_kname as a double
handles.kname=get(handles.edit_kname,'String');
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_kname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_kname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function num_mod_Callback(hObject, eventdata, handles)
% hObject    handle to num_mod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_mod as text
%        str2double(get(hObject,'String')) returns contents of num_mod as a double
val=str2double(get(handles.num_mod,'String'));
n_mod=length(handles.modnames);
%handles.mod=struct();
list=[];
%initialize for all modalities
for i=1:n_mod
    handles.mod(i)=struct('mod_name',[],'mode',[],'mask',[],'detrend',[], ...
        'param_dt',[],'normalise',[],'matnorm',[]);
end
%get information for the selected modalities 
for i=1:val
    tmp=prt_ui_prepare_datamod('UserData',{handles.dat,i});
    list=[list,tmp.mod_name];
    set(handles.sel_mod,'String',list)
    ind=find(strcmpi(handles.modnames,tmp.mod_name));
    handles.mod(ind)=tmp;
end
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function num_mod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_mod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in sel_mod.
function sel_mod_Callback(hObject, eventdata, handles)
% hObject    handle to sel_mod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns sel_mod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sel_mod


% --- Executes during object creation, after setting all properties.
function sel_mod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sel_mod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buildbutt.
function buildbutt_Callback(hObject, eventdata, handles)
% hObject    handle to buildbutt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

input=struct('fname',[],'kname',[],'mod',[]);
input.fname=handles.fname;
input.fs_name=handles.kname;
input.mod=handles.mod;
load(input.fname);
prt_fs(PRT,input);
delete(handles.figure1)
