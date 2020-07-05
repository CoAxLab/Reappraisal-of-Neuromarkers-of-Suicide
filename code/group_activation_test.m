function [aff_avgMpsc, con_avgMpsc] = group_activation_test(config)

  % Run the standard configuration file
  run(['./' config '.m']);

  % Load subject ID list
  load(in_common); % common aff_subj con_subj
  aff_subj = aff_subj(aff_subj2use);
  con_subj = con_subj(con_subj2use);

  % Pull the activation values for all words and all voxels
  % across the subject groups
  
  aff_avgMpsc = [];
  for sub = 1:length(aff_subj)
    % Subject's adjusted percent signal change.
    load([pd 'data/adjMpsc/' aff_subj{sub} '_avgMpsc.mat']);

    % cols = words2use (6 for now)
    % sub = subject
    s2n = median(avgMpsc(words2use,:),2)' ./ std(avgMpsc(words2use,:),[],2)';
    aff_avgMpsc = [aff_avgMpsc; s2n];
  end

  con_avgMpsc = [];
  for sub = 1:length(con_subj)
    % Subject's adjusted percent signal change.
    load([pd 'data/adjMpsc/' con_subj{sub} '_avgMpsc.mat']);

    % cols = words2use (6 for now)
    % sub = subject
    s2n = median(avgMpsc(words2use,:),2)' ./ std(avgMpsc(words2use,:),[],2)';
    con_avgMpsc = [con_avgMpsc; s2n];
    
  end
  
 