function MAIN_compute_non_directional_second_level()
% This function computes second levele results 

results_dir = fullfile('..','..','results');
ffldrs = findFilesBVQX(results_dir,'results_VocalDataSet_FIR_AR6_FFX*',...
    struct('dirs',1));
fprintf('The following results folders were found:\n'); 
for i = 1:length(ffldrs)
    [pn,fn] = fileparts(ffldrs{i});
    fprintf('[%d]\t%s\n',i,fn);
end
fprintf('enter number of results folder to compute second level on\n'); 
foldernum = input('what num? ');
analysisfolder = ffldrs{foldernum}; 
secondlevelresultsfolder = fullfile(analysisfolder,'2nd_level');
mkdir(secondlevelresultsfolder); 

subsToExtract = subsUsedGet(20); % 150 / 20 for vocal data set 
fold = 1; 
numMaps = 5e3;
computeFFXresults(subsToExtract,fold,secondlevelresultsfolder,numMaps)
% computeFFXresults_repart_comp(subsToExtract,fold,secondlevelresultsfolder,numMaps);
end
