function skenessmeasure   = calcSkewnessMeasure(deltabeam)
% input data is sphers x subs
% move to 2 D (27xSubs);

for i = 1:size(deltabeam,2)
    subvec = deltabeam(:,i); 
    repsubvec = repmat(subvec, 1, size(deltabeam,2)-1);
    othersubs = deltabeam(:,1:size(deltabeam,2)~=i);
    diffvec = repsubvec - othersubs;
    avgofnorms_num(i) = sum(sqrt(sum(diffvec.^2,1)));
    diffvec = repsubvec + othersubs;
    avgofnorms_den(i) = sum(sqrt(sum(diffvec.^2,1)));
end
skenessmeasure = 1- sum(avgofnorms_num)/sum(avgofnorms_den);

end