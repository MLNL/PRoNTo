function varargout = prt_ui_disp_weights(varargin)
% PRT_UI_DISP_WEIGHTS MATLAB code for prt_ui_disp_weights.fig
%
% PRT_UI_DISP_WEIGHTS, by itself, creates a new PRT_UI_DISP_WEIGHTS or raises the
% existing singleton*.
%
% H = PRT_UI_DISP_WEIGHTS returns the handle to a new PRT_UI_DISP_WEIGHTS or the
% handle to the existing singleton*.
%
% PRT_UI_DISP_WEIGHTS('CALLBACK',hObject,eventData,handles,...) calls the local
% function named CALLBACK in PRT_UI_DISP_WEIGHTS.M with the given input arguments.
%
% PRT_UI_DISP_WEIGHTS('Property','Value',...) creates a new PRT_UI_DISP_WEIGHTS or
% raises the existing singleton*.  Starting from the left, property value
% pairs are applied to the GUI before prt_ui_disp_weights_OpeningFcn gets called.
% An unrecognized property name or invalid value makes property application
% stop.  All inputs are passed to prt_ui_disp_weights_OpeningFcn via varargin.
%
% *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
% instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by M. J. Rosa and J. Schrouff
% $Id: prt_ui_disp_weights.m 784 2013-08-22 16:43:32Z monteiro $

% Edit the above text to modify the response to help prt_ui_disp_weights

% Last Modified by GUIDE v2.5 09-Apr-2014 16:47:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @prt_ui_disp_weights_OpeningFcn, ...
    'gui_OutputFcn',  @prt_ui_disp_weights_OutputFcn, ...
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


% --- Executes just before prt_ui_disp_weights is made visible.
function prt_ui_disp_weights_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_ui_disp_weights (see VARARGIN)

%if window already exists, just put it as the current figure
Tag='Results';
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
    set(handles.figure1,'Name','PRoNTo :: Model interpretation')
    set(handles.figure1,'MenuBar','figure','WindowStyle','normal');
    
    %set size of the window, taking screen resolution and platform into account
    %--------------------------------------------------------------------------
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
    set(handles.figure1,'Position',ratio.*x)
    set(handles.figure1,'Resize','on')
    
    
    color=prt_get_defaults('color');
    set(handles.figure1,'Color',color.bg1)
    aa=get(handles.figure1,'children');
    for i=1:length(aa)
        if strcmpi(get(aa(i),'type'),'uipanel')
            set(aa(i),'BackgroundColor',color.bg2)
            bb=get(aa(i),'children');
            if ~isempty(bb)
                for j=1:length(bb)
                    if strcmpi(get(bb(j),'type'),'uipanel')
                        cc=get(bb(j),'children');
                        set(bb(j),'BackgroundColor',color.bg2)
                        for k=1:length(cc)
                            if strcmpi(get(cc(k),'type'),'uipanel')
                                dd=get(cc(k),'children');
                                set(cc(k),'BackgroundColor',color.bg2)
                                for l=1:length(dd)
                                    if strcmpi(get(dd(l),'type'),'uicontrol')
                                        if ~isempty(find(strcmpi(get(dd(l),'Style'),{'text',...
                                                'radiobutton','checkbox'})))
                                            set(dd(l),'BackgroundColor',color.bg2)
                                        elseif ~isempty(find(strcmpi(get(dd(l),'Style'),'pushbutton')))
                                            set(dd(l),'BackgroundColor',color.fr)
                                        end
                                    end
                                    set(dd(l),'FontUnits','pixel')
                                    xf=get(dd(l),'FontSize');
                                    if ispc
                                        set(dd(l),'FontSize',ceil(FS*xf),'FontName',PF,...
                                            'FontUnits','normalized','Units','normalized')
                                    else
                                        set(dd(l),'FontSize',ceil(FS*xf),'FontName',PF,...
                                            'Units','normalized')
                                    end
                                end
                            elseif strcmpi(get(cc(k),'type'),'uicontrol') && ...
                                    ~isempty(find(strcmpi(get(cc(k),'Style'),{'text',...
                                    'radiobutton','checkbox'})))
                                set(cc(k),'BackgroundColor',color.bg2)
                            elseif strcmpi(get(cc(k),'type'),'uicontrol')&& ...
                                    ~isempty(find(strcmpi(get(cc(k),'Style'),'pushbutton')))
                                set(cc(k),'BackgroundColor',color.fr)
                            end
                            set(cc(k),'FontUnits','pixel')
                            xf=get(cc(k),'FontSize');
                            set(cc(k),'FontSize',ceil(FS*xf),'FontName',PF,...
                                'Units','normalized')
                        end
                    elseif strcmpi(get(bb(j),'type'),'uicontrol') && ...
                            ~isempty(find(strcmpi(get(bb(j),'Style'),{'text',...
                            'radiobutton','checkbox'})))
                        set(bb(j),'BackgroundColor',color.bg2)
                    elseif strcmpi(get(bb(j),'type'),'uicontrol') && ...
                            ~isempty(find(strcmpi(get(bb(j),'Style'),'pushbutton')))
                        set(bb(j),'BackgroundColor',color.fr)
                    end
                    set(bb(j),'FontUnits','pixel')
                    xf=get(bb(j),'FontSize');
                    set(bb(j),'FontSize',ceil(FS*xf),'FontName',PF,...
                        'Units','normalized')
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
        if ~strcmpi(get(aa(i),'type'),'uimenu')
            set(aa(i),'FontUnits','pixel')
            xf=get(aa(i),'FontSize');
            set(aa(i),'FontSize',ceil(FS*xf),'FontName',PF,...
                'Units','normalized')
        end
    end
    
    
    % Initialize window
    % -------------------------------------------------------------------------
    
    if ~isfield(handles,'notinit')
        
        % Load PRT.mat
        PRT     = spm_select(1,'mat','Select PRT.mat',[],pwd,'PRT.mat');
        if isempty(PRT)
            error('prt_ui_disp_weights:NoPRT','No PRT file selected')        
        end

        pathdir = regexprep(PRT,'PRT.mat', '');
        handles.pathdir = pathdir;
        handles.prtdir=fileparts(PRT);
        load(PRT);
        
        % Save PRT
        handles.PRT = PRT;
        
        % Flag to load new weights
        handles.noloadw = 0;
        
        % Load model names
        if ~isfield(PRT,'model')
            error('No models found in PRT.mat!')
        end
        
        
        nmodels = length(PRT.model);
        mi  = [];
        nmi = 0;
        nmroi = 0;
        for m = 1:nmodels
            if isfield(PRT.model(m),'input') && ~isempty(PRT.model(m).input)
                if isfield(PRT.model(m),'output') && ~isempty(PRT.model(m).output)
                    if isfield(PRT.model(m).output,'weight_img') && ~isempty(PRT.model(m).output.weight_img)
                        nmi = nmi +1;
                        model_name{nmi} = PRT.model(m).model_name;
                        mi = [mi, m];
                        if isfield(PRT.model(m).output,'weight_ROI') && ...
                                ~isempty(PRT.model(m).output.weight_ROI)
                            nmroi = nmroi+1;
                        end
                    else
                        disp(sprintf('Weights not computed for model %s ! It will not be displayed',PRT.model(m).model_name));
                    end
                else
                    beep;
                    disp(sprintf('Weights not computed for model %s ! It will not be displayed',PRT.model(m).model_name));
                end
            else
                beep;
                disp(sprintf('Model %s not properly specified! It will not be displayed',PRT.model(m).model_name));
            end
            
        end
        %         if ~nmi, error('There are no estimated/good models in this
        %         PRT!'); end
        
        if nmi
            handles.mi = mi;
            
            % Set model pulldown menu
            handles.mnames = model_name;
            set(handles.classmenu,'String',handles.mnames);
            
            % Get folds pulldown menu
            m             = get(handles.classmenu,'Value');
            handles.nfold = length(PRT.model(mi(m)).output.fold);
            folds{1}      = 'All folds / Average';
            for f = 1:handles.nfold
                folds{f+1} = num2str(f);
            end
            handles.folds = folds;
            set(handles.foldmenu,'String',handles.folds);
            set(handles.foldmenu,'Value',1);
            
        end
        % Initialize model button
        handles.model_button = 0;
        
        % Deal with ROI table and bar graph: 1st turned off        
        set(handles.axes1, 'visible','off')
        set(handles.ROItable,'visible','off')
        handles.selectedcell = [];
        handles.labels=cell(nmodels,1);
        set(handles.butt_load_labels,'visible','off');
        % Clear axes
        cla(handles.axes1);
    end
end

% Choose default command line output for prt_ui_disp_weights
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes prt_ui_disp_weights wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prt_ui_disp_weights_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in originbutton.
function originbutton_Callback(hObject, eventdata, handles)
% hObject    handle to originbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Reset the crosshairs position
% -------------------------------------------------------------------------
if isfield(handles,'img')
    spm_orthviews('Reposition',[0 0 0]);
end

function mmedit_Callback(hObject, eventdata, handles)
% hObject    handle to mmedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mmedit as text
%        str2double(get(hObject,'String')) returns contents of mmedit as a double

% Move crosshairs position in mm
% -------------------------------------------------------------------------
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

% Move crosshairs position in vx
% -------------------------------------------------------------------------
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


% --- Executes on button press in quitbutton.
function quitbutton_Callback(hObject, eventdata, handles)
% hObject    handle to quitbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Close and clear figure
% -------------------------------------------------------------------------
close(handles.figure1);


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


% --- Executes on button press in weightbutton.
function weightbutton_Callback(hObject, eventdata, handles)
% hObject    handle to weightbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('Loading weights...>>')
% Select results (.img) for weight map
% -------------------------------------------------------------------------
if ~isfield(handles,'wmap') || ~handles.noloadw
    wmap            = spm_select(1,'image','Select weight map.');
    % Remove number in file name
    if strcmp(wmap(end-1),',')
        wmap = wmap(1:end-2);
    end
    V               = spm_vol(wmap);
    handles.vols{1} = V;
    handles.wmap    = wmap;
    
end

spm_orthviews('Reset');
% Image dimensions
% -------------------------------------------------------------------------
fold          = get(handles.foldmenu,'Value')-1;
Vfolds        = handles.vols{1};
V             = Vfolds(1);
M             = V.mat;
DIM           = V.dim(1:3)';
xdim          = DIM(1); ydim  = DIM(2); zdim  = DIM(3);
if length(V.private.dat.dim) < 4
    fdim = 1;                       % Handle 3D images
else
    fdim = V.private.dat.dim(4);    % Handle 4D images
end
[xords,yords] = ndgrid(1:xdim,1:ydim);
xords         = xords(:)';  yords = yords(:)';
I             = 1:xdim*ydim;
zords_init    = ones(1,xdim*ydim);

if ~isempty(handles.selectedcell)
    matroi = NaN * ones(xdim,ydim,zdim);
    idroi = handles.idfeat_roi{handles.sort_roi(handles.selectedcell(1))};
    matroi(idroi) = 1;
    handles.roimatdisp = matroi;
else
    matroi = ones(xdim,ydim,zdim);
    handles.roimatdisp = matroi;
end

% Get image values above zero for each fold and all folds
% -------------------------------------------------------------------------
xyz_above = [];
z_above   = [];
if fold == 0,
    fold_coord = fdim*ones(1,xdim*ydim);
    V = Vfolds(fdim);
else
    fold_coord = fold*ones(1,xdim*ydim);
    V = Vfolds(fold);
end

for z = 1:zdim,
    zords = z*zords_init;
    xyz   = [xords(I); yords(I); zords(I); fold_coord];
    zvals = spm_get_data(V,xyz);
    if isfield(handles,'roimatdisp') && ~isempty(handles.roimatdisp)
        indmask = sub2ind([xdim,ydim,zdim],xords(I)', yords(I)', zords(I)');
        mroi = handles.roimatdisp(indmask);
        zvals = zvals.*mroi';
    end
    above = find(~isnan(zvals));
    if length(above)==length(zvals) %old version of weight computation
        above = find(zvals~=0);
    end
    if ~isempty(above)
        xyz_above = [xyz_above,xyz(:,above)];
        z_above   = [z_above,zvals(above)];
    end
end
XYZ   = xyz_above(1:3,:);
Z     = z_above;

%compute center of gravity to reposition crosshairs
xm = round(median(XYZ(1,:)));
ym = round(median(XYZ(2,:)));
zm = round(median(XYZ(3,:)));
% xmin = min(XYZ(1,:));
% xmax = max(XYZ(1,:));
% xfov =xmax-xmin;
% Set spm_orthviews properties
% -------------------------------------------------------------------------
rotate3d off
global st

handles.notinit = 1;
handles.img     = 1;

st.handles  = handles;
st.fig      = handles.figure1;
st.V        = V;
st.callback = 'prt_ui_results(''showpos'')';

% Display maps
% -------------------------------------------------------------------------
[BB vx] = spm_get_bbox(handles.wmap);
xax = BB(1,1):abs(vx(1)):BB(2,1);
yax = BB(1,2):abs(vx(2)):BB(2,2);
zax = BB(1,3):abs(vx(3)):BB(2,3);

h  = spm_orthviews('Image', handles.wmap,[0.0519 0.5304 0.4182 0.3951]);
handles.wimgh = h;
spm_orthviews('AddContext', h);
spm_orthviews('MaxBB');
spm_orthviews('AddBlobs', h, XYZ, Z, M);
cmap = get(gcf,'Colormap');
if size(cmap,1)~=128
    spm_figure('Colormap','jet');
end
spm_orthviews('Reposition',[sign(vx(1))*xax(xm),sign(vx(2))*yax(ym),sign(vx(3))*zax(zm)])
% spm_orthviews('Zoom',(xfov*abs(vx(1))))
spm_orthviews('Redraw');

if isfield(handles,'aimg')
    anatomicalbutton_Callback(hObject, eventdata, handles);
end

% Show positions
% -------------------------------------------------------------------------
prt_ui_results('showpos');

disp('Done');

% Reset flag to load weights
handles.noloadw = 1;

% Show file name
% -------------------------------------------------------------------------
set(handles.loadweight,'String',handles.wmap);
guidata(hObject, handles);

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

% Check if weight map and anatomical image exist and reset orthviews
% -------------------------------------------------------------------------
if ~isfield(handles,'wmap')
    spm_orthviews('Reset');
end
global st
st.fig = handles.figure1;
if ~isfield(handles,'aimg') || ~handles.noloadi
    img    = spm_select(1,'image','Select anatomical image.');
else
    img = handles.aimg;
end

% Show anatomical image
% -------------------------------------------------------------------------
rotate3d off
st.fig = handles.figure1;
handle = spm_orthviews('Image', img, [0.5595 0.5304 0.4182 0.3951]);
cmap   = get(gcf,'Colormap');
if size(cmap,1)~=128
    spm_figure('Colormap','gray')
end

handles.aimgh   = handle;
handles.aimg    = img;
handles.img     = 1;
handles.noloadi = 1;

% Show file name
% -------------------------------------------------------------------------
set(handles.loadanatomical,'String',handles.aimg);

guidata(hObject, handles);


% --- Executes on selection change in foldmenu.
function foldmenu_Callback(hObject, eventdata, handles)
% hObject    handle to foldmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns foldmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from foldmenu

% Change weight map
% -------------------------------------------------------------------------
if ~handles.model_button
    if isfield(handles,'vols')
        handles.noloadw = 1;
        handles.selectedcell = [];
        weightbutton_Callback(hObject, eventdata, handles);
    end
end

% Update table and bar graph
m  = get(handles.classmenu,'Value');
if m==0
    m=1;
end
mi = handles.mi;
ffi = get(handles.foldmenu,'Value')-1;
if ffi == -1 % for Mac issues with popup menus
    ffi = 0;
end
if ffi==0 % for average
    ffi=length(get(handles.foldmenu,'String'));
end
if isfield(handles.PRT.model(mi(m)).output,'weight_ROI') &&... % chosen model has ROI values
       ~isempty(handles.PRT.model(mi(m)).output.weight_ROI)
   dat = handles.dattable;
   weights = handles.PRT.model(mi(m)).output.weight_ROI(:,ffi)*100;
   dat(:,2) = num2cell(weights);
   dat(:,5) = num2cell(handles.hom_roi(:,ffi)*100);
   [vald,idwroi] = sort(weights,'descend');
   dat = dat(idwroi,:);
   set(handles.ROItable,'Data',dat);
   set(handles.ROItable,'visible','on');
   
   %Bar graph to show decrease in ROI weights
   set(handles.axes1,'visible','on')
   bar(handles.axes1,weights(idwroi));
   set(get(handles.axes1,'XLabel'),'FontWeight','demi')
   set(get(handles.axes1,'XLabel'),'String','ROI index')
   set(get(handles.axes1,'YLabel'),'String','ROI weight')
   set(get(handles.axes1,'YLabel'),'FontWeight','demi')    
end
guidata(hObject, handles);




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


% --- Executes on selection change in classmenu.
function classmenu_Callback(hObject, eventdata, handles)
% hObject    handle to classmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns classmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from classmenu

% Hints: contents = cellstr(get(hObject,'String')) returns classmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from classmenu

% Get folds
m  = get(handles.classmenu,'Value');
if m==0
    m=1;
end
mi = handles.mi;
handles.nfold = length(handles.PRT.model(mi(m)).output.fold);


folds{1}      = 'All folds / Average';
for f = 1:handles.nfold
    folds{f+1} = num2str(f);
end


% Set folds and call fold function to plot the weights for that model
handles.folds = folds;
set(handles.foldmenu,'String',handles.folds);

ffi = get(handles.foldmenu,'Value')-1;
if ffi == -1 % for Mac issues with popup menus
    ffi = 0;
end
if ffi==0 % for average
    ffi=length(get(handles.foldmenu,'String'));
end
if isfield(handles.PRT.model(mi(m)).output,'weight_ROI') &&... % chosen model has ROI values
       ~isempty(handles.PRT.model(mi(m)).output.weight_ROI)
   in = struct();
   in.fs_name = handles.PRT.model(mi(m)).input.fs(1).fs_name;
   fid = prt_init_fs(handles.PRT,in);
   if isfield(handles.PRT.fs(fid).modality(1),'num_ROI')
        num_roi = handles.PRT.fs(fid).modality(1).num_ROI;
        atl_name = handles.PRT.fs(fid).atlas_name;
   else
       num_roi = 1:length(handles.PRT.model(mi(m)).output.weight_ROI);
       atl_name = handles.PRT.model(mi(m)).output.weight_atlas ;
   end
   handles.num_roi = num_roi;
   % Get the labels if they are stored in a .mat along the atlas file
   [a,b]=fileparts(atl_name);
   try
       load(fullfile(a,[b,'.mat']))
       try
           handles.labels{mi(m)}=ROI_names;
       catch
           disp('No variable ROI_names found, generic names used')
       end
   catch
         disp('No file containing the names of the ROIs found, generic names used')
   end
   if ~isfield(handles,'labels') || isempty(handles.labels{mi(m)})
       label=cell(length(num_roi),1);
       for i=1:length(num_roi)
           label{i} = ['ROI_',num2str(num_roi(i))];
       end
   else
       if isfield(handles.PRT.fs(fid),'igood_kerns') && ...
               length(handles.PRT.fs(fid).igood_kerns)==length(num_roi)
            label = handles.labels{mi(m)}(handles.PRT.fs(fid).igood_kerns); %take 0 kernels out
            handles.num_roi = handles.PRT.fs(fid).igood_kerns;
       else
           label = handles.labels{mi(m)}(num_roi);
           handles.num_roi = num_roi;
       end
   end   
   dat(:,1) = label;
   weights = handles.PRT.model(mi(m)).output.weight_ROI(:,ffi)*100;
   dat(:,2) = num2cell(weights);   
   lc = {'ROI label','ROI weight (%)'};
   if ~isempty(strfind(handles.PRT.model(mi(m)).input.machine.function,'MKL')) && ...
           handles.PRT.fs(fid).multkernel && ...
           ~isempty(handles.PRT.fs(fid).atlas_name) %Multiple kernel learning on ROIs
       if isfield(handles.PRT.fs(fid).modality,'idfeat_img')&& ... % Get the indexes of each ROI in the image
               ~isempty(handles.PRT.fs(fid).modality.idfeat_img)
           lc = [lc,{'ROI size (vox)'}];
           for i=1:length(handles.PRT.fas)
               if strcmpi(handles.PRT.fs(fid).modality.mod_name,...
                       handles.PRT.fas(i).mod_name)
                   mid = i;
               end
           end
           idfeat = handles.PRT.fas(mid).idfeat_img;
           if isempty(handles.PRT.fs(fid).modality(1).idfeat_fas) % get the 2nd level masking
               idfeat_fas = 1:length(idfeat);
           else
               idfeat_fas = handles.PRT.fs(fid).modality(1).idfeat_fas;
           end
           handles.idfeat_roi = cell(length(handles.PRT.fs(fid).modality.idfeat_img),1);
           for i = 1:length(handles.PRT.fs(fid).modality.idfeat_img)
               dat(i,3) = {length(handles.PRT.fs(fid).modality.idfeat_img{i})};
               handles.idfeat_roi{i} = idfeat(idfeat_fas(handles.PRT.fs(fid).modality.idfeat_img{i}));
           end
       end
   else % Summarizing the weights
       if isfield(handles.PRT.model(mi(m)).output,'weight_idfeatroi') && ... % Get the indexes of each ROI in the image
               ~isempty(handles.PRT.model(mi(m)).output.weight_idfeatroi)
           lc = [lc,{'ROI size (vox)'}];
           handles.idfeat_roi = cell(length(handles.PRT.model(mi(m)).output.weight_idfeatroi),1);
           for i = 1:length(handles.PRT.model(mi(m)).output.weight_idfeatroi)
               dat(i,3) = {length(handles.PRT.model(mi(m)).output.weight_idfeatroi{i})};
               handles.idfeat_roi{i} = handles.PRT.model(mi(m)).output.weight_idfeatroi{i};
           end
       end
   end
   % Compute Expected Ranking for model
   w_all = handles.PRT.model(mi(m)).output.weight_ROI(:,1:handles.nfold)*100;
   [d1,d2]=sort(w_all,1,'descend');
   isn=find(isnan(w_all(:,1)));
   d3=1:length(isn);
   d4=length(isn)+1:size(d1,1);
   ihn=[d2(d4,:);d2(d3,:)];
   [d1,dwn]=sort(ihn);
   erwn=zeros(length(num_roi),1);
   for i=1:length(num_roi)
       for j=1:length(num_roi)
           tmp=length(find(dwn(i,1:end-1)==j));
           erwn(i)=erwn(i)+j*tmp;
       end
   end
   erwn=erwn/handles.nfold;
   dat(:,4) = num2cell(erwn); 
   lc = [lc,{'Exp. Ranking'}];
   handles.dattable = dat;
   [vald,idwroi] = sort(weights,'descend');
   handles.sort_roi= idwroi;
else
    % Cut window
    
end

if exist([handles.prtdir,filesep,handles.PRT.model(mi(m)).output.weight_img,'.img'],'file') || ...
        exist([handles.prtdir,filesep,handles.PRT.model(mi(m)).output.weight_img],'file')
    [a,b] = fileparts(handles.PRT.model(mi(m)).output.weight_img);
    handles.wmap = [handles.prtdir,filesep,b,'.img'];
    V               = spm_vol(handles.wmap);
    handles.vols{1} = V;
    handles.noloadw = 1;
    handles.model_button = 0;
    handles.selectedcell = [];
    % Update handles structure
    guidata(hObject, handles);
    weightbutton_Callback(hObject, eventdata, handles);
end

if isfield(handles.PRT.model(mi(m)).output,'weight_ROI') &&... % chosen model has ROI values
       ~isempty(handles.PRT.model(mi(m)).output.weight_ROI) &&...
        isfield(handles,'wmap') && ~isempty(handles.wmap)
    
    % Get homogeneity of each ROI in terms of sign from the image
    dat = handles.dattable;
    [vald,idwroi] = sort([dat{:,2}],'descend');
    hom = zeros(length(vald),handles.nfold+1);
    for f = 1:handles.nfold+1
        imtl = V(f);
        vv = spm_read_vols(imtl);
        for i = 1:length(vald) %for each ROI
            val = vv(handles.idfeat_roi{i});
            hom(i,f) = length(find(val>0))/length(val);
        end
    end
   handles.hom_roi = hom;
   dat(:,5) = num2cell(hom(:,end)*100);
   lc = [lc,{'# Pos. (%)'}];
   handles.dattable = dat;
   
   set(handles.butt_load_labels,'visible','on');
   dat = dat(handles.sort_roi,:);
   set(handles.ROItable,'Data',dat);
   set(handles.ROItable,'ColumnEditable',false(1,length(lc)));
   set(handles.ROItable,'ColumnName',lc);
   set(handles.ROItable,'visible','on');
   
   %Bar graph to show decrease in ROI weights
   set(handles.axes1,'visible','on')
   bar(handles.axes1,weights(idwroi));
   set(get(handles.axes1,'XLabel'),'FontWeight','demi')
   set(get(handles.axes1,'XLabel'),'String','ROI index')
   set(get(handles.axes1,'YLabel'),'String','ROI weight')
   set(get(handles.axes1,'YLabel'),'FontWeight','demi')
else
    cla(handles.axes1, 'reset');
    set(handles.ROItable,'visible','off');
    set(handles.axes1,'visible','off');
    set(handles.butt_load_labels,'visible','off');
end

handles.model_button = 0;
guidata(hObject, handles);


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


function repedit_Callback(hObject, eventdata, handles)
% hObject    handle to repedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of repedit as text
%        str2double(get(hObject,'String')) returns contents of repedit as a double


% --- Executes during object creation, after setting all properties.
function repedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to repedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% Show crosshairs position
% -------------------------------------------------------------------------
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


% --- Executes on button press in resetbutton.
function resetbutton_Callback(hObject, eventdata, handles)
% hObject    handle to resetbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spm_orthviews('Reset');
if isfield(handles, 'wmap'), handles = rmfield(handles, 'wmap'); end
if isfield(handles, 'aimg'), handles = rmfield(handles,'aimg'); end
handles.noloadw = 0;
guidata(hObject, handles);

% Save menu
% -------------------------------------------------------------------------
function savemenu_Callback(hObject, eventdata, handles)
% hObject    handle to savemenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wd=cd;
cd(handles.prtdir)
[filename, pathname] = uiputfile( ...
    {'*.png','Portable Network Graphics (*.png)';...
    '*.jpeg','JPEG figure (*.jpeg)';...
    '*.tiff','Compressed TIFF figure (*.tiff)';...
    '*.fig','Matlab figure (*.fig)';...
    '*.pdf','Color PDF file (*.pdf)';...
    '*.epsc',  'Encapsulated PostScript (*.eps)'},...
    'Save figure as','.png');
[a,b,c]=fileparts(filename);
ext=['-d',c(2:end)];

% Set the color of the different backgrounds and figure parameters to white
cf=get(handles.figure1,'Color');
set(handles.figure1,'Color',[1,1,1])
aa=get(handles.figure1,'children');
xc=[];
for i=1:length(aa)
    if strcmpi(get(aa(i),'type'),'uipanel')
        try
            xc=[xc;get(aa(i),'BackgroundColor')];
            set(aa(i),'BackgroundColor',[1 1 1])
        end
        bb=get(aa(i),'children');
        if ~isempty(bb)
            for j=1:length(bb)
                try
                    xc=[xc;get(bb(j),'BackgroundColor')];
                    set(bb(j),'BackgroundColor',[1 1 1])
                end
                if strcmpi(get(bb(j),'type'),'uipanel')
                    cc=get(bb(j),'children');
                    if ~isempty(cc)
                        for k=1:length(cc)
                            try
                                xc=[xc;get(cc(k),'BackgroundColor')];
                                set(cc(k),'BackgroundColor',[1 1 1])
                            end
                            if strcmpi(get(cc(k),'type'),'uipanel')
                                dd=get(cc(k),'children');
                                if ~isempty(dd)
                                    for l=1:length(dd)
                                        try
                                            xc=[xc;get(dd(l),'BackgroundColor')];
                                            set(dd(l),'BackgroundColor',[1 1 1])
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if ~strcmpi(get(aa(i),'type'),'uimenu')
        try
            xc=[xc;get(aa(i),'BackgroundColor')];
            set(aa(i),'BackgroundColor',[1 1 1])
        end
    end
end

print(handles.figure1,ext,[pathname,filesep,b],'-r500')

% Set the color of the different backgrounds and figure parameters to white
set(handles.figure1,'Color',cf)
scount=1;
for i=1:length(aa)
    if strcmpi(get(aa(i),'type'),'uipanel')
        try
            set(aa(i),'BackgroundColor',xc(scount,:))
            scount=scount+1;
        end
        bb=get(aa(i),'children');
        if ~isempty(bb)
            for j=1:length(bb)
                try
                    set(bb(j),'BackgroundColor',xc(scount,:))
                    scount=scount+1;
                end
                if strcmpi(get(bb(j),'type'),'uipanel')
                    cc=get(bb(j),'children');
                    if ~isempty(cc)
                        for k=1:length(cc)
                            try
                                set(cc(k),'BackgroundColor',xc(scount,:))
                                scount=scount+1;
                            end
                            if strcmpi(get(cc(k),'type'),'uipanel')
                                dd=get(cc(k),'children');
                                if ~isempty(dd)
                                    for l=1:length(dd)
                                        try
                                            set(dd(l),'BackgroundColor',xc(scount,:))
                                            scount=scount+1;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    elseif ~strcmpi(get(aa(i),'type'),'uimenu')
        try
            set(aa(i),'BackgroundColor',xc(scount,:))
            scount=scount+1;
        end
    end
end

cd(wd)

% --- Executes on selection change in table if it is a ROI label.
function disp_weights_CellSelectionCallback(hObject,eventdata,handles)
% hObject    handle to foldmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.selectedcell=eventdata.Indices;
if ~isempty(handles.selectedcell) && handles.selectedcell(2)==1 % ROI label selected
    weightbutton_Callback(hObject, eventdata, handles);
else
    handles.selectedcell = [];
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in foldmenu.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to foldmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns foldmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from foldmenu


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to foldmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in butt_load_labels.
function butt_load_labels_Callback(hObject, eventdata, handles)
% hObject    handle to butt_load_labels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mi = handles.mi;
m = get(handles.classmenu,'Value');
if m==0 % Mac weird error with popup menus
    m=1;
end
fname=spm_select(1,'.mat','Select the file containing the names of the ROIs');
if isempty(fname)
    disp('No file containing the names of the ROIs found, generic names used')
    handles.labels{mi(m)}=[];
else
    load(fname)
    try
        handles.labels{mi(m)}=ROI_names;
    catch
        disp('No variable ROI_names found, generic names used')
    end
end
try
    label = handles.labels{mi(m)}(handles.num_roi);
catch
    label=[];
    disp('Number of labels is not consistent with atlas')
end
if ~isempty(handles.labels{mi(m)}) && ~isempty(label)
    dat = handles.dattable;
    dat(:,1) = label;
    dat = dat(handles.sort_roi,:);
    set(handles.ROItable,'Data',dat);
    set(handles.ROItable,'visible','on');
    guidata(hObject, handles);
end



