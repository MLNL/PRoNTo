function prt_build_region_weights(weight_fname,atlas_fname)
%
%function to compute the weights for each region as specified by the atlas
%image (one value per region). Weights not in the atlas are comprised in an
%additional region with name 'others'.
%--------------------------------------------------------------------------
%input: name of the weights image (weight_fname), name of the atlas image 
%       (atlas_fname)
%output: -image file with the normalized weights in each region, which can
%         be viewed in the results GUI as a weight image.
%        -.mat file containing the weights of each ROI, in %, pH, the
%        normalized weights for each region, in %, pHN and the list of
%        region names.
%        -GUI giving the possibility of viewing the weights for each ROI
%        and sorting the regions by pH or pHN.
%        (display for average across folds).
%--------------------------------------------------------------------------
%Written by Jessica Schrouff, 19/09/2012
%for PRoNTo


%select weight map
if nargin<1
    f=spm_select(1,[],'Select weight map',[],pwd,'.img');
else
    f=weight_fname;
end

%select atlas
if nargin<2
    gi=spm_select(1,'image','Select atlas');
else
    gi=atlas_fname;
end

%get names of regions if .mat with cells present in the same directory
[a,b]=fileparts(gi);
try
    load(fullfile(a,[b,'.mat']))
    try
        LR=ROI_names;
    catch
        disp('No variable ROI_names found, generic names used')
    end
catch
    fname=spm_select(1,'.mat','Select the file containing the names of the ROIs');
    if isempty(fname)
        disp('No file containing the names of the ROIs found, generic names used')
        LR=[];
    else
        load(fname)
        try
            LR=ROI_names;
        catch
            disp('No variable ROI_names found, generic names used')
        end
    end
end


%resize atlas if needed
%--------------------------------------------------------------------------

%load images
V=spm_vol(f);
V1=spm_vol(gi);
dumb=V(1);

if ~any(dumb.dim == V1.dim)
    disp('Resizing atlas--------->>')
    %reslice
    fl_res = struct('mean',false,'interp',0,'which',1,'prefix','resized_');
    spm_reslice([dumb V1],fl_res);

    %build updated atlas
    [V1_pth,V1_fn,V1_ext] = spm_fileparts(V1.fname);
    rV1_fn = [fl_res.prefix,V1_fn];

    if strcmp(V1_ext,'.nii')
        V_in = spm_vol(fullfile(V1_pth,[rV1_fn,'.nii']));
        V_out = V_in; V_out.fname = fullfile(V1_pth,[rV1_fn,'.img']);
        spm_imcalc(V_in,V_out,'i1');
    end

    %put the files into the PRT directory
    mfile_new=['resized_',V1_fn];
    pp=spm_fileparts(f);
    movefile(fullfile(V1_pth,[rV1_fn,'.img']), ...
    fullfile(pp,[mfile_new,'.img']));
    movefile(fullfile(V1_pth,[rV1_fn,'.hdr']), ...
    fullfile(pp,[mfile_new,'.hdr']));
    g=spm_vol(fullfile(pp,[mfile_new,'.img']));
    h=spm_read_vols(g);
else
    h=spm_read_vols(V1);
end


%compute histogram
%--------------------------------------------------------------------------
w=zeros(V(1).dim(1)*V(1).dim(2)*V(1).dim(3),length(V));
VV=spm_read_vols(V);
nfold=size(VV,4)-1;
for i=1:nfold+1  %number of folds + average
    tmp=VV(:,:,:,i);
    w(:,i)=tmp(:);
end
clear tmp

atlas=h(:);
atlas(isnan(w(:,1)))=NaN;

disp('Computing weights in each ROI--------->>')
[H HN] = prt_region_histogram(w, atlas);
nr=size(H,1);
%compute proportions as in PCA
r_min=min(atlas);
R=max(atlas);
if r_min==0
    corr=1;
    LR=[{'others'};LR];
else
    corr=0;
end

%get the sorted names of corresponding ROIs
if numel(LR)~=size(H,1)
    disp('list does not contains as many names as ROIs, generic names used')
    LR=[];
    if corr
        ei=size(HN,1)-1;
        LR={'others'};
    else
        ei=size(HN,1);
    end
    for i=1:ei
        LR=[LR;{['Region ',num2str(i)]}];
    end
end

%sum of weights in each region
pH=H*100;
%compute the rank of each region according to the weights 
[dub,ih]=sort(pH,1,'descend');
[d1,dw]=sort(ih);
%ranking distance between each fold and the "average" fold
drw=zeros(1,nfold); 
for ifold=1:nfold
    drw(ifold)=prt_comp_ranking_dist(dw(:,ifold),dw(:,end));
end
%Expected value of the rank for each region
rw=zeros(nr,1);
for i=1:nr
    for j=1:nr
        tmp=length(find(dw(i,:)==j));
        rw(i)=rw(i)+j*tmp;
    end
end
rw=rw/nfold;
     

%normalized sum of weights in each region
inn=find(~isnan(HN(:,1)));
shn=sum(HN(inn,:));
pHN=(HN./repmat(shn,size(HN,1),1))*100;

%compute the rank of each region according to the weights 
[d1,d2]=sort(pHN,1,'descend');
isn=find(isnan(pHN(:,1)));
d3=1:length(isn);
d4=length(isn)+1:size(d1,1);
ihn=[d2(d4,:);d2(d3,:)];
[d1,dwn]=sort(ihn);
%ranking distance between each fold and the "average" fold
drwn=zeros(1,nfold); 
for ifold=1:nfold
    drwn(ifold)=prt_comp_ranking_dist(dwn(:,ifold),dwn(:,end));
end
%Expected value of the rank for each region
rwn=zeros(nr,1);
for i=1:nr
    for j=1:nr
        tmp=length(find(dwn(i,1:end-1)==j));
        rwn(i)=rwn(i)+j*tmp;
    end
end
rwn=rwn/nfold;


%build new image with the normalized weights and save values
%--------------------------------------------------------------------------

[a,b,c]=fileparts(dumb.fname);
[a1,b1]=fileparts(gi);

% if image exists, overwrite
if exist(fullfile( ...
        a,['atlas_',b1,'_',b,'.img']),'file')
    disp('Image of normalized weights per region already exists, overwriting...')
end

%save sorted H, HN and the list of corresponding ROIs
W_roi=pH;
NW_roi=pHN;
save(fullfile(a,['atlas_',b1,'_',b,'.mat']),'LR',...
    'W_roi','NW_roi','dw','dwn','rw','rwn','drw','drwn');

img_name=[a,filesep,'atlas_',b1,'_',b,c];
img4d = file_array(img_name,size(VV),'float32-le',0,1,0);
for km=1:size(w,2)
    for r=r_min:R
        w(atlas == r,km)=pHN(r+corr);
    end
    img4d(:,:,:,km)=reshape(w(:,km),[size(VV,1),size(VV,2), size(VV,3),1]);
end


% Create weigths file
%--------------------------------------------------------------------------
disp('Creating image--------->>')
No         = V(1).private;     % copy header
No.dat     = img4d;            % change file_array
No.descrip = 'Pronto weigths'; % description
create(No);                    % write header
disp('Done.')

% Displays (on the average across folds only)
%--------------------------------------------------------------------------
prt_ui_results_ROI('UserData',{LR,pH,pHN,drw,drwn,rw,rwn});

