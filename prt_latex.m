function prt_latex
%
% Extract information from the toolbox m-files and output them as usable
% .tex files which can be directly included in the manual.
%
% There are 2 types of m2tex operations:
% 1. converting the job configuration tree, i.e. *_cfg_* files defining the
%    batching interface into a series of .tex files. 
%    NOTE: Only generate .tex files for each exec_branch of prt_batch. 
% 2. converting the help header of the functions into .tex files.
%
% These files are then included in a manually written prt_manual.tex file, 
% which also includes chapter/sections written manually.
%
% File derived from that of the SPM8 distribution.
% http://www.fil.ion.ucl.ac.uk/spm
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% John Ashburner & Christophe Phillips
% $Id$


%% Turning the cfg files into a .tex file
if ~nargin,
    c = prt_cfg_batch;
end
% if nargin && ischar(c),
%     clean_latex_compile;
%     return;
% end

for i=1:numel(c.values),
    fp = fopen(fullfile(prt('dir'),'manual',['batch_',bn,'.tex']),'w');
    if fp==-1, sts = false; return; end;
    chapter(c.values{i},fp);
end;

%% picking all the function help files and put them into a .tex
fp = fopen(fullfile(prt('dir'),'manual','functions.tex'),'w');
if fp==-1, sts = false; return; end;

return;

%==========================================================================
function sts = chapter(c,fp)
bn = c.tag;
if nargin<2
    fp = fopen(fullfile(pwd,'manual',[bn,'.tex']),'w');
    if fp==-1, sts = false; return; end;
end

fprintf(fp,'%% $Id$ \n\n');
fprintf(fp, ...
    '\\chapter{%s  \\label{Chap:%s}}\n\\minitoc\n\n\\vskip 1.5cm\n\n', ...
    texify(c.name),c.tag);
write_help(c,fp);

switch class(c),
    case {'cfg_branch','cfg_exbranch'},
        for i=1:numel(c.val),
            section(c.val{i},fp);
        end;
    case {'cfg_repeat','cfg_choice'},
        for i=1:numel(c.values),
            section(c.values{i},fp);
        end;
end;
fclose(fp);
sts = true;
return;

%==========================================================================
function section(c,fp,lev)
if nargin<3, lev = 1; end;
sec = {'section','subsection','subsubsection','paragraph','subparagraph', ...
            'textbf','textsc','textsl','textit'};
% if lev<=length(sec),
    fprintf(fp,'\n\\%s{%s}\n',sec{min(lev,length(sec))},texify(c.name));
    write_help(c,fp);
    switch class(c),
        case {'cfg_branch','cfg_exbranch'},
            for i=1:numel(c.val),
                section(c.val{i},fp,lev+1);
            end;
        case {'cfg_repeat','cfg_choice'},
            for i=1:numel(c.values),
                section(c.values{i},fp,lev+1);
            end;
    end;
% else
if lev>length(sec),
    warning(['Too many nested levels... ',c.name]); %#ok<WNTAG>
end;
return;

%==========================================================================
function write_help(hlp,fp)
if isa(hlp, 'cfg_item'),
    if ~isempty(hlp.help),
        hlp = hlp.help;
    else
        return;
    end;
end;
if iscell(hlp),
    for i=1:numel(hlp),
        write_help(hlp{i},fp);
    end;
    return;
end;
str = texify(hlp);
fprintf(fp,'%s\n\n',str);
return;

%==========================================================================
function str = texify(str0)
st1  = strfind(str0,'/*');
en1  = strfind(str0,'*/');
st = [];
en = [];
for i=1:numel(st1),
    en1  = en1(en1>st1(i));
    if ~isempty(en1),
        st  = [st st1(i)];
        en  = [en en1(1)];
        en1 = en1(2:end);
    end;
end;

str = [];
pen = 1;
for i=1:numel(st),
    str = [str clean_latex(str0(pen:st(i)-1)) str0(st(i)+2:en(i)-1)];
    pen = en(i)+2;
end;
str = [str clean_latex(str0(pen:numel(str0)))];
return;

%==========================================================================
function str = clean_latex(str)
str  = strrep(str,'$','\$');
str  = strrep(str,'&','\&');
str  = strrep(str,'^','\^');
str  = strrep(str,'_','\_');
str  = strrep(str,'#','\#');
%str  = strrep(str,'\','$\\$');
str  = strrep(str,'|','$|$');
str  = strrep(str,'>','$>$');
str  = strrep(str,'<','$<$');
return;

%==========================================================================
function bibcstr = get_bib(bibdir)
biblist = dir(fullfile(bibdir,'*.bib'));
bibcstr={};
for k = 1:numel(biblist)
    [p n e v] = spm_fileparts(biblist(k).name);
    bibcstr{k}  = fullfile(bibdir,n);
end

%==========================================================================
function clean_latex_compile
PRTdir = prt('dir');
p = fullfile(PRTdir,'manual');
[f, d] = spm_select('FPlist',p,'.*\.aux$');
f = strvcat(f, spm_select('FPlist',p,'.*\.tex$'));
f = strvcat(f, spm_select('FPlist',p,'^manual\..*$'));
f(strcmp(cellstr(f),fullfile(PRTdir,'manual','prt_manual.tex')),:) = [];
f(strcmp(cellstr(f),fullfile(PRTdir,'manual','prt_manual.pdf')),:) = [];
for i=1:size(d,1)
    f = strvcat(f, spm_select('FPlist',deblank(d(i,:)),'.*\.aux$'));
end
f(strcmp(cellstr(f),filesep),:) = [];
disp(f); pause
for i=1:size(f,1)
    spm_unlink(deblank(f(i,:)));
end
