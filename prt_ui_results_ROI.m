function varargout = prt_ui_results_ROI(varargin)
% PRT_UI_RESULTS_ROI M-file for prt_ui_results_ROI.fig
% 
% PRT_UI_RESULTS_ROI, by itself, creates a new PRT_UI_RESULTS_ROI or 
% raises the existing singleton*.
%
% H = PRT_UI_RESULTS_ROI returns the handle to a new PRT_UI_RESULTS_ROI 
% or the handle to the existing singleton*.
%
% PRT_UI_RESULTS_ROI('CALLBACK',hObject,eventData,handles,...) calls the 
% local function named CALLBACK in PRT_UI_RESULTS_ROI.M with the given 
% input arguments.
%
% PRT_UI_RESULTS_ROI('Property','Value',...) creates a new 
% PRT_UI_RESULTS_ROI or raises the existing singleton*.  Starting from the
% left, property value pairs are applied to the GUI before 
% prt_ui_results_ROI_OpeningFcn gets called.  An unrecognized property name
% or invalid value makes property application stop.  All inputs are passed 
% to prt_ui_results_ROI_OpeningFcn via varargin.
%
% *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%  instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J.Schrouff
% $Id: prt_ui_results_ROI.m 555 2012-06-12 08:44:51Z cphillip $

% Edit the above text to modify the response to help prt_ui_results_ROI

% Last Modified by GUIDE v2.5 20-Sep-2012 15:37:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prt_ui_results_ROI_OpeningFcn, ...
                   'gui_OutputFcn',  @prt_ui_results_ROI_OutputFcn, ...
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


% --- Executes just before prt_ui_results_ROI is made visible.
function prt_ui_results_ROI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_ui_results_ROI (see VARARGIN)

% Choose default command line output for prt_ui_results_ROI
handles.output = hObject;

%if window already exists, just put it as the current figure
Tag='ResROI';
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
    set(handles.figure1,'Name','PRoNTo :: ROI weights')
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
    
    %fill table with UserData
    if ~isempty(varargin) && strcmpi(varargin{1},'UserData')
        LR=varargin{2}{1};
        pH=varargin{2}{2};
        pHN=varargin{2}{3};
    else
        f=spm_select(1,'.mat','Select .mat created from atlas weights');
        if ~isempty(f)
            load(f);
            try
                pH=W_roi;
                pHN=NW_roi;
            catch
                error('PRoNTo:prt_ui_results_ROI:Nodata',...
                    'No ROI names or weight values found')
            end
        else
            error('PRoNTo:prt_ui_results_ROI:Nomat',...
                 'No file selected')
        end
        %future: load the saved .mat file
    end
    szn=length(LR);
    dat=cell(szn,3);
    for i=1:szn
        dat{i,1}=LR{i};
        dat{i,2}=pH(i);
        dat{i,3}=pHN(i);
    end
    handles.LR=LR;
    handles.pH=pH;
    handles.pHN=pHN;
    handles.dat=dat;
    set(handles.ROItable,'Data',dat);
    set(handles.ROItable,'ColumnName',{'ROI Name','W_roi (in %)','NW_roi (in %)'});
    set(handles.ROItable,'ColumnEditable',[false,false,false]);
    set(handles.ROItable,'ColumnWidth',{130,80,80});
    set(handles.ROItable,'ColumnFormat',{'char','numeric','numeric'});
    
    % Update Graph
    [AX,H1,H2] = plotyy(handles.axes1,1:size(dat,1), pH,...
        1.4:size(dat,1)+0.4, pHN,'bar');
    set(H2,'FaceColor',[1 0 0])
    set(H2,'BarWidth',0.4)
    set(H1,'BarWidth',0.4)
    aa=get(AX(1),'ylim'); %adapt y scale
    bb=get(AX(2),'ylim');
    m1=max([dat{:,2}])/aa(2);
    m2=max([dat{:,3}])/bb(2);
    sc=min(max(m1,m2)+0.03,1);
    set(AX(1),'ylim',sc*aa)
    set(AX(2),'ylim',sc*bb)
    d2=get(AX(1),'YLabel');
    d1=get(d2,'Position');
    dt=text(d1(1),d1(2)*-0.05,'W roi (in %)');
    set(dt,'Color',[0 0 1])
    d3=get(AX(2),'YLabel');
    d4=get(d3,'Position');
    dt2=text(d4(1)*0.9,d1(2)*-0.05,'NW roi (in %)');
    set(dt2,'Color',[1 0 0])
    set(AX,'XTick',1.4:size(dat,1)+0.4)
    set(AX,'XTickLabel',{''})
    set(AX,'XTick',0)
    legend(handles.axes1,'W_{roi}','NW_{roi}','Location','SouthOutside')
    title('Histogram of (normalized) weights per region','FontWeight','bold')
end
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = prt_ui_results_ROI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

varargout{1} = handles.output;



% --- Executes when entered data in editable cell(s) in ROItable.
function ROItable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to ROItable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in sortH.
function sortH_Callback(hObject, eventdata, handles)
% hObject    handle to sortH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[dumb,ih]=sort(handles.pH,'descend');
dat=handles.dat;
dat=dat(ih,:);
set(handles.ROItable,'Data',dat)

% Update Graph
delete(get(handles.axes1,'Children'))
warning('off')
[AX,H1,H2] = plotyy(handles.axes1,1:size(dat,1), [dat{:,2}],...
    1.4:size(dat,1)+0.4, [dat{:,3}],'bar');
set(H2,'FaceColor',[1 0 0])
set(H2,'BarWidth',0.4)
set(H1,'BarWidth',0.4)
aa=get(AX(1),'ylim'); %adapt y scale
bb=get(AX(2),'ylim');
m1=max([dat{:,2}])/aa(2);
m2=max([dat{:,3}])/bb(2);
sc=min(max(m1,m2)+0.03,1);
set(AX(1),'ylim',sc*aa)
set(AX(2),'ylim',sc*bb)
d2=get(AX(1),'YLabel');
d1=get(d2,'Position');
dt=text(d1(1),d1(2)*-0.05,'W roi (in %)');
set(dt,'Color',[0 0 1])
d3=get(AX(2),'YLabel');
d4=get(d3,'Position');
dt2=text(d4(1)*0.9,d1(2)*-0.05,'NW roi (in %)');
set(dt2,'Color',[1 0 0])
set(AX,'XTick',1.4:size(dat,1)+0.4)
set(AX,'XTickLabel',{''})
legend(handles.axes1,'W_{roi}','NW_{roi}','Location','SouthOutside')
title('Histogram of (normalized) weights per region','FontWeight','bold')
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in sortHN.
function sortHN_Callback(hObject, eventdata, handles)
% hObject    handle to sortHN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[d1,d2]=sort(handles.pHN,'descend');
isn=find(isnan(handles.pHN(:,1)));
d3=1:length(isn);
d4=length(isn)+1:size(d1,1);
ihn=[d2(d4,:);d2(d3,:)];
dat=handles.dat;
dat=dat(ihn,:);
set(handles.ROItable,'Data',dat)

% Update Graph
delete(get(handles.axes1,'Children'))
warning('off')
[AX,H1,H2] = plotyy(handles.axes1,1:size(dat,1), [dat{:,2}],...
    1.4:size(dat,1)+0.4, [dat{:,3}],'bar');
set(H2,'FaceColor',[1 0 0])
set(H2,'BarWidth',0.4)
set(H1,'BarWidth',0.4)
aa=get(AX(1),'ylim'); %adapt y scale
bb=get(AX(2),'ylim');
m1=max([dat{:,2}])/aa(2);
m2=max([dat{:,3}])/bb(2);
sc=min(max(m1,m2)+0.03,1);
set(AX(1),'ylim',sc*aa)
set(AX(2),'ylim',sc*bb)
d2=get(AX(1),'YLabel');
d1=get(d2,'Position');
dt=text(d1(1),d1(2)*-0.05,'W roi (in %)');
set(dt,'Color',[0 0 1])
d3=get(AX(2),'YLabel');
d4=get(d3,'Position');
dt2=text(d4(1)*0.9,d1(2)*-0.05,'NW roi (in %)');
set(dt2,'Color',[1 0 0])
set(AX,'XTick',1.4:size(dat,1)+0.4)
set(AX,'XTickLabel',{''})
legend(handles.axes1,'W_{roi}','NW_{roi}','Location','SouthOutside')
title('Histogram of (normalized) weights per region','FontWeight','bold')
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in quitbutt.
function quitbutt_Callback(hObject, eventdata, handles)
% hObject    handle to quitbutt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% The figure can be deleted now
if isfield(handles,'figure1')
    delete(handles.figure1);
end


