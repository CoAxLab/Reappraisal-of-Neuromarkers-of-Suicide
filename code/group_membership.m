function [meanacc,full_acc] = group_membership(config, varargin)
  % the main function for ideator-control group membership classification
  % config is specified as 'configuration' for configuration.m
  % Example:
  %  [meanacc, full_acc]=group_membership('configuration');
  % produces the overall accuracy meanacc = 0.9118
  % full_acc is a column variable with 1 for correctly classified
  % subjects and 0 for misclassified subjects; subjects are arranged as
  % 17 ideators, then 17 controls.
  % The code also prints the accuracy (1 -correct, 0 - misclassified)
  % for each of the leave-one-subject-out classification folds

   run(['./' config '.m']);


  % Get variable input parameters                                                                  
  for v=1:2:length(varargin),
    eval(sprintf('%s = varargin{%d};',varargin{v},v+1));
  end

   load(in_common); % common aff_subj con_subj
   clear common
   aff_subj = aff_subj(aff_subj2use);
   con_subj = con_subj(con_subj2use);
   allsubj = [aff_subj; con_subj];

   % the affected subjects are labelled as 1, controls as 2
   labels = [ones(length(aff_subj),1); ones(length(con_subj),1)*2];
   list = 1:length(allsubj);
   acc = zeros(length(allsubj),1);

   % cycle through the subjects
   % leave one subject out cross-validation
   for s = list
      % get the discriminating brain locations for the fold
      % (based on the training subjects)
      [f_aff,f_con, locs] = get_brain_locations(config,s,'loc_aff2use',loc_aff2use,...
      'loc_con2use',loc_con2use);
          

      % construct feature images
      [fimage,aff_subj,con_subj,voxel_set]=construct_images(config,f_aff,f_con,...
      'words2use',words2use);

      
      %region_labels{s} = {f_aff.cubes(1).label, f_aff.cubes(2).label, ...
      %    f_con.cubes(1).label,f_con.cubes(2).label,f_con.cubes(3).label};
      
      % split data into training and test set
      testind = s;
      trainind = list~=s;
      testimage = fimage(testind,:);
      trainimage = fimage(trainind,:);
      testlabel = labels(testind);
      trainlabel = labels(trainind);

      ind = sub_subset_features(trainimage,trainlabel,selector);
      [classifier]=trainClassifier( trainimage(:,ind), trainlabel, ...
                                    'nbayesPooled', {});
      [predictions]=applyClassifier(testimage(ind), classifier);

      % predictions are scores for label 1 (aff) and 2 (con)
      % (Larger value corresponds to the predicted label)
      [~,p] = max(predictions);
      acc(s)= p==testlabel;
      if s==1
          fprintf('Aff subj: ');
      end
      if s==18
          fprintf('\nCon subj: ');
      end
      fprintf('%d',acc(s));

%       training_voxels(:,s) = sort(voxel_set(:));
%       locations(s,:) = locs;
%       all_fimage(:,:,s) = fimage;
      

      clear fimage f_aff f_con
   end % subject cycle
   fprintf('\n');
   full_acc = acc;
   meanacc = sum(full_acc)/length(full_acc);
   fprintf('Mean group membership classification accuracy: %3.2f\n',...
           meanacc);
       
   


function ind = sub_subset_features(trainimage,trainlabel,selector);
 % compute a t-test for all features and select n most distinguishing
 % features, depending on the selector value
   aff_ind = find(trainlabel==1);
   con_ind = find(trainlabel==2);
   [H,P,CI,STATS] = ttest2(trainimage(aff_ind,:),trainimage(con_ind,:));
   t = abs(STATS.tstat); % note - the abs value of t is used
   n = round(length(t)*selector);
   [dummy,ind1] = sort(t,'descend');
   ind = ind1(1:n);
