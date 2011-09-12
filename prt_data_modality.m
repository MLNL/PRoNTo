function varargout = prt_data_modality(varargin)
% PRT_DATA_MODALITY M-file for prt_data_modality.fig
%      PRT_DATA_MODALITY, by itself, creates a new PRT_DATA_MODALITY or raises the existing
%      singleton*.
%
%      H = PRT_DATA_MODALITY returns the handle to a new PRT_DATA_MODALITY or the handle to
%      the existing singleton*.
%
%      PRT_DATA_MODALITY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PRT_DATA_MODALITY.M with the given input arguments.
%
%      PRT_DATA_MODALITY('Property','Value',...) creates a new PRT_DATA_MODALITY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before prt_data_modality_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to prt_data_modality_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help prt_data_modality

% Last Modified by GUIDE v2.5 25-Aug-2011 15:53:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prt_data_modality_OpeningFcn, ...
                   'gui_OutputFcn',  @prt_data_modality_OutputFcn, ...
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


% --- Executes just before prt_data_modality is made visible.
function prt_data_modality_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_data_modality (see VARARGIN)

% Choose default command line output for prt_data_modality
handles.output = hObject;


set(handles.design_menu,...
        'String',{'Load SPM.mat','Specify design','No design'},...
        'Value',3);
    

handles.mod=[];
handles.mod.tseries=0;
handles.mod.quant=0;
handles.mod.design=0;
handles.mod.files=[];
handles.mod.name={};

if ~isempty(varargin) && strcmpi(varargin{1},'UserData')    
    if ~isempty(varargin{2}{2}) && isfield(varargin{2}{2},'modality') && ...
            ~isempty(varargin{2}{2}.modality)
        handles.subjmod={varargin{2}{2}.modality(:).mod_name};
        if length(varargin{2})==3 && ~isempty(varargin{2}{3})
            nlist=varargin{2}{1};
            modsel=varargin{2}{2}.modality(varargin{2}{3});
            valsel=find(strcmpi(modsel.mod_name,nlist));
            set(handles.modname,'String',nlist);
            set(handles.modname,'Value',valsel);
            set(handles.quantbutt,'Value',modsel.quant);
            set(handles.tmsbutt,'Value',modsel.timesr);
            handles.mod.tseries=modsel.timesr;
            handles.mod.quant=modsel.quant;
            handles.mod.design=modsel.design;
            handles.mod.files=modsel.scans;
            handles.mod.name=modsel.mod_name;
        else
            nlist=[varargin{2}{1}, {'Enter new'}];
            set(handles.modname,'String',nlist,'Value',length(nlist));  
        end
    else
        nlist=[varargin{2}{1}, {'Enter new'}];
        set(handles.modname,'String',nlist,'Value',length(nlist));  
        handles.subjmod={};
    end
else
    nlist={'Enter new'};
    handles.subjmod={};
    set(handles.modname,'String',nlist,'Value',1);
end


% Update handles structure
guidata(hObject, handles);

% %UIWAIT makes prt_data_modality wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prt_data_modality_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);


% --- Executes on selection change in modname.
function modname_Callback(hObject, eventdata, handles)
% hObject    handle to modname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns modname contents as cell array
%        contents{get(hObject,'Value')} returns selected item from modname
list=get(handles.modname,'String');
if any(strfind(list{get(handles.modname,'Value')}, 'Enter'))
    modname=prt_text_input('Title','Enter modality name');
    if isnumeric(modname)
        return
    end
    if ~any(strcmpi(list,modname))
        nlist=[list;{modname}];
    else
        beep
        disp('This modality has already been set for the selected subject')
        set(handles.modname,'String',list);
        valall=strfind(list,'Enter');
        for i=1:length(valall)
            if ~isempty(valall{i})
                val=i;
                break
            end
        end
        set(handles.modname,'Value',val);
        return               
    end     
    set(handles.modname,'String',nlist);
    set(handles.modname,'Value',length(nlist));
else
    modname=list{get(handles.modname,'Value')};
    if ~isempty(handles.subjmod)
        if any(strcmpi(handles.subjmod,modname))
            beep
            disp('This modality has already been set for the selected subject')
            set(handles.modname,'String',list);
            valall=strfind(list,'Enter');
            for i=1:length(valall)
                if ~isempty(valall{i})
                    val=i;
                    break
                end
            end
            set(handles.modname,'Value',val);
            return
        end
    end         
end
handles.mod.name=modname;
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function modname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to modname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in quantbutt.
function quantbutt_Callback(hObject, eventdata, handles)
% hObject    handle to quantbutt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of quantbutt
val=get(handles.quantbutt,'Value');
if val
    handles.mod.quant=1;
else
    handles.mod.quant=0;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in tmsbutt.
function tmsbutt_Callback(hObject, eventdata, handles)
% hObject    handle to tmsbutt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tmsbutt
val=get(handles.tmsbutt,'Value');
if val
    handles.mod.tseries=1;
else
    handles.mod.tseries=0;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in design_menu.
function design_menu_Callback(hObject, eventdata, handles)
% hObject    handle to design_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns design_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from design_menu
choice=get(handles.design_menu,'Value');
if choice==1
    desn=spm_select(1,'mat','Select SPM.mat file',[],[],'SPM.mat');
    try
        load(desn);
    catch
        beep
        disp('Can not load SPM.mat file');
        return
    end
    ncond = length(SPM.Sess(1).U);
    conds=struct();
    for c = 1:ncond
        conds(c).cond_name = SPM.Sess(1).U(c).name{1};
        conds(c).onsets    = SPM.Sess(1).U(c).ons;
        conds(c).durations = SPM.Sess(1).U(c).dur;
    end
    desn=prt_check_design(conds,SPM.xX.K.RT);
    desn.covar = [];
elseif choice==2
    if isstruct(handles.mod.design)
        desn=prt_data_conditions('UserData',handles.mod.design);
    else
        desn=prt_data_conditions;
    end
else
    desn=[];
end
handles.mod.design=desn;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function design_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to design_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in getfiles.
function getfiles_Callback(hObject, eventdata, handles)
% hObject    handle to getfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.mod.files)
    sel=cellstr(handles.mod.files);
else
    sel=[];
end
t=spm_select([1 Inf],'image','Select files for the modality',sel);
handles.mod.files=t;
% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in okbutton.
function okbutton_Callback(hObject, eventdata, handles)
% hObject    handle to okbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
modprop=handles.mod;
handles.output=modprop;
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);


% --- Executes on button press in cancelbutton.
function cancelbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);
