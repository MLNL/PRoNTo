function varargout = prt_ui_reviewCV(varargin)
% PRT_UI_REVIEWCV M-file for prt_ui_reviewCV.fig
%      PRT_UI_REVIEWCV, by itself, creates a new PRT_UI_REVIEWCV or raises the existing
%      singleton*.
%
%      H = PRT_UI_REVIEWCV returns the handle to a new PRT_UI_REVIEWCV or the handle to
%      the existing singleton*.
%
%      PRT_UI_REVIEWCV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PRT_UI_REVIEWCV.M with the given input arguments.
%
%      PRT_UI_REVIEWCV('Property','Value',...) creates a new PRT_UI_REVIEWCV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before prt_ui_reviewCV_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to prt_ui_reviewCV_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help prt_ui_reviewCV

% Last Modified by GUIDE v2.5 09-Nov-2011 13:38:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prt_ui_reviewCV_OpeningFcn, ...
                   'gui_OutputFcn',  @prt_ui_reviewCV_OutputFcn, ...
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


% --- Executes just before prt_ui_reviewCV is made visible.
function prt_ui_reviewCV_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_ui_reviewCV (see VARARGIN)

% Choose default command line output for prt_ui_reviewCV
handles.output = hObject;

set(handles.figure1,'Name','PRoNTo :: Review Cross-Validation')

if ~isempty(varargin{1}) && strcmpi(varargin{1},'UserData')
    handles.PRT=varargin{2}{1};
    handles.prtdir=varargin{2}{2};
else
    return
end
if ~isfield(handles.PRT,'model')
    beep
    disp('No model found in this PRT.mat')
    disp('No reviweing can be performed')
    return
end
listmod={handles.PRT.model(:).model_name};  
set(handles.pop_model,'String',listmod)
set(handles.pop_model,'Value',1)
%Get the indexes of the model and fs to display
indm=get(handles.pop_model,'Value');
if indm==0
    set(handles.pop_model,'Value',1)
    indm=1;
end
in.fs_name=handles.PRT.model(indm).input.fs.fs_name;
indf=prt_init_fs(handles.PRT,in);
% Update handles structure
guidata(hObject, handles);
disp_cv(hObject,handles,indm,indf);



% UIWAIT makes prt_ui_reviewCV wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prt_ui_reviewCV_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in pop_model.
function pop_model_Callback(hObject, eventdata, handles)
% hObject    handle to pop_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pop_model contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_model
val=get(handles.pop_model,'Value');
if val==0
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
    set(handles.pop_model,'Value',1)
end
%Get the indexes of the model and fs to display
indm=get(handles.pop_model,'Value');
if indm==0
    set(handles.pop_model,'Value',1)
    indm=1;
end
in.fs_name=handles.PRT.model(indm).input.fs.fs_name;
indf=prt_init_fs(handles.PRT,in);
guidata(hObject,handles)
disp_cv(hObject,handles,indm,indf)

% --- Executes during object creation, after setting all properties.
function pop_model_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in kernbutt.
function kernbutt_Callback(hObject, eventdata, handles)
% hObject    handle to kernbutt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Get the indexes of the model and fs to display
indm=get(handles.pop_model,'Value');
if indm==0
    set(handles.pop_model,'Value',1)
    indm=1;
end
in.fs_name=handles.PRT.model(indm).input.fs.fs_name;
indf=prt_init_fs(handles.PRT,in);
hf=figure;
set(hf,'NumberTitle','off')
set(hf,'Name','PRoNTo :: Review kernel')
kername=handles.PRT.fs(indf).k_file;
try
    load([handles.prtdir,filesep,kername])
catch
    beep
    disp('Could not load kernel file')
    return
end
imagesc(Phi)
colormap(jet)
colorbar


%--------------------------------------------------------------------------
%-------------------------  Subfunctions ----------------------------------
%--------------------------------------------------------------------------

function disp_cv(hObject,handles,indm,indf)

cla(handles.axes1)
cla(handles.axes2)
cla(handles.axes3)

%Plot the id_mat in the left part of the window
set(handles.figure1,'CurrentAxes',handles.axes1)
imagesc(handles.PRT.fs(indf).id_mat(:,1:5));
set(gca,'XTickLabel',{'Group','Subject','Modality','Condition','Block'},...
    'FontWeight','demi');
set(gca,'YTickLabel',{})
colorbar('Location','WestOutside')
set(get(gca,'Title'),'String','Feature set','FontWeight','bold')

%Plot the CV matrix in the right part of the window
set(handles.figure1,'CurrentAxes',handles.axes2)
CV_mat_full=zeros(size(handles.PRT.fs.id_mat,1),...
    size(handles.PRT.model(indm).input.cv_mat,2));
xticksl=cell(1,size(handles.PRT.model(indm).input.cv_mat,2));
for i=1:size(handles.PRT.model(indm).input.cv_mat,2)
    CV_mat_full(handles.PRT.model(indm).input.samp_idx,i)=handles.PRT.model(indm).input.cv_mat(:,i);
    xticksl{i}=num2str(i);
end
set(gca,'FontWeight','bold')
xlabel('CV Folds','fontweight','demi')
imagesc(CV_mat_full);
set(gca,'YTickLabel',{})
set(gca,'XTickLabel',xticksl,'FontWeight','demi')
colormap(gray)
set(get(gca,'Title'),'String','Cross-Validation','FontWeight','bold')

%Plot the 'legend' corresponding to the CV matrix in the right bottom part
set(handles.figure1,'CurrentAxes',handles.axes3)
leg=[0; 1; 2];
imagesc(leg);
set(gca,'YTick',[1,2,3])
set(gca,'YAxisLocation','right')
set(gca,'YTickLabel',{'Unused','Train','Test'});
set(gca,'XTickLabel',{})

% Update handles structure
guidata(hObject, handles);
