function out = prt_run_preproc(varargin)
% PRONTO job execution function
% takes a harvested job data structure and rearrange data into "proper"
% data structure, then save do what it has to do...
% Here simply the harvested job structure in a mat file.
%
% Input:
% job    - harvested job data structure (see matlabbatch help)
% Output:
% out    - filename of saved data structure.
%__________________________________________________________________________
% Copyright (C) 2011, ...
% $Id: $


% Job variable
% -------------------------------------------------------------------------

job   = varargin{1};

% Input file
% -------------------------------------------------------------------------

fname = job.infile
load(char(fname));
prt_dir=regexprep(char(fname),'PRT.mat', '');

% -------------------------------------------------------------------------
% Load libraries
% -------------------------------------------------------------------------

%addpath LIB/NII_lib %[afm] moved to the prt_batch script

% -------------------------------------------------------------------------
%Initial checks
% -------------------------------------------------

n_groups = length(PRT.group);
n_modalities = length(PRT.masks);
n_subjects = length(PRT.group(1).subject);
error_flag = 0;

for g = 1:n_groups
    n_subj = length(PRT.group(g).subject);
    if n_subj ~= n_subjects
        error_flag = 1;
        disp(['Group ' int2str(g) ' has a different number of subjects.']);
    end
    for s = 1:n_subj
         n_mod = length(PRT.group(g).subject(s).modality);
         if (n_mod ~= n_modalities)
             error_flag = 1;
             disp(['Subject ' int2str(s) ' group ' int2str(g) ' has a different number of modalities.']);
         end        
    end
end 

if error_flag == 1
    return;
end


for m=1:n_modalities
    sample_img{m} = load_nii(PRT.group(1).subject(1).modality(m).scans{1});
    sample_name{m} = PRT.group(1).subject(1).modality(m).scans{1};
end


% -------------------------------------------------------------------------
% Resizing masks
% -------------------------------------------------

for m=1:n_modalities
    maskname =  regexprep(char(PRT.masks(m).fnames),',1','');
    if isempty(PRT.masks(m).fnames)
       maskname = prt_get_defaults('prep.default_mask');
    end
    mnii{m} = load_nii(maskname);
    newmask_name = [prt_dir 'updated_mask_m' int2str(m) '.img'];   
    if size(mnii{m}.img) ~= size(sample_img{m}.img)
       img1_calc = spm_vol(sample_name{m});
       img2_calc = spm_vol(maskname);
       outputfile = img1_calc;
       outputfile.fname = newmask_name;
       spm_imcalc([img1_calc img2_calc],outputfile,'i2.*(i1>0)');
       mnii{m} = load_nii(newmask_name);
    end
    mask{m} = double(reshape(mnii{m}.img,1,size(mnii{m}.img,1)*size(mnii{m}.img,2)*size(mnii{m}.img,3)));
end


% -------------------------------------------------------------------------
% Loading images, detrending, saving
% -------------------------------------------------------------------------

h = waitbar(0,'Please wait while images are pre-processed (details provided in the main window)');
step=0;
for g = 1:n_groups
    disp(['Loading group ' int2str(g)]);
    n_subj = length(PRT.group(g).subject);
    group_prefix = ['g' int2str(g)];
    for s = 1:n_subj
        disp(['Loading subject ' int2str(s)]);
        n_mod = length(PRT.group(g).subject(s).modality);
        subj_prefix = ['_s' int2str(s)];
        for m = 1:n_mod
            disp(['Loading modality ' int2str(m)]);                  
            n_scans = length(PRT.group(g).subject(s).modality(m).scans);
            mod_prefix = ['_m' int2str(m)];
            dim1 = size(sample_img{m}.img,1);
            dim2 = size(sample_img{m}.img,2);
            dim3 = size(sample_img{m}.img,3);
            dim_vector = dim1*dim2*dim3; 
            
            
            % Loading images
            img_allscans=zeros(n_scans,dim_vector);
            for sc = 1:n_scans
                nii = load_nii(PRT.group(g).subject(s).modality(m).scans{sc});
                if size(nii.img) ~= size(sample_img{m}.img)
                    disp (['Error - Scan ' int2str(sc) 'Modality ' int2str(m) 'Subject ' int2str(s) 'Group ' int2str(g) ' has wrong dimensions']);
                    break;
                else
                    img = double(reshape(nii.img,1,dim_vector));
                    img(find(isnan(img))) = 0;
                    img_allscans(sc,:) = img.*mask{m};
                end
            end
            
            step = step + 1;
            waitbar(step / (n_groups*n_subjects*n_modalities*3));
          
            % Detrending
            if (PRT.group(g).subject(s).modality(m).timesr)
                disp ('Detrending ....');
                n_scans = length(PRT.group(g).subject(s).modality(m).scans);
                mask_indices = mask{m}>0;
                n_voxels_mask = length(mask_indices);
                for v = 1:n_voxels_mask
                    timeserie = img_allscans(:,mask_indices(v));
                    aux = detrend(timeserie);
                    img_allscans(:,mask_indices(v)) = aux;
                end
            end
            
            step = step + 1;
            waitbar(step / (n_groups*n_subjects*n_modalities*3));
            
            %Saving pre-processed images
            disp ('Saving pre-processed images ...');
            % Detrended timeseries 
            if isa(PRT.group(g).subject(s).modality(m).design,'struct') & PRT.group(g).subject(s).modality(m).timesr
                % i.e. if there is a design and if the detrend was done in preprocessing
                n_cond = length(PRT.group(g).subject(s).modality(m).design.conds);
                hrf_delay=floor(3/(PRT.group(g).subject(s).modality(m).design.TR/1000));
                for c = 1:n_cond
                    cond_prefix = ['_c' int2str(c)];
                    filename = [prt_dir group_prefix subj_prefix mod_prefix cond_prefix];
                    examples_list = [];
                    n_ons = length(PRT.group(g).subject(s).modality(m).design.conds(c).onsets);
                    for o = 1:n_ons
                        onset = PRT.group(g).subject(s).modality(m).design.conds(c).onsets(o) + hrf_delay;
                        duration = PRT.group(g).subject(s).modality(m).design.conds(c).durations(o);
                        examples_list = [examples_list onset:(onset+duration-1)];
                    end                 
                    test_design = sort(examples_list);
                    if (test_design(end) > n_scans)
                        disp('Error - design exceeds timeseries');
                        break;
                    end
                    img4d=zeros(dim1,dim2,dim3,length(examples_list));
                    for i = 1:length(examples_list)
                        img1d = img_allscans(examples_list(i),:);
                        img3d = reshape(img1d,dim1,dim2,dim3);
                        img4d(:,:,:,i) = img3d;
                    end
                    nii = make_nii(img4d);  
                    save_nii(nii,filename);
                end
                
            % Structural    
            else % design == 0
                % i.e. if there is not a design (e.g. structural)
                img4d = zeros(dim1,dim2,dim3,n_scans);
                for i = 1:n_scans                 
                    img3d = reshape(img_allscans(i,:),dim1,dim2,dim3);  
                    img4d(:,:,:,i) = img3d;
                end
                filename = [prt_dir group_prefix subj_prefix mod_prefix];
                nii = make_nii(img4d);  
                save_nii(nii,filename);
            end
            
            clear img_allscans;
            clear img4d;
            
            step = step+1;
            waitbar(step / (n_groups*n_subjects*n_modalities*3));
        end        
    end
end

delete(h);


% 
% % Function output
% -------------------------------------------------------------------------
out.files{1} = '';
disp('Preprocessing done.')

 return