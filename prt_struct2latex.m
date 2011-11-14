function prt_struct2latex(S)
% Function that takes in a structure S and writes down the latex code
% describing the whole structure and substructures recursively.
% The routine specifically generates the 'adv_PRTstruct.tex' file that is
% included, in the prt_manual.
%
% Bits of the code and copied/inspired by spm_latex.m from the SPM8 
% distribution: http://www.fil.ion.ucl.ac.uk/spm
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by Christophe Phillips
% $Id$

fp = fopen(fullfile(prt('dir'),'manual','adv_PRTstruct.tex'),'w');
if fp==-1, sts = false; return; end;

%% Heading part
fprintf(fp,'%% $Id$\n\n');
fprintf(fp,'\\chapter{%s}\n \\label{sec:%s}\n\n',...
    texify('PRT structure'),'PRTstruct');
fprintf(fp,'This is how the main {\\tt PRT} structure is organised.\n\n');

%% Deal with structure
fprintf(fp,'{\\tt PRT}\n');
h_skip = .5; % horizontal skip increment

struct2tex(fp,S,h_skip)

fclose(fp);

return

%==========================================================================
function struct2tex(fp,S,h_skip)

if nargin<3, h_skip = .5; end

fieldn = fieldnames(S);
% Begin list
beg_txt = sprintf(['\\begin{list}{$\\bullet$}\n' ...
            '\t{\\setlength{\\labelsep}{.2cm}' ...
            '\\setlength{\\itemindent}{0cm}' ...
             '\\setlength{\\leftmargin}{%2.1fcm}}\n'],h_skip);
fprintf(fp,'%s',beg_txt);

% List of fields
for ii=1:numel(fieldn)
    fprintf(fp,'\\item %s',texify(fieldn{ii}));
    if numel(S)>1
        fprintf(fp,'()\n');
    else
        fprintf(fp,'\n');
    end
    if isstruct(S(1).(fieldn{ii})) & ~isempty(S(1).(fieldn{ii}))
        struct2tex(fp,S(1).(fieldn{ii}),h_skip+.5)
    end
end

% End list
end_txt = '\end{list}';
fprintf(fp,'%s\n\n',end_txt);

return

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
