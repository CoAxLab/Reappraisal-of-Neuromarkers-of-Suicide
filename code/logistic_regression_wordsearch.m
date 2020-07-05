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

      n_regions = size(fimage,2)./k;

      word_ind = repmat(words2use, 1, n_regions);

      % Average across regions
      x = [];
      for word = 1:length(words2use);
          x(:,word) = mean(fimage(:,find(word_ind==words2use(word))),2);
      end

      % Run the logistic regression
      [betas, dev, stats] = mnrfit(x, labels);

      rss = sum([stats.resid(:,1)+stats.resid(:,2)].^2);

      % Store the deviance for the run
      dev_list(w) = dev;
      rss_list(w) = rss;
    end;

    % Find the best feature from this run
    best_term = find(dev_list == min(dev_list));

    if length(best_term) > 1
        % if tie, go with the model with the smallest RSS?
       %keyboard;
       best_term = best_term(1);
    end

    % In logistiic regression dev = -2*log(L(\betas));
    k_len_aic(k) = 2*k + dev_list(best_term);


    % update the lists for the next round
    primelist = [primelist wordlist(best_term)];
    wordlist = setdiff(wordlist,wordlist(best_term));

    clear dev_list rss_list;

    %if k > 1 & (k_len_aic(k-1)<k_len_aic(k) | isempty(wordlist));
    if isempty(wordlist)
      isDone=1;
    else
      k=k+1;
    end;
  end;

return;

%%%%%%%%%% sub-functions %%%%%%%%%%%%%%%
% function f = sub_get_loc_struct(in,loc,descriptor);
%   load(in);
% % $$$   clusters           1x14             81336  struct
% % $$$   common         21828x3             523872  double
% % $$$   nclusters          1x1                  8  double
%   if loc == -1;
%       loc = 1:length(clusters);
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
