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

fname = job.infile;
load(char(fname));
n_groups = length(PRT.group);
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


% -------------------------------------------------------------------------
% Load images, keep NaNs coordinates and build a data matrice per modality
% -------------------------------------------------------------------------

for m=1:n_modalities
    sample_img{m} = load_nii(PRT.group(1).subject(1).modality(m).scans{1});
    sample_name{m} = PRT.group(1).subject(1).modality(m).scans{1};
%     for g = 1:n_groups
%         for s = 1:n_subjects
%             % eval(['data_matrix_',int2str(g),'_',int2str(s),'_',int2str(m) '= []']);
%             disp('teste');
%         end
%     end
end

nan_indices = [];

h = waitbar(0,'Please wait while images are loaded ... ');
step=0;
for g = 1:n_groups
    disp(['Loading group ' int2str(g)]);
    n_subj = length(PRT.group(g).subject);
    for s = 1:n_subj
        disp(['Loading subject ' int2str(s)]);
        n_mod = length(PRT.group(g).subject(s).modality);
        for m = 1:n_mod
            disp(['Loading modality ' int2str(m)]);                  
            n_scans = length(PRT.group(g).subject(s).modality(m).scans);
            for sc = 1:n_scans
                step = step+1;
                nii = load_nii(PRT.group(g).subject(s).modality(m).scans{sc});
                if size(nii.img) ~= size(sample_img{m}.img)
                    disp (['Error - Scan ' int2str(sc) 'Modality ' int2str(m) 'Subject ' int2str(s) 'Group ' int2str(g) ' has wrong dimensions']);
                    break;
                else
                    img = double(reshape(nii.img,1,size(nii.img,1)*size(nii.img,2)*size(nii.img,3)));
                    nan_indices = [nan_indices find(isnan(img))];
                    eval(['data_matrix_',int2str(g),'_',int2str(s),'_',int2str(m),'(',int2str(sc),',:)' '= img;']);
                    waitbar(step / (n_groups*n_subj*n_mod*n_scans));
                end
            end
        end
    end
end
delete(h);


% ------------------------------------------------------------------------- 
% Resize, updated and apply masks to data matrices
% -------------------------------------------------------------------------

h = waitbar(0,'Please wait while masks are applied ... ');
step=0;
for m=1:n_modalities
    maskname =  regexprep(char(PRT.masks(m)),',1','');
    if isempty(PRT.masks{m})
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
    aux = double(reshape(mnii{m}.img,1,size(mnii{m}.img,1)*size(mnii{m}.img,2)*size(mnii{m}.img,3)));
    aux(nan_indices) = 0;
    mask{m} = aux;
    for g = 1:n_groups
        for s = 1:n_subjects
            n_scans = length(PRT.group(g).subject(s).modality(m).scans);
            for sc=1:n_scans
                step = step+1;
                eval(['data_matrix_',int2str(g),'_',int2str(s),'_',int2str(m),'(',int2str(sc),',:) = ' 'data_matrix_',int2str(g),'_',int2str(s),'_',int2str(m),'(',int2str(sc),',:) .* mask{m};']);
                waitbar(step / (n_scans*n_subjects*n_groups*n_modalities));
            end
        end
    end
    mnii{m}.img = reshape(mask{m},size(mnii{m}.img,1),size(mnii{m}.img,2),size(mnii{m}.img,3));
    save_nii(mnii{m},newmask_name);
end
delete(h);


% -------------------------------------------------------------------------
% Detrend
% -------------------------------------------------------------------------

h = waitbar(0,'Please wait while timeseries are detrended ... ');
step = 0;
for g = 1:n_groups
    n_subj = length(PRT.group(g).subject);
    for s = 1:n_subj
        n_mod = length(PRT.group(g).subject(s).modality);
        for m = 1:n_mod
            mask_indices = mask{m}>0;
            if (PRT.group(g).subject(s).modality(m).timesr)
                n_scans = length(PRT.group(g).subject(s).modality(m).scans);
                n_voxels_mask = length(mask_indices);
                for v = 1:n_voxels_mask
                    %timeserie = data_matrix{m}(:,mask_indices(v));
                    timeserie = eval(['data_matrix_',int2str(g),'_',int2str(s),'_',int2str(m),'(:,mask_indices(',int2str(v),'));']);
                    aux = detrend(timeserie);
                    eval(['data_matrix_',int2str(g),'_',int2str(s),'_',int2str(m),'(:,mask_indices(',int2str(v),')) = aux;'])
                    step = step+1;
                    waitbar(step / (n_groups*n_subj*n_mod*n_voxels_mask));
                end
            end
        end
        waitbar(step / n_subj);
    end
end
delete(h);


% -------------------------------------------------------------------------
% Save pre-processed images
% -------------------------------------------------------------------------

h = waitbar(0,'Please wait while pre-processed images are saved ... ');
step = 0;
for g = 1:n_groups
    group_prefix = ['g' int2str(g)];
    n_subj = length(PRT.group(g).subject);
    for s = 1:n_subj
        subj_prefix = ['_s' int2str(s)];
        n_mod = length(PRT.group(g).subject(s).modality);
        for m = 1:n_mod
            mod_prefix = ['_m' int2str(m)];
            n_scans = length(PRT.group(g).subject(s).modality(m).scans);
            if isa(PRT.group(g).subject(s).modality(m).design,'struct') & PRT.group(g).subject(s).modality(m).timesr
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
                    for i = 1:length(examples_list)
                        img1d = eval(['data_matrix_',int2str(g),'_',int2str(s),'_',int2str(m),'(examples_list(',int2str(i),'),:);']);
                        img3d = reshape(img1d,size(mnii{m}.img,1),size(mnii{m}.img,2),size(mnii{m}.img,3));
                        img4d(:,:,:,i) = img3d;
                    end
                    nii = make_nii(img4d);  
                    save_nii(nii,filename);
                    step = step+1;
                    waitbar(step / (n_groups*n_subj*n_mod*n_cond));
                end
            else % design == 0
                filename = [prt_dir group_prefix subj_prefix mod_prefix];
                for i = 1:n_scans
                    img1d = eval(['data_matrix_',int2str(g),'_',int2str(s),'_',int2str(m),'(',int2str(i),',:);']);
                    img3d = reshape(img1d,size(mnii{m}.img,1),size(mnii{m}.img,2),size(mnii{m}.img,3));
                    img4d(:,:,:,i) = img3d;
                end
                nii = make_nii(img4d);  
                save_nii(nii,filename);
                step = step+1;
                waitbar(step / (n_groups*n_subj*n_mod));
            end
            clear img4d;
        end
    end
end
delete(h);



% Function output
% -------------------------------------------------------------------------
out.files{1} = '';
disp('Preprocessing done.')

 return