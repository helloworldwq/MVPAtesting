function Tstat = calcTstatDirectional(delta)
% compute some base values
traceR2 = @(x) trace(x'*x);
getDiag = @(x) (1./x) .*(eye(size(x)));
getDiagSqrt = @(x) (eye(size(x))).* repmat(1./sqrt(diag(x)),[1,size(x,1)]);
covDelta = cov(delta);

% alternate faster computation of corrDelta
covvDeltaSqrt = getDiagSqrt(covDelta);
corrDelta = covvDeltaSqrt * covDelta *  covvDeltaSqrt;
meanDelta = mean(delta);
traceR2ofCorrDelta = traceR2(corrDelta);
N = size(delta,1);
n = N-1;
p = size(delta,2);
%% calculate stat Muni meng:
numerator = N * meanDelta * getDiag(covDelta) * meanDelta' - (n*p/(n-2));
denminatr = 2*(traceR2ofCorrDelta - (p^2/n));
cPn = 1 +  ( traceR2ofCorrDelta/ (p^(3/2)) );
Tstat = numerator / sqrt(denminatr * cPn); % M&M
end