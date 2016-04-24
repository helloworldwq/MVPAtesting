function MAIN()
%% Quantifying spatial pattern similarity in multivariate analysis using functional anisotropy
% if you just want code to see how Multi-T and FuA work on random data so
% you can quickly apply the functions in your own pipeline 
% see function - "example_on_toy_data_set.m". 
% this code runs an a-z version as described in the manuscript but on sample data. 
% it allows you to examine inputs and outputs to the main functions used
% while comput

setting_up() % add spm path, download data set, create folder structure, unzip data
pre_process_and_estimate_betas() % Choose "1" pre process SPM data - this is mainly using modifed code punlished here: https://openfmri.org/dataset/ds000158/ (under 'workflow'); 
pre_process_and_estimate_betas() % Choose "2"   you must run model estimation. 
codeToFlattenVocalDataSet_AR3() % flatten .nii from 3D to 2D for next steps  
run_multi_t_non_directional(); % T 2013
run_multi_t_directional(); % T 2008
run_FuA_analysis(); % run FuA analysis 
end