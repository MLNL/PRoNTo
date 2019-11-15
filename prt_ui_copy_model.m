function varargout = prt_ui_copy_model(varargin)
% PRT_UI_COPY_MODEL M-file for prt_ui_kernel_construction.fig
%
% PRT_UI_COPY_MODEL, by itself, creates a new 
% PRT_UI_KERNEL_CONSTRUCTION or raises the existing singleton*.
%
% H = PRT_UI_COPY_MODEL returns the handle to a new 
% PRT_UI_COPY_MODEL or the handle to the existing singleton*.
%
% PRT_UI_COPY_MODEL('CALLBACK',hObject,eventData,handles,...)
% calls the local function named CALLBACK in PRT_UI_COPY_MODEL.M 
% with the given input arguments.
%
% PRT_UI_COPY_MODEL('Property','Value',...) creates a new 
% PRT_UI_COPY_MODEL or raises the existing singleton*.  Starting 
% from the left, property value pairs are applied to the GUI before 
% prt_ui_COPY_MODEL_OpeningFcn gets called.  An unrecognized 
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
% $Id$

% Edit the above text to modify the response to help prt_ui__COPY_MODEL

% Last Modified by GUIDE v2.5 08-Mar-2016 11:43:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prt_ui_copy_model_OpeningFcn, ...
                   'gui_OutputFcn',  @prt_ui_copy_model_OutputFcn, ...
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
function prt_ui_copy_model_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_ui_kernel_construction (see VARARGIN)

% Choose default command line output for prt_ui_kernel_construction
handles.output = hObject;

%if window already exists, just put it as the current figure
Tag='copymodelwin';
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
    
    %build figure when it doesn't exist
set(handles.figure1,'Name','PRoNTo :: Specify model from')
% Choose the color of the different backgrounds and figure parameters
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
set(handles.figure1,'DefaultTextFontSize',FS*12,...
    'DefaultUicontrolFontSize',FS*12,...
    'DefaultTextFontName',PF,...
    'DefaultAxesFontName',PF,...
    'DefaultUicontrolFontName',PF)
set(handles.figure1,'Position',ratio.*x)
% set(handles.figure1,'Units','normalized')
set(handles.figure1,'Resize','on')

color=prt_get_defaults('color');
handles.color=color;
set(handles.figure1,'Color',color.bg1)
aa=get(handles.figure1,'children');
for i=1:length(aa)
    if strcmpi(get(aa(i),'type'),'uipanel')
        set(aa(i),'BackgroundColor',color.bg2)
        bb=get(aa(i),'children');
        if ~isempty(bb)
            for j=1:length(bb)
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
    elseif strcmpi(get(aa(i),'type'),'uicontrol')
        if ~isempty(find(strcmpi(get(aa(i),'Style'),{'text',...
                'radiobutton','checkbox'})))
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

%Set defaults for some subfields and popup menus
handles.def=prt_get_defaults('model');
set(handles.kernel_methods,'Value',1)
set(handles.kernel_methods,'Enable','on')
handles.use_kernel=1;
set(handles.pop_cv,'String',{''})
set(handles.pop_cv,'Value',1)
set(handles.pop_cv,'Enable','off')
set(handles.pop_reg,'String',{''})
set(handles.pop_reg,'Value',1)
set(handles.pop_reg,'Enable','off')
handles.type='classification';
set(handles.pop_machine,'String',{''})
set(handles.pop_machine,'Value',1)
handles.oplist = {'Sample averaging (within block)',...
    'Sample averaging (within subject/condition)',...
    'Mean centre features using training data',...
    'Normalize samples',...
    'Regress out covariates'};
handles.oplistNK = [handles.oplist,...
    {'Normalize features',...
    'Z-score features'}];
set(handles.uns_list,'String',handles.oplist)
set(handles.sel_list,'String',{''})
set(handles.uns_list,'Value',1)
set(handles.sel_list,'Value',1)
handles.flagguicv=0;
handles.flagguicv_nested=0;
set(handles.flag_opt_param,'Value',0)
set(handles.edit_param_range,'Enable','off')
set(handles.pop_cv_nested,'Enable','off')
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes prt_ui_kernel_construction wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prt_ui_copy_model_OutputFcn(hObject, eventdata, handles) 
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
PRT=prt_load(fname);
if ~isempty(PRT)
    handles.dat=PRT;
    set(handles.edit_prt,'String',fname);
else
    beep
    disp('Could not load file')
    return
end

%Get list of models to copy from
if ~isfield(handles.dat,'model')
    disp('No model found in the PRT.mat')
    disp('Please, specify at least one NEW model before this step')
    delete(handles.figure1)
    return
end
lmod = {handles.dat.model(:).model_name};
set(handles.popmodels,'String',lmod)
set(handles.popmodels,'Value',1)

%Get the info from model (here first specified model)
indmod = 1;
while isempty(handles.dat.model(indmod).input)
    indmod = indmod +1;
end
update_copy_model(handles,indmod)
handles = guidata(gcf);
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
PRT=prt_load(fname);
if ~isempty(PRT)
    handles.dat=PRT;
    set(handles.edit_prt,'String',fname);
else
    beep
    disp('Could not load file')
    return
end

%Get list of models to copy from
if ~isfield(handles.dat,'model')
    disp('No model found in the PRT.mat')
    disp('Please, specify at least one NEW model before this step')
    delete(handles.figure1)
    return
end
lmod = {handles.dat.model(:).model_name};
set(handles.popmodels,'String',lmod)
set(handles.popmodels,'Value',1)

%Get the info from model (here first specified model)
indmod = 1;
while isempty(handles.dat.model(indmod).input)
    indmod = indmod +1;
end
update_copy_model(handles,indmod)
handles = guidata(gcf);
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
handles.model_name=deblank(get(handles.edit_modelname,'String'));
if ~(prt_checkAlphaNumUnder(handles.model_name))
    beep
    disp('Model name should be entered in alphanumeric format only')
    disp('Please correct')
    set(handles.edit_modelname,'ForegroundColor',[1,0,0])
    return
else
    set(handles.edit_modelname,'ForegroundColor',[0,0,0])
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

% --- Executes on selection change in fs_uns.
function fs_uns_Callback(hObject, eventdata, handles)
% hObject    handle to fs_uns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fs_uns contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fs_uns
list = get(handles.fs_uns,'String');
val = get(handles.fs_uns,'Value');
fsname = list{val};
fsidx = find(strcmpi(fsname,handles.fslist));
if ~isfield(handles,'fs') || ~isfield(handles.fs,'fs_name')
    id = 1;
else
    id = length(handles.fs)+1;
end
% Update lists
idu = setdiff(handles.fsidx{1},fsidx);
handles.fsidx{1} = idu;
if isempty(idu)
    set(handles.fs_uns,'String',{});
else
    set(handles.fs_uns,'String',handles.fslist(idu));
end
set(handles.fs_uns,'Value',1);
sdu = [handles.fsidx{2},fsidx];
handles.fsidx{2} = sdu;
set(handles.fs_sel,'String',handles.fslist(sdu));
set(handles.fs_sel,'Value',length(sdu));
handles.fs(id).fs_name=fsname;
handles.fs(id).indfs=fsidx;
% Add multi-kernel learning if flag to 1
if isfield(handles.dat.fs(fsidx),'multkernelROI')&& handles.dat.fs(fsidx).multkernelROI %allowing for multi-kernel learning
    handles.multiroi = 1;
else
    handles.multiroi = 0;
end
set_machines(handles,hObject);
handles = guidata(hObject);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function fs_uns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fs_uns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fs_sel.
function fs_sel_Callback(hObject, eventdata, handles)
% hObject    handle to fs_sel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fs_sel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fs_sel
list = get(handles.fs_sel,'String');
val = get(handles.fs_sel,'Value');
fsname = list{val};
fsidx = find(strcmpi(fsname,handles.fslist));
if ~isfield(handles,'fs') || ~isfield(handles.fs,'fs_name')
    return
else
    for i = 1:length(handles.fs)
        if strcmpi(fsname,handles.fs(i).fs_name)
            id = i;
        end
    end
end
idtc = setdiff([1:length(handles.fs)],id);
if isempty(idtc)
    handles.fs = [];
else
    handles.fs = handles.fs(idtc);
end
% Update lists
sdu = setdiff(handles.fsidx{2},fsidx);
handles.fsidx{2} = sdu;
if isempty(sdu)
    set(handles.fs_sel,'String',{});
else
    set(handles.fs_sel,'String',handles.fslist(sdu));
end
set(handles.fs_sel,'Value',1);
idu = [handles.fsidx{1},fsidx];
handles.fsidx{1} = idu;
set(handles.fs_uns,'String',handles.fslist(idu));
set(handles.fs_uns,'Value',length(idu));
% Update CV and machine options
if ~isempty(handles.fs)
    fsidx = handles.fs(1).indfs;
    % Add multi-kernel learning if flag to 1
    if isfield(handles.dat.fs(fsidx),'multkernelROI')&& handles.dat.fs(fsidx).multkernelROI %allowing for multi-kernel learning
        handles.multiroi = 1;
    else
        handles.multiroi = 0;
    end
    set_machines(handles,hObject);
    handles = guidata(hObject);
else
    set_machines(handles,hObject);
    handles = guidata(hObject);
end   

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function fs_sel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fs_sel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

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
    val=1;
end
is_class = 0;
if get(handles.pop_reg,'Value')==1
    is_class = 1;
end
is_kernel = get(handles.kernel_methods,'Value');    
[machine] = prt_get_machine_ui(is_class,is_kernel,mach{val});
set(handles.edit_param_range,'Enable','on')
set(handles.pop_cv_nested,'Enable','on')
handles.machine = machine;
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

% --- Executes on button press in flag_opt_param.
function flag_opt_param_Callback(hObject, eventdata, handles)
% hObject    handle to flag_opt_param (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flag_opt_param
v = get(handles.flag_opt_param,'Value');
if v
    switch handles.machine.function
        case {'prt_machine_gpml','prt_machine_gpclap',...
                'prt_machine_rvr','prt_machine_gpr'}
            set(handles.edit_param_range,'Enable','off')
            set(handles.pop_cv_nested,'Enable','off')
            handles.newmodel.use_nested_cv = 0;
            handles.newmodel.nested_param = [];
            set(handles.edit_param_range,'String','');
            beep
            disp('No hyper-parameter can be optimized for this machine')
        otherwise
            set(handles.edit_param_range,'Enable','on')
            set(handles.pop_cv_nested,'Enable','on')
            handles.newmodel.use_nested_cv = 1;
            handles.newmodel.nested_param = handles.def.libsvm_optargs;
            set(handles.edit_param_range,'String',num2str(handles.newmodel.nested_param));
            pop_cv_nested_Callback(hObject, eventdata, handles);
            handles = guidata(hObject);
    end
else
    handles.newmodel.use_nested_cv = 0;
    handles.newmodel.nested_param = [];
    set(handles.edit_param_range,'Enable','off')
    set(handles.pop_cv_nested,'Enable','off')
    set(handles.edit_param_range,'String','');
end

% Update handles structure
guidata(hObject, handles);


function edit_param_range_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
vp = get(handles.edit_param_range,'String');
try
    eval(['p = [' vp '];']);
catch
    beep
    disp('Parameter range cannot be evaluated, please enter as min:step:max')
end
if isnumeric(p)
    handles.newmodel.nested_param = p;
elseif iscell(p)
    handles.newmodel.nested_param = {};
    for i=1:length(p)
        if isnumeric(p{i})
            handles.newmodel.nested_param{i} = p{i};
        else
           beep
            disp('Parameter range is not numeric, please enter as min:step:max')
        end
    end
else
    beep
    disp('Parameter range is not numeric, please enter as min:step:max')
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_param_range_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in uns_list.
function uns_list_Callback(hObject, eventdata, handles)
% hObject    handle to uns_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns uns_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from uns_list
val=get(handles.uns_list,'Value');
if val==0
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
    set(handles.uns_list,'Value',1)
    val=1;
end
% specify operations to apply to the data prior to prediction
ind=handles.indop{1}(val);
handles.operations=[handles.operations, ind];
handles.indop{1}=setdiff(handles.indop{1},ind);
if isempty(handles.indop{1})
    handles.indop{1}=0;
    set(handles.uns_list,'String',{''})
else
    set(handles.uns_list,'String',{handles.namop{handles.indop{1}}})    
end
set(handles.uns_list,'Value',1)
if handles.indop{2}==0
    handles.indop{2}=ind;
else
    handles.indop{2}=[handles.indop{2},ind];
end
set(handles.sel_list,'String',{handles.namop{handles.indop{2}}})
set(handles.sel_list,'Value',length(handles.indop{2}))
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function uns_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uns_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sel_list.
function sel_list_Callback(hObject, eventdata, handles)
% hObject    handle to sel_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns sel_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sel_list
val=get(handles.sel_list,'Value');
if val==0
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
    set(handles.sel_list,'Value',1)
    val=1;
end
% specify operations to apply to the data prior to prediction
ind=handles.indop{2}(val);
handles.operations=setdiff(handles.operations, ind);
handles.indop{2}=setdiff(handles.indop{2},ind);
if isempty(handles.indop{2})
    handles.indop{2}=0;
    set(handles.sel_list,'String',{''})
else
    set(handles.sel_list,'String',{handles.namop{handles.indop{2}}})    
end
set(handles.sel_list,'Value',1)
if handles.indop{1}==0
    handles.indop{1}=ind;
else
    handles.indop{1}=[handles.indop{1},ind];
end
set(handles.uns_list,'String',{handles.namop{handles.indop{1}}})
set(handles.uns_list,'Value',length(handles.indop{1}))
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sel_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sel_list (see GCBO)
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

if isempty(handles.model_name)
    beep
    disp('Provide a model name for this copied model')
    return
end

% find model index
model_exists = false;
if any(strcmpi(handles.model_name,{handles.dat.model(:).model_name}))
    mid = find(strcmpi(handles.model_name,{handles.dat.model(:).model_name}));
    model_exists = true;
else
    mid = length(handles.dat.model)+1;
end

% For each field, input the values into the new model
if model_exists
    warning('prt_init_model:modelAlreadyInPRT',['Model ''',handles.model_name,...
        ''' already exists in PRT.mat. Overwriting...']);
else
    disp(['Model ''',handles.model_name,''' not found in PRT.mat. Creating...'])
end


%fill the input of the 'prt_model' button
handles.newmodel.machine=handles.machine;
handles.newmodel.operations=handles.operations;
handles.newmodel.fs=handles.fs;
handles.newmodel.fs = rmfield(handles.newmodel.fs,'indfs');
handles.newmodel.use_kernel = handles.use_kernel;

%checks on the CV framework compared to the model entered
if strcmpi(handles.newmodel.cv_type,'lobo')
    if isfield(handles.newmodel,'class')
%         beep
%         disp('Leave One Block Out cross-validation only allowed for classification')
%         disp('Please correct')
%         return
%     else
        for c=1:length(handles.newmodel.class)
            for i=1:length(handles.newmodel.class(c).group)
                if length(handles.newmodel.class(c).group(i).subj)>1
                    beep
                    disp('Leave One Block Out cross-validation only allowed for within-subject classification')
                    disp('Please correct')
                    return
                end
            end
        end
    end
end
% if ~isfield(in,'class')
%     if ~strcmpi(in.cv.type,'loso')
%         beep
%         disp('Regression only allows a Leave (One) Subject Out cross-validation')
%         disp('Please correct')
%     end
% end

% Copy model
PRT = handles.dat;
PRT.model(mid).model_name = handles.model_name;
PRT.model(mid).input = handles.newmodel;
PRT.model(mid).output = [];

% Save modified PRT
disp('Updating PRT.mat.......>>')
fname      = get(handles.edit_prt,'String');
if spm_check_version('MATLAB','7') >= 0
    save(fname,'-V7','PRT');
else
    save(fname,'-V6','PRT');
end

in.fname      = get(handles.edit_prt,'String');
in.model_name = handles.model_name;
if exist('PRT','var')
    clear PRT
end
load(in.fname)

prt_cv_model(PRT, in);

disp('Model specification and estimation complete.')
disp('Done...')
delete(handles.figure1)


% --- Executes on button press in buildbutt.
function specbutt_Callback(hObject, eventdata, handles)
% hObject    handle to buildbutt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.model_name)
    beep
    disp('Provide a model name for this copied model')
    return
end

% find model index
model_exists = false;
if any(strcmpi(handles.model_name,{handles.dat.model(:).model_name}))
    mid = find(strcmpi(handles.model_name,{handles.dat.model(:).model_name}));
    model_exists = true;
else
    mid = length(handles.dat.model)+1;
end

% For each field, input the values into the new model
if model_exists
    warning('prt_init_model:modelAlreadyInPRT',['Model ''',handles.model_name,...
        ''' already exists in PRT.mat. Overwriting...']);
else
    disp(['Model ''',handles.model_name,''' not found in PRT.mat. Creating...'])
end


%Copy modified fields into new model
handles.newmodel.machine=handles.machine;
handles.newmodel.operations=handles.operations;
handles.newmodel.fs=handles.fs;
handles.newmodel.fs = rmfield(handles.newmodel.fs,'indfs');
handles.newmodel.use_kernel = handles.use_kernel;

%checks on the CV framework compared to the model entered
if strcmpi(handles.newmodel.cv_type,'lobo')
    if isfield(handles.newmodel,'class')
%         beep
%         disp('Leave One Block Out cross-validation only allowed for classification')
%         disp('Please correct')
%         return
%     else
        for c=1:length(handles.newmodel.class)
            for i=1:length(handles.newmodel.class(c).group)
                if length(handles.newmodel.class(c).group(i).subj)>1
                    beep
                    disp('Leave One Block Out cross-validation only allowed for within-subject classification')
                    disp('Please correct')
                    return
                end
            end
        end
    end
end
% if ~isfield(in,'class')
%     if ~strcmpi(in.cv.type,'loso')
%         beep
%         disp('Regression only allows a Leave (One) Subject Out cross-validation')
%         disp('Please correct')
%     end
% end

% Copy model
PRT = handles.dat;
PRT.model(mid).model_name = handles.model_name;
PRT.model(mid).input = handles.newmodel;
PRT.model(mid).output = [];

% Save modified PRT
disp('Updating PRT.mat.......>>')
fname      = get(handles.edit_prt,'String');
if spm_check_version('MATLAB','7') >= 0
    save(fname,'-V7','PRT');
else
    save(fname,'-V6','PRT');
end

disp('Model specification complete.')
disp('Done...')
delete(handles.figure1)


% --- Executes on selection change in pop_cv_nested.
function pop_cv_nested_Callback(hObject, eventdata, handles)
% hObject    handle to pop_cv_nested (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_cv_nested contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_cv_nested
val=get(handles.pop_cv_nested,'Value');
mach=get(handles.pop_cv_nested,'String');
handles.newmodel.cv_k_nested=0; %by default, Leave-One-Out options
if val==0
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
    set(handles.pop_cv_nested,'Value',1)
    val=1;
end
if any(strfind(mach{val},'Subject Out'))
    handles.newmodel.cv_type_nested = 'loso';
elseif any(strfind(mach{val},'Subject per Class'))
    nscl = zeros(numel(handles.newmodel.class),1);
    for i = 1:numel(handles.newmodel.class)
        nscl(i) = length([handles.newmodel.class(i).group(:).subj]);
    end
    handles.loospg = 1;
    if numel(unique(nscl))~=1
        beep
        disp('Warning: Subjects are not balanced across classes!')
        handles.loospg = 0;
    end
    handles.newmodel.cv_type_nested = 'losgo';
elseif any(strfind(mach{val},'Block'))
    if any(strfind(mach{val},'Block per Class'))
        handles.newmodel.cv_type_nested = 'locbo';
    else
        handles.newmodel.cv_type_nested = 'lobo';
    end   
elseif any(strfind(mach{val},'Run'))        %currently implemented for MCKR only
    handles.newmodel.cv_type_nested = 'loro';
else
    beep
    disp('CV type not supported for inner CV')
    return
end
if any(strfind(mach{val},'k-fold'))
    kt=prt_text_input('Title','Specify k, the number of folds');
    handles.newmodel.cv_k_nested=str2num(kt);
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pop_cv_nested_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_cv_nested (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popmodels.
function popmodels_Callback(hObject, eventdata, handles)
% hObject    handle to popmodels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popmodels contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popmodels

indmod = get(hObject,'Value');
update_copy_model(handles,indmod)



% --- Executes during object creation, after setting all properties.
function popmodels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popmodels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Cannot be modified in this version of 'Copy model' - March 2016
% --- Executes on button press in kernel_methods.
function kernel_methods_Callback(hObject, eventdata, handles)
% hObject    handle to kernel_methods (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of kernel_methods
set_machines(handles,hObject);
handles = guidata(hObject);

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
    val=1;
end
if val==1 %Classification
    handles.type='classification';
    nk=get(handles.kernel_methods,'Value');
    if nk==1
        %set the list of machines
        list = {'Binary support vector machine',...
            'Binary Gaussian Process Classification',...
            'Multiclass GPC'};
        if handles.multimod || handles.multiroi
            list = [list,{'L1- Multi-Kernel Learning',...
                    'wip'}];
        end
        set(handles.pop_machine,'String',list)
        set(handles.pop_machine,'Value',1)
        handles.machine.function='prt_machine_svm_bin';
        handles.machine.args=handles.def.svmargs;
    else
        %set the list of machines
        set(handles.pop_machine,'String',{'Random Forest'})
        set(handles.pop_machine,'Value',1)
        handles.machine.function='prt_machine_RT_bin';
        handles.machine.args=handles.def.rtargs;  
    end
elseif val==2
    handles.type='regression';
    set(handles.butt_defclass,'String','Select subjects/scans')
    %set the list of machines
    set(handles.pop_machine,'String',{'Kernel Ridge Regression',...
        'Relevance Vector Regression','Gaussian Process Regression', 'Multi-Kernel Regression'})
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

% --- Executes on selection change in pop_cv.
function pop_cv_Callback(hObject, eventdata, handles)
% hObject    handle to pop_cv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_cv contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_cv
% assemble structure for performing cross-validation
val=get(handles.pop_cv,'Value');
mach=get(handles.pop_cv,'String');
handles.cv.k=0; %by default, Leave-One-Out options
if val==0
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
    set(handles.pop_cv,'Value',1)
    val=1;
end
if any(strfind(mach{val},'Subject Out'))
    handles.cv.type = 'loso';
elseif any(strfind(mach{val},'Subject per Class')) || ...
        any(strfind(mach{val},'Subject per Group')) % Backwards compatibility
    if ~handles.loospg
        beep
        disp('Warning: Subjects are not balanced across classes!')
    end
    handles.cv.type = 'losgo';
elseif any(strfind(mach{val},'Block'))
    if any(strfind(mach{val},'Block per Class'))
        handles.cv.type = 'locbo';
    else
        handles.cv.type = 'lobo';
    end 
elseif any(strfind(mach{val},'Run'))        %currently implemented for MCKR only
    handles.cv.type = 'loro';
else
    handles.cv.type     = 'custom';
    %fill the input of the 'prt_model' button
    in.fname=get(handles.edit_prt,'String');
    if ~isfield(handles,'model_name')
        beep
        disp('Please enter a valid model name')
        return
    end
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
    handles.in=in;
    prt_ui_specify_CV_basis(handles);
    handles.flagguicv=1;
end
if any(strfind(mach{val},'k-fold'))
    kt=prt_text_input('Title','Specify k, the number of folds');
    handles.cv.k=str2num(kt);
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


%--------------------------------------------------------------------------
% Private functions
%--------------------------------------------------------------------------
function [] = set_machines(handles,hObject)
handles.use_kernel=get(handles.kernel_methods,'Value');
is_kernel = handles.use_kernel;
is_class = 0;
if get(handles.pop_reg,'Value')==1 %for classification
    if handles.use_kernel
        list = handles.class_K;
        if handles.multiroi || length(handles.fs)>1
            list = [list,handles.MK];
        end
        oplist = handles.oplist;
    else
        list = handles.class_NK;
        oplist = handles.oplistNK;
    end
    is_class = 1;
else
    if handles.use_kernel
        list = handles.reg_K;
        if handles.multiroi || length(handles.fs)>1
            list = [list,handles.MK];
        end
        oplist = handles.oplist; % Operations in kernel space
    else
        list = handles.reg_NK;
        oplist = handles.oplistNK; % Add feature normalization
    end
end
set(handles.pop_machine,'String',list)
set(handles.pop_machine,'Value',1)

% Deal with operations
handles.indop{1}=1:length(oplist);
handles.indop{2}=0;
set(handles.uns_list,'String',oplist)
set(handles.sel_list,'String',{''})
handles.operations = [];
handles.namop=oplist;
set(handles.uns_list,'Value',1)
set(handles.sel_list,'Value',1)

name = list{1};
[machine] = prt_get_machine_ui(is_class,is_kernel,name);

handles.machine = machine;

% Update handles structure
guidata(hObject, handles);


function update_copy_model(handles,indmod)

% Copy model
handles.newmodel = handles.dat.model(indmod).input;
set(handles.pop_reg,'String',{'Classification','Regression'})
val = find(strcmpi({'Classification','Regression'},handles.dat.model(indmod).input.type));
set(handles.pop_reg,'Value',val)  
set(handles.pop_reg,'Enable','off')


listall = {handles.dat.fs(:).fs_name};
listfs = {handles.dat.model(indmod).input.fs(:).fs_name};
sel = find(ismember(listall,listfs));
unsel = find(~ismember(listall,listfs));

% Set feature set lists
handles.fslist = listall;
set(handles.fs_uns,'String',listall(unsel))
set(handles.fs_uns,'Value',1)
set(handles.fs_sel,'String',listall(sel))
set(handles.fs_sel,'Value',1)
handles.fsidx = {unsel,sel};
handles.fs = handles.dat.model(indmod).input.fs;
for i = 1:numel(handles.fs)
    handles.fs(i).indfs = sel(i);
end
handles.use_kernel=handles.dat.model(indmod).input.use_kernel;

if isfield(handles.dat.fs(sel(1)),'multkernel')&& handles.dat.fs(sel(1)).multkernel %allowing for multi-kernel learning
    handles.multimod = 1;
else
    handles.multimod = 0;
end
if isfield(handles.dat.fs(sel(1)),'multkernelROI')&& handles.dat.fs(sel(1)).multkernelROI %allowing for multi-kernel learning
    handles.multiroi = 1;
else
    handles.multiroi = 0;
end

% Set list of potential machines and show the one selected
% Machine lists:
mach = prt_get_defaults('machine');
handles.class_K = mach.class_K;
handles.MK = mach.MK;
handles.class_NK = mach.class_NK;
handles.reg_K = mach.reg_K;
handles.reg_NK = mach.reg_NK;
nk=handles.dat.model(indmod).input.use_kernel;
% Map back the machine function to the name of the algorithm
if strcmpi(handles.dat.model(indmod).input.type,'classification')
    handles.type = 'classification';
    if nk==1 % Kernel classification machines
        list = handles.class_K;            
        if handles.multimod || handles.multiroi ||...
                numel(sel)>1
            list = [list,handles.MK];
        end
        if strcmpi(handles.dat.model(indmod).input.machine.function,'prt_machine_svm_bin')
            mach = 'Binary support vector machine';
        elseif strcmpi(handles.dat.model(indmod).input.machine.function,'prt_machine_gpml')
            mach = 'Binary Gaussian Process Classification';
        elseif strcmpi(handles.dat.model(indmod).input.machine.function,'prt_machine_gpclap')
            mach = 'Multiclass GPC';
        elseif strcmpi(handles.dat.model(indmod).input.machine.function,'prt_machine_sMKL_cla')
            mach = 'L1 Multi-Kernel Learning';
        elseif strcmpi(handles.dat.model(indmod).input.machine.function,'prt_machine_liblinearsvm')
            mach = 'L2-Logistic Regression';
        end
    else % Non-Kernel classification machines
        list = handles.class_NK;
        if strcmpi(handles.dat.model(indmod).input.machine.function,'prt_machine_liblinearsvm')
            % Get string argument to know which machine
            sargs = handles.dat.model(indmod).input.machine.s_args;
            if ~isempty(strfind(sargs,'s 0'))
                mach = 'L2-Logistic Regression';
            elseif ~isempty(strfind(sargs,'s 6'))
                mach = 'L1-Logistic Regression';
            elseif ~isempty(strfind(sargs,'s 2'))
                mach = 'Binary L2-SVM';   
            elseif ~isempty(strfind(sargs,'s 5'))
                mach = 'Binary L1-SVM';
            elseif ~isempty(strfind(sargs,'s 4'))
                mach = 'Multiclass SVM';
            end
        elseif strcmpi(handles.dat.model(indmod).input.machine.function,'prt_machine_RT_bin')
            mach = 'Random Forest';
        end
    end
elseif strcmpi(handles.dat.model(indmod).input.type,'regression')
    handles.type='regression';
    if nk % Kernel regression machines
        list = handles.reg_K;
        if handles.multimod || handles.multiroi ||...
                numel(sel)>1
            list = [list,handles.MK];
        end
        if strcmpi(handles.dat.model(indmod).input.machine.function,'prt_machine_krr')
            mach = 'Kernel Ridge Regression';
        elseif strcmpi(handles.dat.model(indmod).input.machine.function,'prt_machine_rvr')
            mach = 'Relevance Vector Regression';
        elseif strcmpi(handles.dat.model(indmod).input.machine.function,'prt_machine_gpr')
            mach = 'Gaussian Process Regression';
        elseif strcmpi(handles.dat.model(indmod).input.machine.function,'prt_machine_sMKL_reg')
            mach = 'L1 Multi-Kernel Learning';
        elseif strcmpi(handles.dat.model(indmod).input.machine.function,'prt_machine_svm_bin')
            mach = 'epsilon-SVR';
        end
    else
        list = handles.reg_NK;
        if strcmpi(handles.dat.model(indmod).input.machine.function,'prt_machine_liblinearsvm')
            mach = 'epsilon-SVR';
        end
    end
end

val = find(ismember(list,mach));
set(handles.pop_machine,'String',list)
set(handles.pop_machine,'Value',val)
set(handles.kernel_methods,'Value',nk)

is_class = 0;
if strcmpi(handles.type,'classification')
    is_class = 1;
end
machine = prt_get_machine_ui(is_class,nk,mach);
handles.machine = machine;

% Nested cross-validation?
v = handles.dat.model(indmod).input.use_nested_cv;
if v
    switch handles.dat.model(indmod).input.machine.function
        case {'prt_machine_gpml','prt_machine_gpclap',...
                'prt_machine_gpr','prt_machine_rvr'}
            set(handles.edit_param_range,'Enable','off')
            set(handles.pop_cv_nested,'Enable','off')
            handles.cv.nested = 0;
            handles.cv.nested_param = [];
            beep
            disp('No hyper-parameter can be optimized for this machine')
        otherwise
            set(handles.edit_param_range,'Enable','on')
            set(handles.pop_cv_nested,'Enable','on')
            handles.cv.nested = 1;
    end
    set(handles.flag_opt_param,'Value',1)
    set(handles.edit_param_range,'String',num2str(handles.dat.model(indmod).input.nested_param))
else
    handles.cv.nested = 0;
    handles.cv.nested_param = [];
    set(handles.flag_opt_param,'Value',0)
    set(handles.edit_param_range,'Enable','off')
    set(handles.edit_param_range,'String','')
    set(handles.pop_cv_nested,'Enable','off')
end

% Set CV parameters (cannot be modified)
tcv = handles.dat.model(indmod).input.cv_type;
kcv = handles.dat.model(indmod).input.cv_k;
if strcmpi(tcv,'lobo')
    if kcv ==0
        listcv = {'Leave One Block Out'};
    else
        listcv = {'k-folds CV on Blocks Out'};
    end
elseif strcmpi(tcv,'loro')
    if kcv ==0
        listcv = {'Leave One Run/Session Out'};
%     else
%         listcv = {'k-folds CV on Runs'};
    end
elseif strcmpi(tcv,'loso')
    if kcv ==0
        listcv = {'Leave One Subject Out'};
    else
        listcv = {'k-folds CV on Subjects Out'};
    end
elseif strcmpi(tcv,'losgo')
    if kcv ==0
        listcv = {'Leave One Subject per Group Out'};
    else
        listcv = {'k-folds CV on Subjects per Group Out'};
    end
elseif strcmpi(tcv,'custom')
    if kcv ==0
        listcv = {'Custom CV'};
    else
        listcv = {'Custom CV'};
    end
elseif strcmpi(tcv,'locbo')
    if kcv ==0
        listcv = {'Leave One Block per Class Out'};
    else
        listcv = {'k-folds CV on Blocks per Class Out'};
    end
else
    listcv = {'custom'};
end
set(handles.pop_cv,'String',listcv)
set(handles.pop_cv,'Value',1)
set(handles.pop_cv,'Enable','off')

% Set options for nested CV and see if one option selected
if strcmpi(handles.type,'classification')
    speccl.class = handles.dat.model(indmod).input.class;
    if isfield(speccl.class(1).group(1).subj(1).modality,'conds') && ...
           ~isempty(speccl.class(1).group(1).subj(1).modality(1).conds(1).cond_name) 
        speccl.design = 1;
    else
        speccl.design = 0;
    end
    ns=zeros(length(speccl.class),1);
    ng1=1;
    ng2=1;
    for ii=1:length(speccl.class)
        for jj=1:length(speccl.class(ii).group)
            ns(ii)=ns(ii)+length(speccl.class(ii).group(jj).subj);
        end
        if jj==1
            if ii==1
                gname=speccl.class(ii).group(jj).gr_name;
            else
                if strcmpi(gname,speccl.class(ii).group(jj).gr_name)
                    ng2=ng2+1;
                end
            end
        else
            ng1=0;
        end
    end
    
    % Options for the inner CV
    ng2=floor(ng2/length(speccl.class));
    list={};
    if (speccl.design) && max(ns)==1
        if ~any(ismember(list, 'Leave One Block Out'))
            list=[list;{'Leave One Block Out'}];
        end
        if ~any(ismember(list, 'k-folds CV on Block'))
            list=[list;{'k-folds CV on Block'}];
        end
        set(handles.pop_cv_nested,'String',list)
        if ~any(ismember(list, 'Leave One Block per Class Out'))
            list=[list;{'Leave One Block per Class Out'}];
        end
        if ~any(ismember(list, 'k-folds CV on Block per Class'))
            list=[list;{'k-folds CV on Block per Class'}];
        end
        set(handles.pop_cv_nested,'String',list)
    end
    if min(ns)>1
        if ~any(ismember(list, 'Leave One Subject Out'))
            list=[list;{'Leave One Subject Out'}];
        end
        if ~any(ismember(list, 'k-folds CV on Subject Out'))
            list=[list;{'k-folds CV on Subject Out'}];
        end
        set(handles.pop_cv_nested,'String',list)
        if ~ng1 || ~ng2
            list=get(handles.pop_cv_nested,'String');
            if ~any(ismember(list, 'Leave One Subject per Class Out'))
                list=[list;{'Leave One Subject per Class Out'}];
            end
            if ~any(ismember(list, 'k-folds CV on Subject per Class'))
                list=[list;{'k-folds CV on Subject per Class'}];
            end
            set(handles.pop_cv_nested,'String',list)
        end
    end
    
else % Regression
    % need to reverse the sample selection to know how many subjects and/or
    % blocks were selected
    id = handles.dat.fs(sel(1)).id_mat(handles.dat.model(indmod).input.samp_idx,:);
    n = numel(unique(id(:,2)));
    blocks = numel(unique(id(:,5)));
    list={};
    if n>1
        if ~any(ismember(list, 'Leave One Subject Out'))
            list=[list;{'Leave One Subject Out'}];
        end
        if ~any(ismember(list, 'k-folds CV on Subject Out'))
            list=[list;{'k-folds CV on Subject Out'}];
        end
        set(handles.pop_cv_nested,'String',list)
    elseif blocks>1 && n==1
        if ~any(ismember(list, 'Leave One Block Out'))
            list=[list;{'Leave One Block Out'}];
        end
        if ~any(ismember(list, 'k-folds CV on Block'))
            list=[list;{'k-folds CV on Block'}];
        end
        set(handles.pop_cv_nested,'String',list)
    end
end
if length(handles.dat.fs(sel(1)).modality)>2
    list=get(handles.pop_cv_nested,'String');
    if ~any(strcmpi(list,'Leave One Run/Session Out'))
        list=[list;{'Leave One Run/Session Out'}];
        set(handles.pop_cv_nested,'String',list)
    end
end

% Get specific values that were selected
if handles.dat.model(indmod).input.use_nested_cv
    tcv = handles.dat.model(indmod).input.cv_type_nested;
    kcv = handles.dat.model(indmod).input.cv_k_nested;
    if strcmpi(tcv,'lobo')
        if kcv ==0
            listcv = {'Leave One Block Out'};
        else
            listcv = {'k-folds CV on Block'};
        end
    elseif strcmpi(tcv,'loro')
        if kcv ==0
            listcv = {'Leave One Run/Session Out'};
            %     else
            %         listcv = {'k-folds CV on Runs'};
        end
    elseif strcmpi(tcv,'loso')
        if kcv ==0
            listcv = {'Leave One Subject Out'};
        else
            listcv = {'k-folds CV on Subject Out'};
        end
    elseif strcmpi(tcv,'losgo')
        if kcv ==0
            listcv = {'Leave One Subject per Class Out'};
        else
            listcv = {'k-folds CV on Subject per Class'};
        end
    elseif strcmpi(tcv,'locbo')
        if kcv ==0
            listcv = {'Leave One Block per Class Out'};
        else
            listcv = {'k-folds CV on Block per Class'};
        end
    end
    val = strcmpi(list,listcv);
    set(handles.pop_cv_nested,'Value',find(val))
else
    set(handles.pop_cv_nested,'String',list)
    set(handles.pop_cv_nested,'Enable','off')
end

% Get operations
if nk
    list=handles.oplist;
else
    list = handles.oplistNK;
end
allops = 1:length(list);
selops = handles.dat.model(indmod).input.operations;
unsops = setdiff(allops,selops);
handles.indop{1}=unsops;
handles.indop{2}=selops;
set(handles.uns_list,'String',list(unsops))
set(handles.sel_list,'String',list(selops))
handles.operations = selops;
handles.namop=list;
set(handles.uns_list,'Value',1)
set(handles.sel_list,'Value',1)

handles.model_name = [];
set(handles.edit_modelname,'ForegroundColor',[1 0 0])
% Update handles structure
hObject = gcf;
guidata(hObject, handles);
