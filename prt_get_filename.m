function out = prt_get_filename(PRT,g,s,m,c)

try
    %group_prefix = [lower(PRT.group(g).gr_name(1:3)) '_'];
    group_prefix = [sprintf('%0.3s',lower(PRT.group(g).gr_name)),'_'];
catch
    group_prefix = 'sxx_';
end

subj_prefix = ['s' int2str(s) '_'];

try
    %mod_prefix = [lower(PRT.group(g).subject(s).modality(m).mod_name(1:3))];
    mod_prefix = [sprintf('%0.3s',lower(PRT.group(g).subject(s).modality(m).mod_name)) '_'];
catch
    mod_prefix = 'mxx_';
end

try
    %cond_prefix = [lower(PRT.group(g).subject(s).modality(m).design.conds(c).cond_name(1:3))];
    cond_prefix = [sprintf('%0.3s',lower(PRT.group(g).subject(s).modality(m).design.conds(c).cond_name))];
catch
    cond_prefix = 'cxx';
end

 out = ['PRT_' group_prefix subj_prefix mod_prefix cond_prefix];
