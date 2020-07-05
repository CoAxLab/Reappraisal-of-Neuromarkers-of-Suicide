function f = sub_filter(f,common)
 % add ccubes.xyz and ccubes.ind to the structure f
   for i=1:length(f)
     for j=1:length(f(i).cubes)
       ind1 = find(ismember(common,f(i).cubes(j).shape,'rows'));
       if length(ind1)>0
         f(i).ccubes(j).xyz = common(ind1,:);
         f(i).ccubes(j).ind = ind1;
       else
         f(i).ccubes(j).xyz = [];
         f(i).ccubes(j).ind = [];
       end
     end
   end
return
