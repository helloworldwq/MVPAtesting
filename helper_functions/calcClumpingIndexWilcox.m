function clumpIdx = calcClumpingIndexWilcox(meanDeltaPerSub, normalize)
% Option 2 (backup):
% Here is a new measure of multivariate symmetry, in the spirit of [1] and [2], (with some [3]):
% The idea is based on the observation that the Wilcoxon signed rank statistic is sensitive to the break of the symetry of a distribution [3].
% I thus adapt (i.e. simplify) a multivatiate version of the Wilcoxon signed rank. I allow myself to simplify, since we are not interested in inference, but only in the break of symmetry.
% The workflow: 
% (1) First center the data so that we know we are not detecting effects, but merely symmetry breaks.
% (2) Compute the proposed multivariate Wilcoxon in each sphere. 
% (3) Create maps of the generalized Wilcoxon and hope that the RFX only regions are less symmetric than FFX. 
% 
% Computing the measure:
% (1) Compute the pairwise sum of all two voxels (returning (27 choose 2) vectors of dim 27).
% (2) Divide each such vector by its norm. (returning (27 choose 2) vectors of dim 27)
% (3) Take the average of the normalize vectors. (returning 1 vector of dim 27)
% (4) Take the norm of the average. (returning a number).
% 
% The larger the asymmetry, the larger this number.
% 
% [1] Möttönen, Jyrki, and Hannu Oja. “Multivariate Spatial Sign and Rank Methods.” Journal of Nonparametric Statistics 5, no. 2 (January 1, 1995): 201–13. doi:10.1080/10485259508832643.
% [2] Oja, Hannu, and Ronald H. Randles. “Multivariate Nonparametric Tests.” Statistical Science 19, no. 4 (November 1, 2004): 598–605

% input data is sphers x subs 
% move to 2 D (27xSubs); 
% subtract the mean from each sphere:
if normalize
    meansToSubtract = mean(meanDeltaPerSub,1);
    meansToSubtractMat = repmat(meansToSubtract,size(meanDeltaPerSub,1),1);
    centeredSpheresPerSub = meanDeltaPerSub - meansToSubtractMat;
else
    centeredSpheresPerSub = meanDeltaPerSub;
end
% pairse wise sum of all voxels. 
idxPairs = nchoosek(1:size(centeredSpheresPerSub,2),2);
pairWise =  centeredSpheresPerSub(:,idxPairs(:,1)) + ...
    centeredSpheresPerSub(:,idxPairs(:,2));
% divide each pair by norm
normsPerPair = sqrt(sum(pairWise.^2,1));
normsPerPairMat = repmat(normsPerPair,size(pairWise,1),1);
pairwiseDivByNorm = pairWise./normsPerPairMat;
% take average of normalized vector 
avgPairWise = mean(pairwiseDivByNorm,2);
% take the norm of the average: 
clumpIdx = norm(avgPairWise);
end