function MAIN_compute_non_directional_second_level_Power_Verification()
% This function computes second levele results 
%% set params 
params.results_dir      = fullfile('..','..','results');
params.reslts_fold      = 'results_VocalDataSet_FIR_AR6_FFX_ND_norm_400-shuf_SLsize-27'; 
params.reslts_fold      = 'results_VocalDataSet_avg-abs-vals_linear_FIR_AR6_FFX_ND_repart-mode-rand_400-shuf_SLsize-27_folds-5';
params.outfold          = fullfile(params.results_dir,params.reslts_fold,'2nd_level','power');
params.srch_str         = 'results_VocalDataSet_*sub_-*.mat';
params.srch_str_file    = 'results_VocalDataSet_*sub_-%.3d_*.mat';
params.fold_rng         = 1; 
params.numMaps          = 5e3;
params.numsubschs       = 20; 
params.modeuse          = 'new-weight';% mode = 'equal-zero'; % mode = 'equal-min'; % mode = 'weight';

%% 
% get subs 
mkdir(params.outfold); 
save(fullfile(pwd,'params_power.mat'),'params');
startmatlab = 'matlabr2015a -nodisplay -nojvm -singleCompThread -r '; % matlab version used to run in parallel
for i = 2%:10
    if isunix 
        subnum = substorun(i);
        runprogram  = sprintf('"run computeFFXresults_power_verification(%d); exit;" ',i);
        pause(0.1);
        unix([startmatlab  runprogram ' &'])
    else
        computeFFXresults_power_verification(i);
    end
end

end

