function varargout = prt_data_conditions(varargin)
% PRT_DATA_CONDITIONS M-file for prt_data_conditions.fig
%      PRT_DATA_CONDITIONS, by itself, creates a new PRT_DATA_CONDITIONS or raises the existing
%      singleton*.
%
%      H = PRT_DATA_CONDITIONS returns the handle to a new PRT_DATA_CONDITIONS or the handle to
%      the existing singleton*.
%
%      PRT_DATA_CONDITIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PRT_DATA_CONDITIONS.M with the given input arguments.
%
%      PRT_DATA_CONDITIONS('Property','Value',...) creates a new PRT_DATA_CONDITIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before prt_data_conditions_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to prt_data_conditions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help prt_data_conditions

% Last Modified by GUIDE v2.5 30-Aug-2011 17:32:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prt_data_conditions_OpeningFcn, ...
                   'gui_OutputFcn',  @prt_data_conditions_OutputFcn, ...
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


% --- Executes just before prt_data_conditions is made visible.
function prt_data_conditions_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_data_conditions (see VARARGIN)

% Choose default command line output for prt_data_conditions
handles.output = hObject;
set(handles.condmenu,'String',{'Specify','From .mat file'})
set(handles.condmenu,'Value',2)
handles.cond=struct();
if ~isempty(varargin) && strcmpi(varargin{1},'UserData')
    des=varargin{2};
    szn=length(des.conds);    
    dat=cell(szn,3);
    for i=1:szn
        try
            dat{i,1}=des.conds(i).cond_name;
        catch
            dat{i,1}=['cond ',num2str(i)];
        end
        handles.cond(i).cond_name=dat{i,1};
        try
            text=[];
            dur=des.conds(i).durations;
            for j=1:length(dur)
                text=[text, num2str(dur(j)),', '];
            end
            dat{i,3}=text(1:end-2);
            handles.cond(i).durations=dur;
        catch
            dat{i,3}='NaN';
            handles.cond(i).durations=[];
        end
        try
            text=[];
            ons=des.conds(i).onsets;
            for j=1:length(ons)
                text=[text, num2str(ons(j)),', '];
            end
            dat{i,2}=text(1:end-2);
            handles.cond(i).onsets=ons;
        catch
            dat{i,2}='NaN';
            handles.cond(i).onsets=[];
        end
    end
    set(handles.condtable,'visible','on');
    set(handles.condtable,'Data',dat);
    handles.trval=des.TR;
    set(handles.tredit,'String',num2str(des.TR));
    if ~isempty(des.covar)
        for j=1:length(des.covar)
            text=[text, num2str(des.covar(j)),', '];
        end
        set(handles.covedit,'String',text(1:end-2));
        handles.covar=des.covar;
    else
        handles.covar=[];
        set(handles.covedit,'String','');
    end
else
    dat={'cond1','0','0'};
    set(handles.condtable,'visible','off');
    handles.trval=0;
    handles.covar=[];
end
set(handles.condtable,'Data',dat);
set(handles.condtable,'ColumnName',{'Name','Onsets','Duration'});
set(handles.condtable,'ColumnEditable',[true,true,true]);
set(handles.condtable,'ColumnWidth',{'auto',130,130});
set(handles.condtable,'ColumnFormat',{'char','char','char'});



def=prt_get_defaults('datad');
handles.def=def;
% Update handles structure
guidata(hObject, handles);

%UIWAIT makes prt_data_conditions wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prt_data_conditions_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);


% --- Executes on selection change in condmenu.
function condmenu_Callback(hObject, eventdata, handles)
% hObject    handle to condmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns condmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from condmenu
choice=get(handles.condmenu,'Value');
if choice==1
    ncond=str2double(prt_text_input('Title','Enter number of conditions'));
    if isnan(ncond)
        return
    end
    dat=cell(ncond,3);
    for i=1:ncond
        dat{i,1}=['cond ',num2str(i)];
        dat{i,2}='NaN';
        dat{i,3}='NaN';
    end
    set(handles.condtable,'visible','on');
    set(handles.condtable,'Data',dat);
else
    des=spm_select(1,'.mat','Select multiple conditions file');
    try
        load(des);
    catch
        beep
        disp('Could not load file')
        return
    end
    try
        na=names;
    catch
        beep
        disp('No "names" found in the .mat file, please select another file')
        return
    end
    try
        dur=durations;
    catch
        beep
        disp('No "durations" found in the .mat file, please select another file')
        return
    end
    try
        ons=onsets;
    catch
        beep
        disp('No "onsets" found in the .mat file, please select another file')
        return
    end
    szn=length(names);    
    dat=cell(szn,3);
    for i=1:szn
        try
            dat{i,1}=na{i};
        catch
            dat{i,1}=['cond ',num2str(i)];
        end
        handles.cond(i).cond_name=dat{i,1};
        try
            text=[];
            for j=1:length(dur{i})
                text=[text, num2str(dur{i}(j)),', '];
            end
            dat{i,3}=text(1:end-2);
            handles.cond(i).durations=dur{i};
        catch
            dat{i,3}='NaN';
            handles.cond(i).durations=[];
        end
        try
            text=[];
            for j=1:length(ons{i})
                text=[text, num2str(ons{i}(j)),', '];
            end
            dat{i,2}=text(1:end-2);
            handles.cond(i).onsets=ons{i};
        catch
            dat{i,2}='NaN';
            handles.cond(i).onsets=[];
        end
    end
    set(handles.condtable,'visible','on');
    set(handles.condtable,'Data',dat);
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function condmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to condmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tredit_Callback(hObject, eventdata, handles)
% hObject    handle to tredit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tredit as text
%        str2double(get(hObject,'String')) returns contents of tredit as a double
val=get(handles.tredit,'String');
eval(['handles.trval=',val]);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function tredit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tredit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function covedit_Callback(hObject, eventdata, handles)
% hObject    handle to covedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of covedit as text
%        str2double(get(hObject,'String')) returns contents of covedit as a double
dat=deblank(get(handles.covedit,'String'));
num=strfind(dat,',');
if ~isempty(num)
    j=1;
    vect=zeros(1,length(num+1));
    for i=1:length(num)
        vect(i)=str2double(dat(j:num(i)-1));
        j=num(i)+1;
        if i==length(num)
            vect(i+1)=str2double(dat(j:end));         
        end
    end
else
    vect=str2double(dat);
end
startsz=length(vect);
vect=vect(~isnan(vect));
vect=unique(vect);
stopsz=length(vect);
if startsz~=stopsz
    beep
    disp('Bad formatting of values or duplicated values found!')
    disp('Please review and correct')
    return
end
handles.covar=vect;
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function covedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to covedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in condtable.
function condtable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to condtable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

ind=eventdata.Indices;
if ind(2)>1
    num=strfind(eventdata.EditData,',');
    if ~isempty(num)
        dat=deblank(eventdata.EditData);
    else
        num=strfind(eventdata.EditData,';');
        if ~isempty(num)
            dat=deblank(eventdata.EditData);
        else
            num=strfind(eventdata.EditData,' ');
            dat=eventdata.EditData;
        end
    end
    if ~isempty(num)
        j=1;
        vect=zeros(1,length(num+1));
        for i=1:length(num)
            vect(i)=str2double(dat(j:num(i)-1));
            j=num(i)+1;
            if i==length(num)
                vect(i+1)=str2double(dat(j:end));         
            end
        end
    else
        vect=str2double(dat);
        if isnan(vect) || vect>10^6
            beep
            disp('Bad formatting of values found!')
            sprintf('Please review and correct condition %d, column %d', ind(1), ind(2))
            disp('Values should be entered in the time_evt1, time_evt2, time_evt3 format')
            return
        end
    end
    startsz=length(vect);
    vect=vect(~isnan(vect));
    if ind(2)<3
        vect=unique(vect);
    end
    stopsz=length(vect);
    if  startsz~=stopsz
        beep
        disp('Bad formatting of values or duplicated values found!')
        sprintf('Please review and correct condition %d, column %d', ind(1), ind(2))
        return
    end
end
if ind(2)==1
    handles.cond(ind(1)).cond_name=eventdata.EditData;
elseif ind(2)==2
    handles.cond(ind(1)).onsets=vect;
elseif ind(2)==3
    handles.cond(ind(1)).durations=vect;
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in okbutton.
function okbutton_Callback(hObject, eventdata, handles)
% hObject    handle to okbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%check that the TR was entered
if handles.trval==0
    beep
    disp('Enter TR value before continuing')
    return
end


%get number of conditions 
ncond=length(handles.cond);

%check that for each condition, the size of the duration and onsets vectors
%are the same
for i=1:ncond
    szon=length(handles.cond(i).onsets);
    szdur=length(handles.cond(i).durations);
    if szdur==1
        handles.cond(i).durations=repmat(handles.cond(i).durations, 1, szon);
        szdur=length(handles.cond(i).durations);
    end
    if szdur ~=szon
        beep
        sprintf('The onsets and durations of condition %d do not have the same size', i)
        disp('Please correct')
        return
    end
end

%Check that the conditions do not overlap, either directly or when taking
%the width of the HRF into account
conds=prt_check_design(handles.cond,handles.trval);
conds.covar=handles.covar;
handles.output=conds;

% Update handles structure
guidata(hObject, handles);

uiresume(handles.figure1);

% --- Executes on button press in cancelbutton.
function cancelbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);
