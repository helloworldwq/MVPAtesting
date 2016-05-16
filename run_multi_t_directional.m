function run_multi_t_directional()
%% Run T2013 - Directioanl multivariate T-test.
% This function will run directional T-test on all subjects in the
% data set based. It will use the shuffle matrix from the non-directional
% analysis.
% for details re how this analysis is run see paper at https://arxiv.org/abs/1605.03482
% output of the function is stored in the results folder.
% these results are later computed into group level .nii maps using
% function XXX
% Further note:
% This function was written such that it uses matlab's parfor function. 
% It can run a lot faster if you increase the number of cores available for
% the parfor function (see inner function). 
%% secon level (directional analysis uses average to compute first levle) 
MAIN_doSearchLight_Directional_basedOnFFX_ND_stelzer_perms() % Second level  
end