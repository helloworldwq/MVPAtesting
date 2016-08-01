function temp_ploy_dr_nd_ffx_svm()
results_dir = fullfile('..','..','results');
ffldrs = findFilesBVQX(results_dir,'results_VocalDataSet_FIR_AR6_FFX*',...
    struct('dirs',1));
fprintf('The following results folders were found:\n'); 
for i = 1:length(ffldrs)
    [pn,fn] = fileparts(ffldrs{i});
    fprintf('[%d]\t%s\n',i,fn);
end

% folders to analyize 
idxs = [1 3 4 5 ]; 

conds  = {'DR FFX','ND long FFX','ND rand FFX','ND short FFX'};
fnms = {'results_VocalDataSet_FFX_DR_SVM_500-shuf_SLsize-27_folds_-005_.mat',...
    'ND_FFX_VDS_20-subs_27-slsze_1-fld_400shufs_1000-stlzer_mode-equal-min_newT2013',...
    'ND_FFX_VDS_20-subs_27-slsze_1-fld_400shufs_1000-stlzer_mode-equal-min_newT2013',...
    'ND_FFX_VDS_20-subs_27-slsze_1-fld_400shufs_1000-stlzer_mode-equal-min_newT2013'};

% loop 
for i = 1:length(conds)
    load(fullfile(ffldrs{idxs(i)},'2nd_level',fnms{i}))
    hfig = figure; 
    plotpval(pval_multit,1,'multi-t'); 
    plotpval(pval_svm,2,'svm'); 
    suptitle(conds{i});
    saveas(hfig,[conds{i} '.jpeg']);
    close(hfig);
end
end

function plotpval(pval,subplotnum,cond)
sigfdr = fdr_bh(pval,0.05,'pdep','no');
subplot(1,2,subplotnum);
histogram(pval); 
xlabel('pval'); 
ylabel('count'); 
title(sprintf('%s (%d)',cond,sum(sigfdr))); 
end