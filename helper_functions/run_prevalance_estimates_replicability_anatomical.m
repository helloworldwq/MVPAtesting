function run_prevalance_estimates_replicability_anatomical()
% needs neureolf: 
p = genpath(pwd); 
addpath(p); 
p = genpath('D:\Roee_Main_Folder\1_AnalysisFiles\Poldrack_RFX\toolboxes\NE_5153'); 
addpath(p); 

resultsdir = fullfile('..','..','results','results_VocalDataSet_anatomical_AR6_FFX_ND_norm_100-shuf');
load('idxs_from_havard_cambridge_atlas.mat'); 
load(fullfile(resultsdir,'allPvals_FIR_ar6_150subs.mat')); 

uval = 0.3; 

n = size(allpvals,2); 
u = floor(uval *n);
df = 2 * (n-u+1);

% sum of pvals. 
Ps = [];
for i = 1:size(allpvals,1)
    pvals = allpvals(i,:);
    sortpvals = sort(pvals);
    upvals = sortpvals(u:end);
    upvalslog = log(upvals) * (-2);
    sumus = sum(upvalslog);
    Ps(i) = chi2cdf(sumus,df,'upper');
end
sigfdr = fdr_bh(Ps,0.05,'pdep','yes');
%% plot vmp 
mapcnt = 1; 
rawvmp = get_raw_vmp();
tosavevmp = rawvmp;
dataFromAnsMatBackIn3d = scoringToMatrix(mask,sigfdr',locations);
mapfn = sprintf('ruti analyssis u = %f',uval); 
tosavevmp = addmapTovmp(tosavevmp,rawvmp,dataFromAnsMatBackIn3d,mapfn,mapcnt);

tosavevmp.SaveAs(fullfile(resultsdir,'outvmp.vmp'));
end