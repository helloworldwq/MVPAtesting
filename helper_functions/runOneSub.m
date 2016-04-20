function runOneSub(subNum,runwhat)
dataLocation = '/home/hezi/roee/vocalDataSet/extractedDataVocalDataSet';
gp_folder = '/home/rack-hezi-03/home/roigilro/vocalDataSetSPM_preproc/2nd_level_analyses';
script_folder = '/home/rack-hezi-03/home/roigilro/vocalDataSet/workflow/workflow'; 
path2ad = genpath(script_folder);
addpath(path2ad);
cd(script_folder);
srchPtrn = sprintf('sub*%s*',subNum);
%subject = findFilesBVQX(dataLocation,srchPtrn,struct('dirs',1));
subject = {fullfile(dataLocation,sprintf('sub%s_Ed',subNum))};

script_folder = pwd; 

%try
switch runwhat
    case 1 
        First_level_block_analysis_stats_only_ar3(subject,script_folder,gp_folder)
    case 2 
        First_level_block_analysis(subject,script_folder,gp_folder)
end 

end
