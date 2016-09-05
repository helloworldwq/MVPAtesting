function [params, settings] = get_and_set_params()
% This code gets and sets number of shuffels / sl size 
%% set params used 
params.numShuffels      = 400; % number of shuffels (per subject)
params.regionSize       = 27;  % search light size (eucledian distance) 
params.cvfold_folds     = 5;   % cv folds if running SVM analysis 

%% settings (data location etc.) 
% assumes following directory strcuture: 
% main project has 3 folders (case matters!): 
% 'data', 'code' and 'results'
% some things to keep in mind: 
% 1. all code runs from a dir called 'helper_functions' 
%    under the 'code' directory. remember this when using relative dirs. 
% 2. a certain data structure is assumed. see XXX for details. 
% 3. results are written to a directory created under the 'results'
%    directory. 
settings.datadir        = fullfile('..','..','data','stats_normalized_sep_beta_FIR_ar6'); % location of .mat files with data 
settings.fnsearchstr    = 'data_%.3d.mat'; % using 'sprintf' function to load data for each subject 
settings.resprefix      = 'results_VocalDataSet_FFX_ND_norm_'; % prefix to identify results file 
settings.resfoldprefix  = 'results_VocalDataSet_FIR_AR6_FFX_ND_norm_'; % prefix to identify results folder 
settings.pushbullettok  = 'o.6i6t6UA0GYvxXgtKZpVjJUIazDFHeF6e'; % get notification when sub done to cellphone see pushbullet.com 

%% output the params used to screen 
fprintf('Params being used are:\n') ;
fprintf('-- number of shuffles = %d\n',params.numShuffels);
fprintf('-- searchlight size   = %d\n',params.regionSize); 
fprintf('-- To change these params change the:\n-- ''get_and_set_params.m'' function under ''helper_functions''\n');

end