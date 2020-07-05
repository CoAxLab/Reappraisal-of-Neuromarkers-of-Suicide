function [fimage,aff_subj,con_subj, voxel_set] = construct_images(config,f_aff,f_con, varargin)
  % construct 1 image per subject using config parameters and f_structures
  % the images consist of first aff locations (factors.cubes), then
  % con locations
    run(['./' config '.m']);

    % Get variable input parameters
    for v=1:2:length(varargin)
        eval(sprintf('%s = varargin{%d};',varargin{v},v+1));
    end
    
    if ~strcmp(data2use,'words2use')
      words2use = [];
    end

    load(in_common); % common aff_subj con_subj
    aff_subj = aff_subj(aff_subj2use);
    con_subj = con_subj(con_subj2use);

    allsubj = [aff_subj; con_subj];

    %main subject cycle
    for s=1:length(allsubj)
      load([pd 'data/adjMpsc/' allsubj{s} '_avgMpsc.mat']);
      % avgMpsc,avgC,common, stab30,stab3
      % use aff locations
      % x = sub_get_image(avgMpsc,common,stab30,stab3, f_con, ...
      %             vsel,data2use,nvox,minnvox,1,words2use);
      [aff_x,n1] = sub_get_image(avgMpsc,common,stab30,stab3, f_aff, ...
                  vsel,data2use,nvox,minnvox,1,words2use);

      % use con locations
      % x = [x sub_get_image(avgMpsc,common,stab30,stab3, f_aff, ...
      %             vsel,data2use,nvox,minnvox,1,words2use)];
      [con_x,n2] = sub_get_image(avgMpsc,common,stab30,stab3, f_con, ...
                  vsel,data2use,nvox,minnvox,1,words2use);

      x = [aff_x con_x];

      % determine the parameters of feature array
      if s==1
        nfeat = length(x);
        fimage = zeros(length(allsubj),nfeat);
      end
      
      fimage(s,:)=x;
      voxel_set(s,:)=[n1(:)' n2(:)'];
        
    end


%%%%%%%%%%% sub-functions %%%%%%%%%%%%%%

function [x,ind_list] = sub_get_image(avgMpsc,common,stab30,stab3,f_group,...
                  vsel,data2use,nvox,minnvox,sgn,words2use)
 % perform image extraction
 x = []; ind_list = [];
      for i=1:length(f_group)
        for j=1:length(f_group(i).ccubes)
        % note that the ccubes length can be different for different f now
          ind = f_group(i).ccubes(j).ind;
          % voxel selection (for now ignore the sign of stability)
          if length(ind) >= minnvox
            if strcmp(vsel,'stab30') % the only option now
              vs_val = stab30(ind);
            elseif strcmp(vsel,'stab3')
              vs_val = stab3(ind);
            else
              disp('Unknown voxel selection method');
              return
            end
            [dummy,ind1] = sort(vs_val,'descend');
            fs_ind = ind(ind1(1:min(nvox,length(ind1))));

            ind_list = [ind_list fs_ind];

            % feature extraction
            if strcmp(data2use,'30_items')
              x = [x mean(avgMpsc(:,fs_ind),2)'];
            elseif strcmp(data2use,'words2use')
              x = [x  mean(avgMpsc(words2use,fs_ind),2)'];
            else
              disp('Unknown data selection method');
              return
            end
          else
            fprintf('Skipping location %d\n',j);
          end
        end
      end
      
return
