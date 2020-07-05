function [meanacc,full_acc] = group_membership_emotions()
  % the main function for ideator-control group membership classification
  % based on the regression weights of 4 emotions for 6 discriminating
  % concepts
  % Example:
  %  [meanacc, full_acc]=group_membership_emotions;
  % produces the overall accuracy meanacc = 0.8529
  % full_acc is a column variable with 1 for correctly classified
  % subjects and 0 for misclassified subjects; subjects are arranged as
  % 17 ideators, then 17 controls.
  % The code also prints the accuracy (1 -correct, 0 - misclassified)
  % for each of the leave-one-subject-out classification folds

  infile = '../data/regression_weights.txt';
  % obtain feature matrix (emotions regression weights) for all participants
  fimage = sub_read_regression_weights(infile);

  aff_subj = [1:17]'; % the first 17 participants are affected
  con_subj = [18:34]';% the following 17 participants are controls
  allsubj = [aff_subj; con_subj];

  % the affected subjects are labelled as 1, controls as 2
  labels = [ones(length(aff_subj),1); ones(length(con_subj),1)*2];
  list = 1:length(allsubj);
  acc = zeros(length(allsubj),1);

  % cycle through the subjects
   % leave one subject out cross-validation
   for s = list
       % split data into training and test set
      testind = s;
      trainind = list~=s;
      testimage = fimage(testind,:);
      trainimage = fimage(trainind,:);
      testlabel = labels(testind);
      trainlabel = labels(trainind);

      [classifier]=trainClassifier( trainimage, trainlabel, ...
                                    'nbayesPooled', {});
      [predictions]=applyClassifier(testimage, classifier);

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
   end % subject cycle
   fprintf('\n');
   full_acc = acc;
   meanacc = sum(full_acc)/length(full_acc);
   fprintf('Mean group membership classification accuracy: %3.2f\n',...
           meanacc);


function fimage =  sub_read_regression_weights(in);
% file format: tab-separated, for each participant and 6 concepts,
% the regression weights of 4 emotions:
% $$$ Participant     Concept sadness shame   anger   pride
% $$$ 1       death   -2.10   1.31    -1.40   -4.00
% $$$ 1       carefree        -2.55   -2.37   0.80    -1.21
% $$$ 1       good    -6.02   0.71    -0.38   -0.93
% $$$ 1       cruelty 6.87    1.09    -2.67   -3.25
% $$$ 1       praise  -5.09   0.59    4.48    0.30
% $$$ 1       trouble 0.11    1.11    -0.79   -3.87
% $$$ 2       death   3.46    1.75    -0.29   -0.92

% fimage format:
% One line per subject,
% [death(4 emotions) carefree(4 emotions) ...]

[subject,concept,sadness,shame,anger,pride] = textread(in,'%d%s%f%f%f%f', ...
                             'headerlines',1,'delimiter','\t');
matr = [sadness shame anger pride];
nsubj = length(unique(subject));
nconc = length(unique(concept));
nemot = size(matr,2);

fimage = zeros(nsubj,nconc*nemot);
for s = 1:nsubj
  sind = (s-1)*nconc+[1:nconc];
  ms =matr(sind,:);
  fimage(s,:) = reshape(ms',1,nconc*nemot);
end
