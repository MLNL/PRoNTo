function prt_preproc(fname)

% Function to preprocess the images, by loading each one of them (or the
% ones corresponding to the selected scans when a design was specified),
% applying the masks on them and, if asked, detrend along each voxel along
% the time series.
% 
% INPUT: 
%   fname   filename and path to PRT.mat
%
% OUTPUT:
%   results are saved on disk.
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J.Rondina
% Id:$

%--------------------------------------------------------------------------
% Load PRT.mat
%--------------------------------------------------------------------------
load(char(fname));    % Load data structure (PRT.mat)
prt_dir=regexprep(char(fname),'PRT.mat', '');  % Get PRT.mat directory 


%-------------------------------------------------------------------------
% Resizing masks
%-------------------------------------------------------------------------

% Get numbers of groups, modalities and subjects from PRT.mat
n_groups = length(PRT.group);
n_modalities = length(PRT.masks);
tot_subj=sum(length([PRT.group(:).subject]));

% Get the first scan from each modality as a sample to resize the
% respective masks, if it is necessary
sample_img=cell(n_modalities,1);
sample_name=cell(n_modalities,1);
mod_name=cell(n_modalities,1);
for m=1:n_modalities
    sample_img{m} = nifti(char(PRT.group(1).subject(1).modality(m).scans(1,:)));
    sample_name{m} = char(PRT.group(1).subject(1).modality(m).scans(1,:));
    mod_name{m}=PRT.group(1).subject(1).modality(m).mod_name;
end

mnii=cell(n_modalities,1);
mask=cell(n_modalities,1);
for m=1:n_modalities
    maskmod=PRT.masks(m).mod_name;
    maskname =  regexprep(char(PRT.masks(strcmpi(mod_name, maskmod)).fname),',1','');   % get mask name    
    mnii{m} = nifti(maskname);
    % Name of the resized mask to be saved 
    newmask_name = [prt_dir 'updated_mask_m' PRT.group(1).subject(1).modality(m).mod_name '.img'];  
    % If dimensions of mask and scan don't match
    if size(mnii{m}.dat(:,:,:,1)) ~= size(sample_img{m}.dat(:,:,:,1)) 
       % Use spm_imcalc function for mask resizing 
       img1_calc = spm_vol(sample_name{m}); 
       img2_calc = spm_vol(maskname);
       outputfile = img1_calc;
       outputfile.fname = newmask_name;
       spm_imcalc([img1_calc img2_calc],outputfile,'i2.*(i1>0)');
       mnii{m} = nifti(newmask_name); 
    end
    % Reshape masks (resized or not)for all modalities as vectors and
    % stores in the structure mask
    mask{m} = double(reshape(mnii{m}.dat,1,size(mnii{m}.dat,1)*size(mnii{m}.dat,2)*size(mnii{m}.dat,3)));
end

%-------------------------------------------------------------------------
% Loading images, detrending, saving
%-------------------------------------------------------------------------

h = waitbar(0,'Please wait while images are pre-processed (details provided in the main window)');
step=0;
for g = 1:n_groups 
    disp(['Loading group ' int2str(g)]); 
    n_subj = length(PRT.group(g).subject);

    for s = 1:n_subj
        disp(['Loading subject ' int2str(s)]);
        n_mod = length(PRT.group(g).subject(s).modality);
        
        for m = 1:n_mod
            disp(['Loading modality ' int2str(m)]);                 
            n_scans = size(PRT.group(g).subject(s).modality(m).scans,1);
            m2=find(strcmpi(mod_name,PRT.group(g).subject(s).modality(m).mod_name));
            dim1 = size(sample_img{m2}.dat,1);
            dim2 = size(sample_img{m2}.dat,2);
            dim3 = size(sample_img{m2}.dat,3);
            n_voxels_scan = dim1*dim2*dim3; % get total number of voxels in the scan
            
            % Loading images
            img_allscans=zeros(n_scans,n_voxels_scan);
            for sc = 1:n_scans              
                nii = nifti(PRT.group(g).subject(s).modality(m).scans(sc,:));
                if size(nii.dat) ~= size(sample_img{m2}.dat)
                    % Check if some scan have different dimensionality
                    % (e.g. corrupted image)
                    disp (['Error - Scan ' int2str(sc) 'Modality ' int2str(m) 'Subject ' int2str(s) 'Group ' int2str(g) ' has wrong dimensions']);
                    break;
                else
                    img = double(reshape(nii.dat,1,n_voxels_scan)); 
                    img(find(isnan(img))) = 0; % Replace NaNs for zeros
                    img_allscans(sc,:) = img.*mask{m2}; % Apply mask to scan and store it in a matrix formed for all the scans from the same subject and modality
                end
            end
            
            step = step + 1;
            waitbar(step / (tot_subj*n_modalities*3));
          
            % Detrending
            if (PRT.group(g).subject(s).modality(m).detrend)
                disp ('Detrending ....');
                n_scans = length(PRT.group(g).subject(s).modality(m).scans);
                mask_indices = mask{m2}>0;
                n_voxels_mask = length(mask_indices); 
                for v = 1:n_voxels_mask  % Detrend only voxels inside the mask
                    timeserie = img_allscans(:,mask_indices(v));
                    aux = detrend(timeserie);
                    img_allscans(:,mask_indices(v)) = aux;
                end
            end
            
            step = step + 1;
            waitbar(step / (tot_subj*n_modalities*3));
            
            %Saving pre-processed images
            disp ('Saving pre-processed images ...');
            % Saving timeseries already detrended (in this case, the examples are extracted from the timeseries 
            if isa(PRT.group(g).subject(s).modality(m).design,'struct') && PRT.group(g).subject(s).modality(m).detrend
                % i.e. if there is a design and if the detrend was done in preprocessing
                n_cond = length(PRT.group(g).subject(s).modality(m).design.conds);
                for c = 1:n_cond 
                    filename = [prt_dir, prt_get_filename([g,s,m,c]),'.img']; %Get output file name                   
                    examples_list = PRT.group(g).subject(s).modality(m).design.conds(c).scans;
                    % Build 4d image with the extracted examples 
                    img4d = file_array(filename,[dim1,dim2,dim3,length(examples_list)],'float64-le',0,1,0);
                    for i = 1:length(examples_list)
                        if ~(examples_list(i)>n_scans)
                            img1d = img_allscans(examples_list(i),:);
                            img3d = reshape(img1d,dim1,dim2,dim3);
                            img4d(:,:,:,i) = img3d;
                        else  %should not happen since checked in the data and design
                            disp('Warning - design exceeds timeseries')
                            disp('Corresponding scans were discarded')
                        end
                    end                
                    No         = sample_img{1}; % copy header
                    No.dat     = img4d;         % change file_array
                    No.descrip = 'Pronto data';
                    No.cal     = [0 1000];
                    create(No);                 % write header
                end
            else % if design == 0 (i.e. structural) or if detrend == 0 (i.e., timeseries not detrended)               
                filename = [prt_dir, prt_get_filename([g,s,m]),'.img'];
                img4d = file_array(filename,[dim1,dim2,dim3,n_scans],'FLOAT64-LE',0,1,0);
                for i = 1:n_scans                 
                    img3d = reshape(img_allscans(i,:),dim1,dim2,dim3);  
                    img4d(:,:,:,i) = img3d;
                end               
                No         = sample_img{1}; % copy header
                No.dat     = img4d;         % change file_array
                No.descrip = 'Pronto data';
                No.cal     = [0 1];
                create(No);                 % write header
            end
            
            clear img_allscans;
            clear img4d;
            
            step = step+1;
            waitbar(step / (tot_subj*n_modalities*3));
        end        
    end
end

delete(h);