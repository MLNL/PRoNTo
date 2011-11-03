function varargout = prt_ui_results(varargin)
% PRT_UI_RESULTS MATLAB code for prt_ui_results.fig
%      PRT_UI_RESULTS, by itself, creates a new PRT_UI_RESULTS or raises the existing
%      singleton*.
%
%      H = PRT_UI_RESULTS returns the handle to a new PRT_UI_RESULTS or the handle to
%      the existing singleton*.
%
%      PRT_UI_RESULTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PRT_UI_RESULTS.M with the given input arguments.
%
%      PRT_UI_RESULTS('Property','Value',...) creates a new PRT_UI_RESULTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before prt_ui_results_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to prt_ui_results_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help prt_ui_results

% Last Modified by GUIDE v2.5 02-Nov-2011 16:22:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prt_ui_results_OpeningFcn, ...
                   'gui_OutputFcn',  @prt_ui_results_OutputFcn, ...
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


% --- Executes just before prt_ui_results is made visible.
function prt_ui_results_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_ui_results (see VARARGIN)

% Figure color
% -------------------------------------------------------------------------
set(handles.figure1,'Color',[0.86,0.86,0.86])

% Initialize window
% -------------------------------------------------------------------------
if ~isfield(handles,'notinit')
    % Load PRT.mat
    PRT   = spm_select(1,'mat','Select PRT.mat');
    load(PRT);
    handles.PRT = PRT;
    % Load models
    nmodels = length(PRT.model);
    for m = 1:nmodels
        model_name{m} = PRT.model(m).model_name;
    end
    % Set model pulldown menu
    handles.mnames = model_name;
    set(handles.classmenu,'String',handles.mnames);
    % Get folds
    nfold         = length(PRT.model(1).output.fold);
    handles.nfold = nfold;
    folds{1}      = 'All folds / Average';
    for f = 1:nfold
        folds{f+1} = num2str(f);
    end
    % Set folds pulldown menu for first model
    handles.folds = folds;
    set(handles.foldmenu,'String',handles.folds);    
    % Clear axes
    cla(handles.axes5);     
end

% Choose default command line output for prt_ui_results
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes prt_ui_results wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prt_ui_results_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in weightbutton.
function weightbutton_Callback(hObject, eventdata, handles)
% hObject    handle to weightbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Select results (.img) for weight map
% -------------------------------------------------------------------------
if ~isfield(handles,'wmap')
    wmap = spm_select(1,'image','Select weight map.');
    V    = spm_vol(wmap);
    handles.vols{1} = V;
    handles.wmap    = wmap;
    if ~(isfield(handles,'wmap') && isfield(handles,'aimg'))
        spm_orthviews('Reset');
    end
end

% Image dimensions
% -------------------------------------------------------------------------
V             = handles.vols{1};
M             = V.mat;
DIM           = V.dim(1:3)'; 
xdim          = DIM(1); ydim  = DIM(2); zdim  = DIM(3);
fdim          = V.private.dat.dim(4);
[xords,yords] = ndgrid(1:xdim,1:ydim);
xords         = xords(:)';  yords = yords(:)';
I             = 1:xdim*ydim;
zords_init    = ones(1,xdim*ydim);
fold          = get(handles.foldmenu,'Value')-1;
fold_coord    = fold*ones(1,xdim*ydim);

% Get image values above zero for each fold and all folds
% -------------------------------------------------------------------------
xyz_above     = [];
if fold == 0,
    z_fold    = [];
    for f = 1:fdim
        z_above   = [];
        for z = 1:zdim,
            zords = z*zords_init;
            xyz   = [xords(I); yords(I); zords(I); f*ones(1,xdim*ydim)];
            zvals = spm_get_data(V,xyz);
            above = find(zvals~=0);
            if ~isempty(above)
                if f == 1
                    xyz_above = [xyz_above,xyz(:,above)];
                end
                z_above = [z_above,zvals(above)];
            end
        end
        z_fold = [z_fold; z_above];
    end
    XYZ = xyz_above(1:3,:);
    Z   = mean(z_fold);
else
    z_above = [];
    for z = 1:zdim,
        zords = z*zords_init;
        xyz   = [xords(I); yords(I); zords(I); fold_coord];
        zvals = spm_get_data(V,xyz);
        above = find(zvals~=0);
        if ~isempty(above)
            xyz_above = [xyz_above,xyz(:,above)];
            z_above   = [z_above,zvals(above)];
        end
    end
    XYZ   = xyz_above(1:3,:);
    Z     = z_above;
end

% Set spm_orthviews properties
% -------------------------------------------------------------------------
global st

handles.notinit = 1;
handles.img     = 1;

st.handles  = handles;
st.fig      = handles.figure1;
st.V        = V;
st.callback = 'prt_ui_results(''showpos'')';

% Display maps
% -------------------------------------------------------------------------
p1 = handles.p(1)-63.7713;
p2 = handles.p(2)-2.0014;
h  = spm_orthviews('Image', handles.wmap,[p1 p2 0.42 0.43]);
spm_orthviews('AddContext', h);
spm_orthviews('MaxBB');
spm_orthviews('AddBlobs', h, XYZ, Z, M);
spm_orthviews('Redraw');

% Show positions
% -------------------------------------------------------------------------
prt_ui_results('showpos');

% Show file name
% -------------------------------------------------------------------------
set(handles.loadweight,'String',handles.wmap);

guidata(hObject, handles);


% --- Executes on selection change in classmenu.
function classmenu_Callback(hObject, eventdata, handles)
% hObject    handle to classmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns classmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from classmenu

foldmenu_Callback(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function classmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to classmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function loadweight_Callback(hObject, eventdata, handles)
% hObject    handle to loadweight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of loadweight as text
%        str2double(get(hObject,'String')) returns contents of loadweight as a double

% --- Executes during object creation, after setting all properties.
function loadweight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadweight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in helpbutton.
function helpbutton_Callback(hObject, eventdata, handles)
% hObject    handle to helpbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in plotmenu.
function plotmenu_Callback(hObject, eventdata, handles)
% hObject    handle to plotmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns plotmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plotmenu

% Read plot, model and fold
% -------------------------------------------------------------------------
plotchosen   = num2str(get(handles.plotmenu,'Value'));
fold         = get(handles.foldmenu,'Value');
m            = get(handles.classmenu,'Value');
PRT          = handles.PRT;
handles.plot = 1;
model        = get(handles.classmenu,'Value');

% All folds
% -------------------------------------------------------------------------
if fold == 1
    scores  = [];
    fVals   = [];
    targets = [];
    targpos = [];
    for f=1:handles.nfold
        targets = [targets;handles.PRT.model(model).output.fold(f).targets];
        scores  = [scores;...
            handles.PRT.model(model).output.fold(f).predictions];
        if isfield(handles.PRT.model(model).output.fold(f),'func_val')
            fVvals_exist = 1;
            fVals  = [fVals;handles.PRT.model(model).output.fold(f).func_val];
        else
            fVvals_exist = 0;
        end
    end
    targpos = targets == 2;
else
    % if folds wise
    targets = handles.PRT.model(model).output.fold(fold-1).targets;
    targpos = targets == 2;
    scores  = handles.PRT.model(model).output.fold(fold-1).predictions;
    if isfield(handles.PRT.model(model).output.fold(fold-1),'func_val')
        fVals  = handles.PRT.model(model).output.fold(fold-1).func_val;
        fVvals_exist = 1;
    else
        fVvals_exist = 0;
    end
end

% Plot
% -------------------------------------------------------------------------
switch plotchosen
    
    case '1'
        % predictions
        
    case '2'
        % ROC curve
                
        [y,idx] = sort(scores);
        targpos = targpos(idx);
        
        fp      = cumsum(single(targpos))/sum(single(targpos));
        tp      = cumsum(single(~targpos))/sum(single(~targpos));
        
        tp      = [0 ; tp ; 1];
        fp      = [0 ; fp ; 1];
        
        n       = size(tp, 1);
        A       = sum((fp(2:n) - fp(1:n-1)).*(tp(2:n)+tp(1:n-1)))/2;
        
        plot(handles.axes5,fp,tp,'--ks','LineWidth',2, 'MarkerEdgeColor','k',...
            'MarkerFaceColor','k',...
            'MarkerSize',4);
        title(handles.axes5,sprintf('Receiver Operator Curve / Area Under Curve = %d',A));
        xlabel(handles.axes5,'False positives')
        ylabel(handles.axes5,'True positives')
        
    case '3'
        % func_val distributions
        if fVvals_exist
            myColours={'r','g'};
            classNames{1}=handles.PRT.model(model).input.class(1).class_name;
            classNames{2}=handles.PRT.model(model).input.class(2).class_name;
            for c=1:2
                func_vals=fVals(targpos);
                if c == 2, func_vals=fVals(~targpos); end
                if exist('ksdensity','file')==2
                    width = 6;
                    [f,x] = ksdensity(func_vals,'width',width);
                    plot(handles.axes5,x,f,myColours{c});
                    hold on;
                else
                    % can't plot density, be happy with a histogram
                    [myHist,myX]=hist(func_vals,100);
                    bar(handles.axes5,myX,myHist,myColours{c});
                    hold on;
                end
                if c == 2, hold off; end
            end
            xlabel(handles.axes5,'function value');
            legend(handles.axes5,classNames{1},classNames{2});
        else
            % do nothing, no func_val available
        end
        
    case '4'
        % confusion matrix
        
        if fold == 1
            for f = 1:handles.nfold,
                conmat(:,:,f) = PRT.model(m).output.fold(f).stats.con_mat;
            end
            mconmat = mean(conmat,3);
        else
            mconmat(:,:) = PRT.model(m).output.fold(fold-1).stats.con_mat;
        end
        imagesc(mconmat,'Parent',handles.axes5);
        colorbar('peer',handles.axes5);
        colormap(handles.axes5,'Jet');
        title(handles.axes5,sprintf('Confusion matrix: fold %d',fold-1));
        xlabel(handles.axes5,'False positives')
        ylabel(handles.axes5,'True positives')
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function plotmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in quitbutton.
function quitbutton_Callback(hObject, eventdata, handles)
% hObject    handle to quitbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Close and clear figure
% -------------------------------------------------------------------------
close(handles.figure1);
clc;

% --- Executes on selection change in foldmenu.
function foldmenu_Callback(hObject, eventdata, handles)
% hObject    handle to foldmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns foldmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from foldmenu

% Reads model and fold
% -------------------------------------------------------------------------
fold  = get(handles.foldmenu,'Value');
m     = get(handles.classmenu,'Value');
PRT   = handles.PRT;

% Read stats
% -------------------------------------------------------------------------
if fold == 1
    for f = 1:handles.nfold
        acc(f)    = PRT.model(m).output.fold(f).stats.acc;
        bacc(f)   = PRT.model(m).output.fold(f).stats.b_acc;
        cacc(:,f) = PRT.model(m).output.fold(f).stats.c_acc;
    end
    macc  = mean(acc);
    mbacc = mean(bacc);
    mcacc = mean(cacc,2);
else
    macc  = PRT.model(m).output.fold(fold-1).stats.acc;
    mbacc = PRT.model(m).output.fold(fold-1).stats.b_acc;
    mcacc = PRT.model(m).output.fold(fold-1).stats.c_acc;
end

% Show stats
% -------------------------------------------------------------------------
set(handles.acctext,'String',sprintf('%.1f %%',macc));
set(handles.bacctext,'String',sprintf('%.1f %%',mbacc));
set(handles.cacctext,'String',sprintf('[%.1f %.1f] %%',mcacc(1),mcacc(2)));

% Change weight map
% -------------------------------------------------------------------------
if isfield(handles,'vols')
    weightbutton_Callback(hObject, eventdata, handles);
end

% Change plot
% -------------------------------------------------------------------------
if isfield(handles,'plot')
   plotmenu_Callback(hObject, eventdata, handles); 
end

% --- Executes during object creation, after setting all properties.
function foldmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to foldmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function loadanatomical_Callback(hObject, eventdata, handles)
% hObject    handle to loadanatomical (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of loadanatomical as text
%        str2double(get(hObject,'String')) returns contents of loadanatomical as a double


% --- Executes during object creation, after setting all properties.
function loadanatomical_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadanatomical (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in anatomicalbutton.
function anatomicalbutton_Callback(hObject, eventdata, handles)
% hObject    handle to anatomicalbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~(isfield(handles,'wmap') && isfield(handles,'wmap')) 
    spm_orthviews('Reset');
    global st
    st.fig      = handles.figure1;
end

img    = spm_select(1,'image','Select anatomical image.');
p1     = handles.p(1)-63.3033;
p2     = handles.p(2)-2.0014;
handle = spm_orthviews('Image', img,...
    [p1 p2 0.42 0.430]);

cmap = get(gcf,'Colormap');
if size(cmap,1)~=128
      spm_figure('Colormap','gray')
end;

handles.aimg = img;
handles.img  = 1;

set(handles.loadanatomical,'String',handles.aimg);

guidata(hObject, handles);

% --- Executes on button press in savebutton.
function savebutton_Callback(hObject, eventdata, handles)
% hObject    handle to savebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in originbutton.
function originbutton_Callback(hObject, eventdata, handles)
% hObject    handle to originbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'img')
    spm_orthviews('Reposition',[0 0 0]);
end

function mmedit_Callback(hObject, eventdata, handles)
% hObject    handle to mmedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mmedit as text
%        str2double(get(hObject,'String')) returns contents of mmedit as a double

if isfield(handles,'img')
    mp    = handles.mmedit;
    posmm = get(mp,'String');
    pos = sscanf(posmm, '%g %g %g');
    if length(pos)~=3
        pos = spm_orthviews('Pos');
    end
    spm_orthviews('Reposition',pos);
end

% --- Executes during object creation, after setting all properties.
function mmedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mmedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function vxedit_Callback(hObject, eventdata, handles)
% hObject    handle to vxedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vxedit as text
%        str2double(get(hObject,'String')) returns contents of vxedit as a double
if isfield(handles,'img')
    mp    = handles.vxedit;
    posvx = get(mp,'String');
    pos   = sscanf(posvx, '%g %g %g');
    if length(pos)~=3
        pos = spm_orthviews('pos',1);
    end
    tmp = handles.vols{1}.mat;
    pos = tmp(1:3,:)*[pos ; 1];
    spm_orthviews('Reposition',pos);
end

% --- Executes during object creation, after setting all properties.
function vxedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vxedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function showpos()
 
global st

mp13 = st.handles.mmedit;
mp14 = st.handles.vxedit;
tx20 = st.handles.posintensitytext;

set(mp13,'String',sprintf('%.1f %.1f %.1f',spm_orthviews('Pos')));
pos = spm_orthviews('Pos',1);
set(mp14,'String',sprintf('%.1f %.1f %.1f',pos));
set(tx20,'String',sprintf('%g',spm_sample_vol(st.V,pos(1),pos(2),pos(3),st.hld)));

cmap = get(gcf,'Colormap');
if size(cmap,1)~=128
      spm_figure('Colormap','gray-jet');
end


% --- Executes on button press in permutbutton.
function permutbutton_Callback(hObject, eventdata, handles)
% hObject    handle to permutbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
