function varargout = prt_ui_prepare_dataMEEG(varargin)
% PRT_UI_PREPARE_DATAMEEG MATLAB code for prt_ui_prepare_dataMEEG.fig
%      PRT_UI_PREPARE_DATAMEEG, by itself, creates a new PRT_UI_PREPARE_DATAMEEG or raises the existing
%      singleton*.
%
%      H = PRT_UI_PREPARE_DATAMEEG returns the handle to a new PRT_UI_PREPARE_DATAMEEG or the handle to
%      the existing singleton*.
%
%      PRT_UI_PREPARE_DATAMEEG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PRT_UI_PREPARE_DATAMEEG.M with the given input arguments.
%
%      PRT_UI_PREPARE_DATAMEEG('Property','Value',...) creates a new PRT_UI_PREPARE_DATAMEEG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before prt_ui_prepare_dataMEEG_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to prt_ui_prepare_dataMEEG_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help prt_ui_prepare_dataMEEG

% Last Modified by GUIDE v2.5 25-Nov-2014 11:44:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prt_ui_prepare_dataMEEG_OpeningFcn, ...
                   'gui_OutputFcn',  @prt_ui_prepare_dataMEEG_OutputFcn, ...
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


% --- Executes just before prt_ui_prepare_dataMEEG is made visible.
function prt_ui_prepare_dataMEEG_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_ui_prepare_dataMEEG (see VARARGIN)

set(handles.figure1,'Name','PRoNTo :: Specify modality to include')
%set size of the window, taking screen resolution and platform into account
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
                'radiobutton','checkbox'})))
            set(aa(i),'BackgroundColor',color.bg1)
        elseif ~isempty(find(strcmpi(get(aa(i),'Style'),'pushbutton')))
            set(aa(i),'BackgroundColor',color.fr)
        end
    end
    set(aa(i),'FontUnits','pixel')
    xf=get(aa(i),'FontSize');
    set(aa(i),'FontSize',ceil(FS*xf),'FontName',PF,...
        'Units','normalized')
end

% GUI specific settings
handles.mod=struct('mod_name',[],'ich',[],'itp',[],'ifr',[],...
            'multkernparam',[],'aver',[0 0 0],'multkern',[0 0 0]);
if ~isempty(varargin) && strcmpi(varargin{1},'UserData')
    handles.dat = varargin{2}{1};
    handles.ismeeg = varargin{2}{2};
    handles.indmod = varargin{2}{3};
    handles.nmods = length(handles.indmod);
    list = {handles.dat.masks(handles.indmod).mod_name};
    % Initialize handles structure
    set(handles.pop_mod,'String',list);
    set(handles.pop_mod,'Value',1);
    handles = update_mod_info(handles);
else
    error('prt_ui_prepare_dataMEEG:CouldNotGetInfo',...
        'Missing information, please load PRT.mat first')
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes prt_ui_kernel_modality wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prt_ui_prepare_dataMEEG_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles)
    varargout{1} = handles.output;
    % The figure can be deleted now
    delete(handles.figure1);
end


% --- Executes on selection change in pop_mod.
function pop_mod_Callback(hObject, eventdata, handles)
% hObject    handle to pop_mod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_mod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_mod

handles = update_mod_info(handles);
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

% --- Update the info (channels, time, frequency) when choosing modality
function [handles] = update_mod_info(handles)

list = get(handles.pop_mod,'String');
val = get(handles.pop_mod,'Value');
handles.mod.mod_name = list(val);
sc = [];
% Load the first file for that modality to get info
for i = 1:length(handles.dat.group)
    for j = 1:length(handles.dat.group(i).subject)
        mnames={handles.dat.group(i).subject(j).modality(:).mod_name};
        indm = find(ismember(mnames,list(val)));
        if ~isempty(indm)
            sc = handles.dat.group(i).subject(j).modality(indm).scans(1,:);
            break
        end
    end
    if ~isempty(sc)
        break
    end
end
try
    D = spm_eeg_load(sc);
catch
    error('prt_ui_prepare_dataMEEG:CouldNotLoadFile',...
        'Could not load MEEG file, please correct in data and design.');
end
% get channels
lchan = D.chanlabels;
set(handles.uns_chan,'Value',1);
set(handles.uns_chan,'String',lchan);
set(handles.sel_chan,'String',{});
handles.chanlist = lchan;
handles.unsindx = [1:length(lchan)]';
handles.selindx = [];
set(handles.av_chan,'Value',0);
set(handles.av_chan,'Enable','on');
set(handles.mult_chan,'Value',0);
set(handles.mult_chan,'Enable','on');
%get freq info
if length(size(D))== 4 
 % by default select all freq bins
%     set(handles.fb_all,'Value',1)
%     set(handles.fb_select,'Value',0)
    handles.mod.ifr = 1:size(D,2);
    handles.freq = D.frequencies;
    set(handles.fb_start,'String',num2str(handles.freq(1)))
    set(handles.fb_start,'Enable','on')
    set(handles.fb_stop,'String',num2str(handles.freq(end)))
    set(handles.fb_stop,'Enable','on')
    set(handles.av_fb,'Value',0)
    set(handles.av_fb,'Enable','on')
    handles.mod.aver(2) = 0;
    set(handles.mult_fb,'Enable','on')
    set(handles.mult_fb,'Value',0)
%     set(handles.mult_fb_fb,'Enable','off')
%     set(handles.mult_fb_fb,'Value',0)
%     set(handles.mult_fb_win,'Enable','off')
%     set(handles.mult_fb_win,'Value',0)
%     set(handles.mult_fb_winsize,'Enable','off')
%     set(handles.mult_fb_winsize,'String','')
    % Set color of all text boxes to the color of enabled buttons
    cc = get(handles.mult_fb,'ForegroundColor');
    aa=get(handles.uipanel3,'children');
    for i = 1:length(aa)
        if ~isempty(find(strcmpi(get(aa(i),'Style'),{'text'})))
            set(aa(i),'ForegroundColor',cc);
        end
    end
    handles.dim = [size(D,1),size(D,2),size(D,3)];    
else
%     set(handles.fb_all,'Value',0)
%     set(handles.fb_select,'Value',0)
    set(handles.fb_start,'String','')
    set(handles.fb_start,'Enable','off')
    set(handles.fb_stop,'String','')
    set(handles.fb_stop,'Enable','off')
    handles.mod(1).ifr = [];
    set(handles.av_fb,'Value',0)
    set(handles.av_fb,'Enable','off')
    handles.mod(1).aver(2) = 0;
    set(handles.mult_fb,'Enable','off')
    set(handles.mult_fb,'Value',0)
%     set(handles.mult_fb_fb,'Enable','off')
%     set(handles.mult_fb_fb,'Value',0)
%     set(handles.mult_fb_win,'Enable','off')
%     set(handles.mult_fb_win,'Value',0)
%     set(handles.mult_fb_winsize,'Enable','off')
%     set(handles.mult_fb_winsize,'String','')
    % Set color of all text boxes to the color of disabled buttons
    cc = get(handles.mult_fb_winsize,'ForegroundColor');
    aa=get(handles.uipanel3,'children');
    for i = 1:length(aa)
        if ~isempty(find(strcmpi(get(aa(i),'Style'),{'text'})))
            set(aa(i),'ForegroundColor',cc);
        end
    end
    handles.dim = [size(D,1),1,size(D,2)];
end
% get time info
handles.time = [D.time];
handles.int_tp = 1/D.fsample;
% set(handles.tp_all,'Value',1) % by default select all freq bins
% set(handles.tp_select,'Value',0)
set(handles.tp_start,'String',num2str(handles.time(1)*1000))
set(handles.tp_start,'Enable','on')
set(handles.tp_stop,'String',num2str(handles.time(end)*1000))
set(handles.tp_stop,'Enable','on')
handles.mod.itp = 1:length(handles.time);
set(handles.av_tp,'Value',0)
set(handles.av_tp,'Enable','on')
handles.mod.aver(3) = 0;
set(handles.mult_tp,'Enable','on')
set(handles.mult_tp,'Value',0)
set(handles.mult_tp_tp,'Enable','off')
set(handles.mult_tp_tp,'Value',0)
set(handles.mult_tp_win,'Enable','off')
set(handles.mult_tp_win,'Value',0)
set(handles.mult_tp_winsize,'Enable','off')
set(handles.mult_tp_winsize,'String','')
cc = get(handles.mult_tp_win,'ForegroundColor');
set(handles.text6,'ForegroundColor',cc);
% set(handles.smooth_tp,'Enable','on')
% set(handles.smooth_tp,'Value',0)
% set(handles.smooth_tp_win,'Enable','off')
% set(handles.smooth_tp_win,'String','')

% --- Executes on selection change in uns_chan.
function uns_chan_Callback(hObject, eventdata, handles)
% hObject    handle to uns_chan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns uns_chan contents as cell array
%        contents{get(hObject,'Value')} returns selected item from uns_chan
idx = get(handles.uns_chan,'Value');
listuns = get(handles.uns_chan,'String');
listchan = handles.chanlist;
[dd,idtr] = intersect(listchan,listuns(idx),'stable');
listsel = get(handles.sel_chan,'String');
listsel = [listsel;listuns(idx)];
listuns = setdiff(listuns,listuns(idx),'stable');
handles.unsindx = setdiff(handles.unsindx,idtr,'stable');
set(handles.uns_chan,'Value',min([max([idx,1]),min([length(listuns),idx])]));
set(handles.uns_chan,'String',listuns);
set(handles.sel_chan,'Value',length(listsel));
set(handles.sel_chan,'String',listsel);
handles.selindx = [handles.selindx;idtr];
% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function uns_chan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uns_chan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sel_chan.
function sel_chan_Callback(hObject, eventdata, handles)
% hObject    handle to sel_chan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sel_chan contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sel_chan
idx = get(handles.sel_chan,'Value');
listsel = get(handles.sel_chan,'String');
listchan = handles.chanlist;
[dd,idtr] = intersect(listchan,listsel(idx),'stable');
listuns = get(handles.uns_chan,'String');
listuns = [listuns;listsel(idx)];
listsel = setdiff(listsel,listsel(idx),'stable');
handles.selindx = setdiff(handles.selindx,idtr,'stable');
set(handles.sel_chan,'Value',min([max([idx,1]),min([length(listsel),idx])]));
set(handles.sel_chan,'String',listsel);
set(handles.uns_chan,'String',listuns);
set(handles.uns_chan,'Value',length(listuns));
handles.unsindx = [handles.unsindx;idtr];
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function sel_chan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sel_chan (see GCBO)
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
listuns = get(handles.uns_chan,'String');
if ~isempty(listuns) % if not all selected, select all
    set(handles.sel_chan,'String',handles.chanlist);
    set(handles.sel_chan,'Value',length(handles.chanlist));
    set(handles.uns_chan,'Value',1);
    set(handles.uns_chan,'String',{});    
    handles.unsindx = [];
    handles.selindx = [1:length(handles.chanlist)]';
else %if unselected list empty, then unselect all
    set(handles.uns_chan,'String',handles.chanlist);
    set(handles.uns_chan,'Value',length(handles.chanlist));
    set(handles.sel_chan,'Value',1);
    set(handles.sel_chan,'String',{});    
    handles.selindx = [];
    handles.unsindx = [1:length(handles.chanlist)]';
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in av_chan.
function av_chan_Callback(hObject, eventdata, handles)
% hObject    handle to av_chan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of av_chan
avchan = get(handles.av_chan,'Value');
handles.mod.aver(1) = avchan;
if avchan % Cannot build one kernel per channel if performing average
    set(handles.mult_chan,'Value',0);
    set(handles.mult_chan,'Enable','off');
    handles.mod.multkern(1) = 0;
else
    multchan = get(handles.mult_chan,'Value');
    set(handles.mult_chan,'Enable','on');
    handles.mod.multkern(1) = multchan;
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in mult_chan.
function mult_chan_Callback(hObject, eventdata, handles)
% hObject    handle to mult_chan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mult_chan
multchan = get(handles.mult_chan,'Value');
handles.mod.multkern(1) = multchan;
if multchan % Cannot average if one kernel per channel
    set(handles.av_chan,'Value',0);
    set(handles.av_chan,'Enable','off');
    handles.mod.aver(1) = 0;
else
    avchan = get(handles.av_chan,'Value');
    set(handles.av_chan,'Enable','on');
    handles.mod.aver(1) = avchan;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in tp_all.
% function tp_all_Callback(hObject, eventdata, handles)
% % hObject    handle to tp_all (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of tp_all
% val = get(handles.tp_all,'Value');
% if val
%     set(handles.tp_select,'Value',0)
%     set(handles.tp_start,'String','')
%     set(handles.tp_start,'Enable','off')
%     set(handles.tp_stop,'String','')
%     set(handles.tp_stop,'Enable','off')
% else
%     set(handles.tp_start,'Enable','on')
%     set(handles.tp_stop,'Enable','on')    
% end
% handles.mod.itp = 1:length(handles.time); % to be over-written by start and stop if selection
% guidata(hObject,handles)

% % --- Executes on button press in tp_select.
% function tp_select_Callback(hObject, eventdata, handles)
% % hObject    handle to tp_select (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of tp_select
% val = get(handles.tp_select,'Value');
% if ~val
%     set(handles.tp_start,'String','')
%     set(handles.tp_start,'Enable','off')
%     set(handles.tp_stop,'String','')
%     set(handles.tp_stop,'Enable','off')
% else
%     set(handles.tp_all,'Value',0)
%     set(handles.tp_start,'Enable','on')
%     set(handles.tp_stop,'Enable','on')
%     handles.mod.itp = 1:length(handles.time);
% end
% guidata(hObject,handles)


function tp_start_Callback(hObject, eventdata, handles)
% hObject    handle to tp_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tp_start as text
%        str2double(get(hObject,'String')) returns contents of tp_start as a double
val = str2double(get(handles.tp_start,'String'));
lb = find(handles.time*1000<=val+handles.int_tp*999);
isamp = lb(end);
maxsamp = handles.mod.itp(end);
if abs(handles.time(isamp)*1000 - val)> handles.int_tp*999
    disp('Getting closest sample taking the sampling rate into account')
    set(handles.tp_start,'String',num2str(handles.time(isamp)*1000));
end
if isempty(isamp) 
    beep
    disp('Specified time of start is outside epoch window, correct')
    return
end
if maxsamp<=isamp
    beep
    disp('Specified time of start is posterior to specified end, correct')
    return
end
handles.mod.itp = isamp:maxsamp;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function tp_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tp_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tp_stop_Callback(hObject, eventdata, handles)
% hObject    handle to tp_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tp_stop as text
%        str2double(get(hObject,'String')) returns contents of tp_stop as a double
val = str2double(get(handles.tp_stop,'String'));
ub = find(handles.time*1000>=val+handles.int_tp*999);
if isempty(ub) 
    beep
    disp('Specified time of end is outside of epoch window, correct')
    return
end
isamp = ub(1)-1;
minsamp = handles.mod.itp(1);
if abs(handles.time(isamp)*1000-val)>handles.int_tp*999
    disp('Getting closest sample taking the sampling rate into account')
    set(handles.tp_stop,'String',num2str(handles.time(isamp)*1000));
end
if isamp<=minsamp
    beep
    disp('Specified time of end is anterior to specified start, correct')
    return
end
handles.mod.itp = minsamp:isamp;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function tp_stop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tp_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in av_tp.
function av_tp_Callback(hObject, eventdata, handles)
% hObject    handle to av_tp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of av_tp
avtp = get(handles.av_tp,'Value');
handles.mod.aver(3) = avtp;
if avtp % Cannot build one kernel per time point if performing average
    set(handles.mult_tp,'Value',0);
    set(handles.mult_tp,'Enable','off');
    set(handles.mult_tp_tp,'Value',0);
    set(handles.mult_tp_tp,'Enable','off')
    set(handles.mult_tp_win,'Value',0);
    set(handles.mult_tp_win,'Enable','off')
    set(handles.mult_tp_winsize,'String','');
    set(handles.mult_tp_winsize,'Enable','off')
    handles.mod.multkern(3) = 0;
else
    multtp = get(handles.mult_tp,'Value');
    set(handles.mult_tp,'Enable','on');
    set(handles.mult_tp_tp,'Enable','on');
    set(handles.mult_tp_win,'Enable','on');
    set(handles.mult_tp_winsize,'Enable','off');
    handles.mod.multkern(3) = multtp;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in mult_tp.
function mult_tp_Callback(hObject, eventdata, handles)
% hObject    handle to mult_tp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mult_tp
multtp = get(handles.mult_tp,'Value');
handles.mod.multkern(3) = multtp;
if multtp % Cannot average if multiple kernels
    set(handles.av_tp,'Value',0);
    set(handles.av_tp,'Enable','off');
    set(handles.mult_tp_tp,'Enable','on')
    set(handles.mult_tp_win,'Value',0);
    set(handles.mult_tp_win,'Enable','on')
    set(handles.mult_tp_winsize,'String','');
    set(handles.mult_tp_winsize,'Enable','off')
    handles.mod.aver(3) = 0;
else
    avtp = get(handles.av_tp,'Value');
    set(handles.mult_tp_win,'Value',0);
    set(handles.mult_tp_tp,'Value',0);
    set(handles.mult_tp_winsize,'String','');
    set(handles.av_tp,'Enable','on');
    set(handles.mult_tp_tp,'Enable','off');
    set(handles.mult_tp_win,'Enable','off');
    set(handles.mult_tp_winsize,'Enable','off');
    handles.mod.aver(3) = avtp;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in mult_tp_tp.
function mult_tp_tp_Callback(hObject, eventdata, handles)
% hObject    handle to mult_tp_tp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mult_tp_tp
val = get(handles.mult_tp_tp,'Value');
if val
    handles.mod.multkernparam{3} = 1;
    set(handles.mult_tp_win,'Value',0);
    set(handles.mult_tp_winsize,'String','');
    set(handles.mult_tp_winsize,'Enable','off');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in mult_tp_win.
function mult_tp_win_Callback(hObject, eventdata, handles)
% hObject    handle to mult_tp_win (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mult_tp_win
val = get(handles.mult_tp_win,'Value');
if val
    set(handles.mult_tp_tp,'Value',0);
    set(handles.mult_tp_winsize,'String','');
    set(handles.mult_tp_winsize,'Enable','on');
end
cc = get(handles.mult_tp_win,'ForegroundColor');
set(handles.text6,'ForegroundColor',cc);
% Update handles structure
guidata(hObject, handles);


function mult_tp_winsize_Callback(hObject, eventdata, handles)
% hObject    handle to mult_tp_winsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mult_tp_winsize as text
%        str2double(get(hObject,'String')) returns contents of mult_tp_winsize as a double
val = str2double(get(handles.mult_tp_winsize,'String'));
tmp = val/(handles.int_tp*1000);
if tmp<1
    beep
    disp('Window specified too small compared to sampling frequency')
    set(handles.mult_tp_winsize,'String','')
    return
elseif tmp>=length(handles.time)
    beep
    disp('Window specified too large compared to epoched window')
    set(handles.mult_tp_winsize,'String','')
    return
elseif isnan(tmp)
    beep
    disp('Please enter a number in ms')
    set(handles.mult_tp_winsize,'String','')
    return
end
handles.mod.multkernparam{3} = tmp;
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function mult_tp_winsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mult_tp_winsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in smooth_tp.
% function smooth_tp_Callback(hObject, eventdata, handles)
% % hObject    handle to smooth_tp (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of smooth_tp
% val = get(handles.smooth_tp,'Value');
% if val
%     handles.mod.smooth = 1;
%     set(handles.smooth_tp_win,'Enable','on');
%     set(handles.smooth_tp_win,'String','');
% else
%     handles.mod.smooth = 0;
%     handles.mod.smoothparam = [];
%     set(handles.smooth_tp_win,'Enable','off');
%     set(handles.smooth_tp_win,'String','');
% end
% guidata(hObject,handles);


% function smooth_tp_win_Callback(hObject, eventdata, handles)
% % hObject    handle to smooth_tp_win (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of smooth_tp_win as text
% %        str2double(get(hObject,'String')) returns contents of smooth_tp_win as a double
% val = str2double(get(handles.smooth_tp_win,'String'));
% if ~isnan(val)
%     handles.mod.smoothparam = val;
% end
% guidata(hObject,handles);

% % --- Executes during object creation, after setting all properties.
% function smooth_tp_win_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to smooth_tp_win (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end


% % --- Executes on button press in fb_all.
% function fb_all_Callback(hObject, eventdata, handles)
% % hObject    handle to fb_all (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of fb_all
% val = get(handles.fb_all,'Value');
% if val
%     set(handles.fb_select,'Value',0)
%     set(handles.fb_start,'String','')
%     set(handles.fb_start,'Enable','off')
%     set(handles.fb_stop,'String','')
%     set(handles.fb_stop,'Enable','off')
% else
%     set(handles.fb_start,'Enable','on')
%     set(handles.fb_stop,'Enable','on')    
% end
% handles.mod.ifr = 1:length(handles.freq); % to be over-written by start and stop if selection
% guidata(hObject,handles)

% --- Executes on button press in fb_select.
% function fb_select_Callback(hObject, eventdata, handles)
% % hObject    handle to fb_select (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of fb_select
% val = get(handles.fb_select,'Value');
% if ~val
%     set(handles.fb_start,'String','')
%     set(handles.fb_start,'Enable','off')
%     set(handles.fb_stop,'String','')
%     set(handles.fb_stop,'Enable','off')
% else
%     set(handles.fb_all,'Value',0)
%     set(handles.fb_start,'Enable','on')
%     set(handles.fb_stop,'Enable','on')
%     handles.mod.ifr = 1:length(handles.freq);
% end
% guidata(hObject,handles)


function fb_start_Callback(hObject, eventdata, handles)
% hObject    handle to fb_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fb_start as text
%        str2double(get(hObject,'String')) returns contents of fb_start as a double
val = str2double(get(handles.fb_start,'String'));
lb = find(handles.freq <=val);
isamp = lb(end);
maxsamp = handles.mod.ifr(end);
if handles.freq(isamp) ~=val
    disp('Getting closest frequency band taking the TF-resolution into account')
    set(handles.fb_start,'String',num2str(handles.freq(isamp)));
end
if isempty(isamp) 
    beep
    disp('Specified frequency is outside frequency range of signal, correct')
    return
end
if maxsamp<=isamp
    beep
    disp('Bandwidth is 0 or negative, correct')
    return
end
handles.mod.ifr = isamp:maxsamp;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function fb_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fb_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fb_stop_Callback(hObject, eventdata, handles)
% hObject    handle to fb_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fb_stop as text
%        str2double(get(hObject,'String')) returns contents of fb_stop as a double
val = str2double(get(handles.fb_stop,'String'));
ub = find(handles.freq>=val);
if isempty(ub) 
    beep
    disp('Specified frequency is outside frequency range of signal, correct')
    return
end
isamp = ub(1);
minsamp = handles.mod.ifr(1);
if handles.freq(isamp) ~= val
    disp('Getting closest frequency band taking the TF-resolution into account')
    set(handles.fb_stop,'String',num2str(handles.freq(isamp)));
end
if isamp<=minsamp
    beep
    disp('Specified time of end is anterior to specified start, correct')
    return
end
handles.mod.ifr = minsamp:isamp;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function fb_stop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fb_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in av_fb.
function av_fb_Callback(hObject, eventdata, handles)
% hObject    handle to av_fb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of av_fb
avfb = get(handles.av_fb,'Value');
handles.mod.aver(2) = avfb;
if avfb % Cannot build one kernel per time point if performing average
    set(handles.mult_fb,'Value',0);
    set(handles.mult_fb,'Enable','off');
%     set(handles.mult_fb_fb,'Value',0);
%     set(handles.mult_fb_fb,'Enable','off')
%     set(handles.mult_fb_win,'Value',0);
%     set(handles.mult_fb_win,'Enable','off')
%     set(handles.mult_fb_winsize,'String','');
%     set(handles.mult_fb_winsize,'Enable','off')
    handles.mod.multkern(2) = 0;
else
    multfb = get(handles.mult_fb,'Value');
    set(handles.mult_fb,'Enable','on');
%     set(handles.mult_fb_fb,'Enable','on');
%     set(handles.mult_fb_win,'Enable','on');
%     set(handles.mult_fb_winsize,'Enable','off');
    handles.mod.multkern(2) = multfb;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in mult_fb.
function mult_fb_Callback(hObject, eventdata, handles)
% hObject    handle to mult_fb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mult_fb
multfb = get(handles.mult_fb,'Value');
handles.mod.multkern(2) = multfb;
if multfb % Cannot average if multiple kernels
    set(handles.av_fb,'Value',0);
    set(handles.av_fb,'Enable','off');
%     set(handles.mult_fb_fb,'Enable','on')
%     set(handles.mult_fb_win,'Value',0);
%     set(handles.mult_fb_win,'Enable','on')
%     set(handles.mult_fb_winsize,'String','');
%     set(handles.mult_fb_winsize,'Enable','off')
    handles.mod.aver(2) = 0;
else
    avfb = get(handles.av_fb,'Value');
%     set(handles.mult_fb_win,'Value',0);
%     set(handles.mult_fb_fb,'Value',0);
%     set(handles.mult_fb_winsize,'String','');
    set(handles.av_fb,'Enable','on');
%     set(handles.mult_fb_fb,'Enable','off');
%     set(handles.mult_fb_win,'Enable','off');
%     set(handles.mult_fb_winsize,'Enable','off');
    handles.mod.aver(2) = avfb;
end
% Update handles structure
guidata(hObject, handles);

% % --- Executes on button press in mult_fb_fb.
% function mult_fb_fb_Callback(hObject, eventdata, handles)
% % hObject    handle to mult_fb_fb (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of mult_fb_fb
% val = get(handles.mult_fb_fb,'Value');
% if val
%     handles.mod.multkernparam{2} = 1;
%     set(handles.mult_fb_win,'Value',0);
%     set(handles.mult_fb_winsize,'String','');
%     set(handles.mult_fb_winsize,'Enable','off');
% end
% % Update handles structure
% guidata(hObject, handles);

% % --- Executes on button press in mult_fb_win.
% function mult_fb_win_Callback(hObject, eventdata, handles)
% % hObject    handle to mult_fb_win (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of mult_fb_win
% val = get(handles.mult_fb_win,'Value');
% if val
%     set(handles.mult_fb_fb,'Value',0);
%     set(handles.mult_fb_winsize,'String','');
%     set(handles.mult_fb_winsize,'Enable','on');
% end
% % Update handles structure
% guidata(hObject, handles);


% function mult_fb_winsize_Callback(hObject, eventdata, handles)
% % hObject    handle to mult_fb_winsize (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of mult_fb_winsize as text
% %        str2double(get(hObject,'String')) returns contents of mult_fb_winsize as a double
% val = str2double(get(handles.mult_fb_winsize,'String'));
% handles.mod.multkernparam{2} = val;
% % Update handles structure
% guidata(hObject, handles);

% % --- Executes during object creation, after setting all properties.
% function mult_fb_winsize_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to mult_fb_winsize (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end


% --- Executes on button press in donebutt.
function donebutt_Callback(hObject, eventdata, handles)
% hObject    handle to donebutt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check everything was filled before passing it to prt_ui_prepare_data
handles.mod.ich = handles.selindx;
if isempty(handles.mod.ich)
    beep
    disp('No channels selected, Please correct')
    return
end
if isempty(handles.mod.itp)
    beep
    disp('No time points selected, Please correct')
    return
end
if isempty(handles.mod.ifr) && handles.dim(2)>1
    beep
    disp('No frequencies selected, Please correct')
    return
end
% if handles.mod.smooth
%     if isempty(handles.mod.smoothparam)
%         beep
%         disp('Temporal smoothing selected but no FWHM provided')
%         return
%     end
% end
if any(handles.mod.multkern)
    idx = find(handles.mod.multkern);
%     if any(ismember(idx,2)) && isempty(handles.mod.multkernparam{2})
%         beep
%         disp('Multiple kernels in frequency but no band width chosen')
%         return
%     end
    if any(ismember(idx,3)) && isempty(handles.mod.multkernparam{3})
        beep
        disp('Multiple kernels in time but no time window chosen')
        return
    end
    
end
handles.output=handles.mod;
% Update handles structure
guidata(hObject, handles);

uiresume(handles.figure1)
