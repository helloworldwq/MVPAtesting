function agregate_andsave_anatomical_results_from_all_subs()
reslts_dir = fullfile('..','..','results','results_VocalDataSet_anatomical_AR6_FFX_ND_norm_100-shuf'); 
resultfiles = findFilesBVQX(reslts_dir,'results_VocalDataSet_anatomical*.mat'); 
for i = 1:length(resultfiles)
    start = tic;
    load(resultfiles{i},'ansMat','idxslabelsout','idxsout','mask','locations','subnum');
    ansMatRaw(:,:,i) = ansMat; 
    subnums(i) = subnum;
    fprintf('sub %d done in %f\n',subnum,toc(start)); 
end
save(fullfile(reslts_dir,'all_ans_mats.mat'),'ansMatRaw','idxslabelsout','idxsout','mask','locations','subnums');
end