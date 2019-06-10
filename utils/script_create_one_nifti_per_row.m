function [path_files] = script_create_one_nifti_per_row(data_matrix,mask)
% Function to creates one nifti per row of a data matrix.
% The files will be saved in a subfolder, with the names 'Subject_S'
% prepended. The second input 'mask' specifies the nifti mask to use.

if nargin<1 || isempty(data_matrix)
    beep
    disp('At least one variable must be specified, the data matrix to convert')
    return
end

if nargin<2 || isempty(mask)
    mask = spm_select([1 1],'image','Select mask file');
end

nsubj = size(data_matrix,1);

d = dir('.');
path_files = fullfile(d(1).folder,'Subjects_nifti');
if ~exist(path_files,'dir')
    mkdir(path_files);
end
cd(path_files);

% Load mask and access variables
V = spm_vol(mask);
VV = spm_read_vols(V);
idx = find(~isnan(VV) & VV>0);


if numel(idx) ~= size(data_matrix,2)
    beep
    disp('Mask and data do not match, aborting')
    return
end

ext = '.img';
hdr        = V.private;

fprintf(['Processing subject (out of %d):',repmat(' ',1,ceil(log10(nsubj))),'%d'],nsubj, 1);
for i = 1:nsubj
    % Subject counter
    if i>1
        for idisp = 1:ceil(log10(i)) % delete previous counter display
            fprintf('\b');
        end
        fprintf('%d',i);
    end
    
    % Access subject's data
    datas = data_matrix(i,:);
    
    % Get subject's file name
    prep = [];
    for idisp = 1:floor(log10(nsubj))-floor(log10(i)) % Add zeros in front of name for easier access
        prep = [prep,'0'];
    end
    img = fullfile(path_files,['Subject_S',prep,num2str(i),ext]);
    
    % check that image does not exist, otherwise, delete
    if exist(img,'file')
        delete(img);
        % delete hdr as well if .img/.hdr pairs
        [pth,nam] = fileparts(img);
        hdr_name  = [pth,filesep,nam,'.hdr'];
        if exist(hdr_name,'file')
            delete(hdr_name);
        end
    end
    
    %Create binary array
    img_arr = file_array(img,[V.dim],'float32-le',0,1,0);
    img_mat = NaN*zeros([V.dim]);
    img_mat(idx) = datas;
    img_arr(:,:,:) = img_mat;
    
    %Save file
    No         = hdr;              % copy header
    No.dat     = img_arr;         % change file_array
    No.descrip = 'Subject nifti'; % description
    create(No);                    % write header
end

fprintf('\n');


