function plotPvalsResults_multiT_vs_SVM()
%% find all results folders:
results_dir = fullfile('..','..','results');
figures_dir = fullfile('..','..','figures');
resultFiles = findFilesBVQX(results_dir,'ND*.mat');

for i = 1:length(resultFiles)
    load(resultFiles{i});
    if exist('avgAnsMat_svm','var')
        plotfig(pval_svm, pval_multit,resultFiles{i},figures_dir);
    else
        continue
    end
    clear avgAnsMat_svm avgAnsMat_multit
end
end

function plotfig(pvals_svm,pvals_multit,fullfilename,figures_dir)
[pn,fn] = fileparts(fullfilename);
hfig = figure('visible','on');
alpha = 0.05; 
%% svm 
subplot(1,2,1); 
histogram(pvals_svm);
sig_svm = fdr_bh(pvals_svm,alpha,'pdep','yes');
title(sprintf('svm pvals across voxels(%d)',sum(sig_svm))); 
xlabel('accuracy');
ylabel('count'); 
%% multit
subplot(1,2,2); 
histogram(pvals_svm);
sig_mtt = fdr_bh(pvals_multit,alpha,'pdep','yes');
title(sprintf('multi-t pvals across voxels (%d)',sum(sig_mtt))); 
xlabel('t values');
ylabel('count'); 
%% save
save(hfig,fullfile(figures_dir,[fn '.jpeg']));
close(hfig); 
end