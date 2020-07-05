function [f_aff,f_con, all_locs] = get_brain_locations(config,drop_subj, varargin)
  % Load pre-computed files with stable clusters computed without the
  % subject specified as drop_subject (a number between 1 and 34);
  % the first 17 subjects are the affected ones.

    run(['./' config '.m']);
   
    % Get variable input parameters
    for v=1:2:length(varargin)
        eval(sprintf('%s = varargin{%d};',varargin{v},v+1));
    end
    
    load(in_common); % common
  % figure out which subject is being dropped - affected or control
    if drop_subj < 18 % one of the affected subjects
      drop_aff_subj = drop_subj;
      drop_con_subj = [];
      
      if exist('comb_cluster_set','var')
        in_aff_clusters = [in_aff_clusters '.mat'];
      else
        in_aff_clusters = [in_aff_clusters num2str(drop_aff_subj) '.mat'];
      end 
      
      in_con_clusters = [in_con_clusters '.mat']; % full control group
    else             % one of the control subjects
      drop_aff_subj = [];
      drop_con_subj = drop_subj - 17;
      in_aff_clusters = [in_aff_clusters '.mat']; % full affected group
      
      if exist('comb_cluster_set','var')
        in_con_clusters = [in_con_clusters '.mat']; % full control group
      else          
        in_con_clusters = [in_con_clusters num2str(drop_con_subj) '.mat'];
      end;
    end

  % process locations for the affected group
 if ~isempty(loc_aff2use)
  f_aff = sub_get_loc_struct(in_aff_clusters,...
                                loc_aff2use,descriptor);
  % filter the cuvox arrays through common; add ccubes.xyz and ccubes.ind
  f_aff = sub_filter(f_aff,common);
 else
  f_aff = [];
 end
  % process locations for the control group
 if ~isempty(loc_con2use)
  f_con = sub_get_loc_struct(in_con_clusters,...
                                loc_con2use,descriptor);
  % filter the cuvox arrays through common; add ccubes.xyz and ccubes.ind
  f_con = sub_filter(f_con,common);
 else
   f_con = [];
 end
 
 all_locs = [loc_aff2use loc_con2use];

 return

%%%%%%%%%%% sub-functions %%%%%%%%%%%%%%%
% function f = sub_get_loc_struct(in,loc,descriptor);
%   load(in);
% % $$$   clusters           1x14             81336  struct
% % $$$   common         21828x3             523872  double
% % $$$   nclusters          1x1                  8  double
%   if loc == -1;
%       loc = length(clusters);
%       if exist('mapped_clusters','var')
%         clear mapped_clusters
%       end;
%   end;
% 
%   if exist('mapped_clusters','var')
%     loc = mapped_clusters;
%   end
% 
%    i=1; % one "factor" only (stability-based locations)
%    for c = 1:length(loc)
%     f(i).cubes(c).label = clusters(loc(c)).label;
%     f(i).cubes(c).centroid = clusters(loc(c)).centroid;
%     f(i).cubes(c).radius = clusters(loc(c)).radius;
%     f(i).cubes(c).nvox = clusters(loc(c)).nvox;
%     f(i).cubes(c).nuvox = clusters(loc(c)).nuvox;
%     f(i).cubes(c).shape = eval(unique(...
%       sprintf('clusters(loc(c)).%s;',descriptor),'rows'));
%    end
% return
% 
% function f = sub_filter(f,common)
%  % add ccubes.xyz and ccubes.ind to the structure f
%    for i=1:length(f)
%      for j=1:length(f(i).cubes)
%        ind1 = find(ismember(common,f(i).cubes(j).shape,'rows'));
%        if length(ind1)>0
%          f(i).ccubes(j).xyz = common(ind1,:);
%          f(i).ccubes(j).ind = ind1;
%        else
%          f(i).ccubes(j).xyz = [];
%          f(i).ccubes(j).ind = [];
%        end
%      end
%    end
% return
