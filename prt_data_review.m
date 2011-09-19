function varargout = prt_data_review(varargin)
% PRT_DATA_REVIEW M-file for prt_data_review.fig
%      PRT_DATA_REVIEW, by itself, creates a new PRT_DATA_REVIEW or raises the existing
%      singleton*.
%
%      H = PRT_DATA_REVIEW returns the handle to a new PRT_DATA_REVIEW or the handle to
%      the existing singleton*.
%
%      PRT_DATA_REVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PRT_DATA_REVIEW.M with the given input arguments.
%
%      PRT_DATA_REVIEW('Property','Value',...) creates a new PRT_DATA_REVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before prt_data_review_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to prt_data_review_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Written by J.Schrouff, 25/08/2011

% Edit the above text to modify the response to help prt_data_review

% Last Modified by GUIDE v2.5 05-Sep-2011 18:40:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prt_data_review_OpeningFcn, ...
                   'gui_OutputFcn',  @prt_data_review_OutputFcn, ...
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


% --- Executes just before prt_data_review is made visible.
function prt_data_review_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_data_review (see VARARGIN)

% Choose default command line output for prt_data_review
handles.output = hObject;


if ~isempty(varargin) && strcmpi(varargin{1},'UserData')
    %get number of groups and subjects/group
    PRT=varargin{2};
    ng=length(PRT.group);
    ns=zeros(ng,1);
    gname=cell(ng);
    handles.gname=gname;
    for i=1:ng
        ns(i)=length(PRT.group(i).subject);
        gname{i}=PRT.group(i).gr_name;
    end
    %get number of modalities and the index of those having designs
    nm=length(PRT.group(1).subject(1).modality);
    ind=[];
    list={};
    for i=1:nm
        if isstruct(PRT.group(1).subject(1).modality(i).design)
            ind=[ind, i];
            list=[list, {PRT.group(1).subject(1).modality(i).mod_name}];
        end
    end   
else
    beep
    disp('No data structure found at this point')
    disp('Please enter at least one completed group before reviewing')
    return
end

%Set the texts of the different fields
set(handles.numgr,'String',num2str(ng))
set(handles.nummod,'String',num2str(nm));
if isempty(ind)
    set(handles.des,'String','No')
    set(handles.modlist,'String',{'None'})
    set(handles.modlist,'Enable','off')
    set(handles.condask,'Visible','off')
    set(handles.axes2,'Visible','off')
    set(handles.axes3,'Visible','off')
    set(handles.numcond,'Visible','off')
    set(handles.pm1,'Visible','off')
    set(handles.pm2,'Visible','off')
    set(handles.intsc,'Visible','off')
    set(handles.befcor,'Visible','off')
    set(handles.aftcor,'Visible','off')
    set(handles.mbef,'Visible','off')
    set(handles.stdbef,'Visible','off')
    set(handles.maft,'Visible','off')
    set(handles.stdaft,'Visible','off')
else
    set(handles.des,'String','Yes')
    set(handles.modlist,'String',list)
    handles.ind=ind;
    set(handles.figure1,'CurrentAxes',handles.axes2)
    % Update handles structure
    guidata(hObject, handles);
    prt_disp_conditions(PRT,ind(1),handles,hObject);   
end

%Display the bar graph for the number of subjects/group
set(handles.figure1,'CurrentAxes',handles.axes1)
bar(handles.axes1,ns);
ylim([0 max(ns)+1])
set(handles.axes1,'XTickLabel',gname)
ylabel('Number of subjects')
handles.PRT=PRT;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes prt_data_review wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prt_data_review_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in modlist.
function modlist_Callback(hObject, eventdata, handles)
% hObject    handle to modlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns modlist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from modlist
val=get(handles.modlist,'Value');
set(handles.figure1,'CurrentAxes',handles.axes2)
prt_disp_conditions(handles.PRT,handles.ind(val),handles,hObject);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function modlist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to modlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%---------------------- Subfunctions --------------------------------------
%--------------------------------------------------------------------------
function prt_disp_conditions(dat,ind,handles,hObject)


mname=dat.group(1).subject(1).modality(ind).mod_name;
nco=length(dat.group(1).subject(1).modality(ind).design.conds);
set(handles.numcond,'String',num2str(nco));


meantp=zeros(length(dat.group),nco);
stdtp=zeros(length(dat.group),nco);
meantpdisc=zeros(length(dat.group),nco);
stdtpdisc=zeros(length(dat.group),nco);
mbef=zeros(length(dat.group),1);
stdbef=zeros(length(dat.group),1);
maft=zeros(length(dat.group),1);
stdaft=zeros(length(dat.group),1);
for i=1:length(dat.group)
    nsc=zeros(length(dat.group(i).subject),nco);
    ndisc=zeros(length(dat.group(i).subject),nco);
    overlbe=zeros(length(dat.group(i).subject),1);
    overlaf=zeros(length(dat.group(i).subject),1);
    for j=1:length(dat.group(i).subject)
        indm=find(strcmpi({dat.group(i).subject(j).modality(:).mod_name},mname));
        ncond=length(dat.group(i).subject(j).modality(indm).design.conds);
        des=dat.group(i).subject(j).modality(indm).design;
        for k=1:ncond
            nsc(j,k)=length(des.conds(k).scans);
            ndisc(j,k)=length(des.conds(k).discardedscans)+length(des.conds(k).hrfdiscardedscans);
        end
        overlbe(j)=des.stats.meanovl;
        overlaf(j)=des.stats.mgoodovl;
    end
    meantp(i,:)=mean(nsc);
    stdtp(i,:)=std(nsc);
    meantpdisc(i,:)=mean(ndisc);
    stdtpdisc(i,:)=std(ndisc);
    mbef(i)=mean(overlbe);
    stdbef(i)=std(overlbe);
    maft(i)=mean(overlaf);
    stdaft(i)=std(overlaf);
end

%plot the results into bar graphs
set(handles.figure1,'CurrentAxes',handles.axes2)
ncond=size(meantp,2);
vecty=2:2+ncond-1;
y=vecty;
for i=2:size(meantp,1)
    vecty=vecty+(ncond+1);
    y=[y;vecty];
end
x    = mean(y,2);
xdim = size(x,2);
if xdim == 1
    bar(meantp,1);
    hold on
    errorbar(meantp,stdtp,'.k')
else
    bar(x,meantp,1);
    hold on
    errorbar(y,meantp,stdtp,'.k')
end
ylim([0 max(meantp(:))+1])
ylabel('Number of scans')
set(handles.axes2,'XTickLabel',handles.gname)

set(handles.figure1,'CurrentAxes',handles.axes3)
if xdim == 1
    bar(meantpdisc,1)
    hold on
    errorbar(meantpdisc,stdtpdisc,'.k')
else
    bar(x,meantpdisc,1)
    hold on
    errorbar(y,meantpdisc,stdtpdisc,'.k')
end
aa=meantpdisc(:)+stdtpdisc(:);
ylim([0 max(aa)+1])
ylabel('Number of discarded scans')
set(handles.axes3,'XTickLabel',handles.gname)

%set the overlaps before and after HRF correction
set(handles.mbef,'String',num2str(mean(mbef)));
set(handles.stdbef,'String',num2str(mean(stdbef)));
set(handles.maft,'String',num2str(mean(maft)));
set(handles.stdaft,'String',num2str(mean(stdaft)));

% Update handles structure
guidata(hObject, handles);
