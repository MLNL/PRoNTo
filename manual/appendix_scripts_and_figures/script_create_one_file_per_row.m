function [path_files] = script_create_one_file_per_row(data_matrix,tosquare)
% Creates one file per row of a data matrix. The files will be saved in a
% subfolder, with the names 'Sample_' prepended. The second input 'tosquare'
% reflects whether the data should be turned into a symmetric matrix or not
% (0, default value)
%--------------------------------------------------------------------------
% Written for PRoNTo v3.0 by J. Schrouff

if nargin<1 || isempty(data_matrix)
    beep
    disp('At least one variable must be specified, the data matrix to convert')
    return
end
if nargin<2 || isempty(tosquare)
    tosquare = 0;
end
nsamp = size(data_matrix,1);
d = dir('.');
path_files = fullfile(d(1).folder,'Samples_mat');
if ~exist(path_files,'dir')
    mkdir(path_files);
end
cd(path_files);
fprintf(['Sample (out of %d):',repmat(' ',1,ceil(log10(nsamp))),'%d'],nsamp, 1);
for i = 1:nsamp
    
    % Subject counter
    if i>1
        for idisp = 1:ceil(log10(i)) % delete previous counter display
            fprintf('\b');
        end
        fprintf('%d',i);
    end
    % Access sample's data
    datas = data_matrix(i,:);
    if tosquare
        try
            data = squareform(datas);
        catch
            data = datas;
        end
    else
        data = datas;
    end
    prep = [];
    for idisp = 1:floor(log10(nsamp))-floor(log10(i)) % Add zeros in front of name for easier access
        prep = [prep,'0'];
    end
    fname = ['Sample_',prep,num2str(i),'.mat'];
    save(fname,'data');
end
fprintf('\n');