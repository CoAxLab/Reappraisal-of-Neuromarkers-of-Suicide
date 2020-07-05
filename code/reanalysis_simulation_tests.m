close all; clear all;

% See OriginalReadMe.txt file for information on original script setup.
%
% These functions run thorugh different feature selection tests
% on the leave one out cross validation classifier for group membership
% from Just et al. NHB 2017

% Original code
[meanacc,full_acc] = group_membership('configuration');

% Run forward stepwise search for words, using all regions.
[prime_list, k_len_aic] = logistic_regression_wordsearch('configuration_stepwise_search');
word_list = prime_list(1:find(k_len_aic == min(k_len_aic))); % Last entry is when AIC jumps, so remove

% Run forward stepwise search for affective group regions, using all words
[prime_list, k_len_aic] = logistic_regression_aff_roisearch('configuration_stepwise_search');
aff_region_list = prime_list(1:find(k_len_aic == min(k_len_aic))); % Last entry is when AIC jumps, so remove

% Run forward stepwise search for control group regions, using all words
[prime_list, k_len_aic] = logistic_regression_con_roisearch('configuration_stepwise_search');
con_region_list = prime_list(1:find(k_len_aic == min(k_len_aic))); % Last entry is when AIC jumps, so remove

% Using the forward stepwise search features
[meanacc,full_acc] = group_membership('configuration_fssearch');
 
% Using all words & regions from Just et al. 2017
[meanacc,full_acc] = group_membership('configuration_all_words');

% Using all regions & words from Just et al. 2017
[meanacc,full_acc] = group_membership('configuration_all_regions');

% Using all regions & all words
[meanacc,full_acc] = group_membership('configuration_full');
