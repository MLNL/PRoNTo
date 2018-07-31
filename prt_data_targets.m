function varargout = prt_data_targets(varargin)
% PRT_DATA_TARGETS M-file for prt_data_targets.fig
% 
% PRT_DATA_TARGETS, by itself, creates a new PRT_DATA_TARGETS or 
% raises the existing singleton*.
%
% H = PRT_DATA_TARGETS returns the handle to a new PRT_DATA_TARGETS 
% or the handle to the existing singleton*.
%
% PRT_DATA_TARGETS('CALLBACK',hObject,eventData,handles,...) calls the 
% local function named CALLBACK in PRT_DATA_TARGETS.M with the given 
% input arguments.
%
% PRT_DATA_TARGETS('Property','Value',...) creates a new 
% PRT_DATA_TARGETS or raises the existing singleton*.  Starting from the
% left, property value pairs are applied to the GUI before 
% prt_data_targets_OpeningFcn gets called.  An unrecognized property name
% or invalid value makes property application stop.  All inputs are passed 
% to prt_data_targets_OpeningFcn via varargin.
%
% *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%  instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J.Schrouff
% $Id$

% Edit the above text to modify the response to help prt_data_targets

% Last Modified by GUIDE v2.5 31-Jul-2018 10:50:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prt_data_targets_OpeningFcn, ...
                   'gui_OutputFcn',  @prt_data_targets_OutputFcn, ...
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


% --- Executes just before prt_data_targets is made visible.
function prt_data_targets_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_data_targets (see VARARGIN)

% Choose default command line output for prt_data_targets
handles.output = hObject;

%if window already exists, just put it as the current figure
Tag='DDTargets';
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
    %build figure when it doesn't exist yet
    set(handles.figure1,'Name','PRoNTo :: Specify targets')
    set(handles.targmenu,'String',{'Specify','From .mat file'})
    set(handles.targmenu,'Value',2)
%set size of the window, taking screen resolution and platform into account
S0= spm('WinSize','0',1);   %-Screen size (of the current monitor)
if ispc
    PF ='MS Sans Serif';
else
    PF = spm_platform('fonts');     %-Font names (for this platform)
    PF = PF.helvetica;
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
set(handles.figure1,'Resize','on')

% Choose the color of the different backgrounds and figure parameters
color=prt_get_defaults('color');
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
                'radiobutton','checkbox','listbox'})))
            set(aa(i),'BackgroundColor',color.bg1)
        elseif ~isempty(find(strcmpi(get(aa(i),'Style'),'pushbutton')))
            set(aa(i),'BackgroundColor',color.fr)
        end
    end
    set(aa(i),'FontUnits','pixel')
    xf=get(aa(i),'FontSize');
    if ispc
        set(aa(i),'FontSize',ceil(FS*xf),'FontName',PF,...
            'FontUnits','normalized','Units','normalized')
    else
        set(aa(i),'FontSize',ceil(FS*xf),'FontName',PF,...
            'Units','normalized')
    end
end

% Fill fields if targets have been specified for this modality
handles.rt_subj=struct();
if ~isempty(varargin) && strcmpi(varargin{1},'UserData')
    rt=varargin{2}{1};
    szn=length(rt);    
    dat=cell(szn,2);
    handles.rt_subj = rt;
    for i=1:szn
        try
            dat{i,1}=rt(i).name;
        catch
            dat{i,1}=['Tar ',num2str(i)];
        end
        handles.rt_subj(i).name=dat{i,1};
        try
            temp=[];
            for j=1:length(rt(i).tar)
                temp=[temp, ' ',num2str(rt(i).tar(j),3)];
            end
            dat{i,2}=temp;
            handles.rt_subj(i).tar=rt(i).tar;
        catch
            dat{i,2}='NaN';
            handles.rt_subj(i).tar=[];
        end
    end
    set(handles.targtable,'visible','on');
    set(handles.targtable,'Data',dat);
else
    dat={'Tar 1','NaN'};
    set(handles.targtable,'visible','off');
end
set(handles.targtable,'Data',dat);
set(handles.targtable,'ColumnName',{'Name','Regression targets'});
set(handles.targtable,'ColumnEditable',[true,true]);
set(handles.targtable,'ColumnWidth',{200,250});
set(handles.targtable,'ColumnFormat',{'char','char'});

end

% Update handles structure
guidata(hObject, handles);

%UIWAIT makes prt_data_targets wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prt_data_targets_OutputFcn(hObject, eventdata, handles) 
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

% The figure can be deleted now
if isfield(handles,'figure1')
    delete(handles.figure1);
end


% --- Executes on selection change in targmenu.
function targmenu_Callback(hObject, eventdata, handles)
% hObject    handle to targmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns targmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from targmenu
choice=get(handles.targmenu,'Value');
if choice==1
    ntar=str2double(prt_text_input('Title','Enter number of targets'));
    if isnan(ntar)
        return
    end
    dat=cell(ntar,2);
    for i=1:ntar
        dat{i,1}=['Tar ',num2str(i)];
        dat{i,2}='NaN';
        handles.rt_subj(i).name=['Tar ',num2str(i)];
    end
    set(handles.targtable,'visible','on');
    set(handles.targtable,'Data',dat);
else
    tarfile = spm_select(1,'.mat','Select regression target file');
    try
        load(tarfile);
    catch
        beep
        disp('Could not load file')
        return
    end
    try
        na=names;
    catch
        beep
        disp('No "names" found in the .mat file, using default names')
    end
    try
        tar=rt_subj;
    catch
        beep
        disp('No "rt_subj" found in the .mat file, please select another file')
        return
    end
    szn=length(names);    
    dat=cell(szn,2);
    for i=1:szn
        try
            dat{i,1}=na{i};
        catch
            dat{i,1}=['Tar ',num2str(i)];
        end
        handles.rt_subj(i).name=dat{i,1};
        try
            dat{i,2}=num2str(tar(:,i)',3);
            handles.rt_subj(i).tar=tar(:,i)';
        catch
            dat{i,2}='NaN';
            handles.rt_subj(i).tar=[];
        end
    end
    set(handles.targtable,'visible','on');
    set(handles.targtable,'Data',dat);
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function targmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to targmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes when entered data in editable cell(s) in targtable.
function targtable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to targtable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

ind=eventdata.Indices;
if ind(2)>1
    dat=eventdata.EditData;
    try
        eval(['vect=[',dat,'];']);
    catch
        warning('prt_data_targets:EvalError',...
            'Could not evaluate statement, please correct')
        return
    end
    % check for bad values or formatting
    if ~any(size(vect)==1)|| any(isnan(vect)) || any(vect>10^6) 
        beep
        disp('Bad formatting of values found!')
        sprintf('Please review and correct condition %d, column %d', ind(1), ind(2))
        return
    end
end

if ind(2)==1
    handles.rt_subj(ind(1)).name=eventdata.EditData;
    vect = [];
elseif ind(2)==2
    handles.rt_subj(ind(1)).tar=vect;
end
temp=[];
if ~isempty(vect)
    for j=1:length(vect)
        temp=[temp, ' ',num2str(vect(j),3)];
    end
else
    temp = handles.rt_subj(ind(1)).name;
end
dat = get(handles.targtable,'Data');
dat{ind(1),ind(2)} = temp;
set(handles.targtable,'Data',dat);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in okbutton.
function okbutton_Callback(hObject, eventdata, handles)
% hObject    handle to okbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get number of targets 
ntar=length(handles.rt_subj);

%check that each target has the same number of targets
for i=1:ntar
    sztar=length(handles.rt_subj(i).tar);
    if i==1
        szrt = sztar;
    end
    if sztar ~=szrt
        beep
        disp('The number of regression targets must be the same in all targets!')
        sprintf('Please correct target %d',i)
        return
    end
end

%Output targets
handles.output=handles.rt_subj;
% Update handles structure
guidata(hObject, handles);

uiresume(handles.figure1);

% --- Executes on button press in cancelbutton.
function cancelbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);

