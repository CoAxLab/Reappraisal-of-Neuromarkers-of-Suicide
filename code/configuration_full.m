% stab-based locations
% main : group_membership.m
% uses specified: words; locations; descriptors

% configuration parameters for multiple analysis functions
    % root installation directory, with code and data subdirs
    pd = '../';

    in_common = '../data/common_info.mat';
    aff_subj2use = [1:17];
    con_subj2use = [1:17];
    % stab clusters locations per group
% $$$     in_aff_clusters = ['../data/aff_stabLocations.mat'];
% $$$     in_con_clusters= ['../data/con_stabLocations.mat'];
    in_aff_clusters = ['../data/aff_stabLocations'];
    in_con_clusters= ['../data/con_stabLocations'];
% clusters (numbered, in decreasing nvox order)
% aff: 11 con: 14
% the most predicitve locations:
   %loc_aff2use = [11 9];
   loc_aff2use = -1;
   loc_con2use = -1;
   descriptor = 'xyz_cluster';

% configuration parameters for the construction of images
% voxel selection
   nvox = 5; % select nvox best voxels in each sphere
   minnvox =2;% no less than minnvox
   vsel = 'stab30'; % use the most stable (30) voxels
   data2use = 'words2use'; % if this one, then also specify words2use
   %words2use = [2 12 15 23 18 29];
   words2use = [1:30];
   %death carefree good cruelty praise trouble - the most predictive concepts

% classification parameters
% use only most different features (t-test value)
% selector is % of features to use
selector = 0.5;
