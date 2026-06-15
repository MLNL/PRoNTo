function [atl_mat,ROI_names] = script_build_atlas_from_cell_array(region_list)
if nargin<1 || isempty(region_list)
    beep;
    disp('Import excel file into cell array first')
    return
end
if size(region_list,2)>1
    beep
    disp('Please only provide the list of regions, no other variable')
    return
end
if ~iscell(region_list(1))
    beep
    disp('List of regions must be a cell array')
    return
end
if isstring(region_list{1})
    region_list = cellstr(region_list); % Convert to cell array of characters
end

% Gather ROI names and labels
labs = unique(region_list);
n = numel(labs);

% Build atlas (squareform)
% -------------------------------------------------------------------------
% Initalize matrices
cnt=1;
a = zeros(numel(region_list),numel(region_list));
c = zeros(size(a));

% Loop over each pair of 'networks' and give it a unique number (i.e.
% the same unique number to all regions pertaining to the pair)
labels = cell((n*(n-1))/2 + n,1);
for i=1:n
    indi = ismember(region_list,labs{i});
    for j=i:n
        indj = ismember(region_list,labs{j});
        nroi1 = nnz(indi);
        nroi2 = nnz(indj);
        roi = cnt*ones(nroi1,nroi2);
        
        % Build diagonal matrix (i.e. (i,i) interactions)
        if j==i
            c(indi,indj)= roi;
        end
        a(indi,indj)= roi;
        labels{cnt}=[labs{i},'-',labs{j}];
        cnt=cnt+1;
    end
end

% Maybe regions were not sorted before we built the matrix. This will
% result in a matrix a that is not upper triangular (not symmetric). We
% correct for this with the following:
b = a+a'-c;

% b is now symmetric, and we can extract its upper triangle to match the
% inputs from the connectivity matrix
mask = triu(true(size(b)),1);
atl_mat = b.*mask;
save('atlas.mat','atl_mat');

% Save them in a file for display with the weights
ROI_names = labels;
save('Labels_atlas.mat','ROI_names')