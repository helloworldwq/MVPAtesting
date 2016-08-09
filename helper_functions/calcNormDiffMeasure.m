function normdiff   = calcNormDiffMeasure(deltabeam)
% input data is sphers x subs
% move to 2 D (27xSubs);

% average of norms: 
avgofnorms = mean(sqrt(sum(deltabeam.^2,1)));
% norm of average: 
normofavg = norm(mean(deltabeam,2));
% norm diff 
normdiff = 1/abs(avgofnorms - normofavg) ;

end