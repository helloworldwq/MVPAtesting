function reportZeroVoxels()
datadir = fullfile('..','..','data','stats_normalized_sep_beta_ar3'); 
ff = findFilesBVQX(datadir,'*.mat'); 
load('idxs_from_havard_cambridge_atlas.mat'); 
for i = 1:length(ff)
    load(ff{i}); 
    for j = 1:length(idxsout)
        datatemp = data(:,idxsout{j,1});
        zerovoxes(j,i) = sum(sum(datatemp,1)==0);
        remvoxes(j,i) = size(datatemp,2)-zerovoxes(j,i);
    end
end

end