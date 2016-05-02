function plot_ruti_pvals(rutiPs,allpvals,uval,figfold,ARorder)
sigfdr = fdr_bh(rutiPs,0.05,'pdep','yes');
titlestr = sprintf('%d subs , u = %f , AR(%d)',...
                    size(allpvals,2),uval,ARorder);
     
%% plot box plots of pvalues (non ruti p values, raw p values) 
figure;
hbox = boxplot(allpvals');
ax = gca;
ax.XTickLabelRotation = 70;
h=findobj(gca,'tag','Outliers'); % Get handles for outlier lines.
% make nice
title(titlestr); 
xlabel('area index'); 
end