function varargout = prt_data_modality(varargin)
% PRT_DATA_MODALITY M-file for prt_data_modality.fig
%
% PRT_DATA_MODALITY, by itself, creates a new PRT_DATA_MODALITY or raises
% the existing singleton*.
%
% H = PRT_DATA_MODALITY returns the handle to a new PRT_DATA_MODALITY or
% the handle to the existing singleton*.
%
% PRT_DATA_MODALITY('CALLBACK',hObject,eventData,handles,...) calls the local
% function named CALLBACK in PRT_DATA_MODALITY.M with the given input arguments.
%
% PRT_DATA_MODALITY('Property','Value',...) creates a new PRT_DATA_MODALITY
% or raises the existing singleton*.  Starting from the left, property value
% pairs are applied to the GUI before prt_data_modality_OpeningFcn gets called.
% An unrecognized property name or invalid value makes property application
% stop.  All inputs are passed to prt_data_modality_OpeningFcn via varargin.
%
% *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%  instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J.Schrouff
% $Id$

% Edit the above text to modify the response to help prt_data_modality
% Last Modified by GUIDE v2.5 31-Jul-2018 11:19:33


% Begin initialization code - DO NOT EDIT


gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @prt_data_modality_OpeningFcn, ...
    'gui_OutputFcn',  @prt_data_modality_OutputFcn, ...
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


% --- Executes just before prt_data_modality is made visible.
function prt_data_modality_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prt_data_modality (see VARARGIN)

% Choose default command line output for prt_data_modality
handles.output = hObject;

%if window already exists, just put it as the current figure
Tag='DDmod';
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
    
    set(handles.figure1,'Name','PRoNTo :: Specify modality')
    
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
    set(handles.figure1,'DefaultTextFontSize',FS*8,...
        'DefaultUicontrolFontSize',FS*8,...
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
        else
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
    handles.mod=[];
    handles.mod.detrend=0;
    handles.mod.design=0;
    handles.mod.scans=[];
    handles.mod.name={};
    handles.mod.covar=[];
    handles.mod.rt_subj=[];
    handles.mod.type = 'nifti';
    handles.subj1=0;
    set(handles.design_menu,...
        'String',{'No design','Specify design','Load SPM.mat'},...
        'Value',1);
    set(handles.target_menu,...
        'String',{'Specify targets','No targets'},...
        'Value',2);
    set(handles.edit_covar,...
        'String',{'Specify covariates','No covariates'},...
        'Value',2);
    set(handles.type,...
        'String',{'nifti','MEEG','.mat'},...
        'Value',1);
    
    if ~isempty(varargin) && strcmpi(varargin{1},'UserData')
        %Particular options if you select by 'scans'
        if ~isempty(varargin{2}{2})
            if ~isempty(varargin{2}{3}) % Review or modify existing modality
                openmod = 1;
                set(handles.modname,'Enable','off')
            else % Create new modality
                openmod = 0;
                set(handles.modname,'Enable','on')
            end
            handles.scans =strcmpi(varargin{2}{2}.subj_name,'Samples');
            if strcmpi(varargin{2}{2}.subj_name,'Samples') || ...
                    (isfield(varargin{2}{2},'modality') && ...
                    (openmod && ~isstruct(varargin{2}{2}.modality(varargin{2}{3}).design)) && ...
                    (openmod && isempty(varargin{2}{2}.modality(varargin{2}{3}).design))) %No design, One image per subject
                set(handles.design_menu,'Enable','off')
                set(handles.target_menu,'Enable','on')
                set(handles.edit_covar,'Enable','on')
                set(handles.edit_covar,'Visible','on')
                set(handles.text7,'Visible','on') % Covariates
            else % When more than one image per subject (i.e. design), only regression targets and covariates within trials
                set(handles.target_menu,'Enable','off')
                set(handles.edit_covar,'Enable','off')
                set(handles.edit_covar,'Visible','off')
                set(handles.text7,'Visible','off')
            end
        else
            set(handles.design_menu,'Enable','on')
            set(handles.edit_covar,'Enable','off')
            set(handles.edit_covar,'Visible','off')
            set(handles.text7,'Visible','off')
            set(handles.target_menu,'Enable','off')
        end
        
        
        if ~isempty(varargin{2}{2}) && isfield(varargin{2}{2},'modality') && ...
                ~isempty(varargin{2}{2}.modality)
            handles.subjmod={varargin{2}{2}.modality(:).mod_name};
            
            if length(varargin{2})>=3 && ~isempty(varargin{2}{3})
                nlist=varargin{2}{1};
                modsel=varargin{2}{2}.modality(varargin{2}{3});
                valsel=find(strcmpi(modsel.mod_name,nlist));
                set(handles.modname,'String',nlist);
                set(handles.modname,'Value',valsel);
                handles.mod.design=modsel.design;
                if ~isempty(modsel.design)
                    if ~isstruct(modsel.design) && modsel.design== 0
                        set(handles.design_menu,'Value',1)
                        handles.desnmenu = 3;
                    else
                        set(handles.design_menu,'Value',2)
                        handles.desnmenu = 2;
                    end
                end
                handles.mod.scans=modsel.scans;
                handles.mod.name=modsel.mod_name;
                handles.mod.covar=modsel.covar;
                if ~isempty(modsel.covar)
                    set(handles.edit_covar,'Enable','off')
                    set(handles.edit_covar,'Visible','on')
                    set(handles.text7,'Visible','on')
                    if size(modsel.covar,1)==1 %Review numbers for only one subject                        
                        set(handles.edit_covar,...
                            'String',{'Specify covariates','No covariates', num2str(modsel.covar)},...
                            'Value',3);
                    else
                        set(handles.edit_covar,...
                            'String',{'Specify covariates','No covariates', 'Entered'},...
                            'Value',3);
                    end
                end
                handles.mod.rt_subj=modsel.rt_subj;
                if ~isempty(modsel.rt_subj)
                    set(handles.target_menu,'Enable','on')
                    set(handles.target_menu,'Value',1)
                end
                if isfield(modsel,'type')
                    if strcmpi(modsel.type,'MEEG')
                        set(handles.type,'Value',2)
                        set(handles.design_menu,...
                            'String',{'Events in file'},...
                            'Value',1);
                    else
                        if strcmpi(modsel.type,'.mat')
                            set(handles.type,'Value',3)
                            set(handles.design_menu,'Enable','on')
                        else
                            set(handles.type,'Value',1)
                        end
                    end
                    handles.mod.type = modsel.type;
                else
                    set(handles.type,'Value',1)
                end
                set(handles.modname,'Enable','off')
            else
                nlist=[varargin{2}{1}, {'Enter new'}];
                set(handles.modname,'String',nlist,'Value',length(nlist));
            end
        else
            nlist=[varargin{2}{1}, {'Enter new'}];
            set(handles.modname,'String',nlist,'Value',length(nlist));
            handles.subjmod={};
        end
    else
        nlist={'Enter new'};
        handles.subjmod={};
        set(handles.modname,'String',nlist,'Value',1);
    end
    if length(varargin{2})>=4 && ~isempty(varargin{2}{4})
        handles.subj1=varargin{2}{4};
    end
    if length(varargin{2})==5 && ~isempty(varargin{2}{5})
        handles.PRT=varargin{2}{5};
    end
    warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
end

% Update handles structure
guidata(hObject, handles);

% %UIWAIT makes prt_data_modality wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prt_data_modality_OutputFcn(hObject, eventdata, handles)
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


% --- Executes on selection change in modname.
function modname_Callback(hObject, eventdata, handles)
% hObject    handle to modname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns modname contents as cell array
%        contents{get(hObject,'Value')} returns selected item from modname
warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid')
list=get(handles.modname,'String');
% [UPDATE v3.1 - R2025a compatibility] In MATLAB R2025a, get(handle,'String')
% may return a string array instead of a cell array. cellstr() ensures
% brace indexing works correctly across all MATLAB versions.
if ~iscell(list)
    list = cellstr(list);
end

%handle particular bug with matlab(7.10.0499) and mac (OSX 10.6.4)
if length(list)==1
    set(handles.modname,'Value',1)
end

if any(strfind(list{get(handles.modname,'Value')}, 'Enter'))
    modname=prt_text_input('Title','Enter modality name');
    if isnumeric(modname)
        return
    end
    if ~any(strcmpi(list,modname))
        nlist=[list;{modname}];
    else
        beep
        disp('This modality has already been set for the selected subject')
        set(handles.modname,'String',list);
        valall=strfind(list,'Enter');
        for i=1:length(valall)
            if ~isempty(valall{i})
                val=i;
                break
            end
        end
        set(handles.modname,'Value',val);
        return
    end
    set(handles.modname,'String',nlist);
    set(handles.modname,'Value',length(nlist));
else
    modname=list{get(handles.modname,'Value')};
    if ~isempty(handles.subjmod)
        if any(strcmpi(handles.subjmod,modname))
            set(handles.modname,'String',list);
            valall=strfind(list,'Enter');
            if length(valall)==1 && isempty(valall{1}) %case of reviewing the modality
                val=1;
                set(handles.modname,'Value',val);
            else    %user tries to give a name he already used
                beep
                disp('This modality has already been set for the selected subject')
                for i=1:length(valall)
                    if ~isempty(valall{i})
                        val=i;
                        break
                    end
                end
                set(handles.modname,'Value',val);
                return
            end
        end
    end
end

%if a subject was previously entered in this modality, extract info
if isstruct(handles.subj1)
    if any(strcmpi(modname, {handles.subj1(:).mod_name}))
        handles.indmods1=find(strcmpi(modname, {handles.subj1(:).mod_name}));
        % Automatically set data type and design options
        type = handles.subj1(handles.indmods1).type;
        if strcmpi(type,'MEEG')
            set(handles.type,'Value',2)
            set(handles.design_menu,...
                'String',{'Events in file'},...
                'Value',1);
        else
            if strcmpi(type,'.mat')
                set(handles.type,'Value',3)
                set(handles.design_menu,...
                    'String',{'No design','Specify design'},...
                    'Value',1);
            else
                set(handles.type,'Value',1)
                set(handles.design_menu,...
                    'String',{'No design','Specify design','Load SPM.mat'},...
                    'Value',1);
            end
        end
        handles.mod.type = type;
        % Allow to replicate subject 1 design
        list=get(handles.design_menu,'String');
        list=[list;{'Replicate design of subject 1'}];
        set(handles.design_menu,'String',cellstr(list)); % [UPDATE v3.1 - R2025a] ensure cell array for String
    end
end
handles.mod.name=modname;
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function modname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to modname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in design_menu.
function design_menu_Callback(hObject, eventdata, handles)
% hObject    handle to design_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns design_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from design_menu
choice=get(handles.design_menu,'Value');
%Mac and Matlab versions strange things with popup menus
if choice==0
    choice=handles.desnmenu;
end
list = get(handles.design_menu,'String');
% [UPDATE v3.1 - R2025a compatibility] Ensure list is a cell array.
if ~iscell(list)
    list = cellstr(list);
end
chosen = list{choice};
switch chosen
    case 'Load SPM.mat' % for nifti only
        desn=spm_select(1,'mat','Select SPM.mat file',[],[],'SPM.mat');
        try
            load(desn);
        catch
            beep
            disp('Can not load SPM.mat file');
            return
        end
        conds=struct();
        list={};
        for sspm=1:length(SPM.Sess) % Gather SPM.mat fields
            ncond = length(SPM.Sess(sspm).U);
            for c = 1:ncond
                if sspm==1  %set the conditions
                    conds(c).cond_name = SPM.Sess(sspm).U(c).name{1};
                    list=[list, {conds(c).cond_name}];
                    conds(c).onsets = SPM.Sess(sspm).U(c).ons;
                    if length(SPM.Sess(sspm).U(c).dur)==1
                        conds(c).durations=repmat(SPM.Sess(sspm).U(c).dur,...
                            numel(conds(c).onsets),1);
                    else
                        conds(c).durations = SPM.Sess(sspm).U(c).dur;
                    end
                    indcond=ncond;
                else  %for other sessions, look if the conditions are the same
                    name_cond=SPM.Sess(sspm).U(c).name{1};
                    itoadd=find(strcmpi(name_cond,list));
                    if isempty(itoadd)  % if not, then add condition
                        indcond=indcond+1;
                        conds(indcond).cond_name = SPM.Sess(sspm).U(c).name{1};
                        conds(indcond).onsets = SPM.Sess(sspm).U(c).ons;
                        if length(SPM.Sess(sspm).U(c).dur)==1
                            conds(indcond).durations=repmat(SPM.Sess(sspm).U(c).dur,...
                                numel(conds(indcond).onsets),1);
                        else
                            conds(indcond).durations = SPM.Sess(sspm).U(c).dur;
                        end
                        list=[list, {name_cond}];
                    else               %if yes, then add the onsets
                        conds(itoadd).onsets    = [conds(itoadd).onsets;SPM.Sess(sspm).U(c).ons];
                        if length(SPM.Sess(sspm).U(c).dur)==1
                            tmp=repmat(SPM.Sess(sspm).U(c).dur,...
                                numel(SPM.Sess(sspm).U(c).ons),1);
                        else
                            tmp = SPM.Sess(sspm).U(c).dur;
                        end
                        conds(itoadd).durations = [conds(itoadd).durations;tmp];
                    end
                end
            end
        end
        def=prt_get_defaults('datad'); % HRF parameters only for nifti
        if isfield(handles.PRT.group,'hrfoverlap')
            overl=handles.PRT.group.hrfoverlap;
        else
            overl=def.hrfw;
        end
        if isfield(handles.PRT.group,'hrfdelay')
            del=handles.PRT.group.hrfdelay;
        else
            del=def.hrfd;
        end
        if length(unique([SPM.xX.K(:).RT])) ~=1
            beep
            disp('Differents TR found in SPM.mat, please separate sessions')
            return
        else
            RT = SPM.xX.K(:).RT;
        end
        if strcmpi(SPM.xBF.UNITS,'scans') %units, TR or seconds
            units=0;
        else
            units=1;
        end
        
        %check that TR is the same for all sessions
        desn=prt_check_design(conds,RT,units,overl,del);
        desn.covar = [];
    case 'Specify design'
        if isstruct(handles.mod.design)
            desn=prt_data_conditions('UserData',{handles.mod.design,handles.PRT,0});
        else
            desn=prt_data_conditions;
        end
    case 'No design'
        desn=[];
        if size(handles.mod.scans,1)==1 %If no design and one image, can enter covariates and RT
            set(handles.design_menu,'Value')
            set(handles.target_menu,'Enable','on')
            set(handles.edit_covar,'Enable','on')
            set(handles.edit_covar,'Visible','on')
            set(handles.text7,'Visible','on')
        elseif ~handles.scans && size(handles.mod.scans,1)>1
            set(handles.target_menu,'Enable','off')
            set(handles.edit_covar,'Enable','off')
            set(handles.edit_covar,'Visible','off')
            set(handles.text7,'Visible','off')
            handles.mod.covar=[];
            handles.mod.rt_subj=[];
        end
    case 'Replicate design of subject 1'
        desn=handles.subj1(handles.indmods1).design;
    case 'Events in file' % For MEEG only
        if isempty(handles.mod.scans)
            beep
            disp('Select .mat for subject first')
            return
        elseif size(handles.mod.scans,1)>1
            beep
            disp('Select only one file per modality for MEEG')
            return
        end
        if ~isstruct(handles.mod.design)
            D = spm_eeg_load(handles.mod.scans(1,:));
            desn = prt_get_design_MEEG(D);
            desn.covar = [];
            handles.mod.design=desn;
        end
        desn=prt_data_conditions('UserData',{handles.mod.design,handles.PRT,1});
end
handles.mod.design=desn;
if isfield(desn,'covar') && ~isempty(desn.covar)
    set(handles.edit_covar,'String','Entered');
    set(handles.edit_covar,'Visible','on');
    set(handles.text7, 'Visible','on')
end
if choice ~= 3
    set(handles.target_menu,'Enable','off')
    set(handles.edit_covar,'Enable','off')
    set(handles.edit_covar,'Visible','off')
    set(handles.text7,'Visible','off')
    handles.mod.covar=[];
    handles.mod.rt_subj=[];
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function design_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to design_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in getfiles.
function getfiles_Callback(hObject, eventdata, handles)
% hObject    handle to getfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.mod.scans)
    sel=cellstr(handles.mod.scans);
else
    sel=[];
end

typ = get(handles.type,'Value');
desn=[];
if typ>1 % either MEEG or .mat with data matrix (v3.1)
    [t, status]=spm_select([1 Inf],'mat','Select files for the modality',sel);
    if typ==2 %MEEG, load events in file
        if isempty(t)
            beep
            disp('Select .mat for subject first')
            return
        elseif size(t,1)>1
            beep
            disp('Select only one file per modality for MEEG')
            return
        end
        if ~isstruct(handles.mod.design)
            D = spm_eeg_load(t(1,:));
            desn = prt_get_design_MEEG(D);
            desn.covar = [];
            handles.mod.design=desn;
        end
    end
    handles.mod.design=desn;
    if isfield(desn,'covar') && ~isempty(desn.covar)
        set(handles.edit_covar,'String','Entered');
        set(handles.edit_covar,'Visible','on');
        set(handles.text7, 'Visible','on')
    end
else
    [t,status]=spm_select([1 Inf],'image','Select files for the modality',sel);
end
if status
    handles.mod.scans=t;
else
    handles.mod.scans=sel;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in type.
function type_Callback(hObject, eventdata, handles)
% hObject    handle to type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of type
val = get(handles.type,'Value');
typ = get(handles.type,'String');
% [UPDATE v3.1 - R2025a compatibility] Ensure typ is a cell array.
if ~iscell(typ)
    typ = cellstr(typ);
end
if val==0
    val=1;
    set(handles.type,'Value',val)
end
if val==2
    set(handles.design_menu,...
        'String',{'Events in file'},...
        'Value',1);
else
    if val==1
        set(handles.design_menu,...
            'String',{'No design','Specify design','Load SPM.mat'},...
            'Value',1);
    else
        set(handles.design_menu,...
            'String',{'No design','Specify design'},...
            'Value',1);
    end
    if isstruct(handles.subj1)
        
        list=get(handles.modname,'String');
        % [UPDATE v3.1 - R2025a compatibility] Ensure list is a cell array.
        if ~iscell(list)
            list = cellstr(list);
        end
        modname=list{get(handles.modname,'Value')};
        
        if any(strcmpi(modname, {handles.subj1(:).mod_name}))
            handles.indmods1=find(strcmpi(modname, {handles.subj1(:).mod_name}));
            list=get(handles.design_menu,'String');
            % [UPDATE v3.1 - R2025a compatibility] Ensure list is a cell array.
            if ~iscell(list)
                list = cellstr(list);
            end
            list=[list;{'Replicate design of subject 1'}];
            set(handles.design_menu,'String',cellstr(list)); % [UPDATE v3.1 - R2025a] ensure cell array for String
        end
    end
end
handles.mod.type = typ{val};
% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in target_menu.
function target_menu_Callback(hObject, eventdata, handles)
% hObject    handle to target_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns target_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from target_menu
choice=get(handles.target_menu,'Value');
%Mac and Matlab versions strange things with popup menus
if choice==0
    choice=2;
end
switch choice
    case 2
        rte = [];
    case 1
        if isstruct(handles.mod.rt_subj)
            rte=prt_data_targets('UserData',{handles.mod.rt_subj,handles.PRT,0});
        else
            rte=prt_data_targets;
        end
end

handles.mod.rt_subj=rte;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function target_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to target_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_covar_Callback(hObject, eventdata, handles)
% hObject    handle to edit_covar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_covar as text
%        str2double(get(hObject,'String')) returns contents of edit_covar as a double
%first option of loading: writing the values
rt=get(handles.edit_covar,'Value');
%Mac and Matlab versions strange things with popup menus

if rt==0
    rt=2;
end
switch rt
    case 3
        return
    case 2
        rte = [];
    case 1
        tarfile = spm_select(1,'.mat','Select covariates file');
        try
            load(tarfile);
        catch
            beep
            disp('Could not load the file')
            disp('Please enter a .mat file containing the covariate values')
            return
        end
        
        if ~exist('R','var')
            beep
            disp('Covariates file must contain the covariate values in an "R" variable!')
            disp('Please correct!')
            return
        else
            rte=R;
        end
        
end

handles.mod.covar=rte;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_covar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_covar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in okbutton.
function okbutton_Callback(hObject, eventdata, handles)
% hObject    handle to okbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%check that the files were selected
if isempty(handles.mod.scans)
    beep
    disp('Please, select the files before returning')
    return
end

%check that the regression targets have the same number of elements as the
%number of scans or as the number of events in design
if ~isempty(handles.mod.rt_subj)
    szrt=length(handles.mod.rt_subj(1).tar); %prt_data_targets already check all targets have the same number of values
    if  size(handles.mod.scans,1)~=szrt
        beep
        disp('Number of regression targets must be the number of files selected! ')
        disp('Please correct!')
        return
    end
    if ~handles.scans && size(handles.mod.scans,1)>1
        beep
        disp('Regression targets can only be entered if one image per subject! ')
        disp('Please correct!')
        return
    end
end
%check that the covariates have the same number of elements as the
%number of scans
if ~isempty(handles.mod.covar)
    szrt=size(handles.mod.covar);
    nsc = size(handles.mod.scans,1);
    ins = find(szrt == nsc);
    if  isempty(ins)
        beep
        disp('Number of covariates must be the number of files selected! ')
        disp('Please correct!')
        return
    else
        if ~handles.scans && size(handles.mod.scans,1)>1
            beep
            disp('Covariates can only be entered if one image per subject! ')
            disp('Please correct!')
            return
        end
        if ins~=1 %not the first dimension
            handles.mod.covar = handles.mod.covar';
        end
    end
end

modprop=handles.mod;
handles.output=modprop;
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);


% --- Executes on button press in cancelbutton.
function cancelbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);
