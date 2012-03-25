function varargout = prt_ui_stats(varargin)
% PRT_UI_STATS MATLAB code for prt_ui_stats.fig
%      PRT_UI_STATS, by itself, creates a new PRT_UI_STATS or raises the existing
%      singleton*.
%
%      H = PRT_UI_STATS returns the handle to a new PRT_UI_STATS or the handle to
%      the existing singleton*.
%
%      PRT_UI_STATS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PRT_UI_STATS.M with the given input arguments.
%
%      PRT_UI_STATS('Property','Value',...) creates a new PRT_UI_STATS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before prt_ui_stats_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to prt_ui_stats_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help prt_ui_stats

% Last Modified by GUIDE v2.5 24-Jan-2012 22:25:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prt_ui_stats_OpeningFcn, ...
                   'gui_OutputFcn',  @prt_ui_stats_OutputFcn, ...
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


% --- Executes just before prt_ui_stats is made visible.
function prt_ui_stats_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_ui_stats (see VARARGIN)

% set(handles.figure1,'Name','PRoNTo :: Stats table)
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
end

S0= spm('WinSize','0',1);   %-Screen size (of the current monitor)
FS= spm('FontSizes');       %-Scaled font sizes
refres=[1 1 1280 800];
ratio=S0./refres;
set(handles.figure1,'DefaultTextFontSize',FS(10))
% hAxes = findall(handles.figure1,'type','axes');
% hText = findall(hAxes,'type','text');
% hUIControls = findall(handles.figure1,'type','uicontrol');
% set([hAxes; hText;hUIControls],...
%     'units','normalized','fontunits','normalized');
set(handles.figure1,'Units','normalized')
set(handles.figure1,'Resize','on')
set(handles.figure1,'Position',ratio.*[0.35,0.3,0.35,0.5])



if ~isempty(varargin)
    
    stats = varargin{1};
    
        
        switch stats.type
            
            case 'class'
                
                
                set(handles.corrtext,'Visible','off');
                set(handles.corrvaltext,'Visible','off');
                
                set(handles.msetext,'Visible','off');
                set(handles.msevaltext,'Visible','off');
                
                set(handles.pcorr,'Visible','off');
                set(handles.pmse,'Visible','off');
                
                set(handles.accuracytext,'String','Accuracy (acc):','Visible','on');
                set(handles.baccuracytext,'String','Balanced acc:','Visible','on');
                set(handles.classaccuracytext,'String','Class acc:','Visible','on');
                
                set(handles.acctext,'String',sprintf('%3.1f %%',stats.macc*100),'Visible','on');
                set(handles.bacctext,'String',sprintf('%3.1f %%',stats.mbacc*100),'Visible','on');
                
                set(handles.cacctext,'String',sprintf('[%3.1f %3.1f] %%',...
                    stats.mcacc(1)*100,stats.mcacc(2)*100),'Visible','on');
                
                
                if isfield(stats,'show_perm')
                    
                    if stats.show_perm
                        
                        set(handles.pbacc,'String',sprintf('p-val: %3.2f',stats.perm.pvalue_b_acc), 'Visible','on');
                        set(handles.pcacc,'String',sprintf('p-val: %3.2f, %3.2f',stats.perm.pvalue_c_acc(1),...
                            stats.perm.pvalue_c_acc(2)),'Visible','on');
                    else
                        
                        set(handles.pbacc,'Visible','off');
                        set(handles.pcacc,'Visible','off');
                    end
                    
                else
                    
                    set(handles.pbacc,'Visible','off');
                    set(handles.pcacc,'Visible','off');
                    
                end
                
            case 'reg'
                
                set(handles.accuracytext,'String','Accuracy (acc):','Visible','off');
                set(handles.baccuracytext,'String','Balanced acc:','Visible','off');
                set(handles.classaccuracytext,'String','Class acc:','Visible','off');
                set(handles.pbacc, 'Visible','off');
                set(handles.pcacc,'Visible','off');
                
                set(handles.acctext,'Visible','off');
                set(handles.bacctext,'Visible','off');
                set(handles.cacctext,'Visible','off');
                
                set(handles.corrtext,'String','Correlation:','Visible','on');
                set(handles.corrvaltext,'String',sprintf('%3.1f',stats.corr),'Visible','on');
                
                set(handles.msetext,'String','MSE:','Visible','on');
                set(handles.msevaltext,'String',sprintf('%3.1f',stats.mse),'Visible','on');
                
                if isfield(stats,'show_perm')
                    
                    if stats.show_perm
                        
                        set(handles.pbacc, 'Visible','off');
                        set(handles.pcacc,'Visible','off');
                        
                        set(handles.pcorr,sprintf('p: %3.2f',stats.perm.pval_corr),'Visible','on');
                        set(handles.pmse,sprintf('p: %3.2f',stats.perm.pval_mse),'Visible','on');
                        
                    else
                        set(handles.pcorr,'Visible','off');
                        set(handles.pmse,'Visible','off');
                    end
                    
                else
                    set(handles.pcorr,'Visible','off');
                    set(handles.pmse,'Visible','off');
                end
        end
        
        
end


% Choose default command line output for prt_ui_stats
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes prt_ui_stats wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prt_ui_stats_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
