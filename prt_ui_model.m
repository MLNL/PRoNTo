function varargout = prt_ui_model(varargin)
% PRT_UI_KERNEL_CONSTRUCTION M-file for prt_ui_kernel_construction.fig
%
% PRT_UI_KERNEL_CONSTRUCTION, by itself, creates a new 
% PRT_UI_KERNEL_CONSTRUCTION or raises the existing singleton*.
%
% H = PRT_UI_KERNEL_CONSTRUCTION returns the handle to a new 
% PRT_UI_KERNEL_CONSTRUCTION or the handle to the existing singleton*.
%
% PRT_UI_KERNEL_CONSTRUCTION('CALLBACK',hObject,eventData,handles,...)
% calls the local function named CALLBACK in PRT_UI_KERNEL_CONSTRUCTION.M 
% with the given input arguments.
%
% PRT_UI_KERNEL_CONSTRUCTION('Property','Value',...) creates a new 
% PRT_UI_KERNEL_CONSTRUCTION or raises the existing singleton*.  Starting 
% from the left, property value pairs are applied to the GUI before 
% prt_ui_kernel_construction_OpeningFcn gets called.  An unrecognized 
% property name or invalid value makes property application stop.  All 
% inputs are passed to prt_ui_kernel_construction_OpeningFcn via varargin.
%
% *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
% instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Schrouff
% $Id: prt_ui_model.m 211 2011-10-26 15:57:27Z schrouff $

% Edit the above text to modify the response to help prt_ui_kernel_construction

% Last Modified by GUIDE v2.5 01-Nov-2011 17:19:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prt_ui_model_OpeningFcn, ...
                   'gui_OutputFcn',  @prt_ui_model_OutputFcn, ...
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


% --- Executes just before prt_ui_kernel_construction is made visible.
function prt_ui_model_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_ui_kernel_construction (see VARARGIN)

% Choose default command line output for prt_ui_kernel_construction
handles.output = hObject;

set(handles.figure1,'Name','PRoNTo :: Specify model')
%Set defaults for some subfields and popup menus
handles.def=prt_get_defaults('model');
set(handles.usekern,'Value',1)
handles.use_kernel=1;
set(handles.pop_cv,'String',{'Leave One Subject Out','Leave One Subject per Group Out',...
    'Leave One Block Out','Leave One Run/Session Out','Custom'})
set(handles.pop_cv,'Value',1)
handles.cv.type='loso';
handles.cv.mat_file=[];
set(handles.pop_datop,'String',{'None'})
set(handles.pop_datop,'Value',1)
handles.operations=[];
set(handles.pop_reg,'String',{'Classification','Regression'})
set(handles.pop_reg,'Value',1)
handles.type='classification';
set(handles.pop_machine,'String',{'Binary support vector machine',...
    'Gaussian Process Classification'})
set(handles.pop_machine,'Value',1)
handles.machine.function='prt_machine_svm_bin';
handles.machine.args=handles.def.svmargs;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes prt_ui_kernel_construction wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prt_ui_model_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isfield(handles,'output') && ~isempty(handles.output)
    varargout{1} = handles.output;
else
    varargout{1}=[];
end




% --- Executes on button press in br_prt.
function br_prt_Callback(hObject, eventdata, handles)
% hObject    handle to br_prt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fname=spm_select(1,'.mat','Select PRT.mat',[],pwd,'PRT.mat');
if exist('PRT','var')
    clear PRT
end
try
    load(fname)
    handles.dat=PRT;
    set(handles.edit_prt,'String',fname);
catch
    beep
    disp('Could not load file')
    return
end

if ~isfield(handles.dat,'fs')
    beep
    disp('No feature set found in the PRT.mat')
    disp('Please, prepare feature set before computing model')
    return
end
set(handles.pop_featset,'String',{PRT.fs(:).fs_name})
set(handles.pop_featset,'Value',1)
list=get(handles.pop_featset,'String');
handles.fs(1).fs_name=list{1};
handles.fs(1).indfs=1;

% Update handles structure
guidata(hObject, handles);



function edit_prt_Callback(hObject, eventdata, handles)
% hObject    handle to edit_prt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_prt as text
%        str2double(get(hObject,'String')) returns contents of edit_prt as a double
fname=get(handles.edit_prt,'String');
if exist('PRT','var')
    clear PRT
end
try
    load(fname)
    handles.dat=PRT;
    set(handles.edit_prt,'String',fname);
catch
    beep
    disp('Could not load file')
    return
end

if ~isfield(handles.dat,'fs')
    beep
    disp('No feature set found in the PRT.mat')
    disp('Please, prepare feature set before computing model')
    return
end
set(handles.pop_featset,'String',{PRT.fs(:).fs_name})
set(handles.pop_featset,'Value',1)
list=get(handles.pop_featset,'String');
handles.fs(1).fs_name=list{1};
handles.fs(1).indfs=1;

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

function edit_modelname_Callback(hObject, eventdata, handles)
% hObject    handle to edit_modelname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_modelname as text
%        str2double(get(hObject,'String')) returns contents of edit_modelname as a double
handles.model_name=get(handles.edit_modelname,'String');
if ~(prt_checkAlphaNumUnder(handles.model_name))
    beep
    disp('Model name should be entered in alphanumeric format only')
    disp('Please correct')
    return
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_modelname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_modelname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_featset.
function pop_featset_Callback(hObject, eventdata, handles)
% hObject    handle to pop_featset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_featset contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_featset
val=get(handles.pop_featset,'Value');
if val==0
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
    set(handles.pop_feaset,'Value',1)
end
val=get(handles.pop_featset,'Value');
list=get(handles.pop_featset,'String');
handles.fs(1).fs_name=list{val};
handles.fs(1).indfs=val;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pop_featset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_featset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in usekern.
function usekern_Callback(hObject, eventdata, handles)
% hObject    handle to usekern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of usekern
handles.use_kernel=get(handles.usekern,'Value');
% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in pop_reg.
function pop_reg_Callback(hObject, eventdata, handles)
% hObject    handle to pop_reg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_reg contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_reg
val=get(handles.pop_reg,'Value');
if val==0
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
    set(handles.pop_reg,'Value',1)
end
val=get(handles.pop_reg,'Value');
if val==1 %Classification
    handles.type='classification';
    %set the list of machines
    set(handles.pop_machine,'String',{'Binary support vector machine',...
        'Gaussian Process Classification'})
    set(handles.pop_machine,'Value',1)
    handles.machine.function='prt_machine_svm_bin';
    handles.machine.args=handles.def.svmargs;
    set(handles.butt_defclass,'Label','Define classes')
elseif val==2
    handles.type='regression';
    set(handles.butt_defclass,'String','Select subjects/scans')
    %set the list of machines
    set(handles.pop_machine,'String',{'Kernel Ridge Regression',...
        'Relevance Vector Regression','Random Forest'})
    set(handles.pop_machine,'Value',1)
    handles.machine.function='prt_machine_krr';
    handles.machine.args=handles.def.krrargs;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pop_reg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_reg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in but_defclass.
function butt_defclass_Callback(hObject, eventdata, handles)
% hObject    handle to butt_def_class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(handles.type,'classification')
    speccl=prt_ui_select_class('UserData',{handles.dat,handles.fs(1).indfs});
    handles.class=speccl;
else
    sel=prt_ui_select_reg('UserData',{handles.dat,handles.fs(1).indfs});
    handles.group=sel;
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in pop_machine.
function pop_machine_Callback(hObject, eventdata, handles)
% hObject    handle to pop_machine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_machine contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_machine
mach=get(handles.pop_machine,'String');
val=get(handles.pop_machine,'Value');
if val==0
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
    set(handles.pop_machine,'Value',1)
end
val=get(handles.pop_machine,'Value');
if any(strfind(mach{val},'support'))
    handles.machine.function='prt_machine_svm_bin';
    handles.machine.args=handles.def.svmargs;
elseif any(strfind(mach{val},'Process'))
    handles.machine.function='prt_machine_gpml';
    handles.machine.args=handles.def.gpcargs;
elseif any(strfind(mach{val},'Ridge'))
    handles.machine.function='prt_machine_krr';
    handles.machine.args=handles.def.krrargs;
elseif any(strfind(mach{val},'Relevance'))
    handles.machine.function='prt_machine_rvr';
    handles.machine.args=[];
elseif any(strfind(mach{val},'Random'))
    handles.machine.function='prt_machine_RT_bin';
    handles.machine.args=handles.def.rtargs;    
end
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function pop_machine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_machine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_cv.
function pop_cv_Callback(hObject, eventdata, handles)
% hObject    handle to pop_cv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_cv contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_cv
% assemble structure for performing cross-validation
val=get(handles.pop_cv,'Value');
if val==0
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
    set(handles.pop_cv,'Value',1)
end
val=get(handles.pop_cv,'Value');
if val==1
    handles.cv.type = 'loso';
elseif val==2
    handles.cv.type = 'losgo';
elseif val==3
    handles.cv.type = 'lobo';
elseif val==4        %currently implemented for MCKR only
    handles.cv.type = 'loro';
else
    handles.cv.type     = 'custom';
    cvmatf=spm_select(1,'mat','Select .mat file corresponding to the custom cross-validation');
    handles.cv.mat_file = cvmatf;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pop_cv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_cv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in pop_datop.
function pop_datop_Callback(hObject, eventdata, handles)
% hObject    handle to pop_datop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_datop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        pop_datop
val=get(handles.pop_datop,'Value');
if val==0
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
    set(handles.pop_datop,'Value',1)
end
val=get(handles.pop_datop,'Value');
listop=get(handles.pop_datop,'String');
% specify operations to apply to the data prior to prediction
if val==length(listop)
    handles.operations = [];
else
    handles.operations = [handles.operations,{listop{val}}];
end
handles.operations=unique(handles.operations);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pop_datop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_datop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buildbutt.
function buildbutt_Callback(hObject, eventdata, handles)
% hObject    handle to buildbutt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%fill the input of the 'prt_model' button
in.fname=get(handles.edit_prt,'String');
in.model_name=handles.model_name;
in.type=handles.type;
in.machine=handles.machine;
in.use_kernel=handles.use_kernel;
in.operations=handles.operations;
in.fs(1).fs_name=handles.fs(1).fs_name;
in.cv=handles.cv;
%check that classes/subjects/scans were defined
if strcmpi(in.type,'classification')
    if ~isfield(handles,'class')
        beep
        disp('No class selected for classification')
        disp('Please, define classes')
        return
    else
        for i=1:length(handles.class)
            ind=[];
            for g=1:length(handles.class(i).group)
                if ~isempty(handles.class(i).group(g).gr_name)
                    ind=[ind,g];
                end
            end
            handles.class(i).group=handles.class(i).group(ind);
        end
        in.class=handles.class;
    end
else
    if ~isfield(handles,'group')
        beep
        disp('No subjects/scans selected for classification')
        disp('Please, select subjects/scans')
        return
    else
        ind=[];
        for g=1:length(handles.group)
            if ~isempty(handles.group(g).gr_name)
                ind=[ind,g];
            end
        end
        handles.group=handles.group(ind);
        in.group=handles.group;
    end
end

%checks on the CV framework compared to the model entered
if strcmpi(in.cv.type,'lobo')
    if ~isfield(in,'class')
        beep
        disp('Leave One Block Out cross-validation only allowed for classification')
        disp('Please correct')
        return
    else
        for c=1:length(in.class)
            for i=1:length(in.class(c).group)
                if length(in.class(c).group(i).subj)>1
                    beep
                    disp('Leave One Block Out cross-validation only allowed for within-subject classification')
                    disp('Please correct')
                    return
                end
            end
        end
    end
end
if ~isfield(in,'class')
    if ~strcmpi(in.cv.type,'loso')
        beep
        disp('Regression only allows a Leave One Subject Out cross-validation')
        disp('Please correct')
    end
end
PRT=prt_model(handles.dat,in);
clear in
in.fname      = get(handles.edit_prt,'String');
in.model_name = handles.model_name;
if exist('PRT','var')
    clear PRT
end
load(in.fname)
mid = prt_init_model(PRT, in);
% Special cross-validation for MCKR
if strcmpi(PRT.model(mid).input.machine.function,'prt_machine_mckr')
    prt_cv_mckr(PRT,in);
else
    prt_cv_model(PRT, in);
end
disp('Model specification and estimation complete.')
disp('Done...')
delete(handles.figure1)


% --- Executes on button press in buildbutt.
function specbutt_Callback(hObject, eventdata, handles)
% hObject    handle to buildbutt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%fill the input of the 'prt_model' button
in.fname=get(handles.edit_prt,'String');
in.model_name=handles.model_name;
in.type=handles.type;
in.machine=handles.machine;
in.use_kernel=handles.use_kernel;
in.operations=handles.operations;
in.fs(1).fs_name=handles.fs(1).fs_name;
in.cv=handles.cv;
%check that classes/subjects/scans were defined
if strcmpi(in.type,'classification')
    if ~isfield(handles,'class')
        beep
        disp('No class selected for classification')
        disp('Please, define classes')
        return
    else
        in.class=handles.class;
    end
else
    if ~isfield(handles,'group')
        beep
        disp('No subjects/scans selected for classification')
        disp('Please, select subjects/scans')
        return
    else
        in.group=handles.group;
    end
end

%checks on the CV framework compared to the model entered
if strcmpi(in.cv.type,'lobo')
    if ~isfield(in,'class')
        beep
        disp('Leave One Block Out cross-validation only allowed for classification')
        disp('Please correct')
        return
    else
        for c=1:length(in.class)
            for i=1:length(in.class(c).group)
                if length(in.class(c).group(i).subj)>1
                    beep
                    disp('Leave One Block Out cross-validation only allowed for within-subject classification')
                    disp('Please correct')
                    return
                end
            end
        end
    end
end
if ~isfield(in,'class')
    if ~strcmpi(in.cv.type,'loso')
        beep
        disp('Regression only allows a Leave One Subject Out cross-validation')
        disp('Please correct')
    end
end

prt_model(handles.dat,in);

disp('Model specification complete.')
disp('Done...')
delete(handles.figure1)


