function [H HN sorted_regions] = prt_region_histogram(beta, atlas, fig)

%% L1-HISTOGRAM
% (c) Luca Baldassarre
% CS Dept, UCL, London, UK
% 8th May 2012
% l.baldassarre@cs.ucl.ac.uk
% baldazen@gmail.com
%
% Atlas-based region histograms.
%
% For each column of beta, l1_histogram(beta, atlas) computes the relative amount of
% the l1_norm that is contained in each region defined by the atlas.
% Atlas is a nx1 vector, where n = size(beta,1), such that atlas(i) is the
% region to which voxel i belongs.
%
% H = l1_histogram(beta, atlas) only computes the standard histogram
%
% [H HN] = l1_histogram(beta, atlas) also computes the normalized
% histogram, where each bin is normalized by the region's volume (i.e. the
% number of voxels it contains).
%
% [H HN sorted_regions] = l1_histogram(beta, atlas) return the list of
% regions, sorted in descending order according to the normalized
% histogram.
% 
% l1_histogram(beta,atlas,fig) also plots the histogram(s) if fig == 1;
%

if nargin < 3
   fig = 0;
end
% Number of vectors
m = size(beta, 2);
% Number of regions
R = max(atlas);
% Initial region index
r_min = min(atlas);
% Add an offset to account for matlab indexing (it starts from 1)
if r_min == 0
   correction = 1;
else
   correction = 0;
end

H = zeros(R,m);

for km = 1:m
   l1_norm = norm(beta(~isnan(beta(:,km)),km),1);
   disp(['Fold ',num2str(km)])
   % Compute relative frequencies for each region
   for r = r_min:R
      H(r+correction,km) = sum(abs(beta(atlas == r,km)))/l1_norm;
   end
end

%% COMPUTE NORMALIZED HISTOGRAMS AND FULL INTERSECTION
if nargout > 1
   % Compute volumes according to atlas
   volume = zeros(R,1);
   for r = r_min:R
      volume(r+correction) = sum(atlas == r);
   end
   HN = H./repmat(volume,1,m);
end

%% SORT REGIONS in DECREASING ORDER ACCORDING TO NORMALIZED HISTOGRAM
if nargout > 2
   [dummy sorted_regions] = sort(HN,'descend');
   % Translate back to original indeces (0 = CSF)
   sorted_regions = sorted_regions - correction;
end
%% PLOT HISTOGRAMS
if fig
   figure,
   if nargout > 1
      [AX,H1,H2] = plotyy(r_min:R, H, r_min:R, HN);
      set(AX,'FontSize',16);
      set(H1,'LineWidth',2,'LineStyle','-');
      set(H2,'LineWidth',2,'LineStyle','--');
      set(get(AX(1),'Ylabel'),'String','Standard histogram','FontSize',16);
      set(get(AX(2),'Ylabel'),'String','Normalized histogram','FontSize',16);
      % Create legend
      str_legend = cell(2*m,1);
      for km = 1:m
         str_legend{km} = ['Standard: Map ',num2str(km)];
         str_legend{m+km} = ['Normalized: Map ',num2str(km)];
      end
      legend(str_legend);
      %legend('HISTOGRAM','NORMALIZED HISTOGRAM');
   else
      plot(r_min:R, H, 'LineWidth',2)
      set(gca,'FontSize',16);
      %legend('HISTOGRAM','NORMALIZED HISTOGRAM');
   end
   
   xlabel('Region','FontSize',16);
   title('ATLAS-BASED REGION HISTOGRAM','FontSize',20);
end