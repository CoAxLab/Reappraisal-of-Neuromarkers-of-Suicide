function f = sub_get_loc_struct(in,loc,descriptor);
  load(in);
% $$$   clusters           1x14             81336  struct
% $$$   common         21828x3             523872  double
% $$$   nclusters          1x1                  8  double
  if loc == -1;
      loc = 1:length(clusters);
      if exist('mapped_clusters','var')
        clear mapped_clusters
      end;
  end;

  if exist('mapped_clusters','var')
    loc = mapped_clusters;
  end

   i=1; % one "factor" only (stability-based locations)
   for c = 1:length(loc)
    f(i).cubes(c).label = clusters(loc(c)).label;
    f(i).cubes(c).centroid = clusters(loc(c)).centroid;
    f(i).cubes(c).radius = clusters(loc(c)).radius;
    f(i).cubes(c).nvox = clusters(loc(c)).nvox;
    f(i).cubes(c).nuvox = clusters(loc(c)).nuvox;
    f(i).cubes(c).shape = eval(unique(...
      sprintf('clusters(loc(c)).%s;',descriptor),'rows'));
   end
return
