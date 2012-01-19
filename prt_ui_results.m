function varargout = prt_ui_results(varargin)
% PRT_UI_RESULTS MATLAB code for prt_ui_results.fig
% 
% PRT_UI_RESULTS, by itself, creates a new PRT_UI_RESULTS or raises the 
% existing singleton*.
%
% H = PRT_UI_RESULTS returns the handle to a new PRT_UI_RESULTS or the 
% handle to the existing singleton*.
%
% PRT_UI_RESULTS('CALLBACK',hObject,eventData,handles,...) calls the local
% function named CALLBACK in PRT_UI_RESULTS.M with the given input 
% arguments.
%
% PRT_UI_RESULTS('Property','Value',...) creates a new PRT_UI_RESULTS or 
% raises the existing singleton*.  Starting from the left, property value 
% pairs are applied to the GUI before prt_ui_results_OpeningFcn gets 
% called.  An unrecognized property name or invalid value makes property 
% application stop.  All inputs are passed to prt_ui_results_OpeningFcn via varargin.
%
% *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
% instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Schrouff
% $Id$

% Edit the above text to modify the response to help prt_ui_results

% Last Modified by GUIDE v2.5 11-Nov-2011 11:21:16

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
set(handles.figure1,'Color',[0.86,0.86,0.86]);

% Initialize window
% -------------------------------------------------------------------------
if ~isfield(handles,'notinit')
    % Load PRT.mat
    PRT   = spm_select(1,'mat','Select PRT.mat');
    pathdir = regexprep(PRT,'PRT.mat', '');
    handles.pathdir = pathdir;
    load(PRT);
    handles.PRT = PRT;
    % Flag to load new weights
    handles.noloadw = 0;
    % Load models
    if ~isfield(PRT,'model')
        beep
        disp('No model found in this PRT')
        delete(handles.figure1)
        return
    end
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
    m             = get(handles.plotmenu,'Value');
    if strcmp(PRT.model(m).input.type,'classification');
        for f = 1:nfold
            folds{f+1} = num2str(f);
        end
    end
    % Set folds pulldown menu for first model
    handles.folds = folds;
    set(handles.foldmenu,'String',handles.folds);
    % Set plots menu
    if strcmp(PRT.model(m).input.type,'classification');
        plots = {'Predictions','ROC','Histogram','Confusion Matrix'};
       set(handles.plotmenu,'String',plots);
    else
        plots = {'Predictions (scatter)', 'Predictions (bar)'};
       set(handles.plotmenu,'String',plots); 
    end  
    % Set font sizes
    set(handles.text10,'Unit','point','FontSize',11);
    set(handles.classmenu,'Unit','point','FontSize',11);    
    set(handles.text6,'Unit','point','FontSize',11);
    set(handles.foldmenu,'Unit','point','FontSize',11);
    set(handles.text14,'Unit','point','FontSize',11);
    set(handles.plotmenu,'Unit','point','FontSize',11);
    set(handles.statspanel,'Unit','point','FontSize',11);
    set(handles.plotpanel,'Unit','point','FontSize',11);
    set(handles.modelpanel,'Unit','point','FontSize',11);
    set(handles.weightspanel,'Unit','point','FontSize',11);
    set(handles.anatomicalpanel,'Unit','point','FontSize',11);
    set(handles.permutbutton,'Unit','point','FontSize',11);
    set(handles.accuracytext,'Unit','point','FontSize',11,'Visible','off');
    set(handles.acctext,'Unit','point','FontSize',11,'Visible','off');
    set(handles.baccuracytext,'Unit','point','FontSize',11,'Visible','off');
    set(handles.bacctext,'Unit','point','FontSize',11,'Visible','off');
    set(handles.classaccuracytext,'Unit','point','FontSize',11,'Visible','off');
    set(handles.cacctext,'Unit','point','FontSize',11,'Visible','off');
    set(handles.savebutton,'Unit','point','FontSize',11);
    set(handles.helpbutton,'Unit','point','FontSize',11);
    set(handles.quitbutton,'Unit','point','FontSize',11);
    set(handles.corrtext,'Unit','point','FontSize',11,'Visible','off');
    set(handles.msetext,'Unit','point','FontSize',11,'Visible','off');
    set(handles.corrvaltext,'Unit','point','FontSize',11,'Visible','off');
    set(handles.msevaltext,'Unit','point','FontSize',11,'Visible','off');
    set(handles.pbacc,'Visible','off','FontSize',11);
    set(handles.pcacc,'Visible','off','FontSize',11);
    set(handles.pcorr, 'Visible','off','FontSize',11);
    set(handles.pmse,'Visible','off','FontSize',11);
    % Clear axes
    cla(handles.axes5);     
end

% Choose default command line output for prt_ui_results
handles.output = hObject;

Rect = spm('WinSize','Graphics'); %-Graphics window rectangle
S0   = spm('WinSize','0',1);
Rect(3) = Rect(3)*1.8;
set(handles.figure1,'Units','pixels');
set(handles.figure1,'Position',[S0(1) S0(2) 0 0] + Rect);
set(handles.figure1,'Resize','off');

% Reposition main window
set(handles.figure1,'Units','normalized');

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

disp('Loading weights...>>')
% Select results (.img) for weight map
% -------------------------------------------------------------------------
if ~isfield(handles,'wmap') || ~handles.noloadw
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

% Get image values above zero for each fold and all folds
% -------------------------------------------------------------------------
xyz_above = [];
z_above   = [];
if fold == 0,
    fold_coord = fdim*ones(1,xdim*ydim);
else
    fold_coord = fold*ones(1,xdim*ydim);
end
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
h  = spm_orthviews('Image', handles.wmap,[0.0619 0.0699 0.4196 0.4296]);
handles.wimgh = h;
spm_orthviews('AddContext', h);set(handles.figure1,'Units','normalized');
spm_orthviews('MaxBB');
spm_orthviews('AddBlobs', h, XYZ, Z, M);
cmap = get(gcf,'Colormap');
if size(cmap,1)~=128
      spm_figure('Colormap','jet');
end
spm_orthviews('Redraw');

% Show positions
% -------------------------------------------------------------------------
prt_ui_results('showpos');

disp('Done');

% Reset flag to load weights
handles.noloadw = 0;

% Show file name
% -------------------------------------------------------------------------
set(handles.loadweight,'String',handles.wmap);
set(handles.figure1,'Units','normalized');
guidata(hObject, handles);


% --- Executes on selection change in classmenu.
function classmenu_Callback(hObject, eventdata, handles)
% hObject    handle to classmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns classmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from classmenu
warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
list = get(handles.classmenu,'String');
% handle particular bug with matlab(7.10.0499) and mac (OSX 10.6.4)
if length(list) == 1, set(handles.classmenu,'Value',1); end
val = get(handles.classmenu,'Value');
if val==0, set(handles.classmenu,'Value',1); end

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

beep;
disp('Help not supported yet!')

% --- Executes on selection change in plotmenu.
function plotmenu_Callback(hObject, eventdata, handles)
% hObject    handle to plotmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns plotmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plotmenu

warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
list = get(handles.plotmenu,'String');
% handle particular bug with matlab(7.10.0499) and mac (OSX 10.6.4)
if length(list) == 1, set(handles.plotmenu,'Value',1); end
val = get(handles.plotmenu,'Value');
if val==0, set(handles.plotmenu,'Value',1); end

% Read plot, model and fold
% -------------------------------------------------------------------------
plotchosen    = num2str(get(handles.plotmenu,'Value'));
fold          = get(handles.foldmenu,'Value');
m             = get(handles.classmenu,'Value');
PRT           = handles.PRT;
handles.plot  = 1;
model         = get(handles.classmenu,'Value');
nms           = 7;
rotate3d off

if strcmp(PRT.model(m).input.type,'classification')
    
    % All folds
    % ---------------------------------------------------------------------
    classNames{1} = handles.PRT.model(model).input.class(1).class_name;
    classNames{2} = handles.PRT.model(model).input.class(2).class_name;
    myColours     = {'k','r'};
    
    if fold == 1
        fVals   = [];
        targets = [];
        for f=1:handles.nfold
            targets = [targets;handles.PRT.model(model).output.fold(f).targets];
            if isfield(handles.PRT.model(model).output.fold(f),'func_val')
                fVvals_exist = 1;
                fVals  = [fVals;handles.PRT.model(model).output.fold(f).func_val];
            else
                fVvals_exist = 0;
                fVals  = [fVals;...
                    handles.PRT.model(model).output.fold(f).predictions];
            end
        end
        targpos = targets == 1;
    else
        % if folds wise
        targets = handles.PRT.model(model).output.fold(fold-1).targets;
        targpos = targets == 1;
        if isfield(handles.PRT.model(model).output.fold(fold-1),'func_val')
            fVals  = handles.PRT.model(model).output.fold(fold-1).func_val;
            fVvals_exist = 1;
        else
            fVvals_exist = 0;
            fVals  = handles.PRT.model(model).output.fold(fold-1).predictions;
        end
    end
    
    % Plot
    % ---------------------------------------------------------------------
    switch plotchosen
        
        % Predictions
        % -----------------------------------------------------------------
        case '1'
            if strcmp(PRT.model(m).input.type,'classification');
                cla(handles.axes5);
                colorbar('peer',handles.axes5,'off')
                % predictions
                if fVvals_exist
                    if fold == 1
                        for f=2:handles.nfold+1
                            foldlabels{f} = num2str(f-1);
                            targets = handles.PRT.model(model).output.fold(f-1).targets;
                            targpos = targets == 2;
                            fVals   = handles.PRT.model(model).output.fold(f-1).func_val;
                            func_valsc1 = fVals(targpos);
                            func_valsc2 = fVals(~targpos);
                            yc1 = (f-1)*ones(length(func_valsc1),1);
                            yc2 = (f-1)*ones(length(func_valsc2),1);
                            if f==2
                                maxfv = max([func_valsc1;func_valsc2]);
                                minfv = min([func_valsc1;func_valsc2]);
                            end
                            plot(handles.axes5,func_valsc1,yc1,'kx','MarkerSize',nms)
                            hold(handles.axes5,'on');
                            plot(handles.axes5,func_valsc2,yc2,'ro','MarkerSize',nms)
                        end
                    else
                        foldlabels{1} = num2str(fold-1);
                        targets = handles.PRT.model(model).output.fold(fold-1).targets;
                        targpos = targets == 2;
                        fVals   = handles.PRT.model(model).output.fold(fold-1).func_val;
                        func_valsc1 = fVals(targpos);
                        func_valsc2 = fVals(~targpos);
                        yc1 = (fold-1)*ones(length(func_valsc1),1);
                        yc2 = (fold-1)*ones(length(func_valsc2),1);
                        maxfv = max([func_valsc1;func_valsc2]);
                        minfv = min([func_valsc1;func_valsc2]);
                        plot(handles.axes5,func_valsc1,yc1,'kx','MarkerSize',nms)
                        hold(handles.axes5,'on');
                        plot(handles.axes5,func_valsc2,yc2,'ro','MarkerSize',nms)
                    end
                    % Change the x axis for gaussian process - change in
                    % the future
                    y = [0:handles.nfold+1]';
                    if strcmp(PRT.model(m).input.machine.function,'prt_machine_gpml');
                        x = 0.5*ones(handles.nfold+2,1);
                        plot(handles.axes5,x,y,'--','Color',[1 1 1]*.6);
                        xlim(handles.axes5,[0 1]);
                    else
                        x = zeros(handles.nfold+2,1);
                        plot(handles.axes5,x,y,'--','Color',[1 1 1]*.6);
                        mlim = max([abs(maxfv), abs(minfv)]);
                        xlim(handles.axes5,[-mlim-0.5 mlim+0.5]);
                    end
                    ylim(handles.axes5,[0 handles.nfold+1.3]);
                    xlabel(handles.axes5,'function value','FontWeight','bold');
                    ylabel(handles.axes5,'fold','FontWeight','bold');
                    legend(handles.axes5,classNames{1},classNames{2});
                    set(handles.axes5,'YTick',0:handles.nfold)
                    hold(handles.axes5,'off');
                else
                    % do nothing, no func_val available
                end
            end
            
            % ROC / AUC
            % -------------------------------------------------------------
        case '2'
            % ROC curve
            if strcmp(PRT.model(m).input.type,'classification');
                cla(handles.axes5);
                [y,idx] = sort(fVals);
                targpos = targpos(idx);
                
                fp      = cumsum(single(targpos))/sum(single(targpos));
                tp      = cumsum(single(~targpos))/sum(single(~targpos));
                
                tp      = [0 ; tp ; 1];
                fp      = [0 ; fp ; 1];
                
                n       = size(tp, 1);
                A       = sum((fp(2:n) - fp(1:n-1)).*(tp(2:n)+tp(1:n-1)))/2;
                
                plot(handles.axes5,fp,tp,'--ks','LineWidth',1, 'MarkerEdgeColor','k',...
                    'MarkerFaceColor','k',...
                    'MarkerSize',2);
                title(handles.axes5,sprintf('Receiver Operator Curve / Area Under Curve = %3.1f',A));
                xlabel(handles.axes5,'False positives','FontWeight','bold')
                ylabel(handles.axes5,'True positives','FontWeight','bold')
            end
            
            % Histograms
            % -------------------------------------------------------------
        case '3'
            if strcmp(PRT.model(m).input.type,'classification');
                cla(handles.axes5);
                % func_val distributions
                if fVvals_exist
                    for cl=1:2
                        func_vals=fVals(targpos);
                        if cl == 2, func_vals=fVals(~targpos); end
                        if exist('ksdensity','file')==2
                            [f,x] = ksdensity(func_vals,'width',[]);
                            plot(handles.axes5,x,f,myColours{cl},'LineWidth',2);
                            hold(handles.axes5,'on')
                        else
                            % can't plot density, be happy with a histogram
                            [myHist,myX]=hist(func_vals,100);
                            bar(handles.axes5,myX,myHist,myColours{cl});
                            hold(handles.axes5,'on')
                        end
                        if cl == 2, hold(handles.axes5,'off'); end
                    end
                    xlabel(handles.axes5,'function value','FontWeight','bold');
                    legend(handles.axes5,classNames{1},classNames{2});
                else
                    % do nothing, no func_val available
                end
            end
            
            % Confusion matrix
            % -------------------------------------------------------------
        case '4'
            % confusion matrix
            if strcmp(PRT.model(m).input.type,'classification');
                cla(handles.axes5);
                if fold == 1
                    mconmat(:,:) = PRT.model(m).output.stats.con_mat;
                else
                    mconmat(:,:) = PRT.model(m).output.fold(fold-1).stats.con_mat;
                end
                bar3(handles.axes5,mconmat,'detached','w');
                rotate3d on
                if fold == 1
                    title(handles.axes5,sprintf('Confusion matrix: all folds'),'FontWeight','bold');
                else
                    title(handles.axes5,sprintf('Confusion matrix: fold %d',fold-1),'FontWeight','bold');
                end
                xlabel(handles.axes5,'False positives','FontWeight','bold');
                ylabel(handles.axes5,'True positives','FontWeight','bold');
                set(handles.axes5,'XTick',[1 2]);
                set(handles.axes5,'XTickLabel',{'1','2'});
                set(handles.axes5,'YTick',[1 2]);
                set(handles.axes5,'YTickLabel',{'1','2'});
                grid(handles.axes5,'on');
                set(handles.axes5,'Color',[0.8 0.8 0.8]);
            end
    end
    
else
    nfolds = length(PRT.model(m).output.fold);
    switch plotchosen
        case '1'
            cla(handles.axes5);
            preds = zeros(nfolds,2);
            for f = 1:nfolds
                preds(f,1) = PRT.model(m).output.fold(f).targets;
                preds(f,2) = PRT.model(m).output.fold(f).predictions;
                scatter(handles.axes5,preds(:,2),preds(:,1),'filled');
                xlabel(handles.axes5,'predictions','FontWeight','bold');
                ylabel(handles.axes5,'targets','FontWeight','bold');
            end
        case '2'
            cla(handles.axes5);
            preds = zeros(nfolds,2);
            for f = 1:nfolds
                preds(f,1) = PRT.model(m).output.fold(f).targets;
                preds(f,2) = PRT.model(m).output.fold(f).predictions;
                bar(handles.axes5,preds);
                xlabel(handles.axes5,'subjects','FontWeight','bold');
                ylabel(handles.axes5,'targets and predictions','FontWeight','bold');
            end
            legend(handles.axes5,{'Target', 'Predicted'});
    end
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

% --- Executes on selection change in foldmenu.
function foldmenu_Callback(hObject, eventdata, handles)
% hObject    handle to foldmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns foldmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from foldmenu

warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
list = get(handles.foldmenu,'String');
% handle particular bug with matlab(7.10.0499) and mac (OSX 10.6.4)
if length(list) == 1, set(handles.foldmenu,'Value',1); end
val = get(handles.foldmenu,'Value');
if val==0, set(handles.foldmenu,'Value',1); end

% Reads model and fold
% -------------------------------------------------------------------------
fold  = get(handles.foldmenu,'Value');
m     = get(handles.classmenu,'Value');
PRT   = handles.PRT;

% Read stats
% -------------------------------------------------------------------------
if strcmp(PRT.model(m).input.type,'classification')
    if fold == 1
        macc  = PRT.model(m).output.stats.acc;  % overall acc
        if ~strcmp(PRT.model(m).input.cv_type,'lobo')
            macc_lb  = PRT.model(m).output.stats.acc_lb; % lower bound
            macc_ub  = PRT.model(m).output.stats.acc_ub; % upper bound
        end
        mbacc = PRT.model(m).output.stats.b_acc;
        mcacc = PRT.model(m).output.stats.c_acc;
    else
        macc  = PRT.model(m).output.fold(fold-1).stats.acc;
        if ~strcmp(PRT.model(m).input.cv_type,'lobo')
            macc_lb  = PRT.model(m).output.fold(fold-1).stats.acc_lb;
            macc_ub  = PRT.model(m).output.fold(fold-1).stats.acc_ub;
        end
        mbacc = PRT.model(m).output.fold(fold-1).stats.b_acc;
        mcacc = PRT.model(m).output.fold(fold-1).stats.c_acc;
    end
    % Show stats
    % ---------------------------------------------------------------------
    set(handles.accuracytext,'String','Accuracy (acc):','Visible','on');
    set(handles.baccuracytext,'String','Balanced acc:','Visible','on');
    set(handles.classaccuracytext,'String','Class acc:','Visible','on');
    
    if ~strcmp(PRT.model(m).input.cv_type,'lobo')
        set(handles.acctext,'String',sprintf('%3.1f %% (%3.1f %%, %3.1f%%)',...
            macc*100,macc_lb*100,macc_ub*100),'Visible','on');
    else
        set(handles.acctext,'String',sprintf('%3.1f %% (Not IID)',...
            macc*100),'Visible','on');
    end
    set(handles.bacctext,'String',sprintf('%3.1f %%',mbacc*100),'Visible','on');
    set(handles.cacctext,'String',sprintf('[%3.1f %3.1f] %%',...
        mcacc(1)*100,mcacc(2)*100),'Visible','on');
    set(handles.corrtext,'Visible','off');
    set(handles.msetext,'Visible','off');
    set(handles.corrvaltext,'Visible','off');
    set(handles.msevaltext,'Visible','off');
else
    if fold == 1
        corr  = PRT.model(m).output.stats.corr;  % overall correlation
        mse   = PRT.model(m).output.stats.mse;  % overall mse
    else
        corr  = PRT.model(m).output.fold(fold-1).stats.corr;  % overall correlation
        mse   = PRT.model(m).output.fold(fold-1).stats.mse;  % overall mse
    end
    set(handles.corrtext,'String','Correlation:','Visible','on');
    set(handles.msetext,'String','MSE:','Visible','on');
    set(handles.corrvaltext,'String',sprintf('%3.1f',corr),'Visible','on');
    set(handles.msevaltext,'String',sprintf('%3.1f',mse),'Visible','on');
    set(handles.accuracytext,'Visible','off');
    set(handles.baccuracytext,'Visible','off');
    set(handles.classaccuracytext,'Visible','off');
    set(handles.acctext,'Visible','off');
    set(handles.bacctext,'Visible','off');
    set(handles.cacctext,'Visible','off');
end
set(handles.pbacc,'Visible','off');
set(handles.pcacc,'Visible','off');
set(handles.pcorr, 'Visible','off');
set(handles.pmse,'Visible','off');


% Change weight map
% -------------------------------------------------------------------------
if isfield(handles,'vols')
    handles.noloadw = 1;
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

% Check if weight map and anatomical image exist and reset orthviews
% -------------------------------------------------------------------------
if ~(isfield(handles,'wmap') && isfield(handles,'wmap')) 
    spm_orthviews('Reset');
    global st
    st.fig = handles.figure1;
end

% Show anatomical image
% -------------------------------------------------------------------------
rotate3d off
img    = spm_select(1,'image','Select anatomical image.');
handle = spm_orthviews('Image', img, [0.5295 0.0699 0.4196 0.4296]);
cmap   = get(gcf,'Colormap');
if size(cmap,1)~=128
      spm_figure('Colormap','gray')
end

handles.aimgh = handle;
handles.aimg  = img;
handles.img   = 1;

% Show file name
% -------------------------------------------------------------------------
set(handles.loadanatomical,'String',handles.aimg);

guidata(hObject, handles);

% --- Executes on button press in savebutton.
function savebutton_Callback(hObject, eventdata, handles)
% hObject    handle to savebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

beep;
disp('Save option not supported yet!')

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


% --- Executes on button press in permutbutton.
function permutbutton_Callback(hObject, eventdata, handles)
% hObject    handle to permutbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.accuracytext,'Visible'),'on') || strcmp(get(handles.corrtext,'Visible'),'on')
    m    = get(handles.classmenu,'Value');
    reps = str2num(get(handles.repedit,'String'));
    if  ~isempty(reps)
        if length(reps) ==1
            reps = round(reps);
            disp('Performing permutation test.........>>')
            prt_permutation(handles.PRT, reps, m, handles.pathdir);
            % Load new PRT.mat
            PRTmat = fullfile(handles.pathdir,'PRT.mat');
            load(PRTmat);
            perm = PRT.model(m).output.stats.permutation;
            if strcmp(handles.PRT.model(m).input.type,'classification');
                set(handles.pbacc,'String',sprintf('p: %3.2f',perm.pvalue_b_acc), 'Visible','on');
                set(handles.pcacc,'String',sprintf('p: %3.2f, %3.2f',perm.pvalue_c_acc(1),...
                    perm.pvalue_c_acc(2)),'Visible','on');
            else
                set(handles.pcorr,'String',sprintf('p: %3.2f',perm.pval_corr), 'Visible','on');
                set(handles.pmse,'String',sprintf('p: %3.2f',perm.pval_mse),'Visible','on');
            end
        else
            beep;
            disp('Please enter only one value for the number of repetitions!');
        end
    else
        beep;
        disp('Repetitions should be a number!');
    end
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
