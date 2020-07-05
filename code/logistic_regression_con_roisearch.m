function [primelist, k_len_aic] = logistic_regression_con_roisearch(config, scram_ind)

  warning off
  run(['./' config '.m']);

  if nargin < 2 | isempty(scram_ind);
    scram_ind = 1:(length(aff_subj2use)+length(con_subj2use));
  end;

  % Grab all the locations. Using
  % full set for this test
  load(in_common)

  % Use all of the stable clusters first
  in_aff_clusters = [in_aff_clusters '.mat'];
  in_con_clusters = [in_con_clusters '.mat'];

   % the affected subjects are labelled as 1, controls as 2
  labels = [ones(length(aff_subj),1); ones(length(con_subj),1)*2];
  labels = labels(scram_ind);


  % First cycle throught the stable aff clusters
  % Start word search
  roilist = 1:14;
  primelist = [];

  % Make an empty structure for the control group
  null_aff.cubes = [];
  null_aff.ccubes = [];  

  % Start a counter for the loop
  k = 1;

  % Termination flag
  isDone = 0;

  % Load the data matrix
  f_con = sub_get_loc_struct(in_con_clusters,...
                                    loc_con2use,descriptor);
  f_con = sub_filter(f_con,common);

  
  while ~isDone

    for r = 1:length(roilist)
      fprintf(sprintf('k=%d, r = %d\n',k,r));
      regions2use = [primelist roilist(r)];
 
      subset_f_con = f_con;
      subset_f_con.cubes = f_con.cubes(regions2use);
      subset_f_con.ccubes = f_con.ccubes(regions2use);

      [fimage,aff_subj,con_subj,voxel_set]=construct_images(config,null_aff,subset_f_con,...
          'words2use',words2use);

      n_regions = size(fimage,2)./length(words2use);

      regions_ind = repmat(words2use, 1, n_regions);

      % Average across regions
      x = [];
      for region = 1:length(regions2use);
          x(:,region) = mean(fimage(:,find(regions_ind==regions2use(region))),2);
      end

      % Run the logistic regression
      [betas, dev, stats] = mnrfit(x, labels);

      rss = sum([stats.resid(:,1)+stats.resid(:,2)].^2);

      % Store the deviance for the run
      dev_list(r) = dev;
      rss_list(r) = rss;
    end;

    % Find the best feature from this run
    best_region = find(dev_list == min(dev_list));

    if length(best_region) > 1
        % if tie, go with the model with the smallest RSS?
       %keyboard;
       best_region = best_region(1);
    end

    % In logistiic regression dev = -2*log(L(\betas));
    k_len_aic(k) = 2*k + dev_list(best_region);


    % update the lists for the next round
    primelist = [primelist roilist(best_region)];
    roilist = setdiff(roilist, roilist(best_region));

    clear dev_list rss_list;

    %if k > 1 & (k_len_aic(k-1)<k_len_aic(k) | isempty(roilist));
    if isempty(roilist)
      isDone=1;
    else
      k=k+1;
    end;
  end;

return;


