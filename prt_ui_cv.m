function varargout = prt_ui_cv(varargin)
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
% $Id$

% Edit the above text to modify the response to help prt_ui_kernel_construction

% Last Modified by GUIDE v2.5 26-Sep-2011 11:09:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prt_ui_kernel_construction_OpeningFcn, ...
                   'gui_OutputFcn',  @prt_ui_kernel_construction_OutputFcn, ...
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
function prt_ui_kernel_construction_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_ui_kernel_construction (see VARARGIN)

% Choose default command line output for prt_ui_kernel_construction
handles.output = hObject;
set(handles.group_list,'Enable','off')
set(handles.uns_list,'Enable','off')
set(handles.sel_list,'Enable','off')
set(handles.uns_cond_list,'Enable','off')
set(handles.sel_cond_list,'Enable','off')
set(handles.sel_all,'Enable','off')
set(handles.sel_cond_all,'Enable','off');
set(handles.pop_compa,'String',{'Groups', 'Conditions'})

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes prt_ui_kernel_construction wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prt_ui_kernel_construction_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


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
%get names of modalities
list={handles.dat.masks(:).mod_name};
set(handles.pop_mod,'String',list);
nm=length(list);
%get names of groups
list={handles.dat.group(:).gr_name};
ng=length(list);
set(handles.group_list,'String',list)
set(handles.group_list,'Value',1)
list={handles.dat.group(1).subject(:).subj_name};
set(handles.uns_list,'String',list);
set(handles.sel_list,'String',{}); 
handles.condm=cell(nm,3);
%get the conditions which are common to all groups and subjects for the
%different modalities
for i=1:nm
    handles.condm{i,1}=get(handles.group_list,'String');
    handles.condm{i,3}=cell(length(get(handles.group_list,'String')),1);
    flag=1;
    for j=1:ng
        handles.condm{i,3}{j}={handles.dat.group(j).subject(:).subj_name};
        for k=1:length(handles.dat.group(j).subject)
            des=handles.dat.group(j).subject(k).modality(nm).design;
            if isstruct(des) && flag
                if k==1
                    lcond={des.conds(:).cond_name};
                else
                    tocmp={des.conds(:).cond_name};
                    for xx=1:length(lcond)
                        if ~any(strcmpi(lcond(i),tocmp))
                            ind=1:length(lcond);
                            nind=setdiff(ind,i);
                            lcond=lcond(nind);
                        end
                    end
                end
            else
                handles.condm{i,2}=0;
                flag=0;
            end
        end
    end
    handles.condm{i,2}=lcond;
end
handles.clas=cell(nm);
% Update handles structure
guidata(hObject, handles);

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
%get names of modalities
list={handles.dat.masks(:).mod_name};
nm=length(list);
set(handles.pop_mod,'String',list);
%get names of groups
list={handles.dat.group(:).gr_name};
ng=length(list);
set(handles.group_list,'String',list)
set(handles.group_list,'Value',1)
list={handles.dat.group(1).subject(:).subj_name};
set(handles.uns_list,'String',list);
set(handles.sel_list,'String',{});
handles.condm=cell(nm,3);
%get the conditions which are common to all groups and subjects for the
%different modalities
for i=1:nm
    handles.condm{i,1}=get(handles.uns_list,'String');
    handles.condm{i,3}=cell(length(get(handles.group_list,'String')),1);
    flag=1;
    for j=1:ng
        handles.condm{i,3}{j}={handles.dat.group(j).subject(:).subj_name};
        for k=1:length(handles.dat.group(j).subject)
            des=handles.dat.group(j).subject(k).modality(nm).design;
            if isstruct(des) && flag
                if k==1
                    lcond={des.conds(:).cond_name};
                else
                    tocmp={des.conds(:).cond_name};
                    for xx=1:length(lcond)
                        if ~any(strcmpi(lcond(i),tocmp))
                            ind=1:length(lcond);
                            nind=setdiff(ind,i);
                            lcond=lcond(nind);
                        end
                    end
                end
            else
                handles.condm{i,2}=0;
                flag=0;
            end
        end
    end
    handles.condm{i,2}=lcond;
end
handles.clas=cell(nm);
%set the lists as the conditions of the first modality
set(handles.uns_cond_list,'String',handles.condm{1,2});
set(handles.sel_cond_list,'String',{});
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

% --- Executes on selection change in pop_mod.
function pop_mod_Callback(hObject, eventdata, handles)
% hObject    handle to pop_mod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_mod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_mod
mname=get(handles.pop_mod,'String');
val=find(strcmpi({handles.dat.group(1).subject(1).modality(:).mod_name},mname));
des=handles.dat.group(1).subject(1).modality(val).design;
set(handles.group_list,'Value',1);
if ~isstruct(des)
    set(handles.uns_cond_list,'Enable','off')
    set(handles.sel_cond_list,'Enable','off');
    set(handles.sel_cond_all,'Enable','off');
    set(handles.pop_compa,'Value',1);
    lcv={'Leave One Out','Leave 2 out','Leave Half Out'};
    lval={'No','Leave One Out','Leave 2 out'};
else
    if ~isnumeric(get(handles.num_class,'String'))
        set(handles.uns_cond_list,'String',handles.condm{val,2});
        set(handles.sel_cond_list,'String',{});
        set(handles.uns_list,'String',handles.condm{val,3}{1});
        set(handles.sel_list,'String',{});
    else
        set(handles.uns_cond_list,'String',handles.condm{val,2});
        set(handles.sel_cond_list,'String',{});
        set(handles.uns_list,'String',handles.condm{val,3}{1});
        set(handles.sel_list,'String',{});
    end
    lcv={'Leave One Out','Leave 2 out','Leave Block Out','Leave Half Out'};
    lval={'No','Leave One Out','Leave 2 out','Leave Block Out'};
end
set(handles.pop_cv,'String',lcv);
set(handles.pop_val,'String',lval);
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function pop_mod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_mod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_compa.
function pop_compa_Callback(hObject, eventdata, handles)
% hObject    handle to pop_compa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_compa contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_compa


% --- Executes during object creation, after setting all properties.
function pop_compa_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_compa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function num_class_Callback(hObject, eventdata, handles)
% hObject    handle to num_class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_class as text
%        str2double(get(hObject,'String')) returns contents of num_class as a double
ncl=str2double(get(handles.num_class,'String'));
if isnan(ncl)
    return
end
%set the names of the classes in the pop_class
cl={};
for i=1:ncl
    cl=[cl,{['Class ',num2str(i)]}];
end
set(handles.pop_class,'String',cl);
set(handles.pop_class,'Value',1);
%for each class of that modality, build a cell containing the indexes of
%the selected groups and conditions
val=get(handles.pop_mod,'Value');
handles.clas{val}=cell(ncl,4);
for i=1:ncl
    handles.clas{val}{i,1}=1:length(handles.condm{val,1});
    handles.clas{val}{i,2}=cell(length(handles.condm{val,1}),2);
    for j=1:length(get(handles.group_list,'String'))
        handles.clas{val}{i,2}{j,1}=1:length(handles.condm{val,3}{j});
        handles.clas{val}{i,2}{j,2}=0;
    end
    handles.clas{val}{i,3}=1:length(handles.condm{val,2});
    handles.clas{val}{i,4}=0;
end
    
% Update handles structure
guidata(hObject, handles);
 

% --- Executes during object creation, after setting all properties.
function num_class_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_class.
function pop_class_Callback(hObject, eventdata, handles)
% hObject    handle to pop_class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_class contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_class
%initialize the conditions structure for each group and modality
vc=get(handles.pop_class,'Value');
val=get(handles.pop_mod,'Value');
cg=get(handles.group_list,'Value');
list=handles.condm{val,3}{cg};
clist=handles.condm{val,2};
%set subjects lists
if handles.clas{val}{vc,2}{cg,1}~=0
    set(handles.uns_list,'Value',1);
    set(handles.uns_list,'String',list(handles.clas{val}{vc,2}{cg,1}));
else
    set(handles.uns_list,'Value',0);
    set(handles.uns_list,'String',{});
end
if handles.clas{val}{vc,2}{cg,2}~=0
    set(handles.sel_list,'Value',1);
    set(handles.sel_list,'String',list(handles.clas{val}{vc,2}{cg,2}));
else
    set(handles.sel_list,'Value',0);
    set(handles.sel_list,'String',{});
end
%set conditions lists
if handles.clas{val}{vc,3}~=0
    set(handles.uns_cond_list,'Value',1);
    set(handles.uns_cond_list,'String',clist(handles.clas{val}{vc,3}));
else
    set(handles.uns_cond_list,'Value',0);
    set(handles.uns_cond_list,'String',{});
end
if handles.clas{val}{vc,4}~=0
    set(handles.sel_cond_list,'Value',1);
    set(handles.sel_cond_list,'String',clist(handles.clas{val}{vc,4}));
else
    set(handles.sel_cond_list,'Value',0);
    set(handles.sel_cond_list,'String',{});
end
set(handles.uns_cond_list,'Enable','on');
set(handles.sel_cond_list,'Enable','on');
set(handles.sel_cond_all,'Enable','on');
set(handles.uns_list,'Enable','on');
set(handles.sel_list,'Enable','on');
set(handles.sel_all,'Enable','on');
set(handles.group_list,'Enable','on');
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function pop_class_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in group_list.
function group_list_Callback(hObject, eventdata, handles)
% hObject    handle to group_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns group_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from group_list
cl=get(handles.pop_class,'Value');
cm=get(handles.pop_mod,'Value');
cg=get(handles.group_list,'Value');
list=handles.condm{cm,3}{cg};
%set subjects lists
if handles.clas{cm}{cl,2}{cg,1}~=0
    set(handles.uns_list,'Value',1);
    set(handles.uns_list,'String',list(handles.clas{cm}{cl,2}{cg,1}));
else
    set(handles.uns_list,'Value',0);
    set(handles.uns_list,'String',{});
end
if handles.clas{cm}{cl,2}{cg,2}~=0
    set(handles.sel_list,'Value',1);
    set(handles.sel_list,'String',list(handles.clas{cm}{cl,2}{cg,2}));
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
cl=get(handles.pop_class,'Value');
cm=get(handles.pop_mod,'Value');
cg=get(handles.group_list,'Value');
if handles.clas{cm}{cl,2}{cg,2}==0
    handles.clas{cm}{cl,2}{cg,2}=handles.clas{cm}{cl,2}{cg,1}(val);
else
    handles.clas{cm}{cl,2}{cg,2}=[handles.clas{cm}{cl,2}{cg,2}, handles.clas{cm}{cl,2}{cg,1}(val)];
end
if isempty(indok)
    handles.clas{cm}{cl,2}{cg,1}=0;
else
    handles.clas{cm}{cl,2}{cg,1}=handles.clas{cm}{cl,2}{cg,1}(indok);
end
list=handles.condm{cm,3}{cg};
%set subjects lists
if handles.clas{cm}{cl,2}{cg,1}~=0
    set(handles.uns_list,'Value',1);
    set(handles.uns_list,'String',list(handles.clas{cm}{cl,2}{cg,1}));
else
    set(handles.uns_list,'Value',0);
    set(handles.uns_list,'String',{});
end
if handles.clas{cm}{cl,2}{cg,2}~=0
    set(handles.sel_list,'Value',1);
    set(handles.sel_list,'String',list(handles.clas{cm}{cl,2}{cg,2}));
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
cl=get(handles.pop_class,'Value');
cm=get(handles.pop_mod,'Value');
cg=get(handles.group_list,'Value');
if handles.clas{cm}{cl,2}{cg,1}==0
    handles.clas{cm}{cl,2}{cg,1}=handles.clas{cm}{cl,2}{cg,2}(val);
else
    handles.clas{cm}{cl,2}{cg,1}=[handles.clas{cm}{cl,2}{cg,1}, handles.clas{cm}{cl,2}{cg,2}(val)];
end
if isempty(indok)
    handles.clas{cm}{cl,2}{cg,2}=0;
else
    handles.clas{cm}{cl,2}{cg,2}=handles.clas{cm}{cl,2}{cg,2}(indok);
end
list=handles.condm{cm,3}{cg};
%set subjects lists
if handles.clas{cm}{cl,2}{cg,1}~=0
    set(handles.uns_list,'String',list(handles.clas{cm}{cl,2}{cg,1}));
    set(handles.uns_list,'Value',length(get(handles.uns_list,'String')));
else
    set(handles.uns_list,'Value',0);
    set(handles.uns_list,'String',{});
end
if handles.clas{cm}{cl,2}{cg,2}~=0
    set(handles.sel_list,'String',list(handles.clas{cm}{cl,2}{cg,2}));
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
cl=get(handles.pop_class,'Value');
cm=get(handles.pop_mod,'Value');
cg=get(handles.group_list,'Value');
list=handles.condm{cm,3}{cg,1};
indsel=1:length(list);
handles.clas{cm}{cl,2}{cg,2}=indsel;
handles.clas{cm}{cl,2}{cg,1}=0;
set(handles.uns_list,'String',{});
set(handles.uns_list,'Value',0);
set(handles.sel_list,'String',list(handles.clas{cm}{cl,2}{cg,2}));
set(handles.sel_list,'Value',length(get(handles.sel_list,'String')));
% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in uns_cond_list.
function uns_cond_list_Callback(hObject, eventdata, handles)
% hObject    handle to uns_cond_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns uns_cond_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from uns_cond_list
val=get(handles.uns_cond_list,'Value');
induns=1:length(get(handles.uns_cond_list,'String'));
indok=setdiff(induns,val);
cl=get(handles.pop_class,'Value');
cm=get(handles.pop_mod,'Value');
if handles.clas{cm}{cl,4}==0
    handles.clas{cm}{cl,4}=handles.clas{cm}{cl,3}(val);
else
    handles.clas{cm}{cl,4}=[handles.clas{cm}{cl,4}, handles.clas{cm}{cl,3}(val)];
end
if isempty(indok)
    handles.clas{cm}{cl,3}=0;
else
    handles.clas{cm}{cl,3}=handles.clas{cm}{cl,3}(indok);
end
%set conditions lists
clist=handles.condm{cm,2};
if handles.clas{cm}{cl,3}~=0
    set(handles.uns_cond_list,'Value',1);
    set(handles.uns_cond_list,'String',clist(handles.clas{cm}{cl,3}));
else
    set(handles.uns_cond_list,'Value',0);
    set(handles.uns_cond_list,'String',{});
end
if handles.clas{cm}{cl,4}~=0
    set(handles.sel_cond_list,'Value',1);
    set(handles.sel_cond_list,'String',clist(handles.clas{cm}{cl,4}));
else
    set(handles.sel_cond_list,'Value',0);
    set(handles.sel_cond_list,'String',{});
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function uns_cond_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uns_cond_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sel_cond_list.
function sel_cond_list_Callback(hObject, eventdata, handles)
% hObject    handle to sel_cond_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns sel_cond_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sel_cond_list
val=get(handles.sel_cond_list,'Value');
induns=1:length(get(handles.sel_cond_list,'String'));
indok=setdiff(induns,val);
cl=get(handles.pop_class,'Value');
cm=get(handles.pop_mod,'Value');
if handles.clas{cm}{cl,3}==0
    handles.clas{cm}{cl,3}=handles.clas{cm}{cl,4}(val);
else
    handles.clas{cm}{cl,3}=[handles.clas{cm}{cl,3}, handles.clas{cm}{cl,4}(val)];
end
if isempty(indok)
    handles.clas{cm}{cl,4}=0;
else
    handles.clas{cm}{cl,4}=handles.clas{cm}{cl,4}(indok);
end
%set conditions lists
clist=handles.condm{cm,2};
if handles.clas{cm}{cl,3}~=0
    set(handles.uns_cond_list,'String',clist(handles.clas{cm}{cl,3}));
    set(handles.uns_cond_list,'Value',length(get(handles.uns_cond_list,'String')));
else
    set(handles.uns_cond_list,'Value',0);
    set(handles.uns_cond_list,'String',{});
end
if handles.clas{cm}{cl,4}~=0
    set(handles.sel_cond_list,'String',clist(handles.clas{cm}{cl,4}));
    set(handles.sel_cond_list,'Value',length(get(handles.sel_cond_list,'String')));
else
    set(handles.sel_cond_list,'Value',0);
    set(handles.sel_cond_list,'String',{});
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sel_cond_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sel_cond_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sel_cond_all.
function sel_cond_all_Callback(hObject, eventdata, handles)
% hObject    handle to sel_cond_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cl=get(handles.pop_class,'Value');
cm=get(handles.pop_mod,'Value');
list=handles.condm{cm,2};
indsel=1:length(list);
handles.clas{cm}{cl,4}=indsel;
handles.clas{cm}{cl,3}=0;
set(handles.uns_cond_list,'String',{});
set(handles.uns_cond_list,'Value',0);
set(handles.sel_cond_list,'String',list(handles.clas{cm}{cl,4}));
set(handles.sel_cond_list,'Value',length(get(handles.sel_cond_list,'String')));
% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in pop_cv.
function pop_cv_Callback(hObject, eventdata, handles)
% hObject    handle to pop_cv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_cv contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_cv


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


% --- Executes on selection change in pop_val.
function pop_val_Callback(hObject, eventdata, handles)
% hObject    handle to pop_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_val contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_val


% --- Executes during object creation, after setting all properties.
function pop_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_val (see GCBO)
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


%--------------------------------------------------------------------------
%-----------------------Subfunctions---------------------------------------
%--------------------------------------------------------------------------

function [co]=check_selection(handles)

