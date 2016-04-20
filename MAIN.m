function MAIN()
%% Multi T main code
% if you just want code to see how Multi-T and FuA work on random data so
% you can quickl apply the functions in your own pipeline 
% see function - "example_on_toy_data_set.m". 

setting_up() % add spm path, download data set, create folder structure, unzip data
pre_process_and_estimate_betas() % pre process SPM data - this is mainly using modifed code punlished here: https://openfmri.org/dataset/ds000158/ (under 'workflow'); 
end