function out = prt_run_kernel_construction(varargin)
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

% Load PRT.mat and configure some variables
% -------------------------------------------------------------------------
fname = job.infile;
load(char(fname));

%prt_dir=regexprep(char(fname),'PRT.mat', '');
%n_groups     = length(PRT.group);
n_modalities = length(PRT.group(1).subject(1).modality(1));   
n_groups     = length(PRT.group);
n_subjects   = length(PRT.group(1).subject);

% %n = 
% % Initialize
% Kt=zeros(n);
% 
% chunk_size=100000; % number of voxels to process at a time
% chunk_start=1; chunk_end=min(chunk_size,length(l2_mask));
% while chunk_start < length(l2_mask)
%     disp ([' > processing voxels: ', num2str(chunk_start),' - ',num2str(chunk_end),' ...']);
%     
%     chunk_mask=l2_mask(chunk_start:chunk_end);
%     
%     data_vols=zeros(length(chunk_mask),n);
%     % Load data from all subjects
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     for s=1:n_subjects,
%         %disp([' >> subject: ',num2str(s)]);
%         scan_range1=(s-1)*n_task*n_scans_s+1:(s-1)*n_scans_s*2+n_scans_s;
%         scan_range2=scan_range1+n_scans_s;
%         
%         % load class 1
%         load ([prefix_group1,subjects(s,:),suffix_group1]);
%         data_vols(:,scan_range1) = class_n(chunk_mask,:);
%         clear class_n;
%         
%         % load class 2
%         load ([prefix_group2,subjects(s,:),suffix_group2]);
%         data_vols(:,scan_range2)=class_n(chunk_mask,:);
%         clear class_n;
%     end
%     
%     % Add this chunk's contribution to the Kernel matrix
%     Kt = Kt + (data_vols' * data_vols);
%     
%     chunk_start=chunk_end+1; chunk_end=min(chunk_start+chunk_size-1,length(l2_mask));
% end
% 
% % Mean centre
% C=ones(n,1);
% R=eye(n)-C*pinv(C);
% Kt=R'*Kt*R;

% Function output
% -------------------------------------------------------------------------
out.files{1} = '';
disp('Kernel construction done.')
end
