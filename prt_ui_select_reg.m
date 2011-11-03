function varargout = prt_ui_select_reg(varargin)
% PRT_UI_SELECT_REG M-file for prt_ui_select_reg.fig
%      PRT_UI_SELECT_REG, by itself, creates a new PRT_UI_SELECT_REG or raises the existing
%      singleton*.
%
%      H = PRT_UI_SELECT_REG returns the handle to a new PRT_UI_SELECT_REG or the handle to
%      the existing singleton*.
%
%      PRT_UI_SELECT_REG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PRT_UI_SELECT_REG.M with the given input arguments.
%
%      PRT_UI_SELECT_REG('Property','Value',...) creates a new PRT_UI_SELECT_REG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before prt_ui_select_reg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to prt_ui_select_reg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help prt_ui_select_reg

% Last Modified by GUIDE v2.5 02-Nov-2011 17:45:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prt_ui_select_reg_OpeningFcn, ...
                   'gui_OutputFcn',  @prt_ui_select_reg_OutputFcn, ...
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


% --- Executes just before prt_ui_select_reg is made visible.
function prt_ui_select_reg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_ui_select_reg (see VARARGIN)

% Choose default command line output for prt_ui_kernel_construction
handles.output = hObject;

%get information from the PRT.mat
if ~isempty(varargin) && strcmpi(varargin{1},'UserData')
    handles.dat=varargin{2}{1};
    %get names of groups
    list={handles.dat.group(:).gr_name};
    ng=length(list);
    set(handles.group_list,'String',list)
    set(handles.group_list,'Value',1)
    list={handles.dat.group(1).subject(:).subj_name};
    set(handles.uns_list,'String',list);
    set(handles.sel_list,'String',{});
    %get the conditions which are common to all groups and subjects for the
    %different modalities comprised in the selected feature set
    indfs=varargin{2}{2};
    handles.indfs=indfs;
    nm=length(handles.dat.fs(indfs).modality);
    handles.condm=cell(1,2);
    %for each modality, get the conditions which are common to all subjects
    for i=1:nm
        handles.condm{1,1}=get(handles.group_list,'String');
        handles.condm{1,2}=cell(length(get(handles.group_list,'String')),1);
        for j=1:ng
            handles.condm{1,2}{j}={handles.dat.group(j).subject(:).subj_name};
        end
    end
    handles.clas{1,1}=1:length(handles.condm{1,1});
    handles.clas{1,2}=cell(length(handles.condm{1,1}),2);
    for j=1:length(get(handles.group_list,'String'))
        handles.clas{1,2}{j,1}=1:length(handles.condm{1,2}{j});
        handles.clas{1,2}{j,2}=0;
    end
    cg=get(handles.group_list,'Value');
    list=handles.condm{1,2}{cg};
    %set subjects lists
    if handles.clas{1,2}{cg,1}~=0
        set(handles.uns_list,'Value',1);
        set(handles.uns_list,'String',list(handles.clas{1,2}{cg,1}));
    else
        set(handles.uns_list,'Value',0);
        set(handles.uns_list,'String',{});
    end
    if handles.clas{1,2}{cg,2}~=0
        set(handles.sel_list,'Value',1);
        set(handles.sel_list,'String',list(handles.clas{1,2}{cg,2}));
    else
        set(handles.sel_list,'Value',0);
        set(handles.sel_list,'String',{});
    end
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes prt_ui_select_reg wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prt_ui_select_reg_OutputFcn(hObject, eventdata, handles) 
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

%This figure can be deleted now
if isfield(handles,'figure1')
    delete(handles.figure1)
end



% --- Executes on selection change in group_list.
function group_list_Callback(hObject, eventdata, handles)
% hObject    handle to group_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns group_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from group_list
cl=1;
cg=get(handles.group_list,'Value');
list=handles.condm{1,2}{cg};
%set subjects lists
if handles.clas{cl,2}{cg,1}~=0
    set(handles.uns_list,'Value',1);
    set(handles.uns_list,'String',list(handles.clas{cl,2}{cg,1}));
else
    set(handles.uns_list,'Value',0);
    set(handles.uns_list,'String',{});
end
if handles.clas{cl,2}{cg,2}~=0
    set(handles.sel_list,'Value',1);
    set(handles.sel_list,'String',list(handles.clas{cl,2}{cg,2}));
else
    set(handles.sel_list,'Value',0);
    set(handles.sel_list,'String',{});
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function group_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to group_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
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
induns=1:length(get(handles.uns_list,'String'));
indok=setdiff(induns,val);
cl=1;
cg=get(handles.group_list,'Value');
if handles.clas{cl,2}{cg,2}==0
    handles.clas{cl,2}{cg,2}=handles.clas{cl,2}{cg,1}(val);
else
    handles.clas{cl,2}{cg,2}=[handles.clas{cl,2}{cg,2}, handles.clas{cl,2}{cg,1}(val)];
end
if isempty(indok)
    handles.clas{cl,2}{cg,1}=0;
else
    handles.clas{cl,2}{cg,1}=handles.clas{cl,2}{cg,1}(indok);
end
list=handles.condm{1,2}{cg};
%set subjects lists
if handles.clas{cl,2}{cg,1}~=0
    set(handles.uns_list,'Value',1);
    set(handles.uns_list,'String',list(handles.clas{cl,2}{cg,1}));
else
    set(handles.uns_list,'Value',0);
    set(handles.uns_list,'String',{});
end
if handles.clas{cl,2}{cg,2}~=0
    set(handles.sel_list,'Value',1);
    set(handles.sel_list,'String',list(handles.clas{cl,2}{cg,2}));
else
    set(handles.sel_list,'Value',0);
    set(handles.sel_list,'String',{});
end

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
indsel=1:length(get(handles.sel_list,'String'));
indok=setdiff(indsel,val);
cl=1;
cg=get(handles.group_list,'Value');
if handles.clas{cl,2}{cg,1}==0
    handles.clas{cl,2}{cg,1}=handles.clas{cl,2}{cg,2}(val);
else
    handles.clas{cl,2}{cg,1}=[handles.clas{cl,2}{cg,1}, handles.clas{cl,2}{cg,2}(val)];
end
if isempty(indok)
    handles.clas{cl,2}{cg,2}=0;
else
    handles.clas{cl,2}{cg,2}=handles.clas{cl,2}{cg,2}(indok);
end
list=handles.condm{1,2}{cg};
%set subjects lists
if handles.clas{cl,2}{cg,1}~=0
    set(handles.uns_list,'String',list(handles.clas{cl,2}{cg,1}));
    set(handles.uns_list,'Value',length(get(handles.uns_list,'String')));
else
    set(handles.uns_list,'Value',0);
    set(handles.uns_list,'String',{});
end
if handles.clas{cl,2}{cg,2}~=0
    set(handles.sel_list,'String',list(handles.clas{cl,2}{cg,2}));
    set(handles.sel_list,'Value',length(get(handles.sel_list,'String')));
else
    set(handles.sel_list,'Value',0);
    set(handles.sel_list,'String',{});
end
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


% --- Executes on button press in sel_all.
function sel_all_Callback(hObject, eventdata, handles)
% hObject    handle to sel_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cl=1;
cg=get(handles.group_list,'Value');
list=handles.condm{1,2}{cg,1};
indsel=1:length(list);
handles.clas{cl,2}{cg,2}=indsel;
handles.clas{cl,2}{cg,1}=0;
set(handles.uns_list,'String',{});
set(handles.uns_list,'Value',0);
set(handles.sel_list,'String',list(handles.clas{cl,2}{cg,2}));
set(handles.sel_list,'Value',length(get(handles.sel_list,'String')));
% Update handles structure
guidata(hObject, handles);




% --- Executes on button press in done_button.
function done_button_Callback(hObject, eventdata, handles)
% hObject    handle to done_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

for i=1:size(handles.clas,1)
    list=get(handles.group_list,'String');
    for g=1:length(list)
        scount=1;
        g2=find(strcmpi(list{g},{handles.dat.group(:).gr_name}));
        sids=handles.clas{i,2}{g,2};
        handles.class(i).group(g2).gr_name=list{g};
        for s=1:length(sids)
            handles.class(i).group(g2).subj(scount).num=sids(s);
            listm={handles.dat.fs(handles.indfs).modality(:).mod_name};
            for m=1:length(listm)
                handles.class(i).group(g2).subj(scount).modality(m).mod_name=listm{m};
            end
            scount=scount+1;
        end
    end
end

handles.output=handles.class.group;
% Update handles structure
guidata(hObject, handles);

uiresume(handles.figure1)
