function [primelist, k_len_aic] = logistic_regression_wordsearch(config, scram_ind)

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

  % Start word search
  wordlist = 1:30;
  primelist = [];

  % Start a counter for the loop
  k = 1;

  % Termination flag
  isDone = 0;

  while ~isDone

    for w = 1:length(wordlist)
      fprintf(sprintf('k=%d, w = %d\n',k,w));
      words2use = [primelist wordlist(w)];

      % Load the data matrix
      f_aff = sub_get_loc_struct(in_aff_clusters,...
                                    loc_aff2use,descriptor);
      f_aff = sub_filter(f_aff,common);

      f_con = sub_get_loc_struct(in_con_clusters,...
                                    loc_con2use,descriptor);
      f_con = sub_filter(f_con,common);

      [fimage,aff_subj,con_subj,voxel_set]=construct_images(config,f_aff,f_con,...
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
	x = [ones(size(x,1)) x];
	
	try 
	  [~,betas, dev] = logistic_regression(labels,x);
	catch
	  dev = Inf; # If model fails to converge 
	end;
	
      end;

      % Store the AIC for the run: DEV = -2*ln(L)
      % AIC for logistic: -(2/N)*L + 2(p/N)
      aic_list(w) = dev/n + 2*(p/n);
      
    end;

    % Find the best feature from this run
    best_term = find(aic_list == min(aic_list));

    if length(best_term) > 1
       best_term = best_term(1);
    end

    % In logistiic regression dev = -2*log(L(\betas));
    k_len_aic(k) = aic_list(best_term);


    % update the lists for the next round
    primelist = [primelist wordlist(best_term)];
    wordlist = setdiff(wordlist,wordlist(best_term));

    clear aic_list; 

    if isempty(wordlist)
      isDone=1;
    else
      k=k+1;
    end;
  end;

return;

