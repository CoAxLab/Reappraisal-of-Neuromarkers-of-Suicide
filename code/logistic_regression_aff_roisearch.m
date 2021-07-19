function [primelist, k_len_aic] = logistic_regression_aff_roisearch(config, scram_ind)

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
  roilist = 1:11;
  primelist = [];

  % Make an empty structure for the control group
  null_con.cubes = [];
  null_con.ccubes = [];  

  % Start a counter for the loop
  k = 1;

  % Termination flag
  isDone = 0;

  % Load the data matrix
  f_aff = sub_get_loc_struct(in_aff_clusters,...
                                    loc_aff2use,descriptor);
  f_aff = sub_filter(f_aff,common);

  
  while ~isDone

    for r = 1:length(roilist)
      fprintf(sprintf('k=%d, r = %d\n',k,r));
      regions2use = [primelist roilist(r)];
  
      subset_f_aff = f_aff;
      subset_f_aff.cubes = f_aff.cubes(regions2use);
      subset_f_aff.ccubes = f_aff.ccubes(regions2use);

      [fimage,aff_subj,con_subj,voxel_set]=construct_images(config,subset_f_aff,null_con,...
          'words2use',words2use);

      % Revision: Do not collapse across regions
      x = fimage;
      n = size(x,1); 
      p = size(x,2);
      
      % Run the logistic regression
      try
	# If running Matlab use mrnfit
	[betas, dev] = mnrfit(x, labels);

      catch
	# Otherwise, use logistic_regression in Octave
	x = [ones(size(x),1) x];
	
	try 
	  [~,betas, dev] = logistic_regression(labels,x);
	catch
	  dev = Inf; # If model fails to converge
	end
	
      end;

      % Store the AIC for the run: DEV = -2*ln(L)
      % AIC for logistic: -(2/N)*L + 2(p/N)      
      aic_list(r) = dev + 2*(p/n);
      
    end;

    % Find the best feature from this run
    best_region = find(aic_list == min(aic_list));

    # If a tie take the first one
    if length(best_region) > 1
       best_region = best_region(1);
    end

    % Keep the best AIC value
    k_len_aic(k) = aic_list(best_region);

    % update the lists for the next round
    primelist = [primelist roilist(best_region)];
    roilist = setdiff(roilist, roilist(best_region));

    clear aic_list;

    if isempty(roilist)
      isDone=1;
    else
      k=k+1;
    end;
  end;

return;


