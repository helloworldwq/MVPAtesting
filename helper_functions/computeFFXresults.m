function computeFFXresults(subsToExtract,fold,ffxResFold,numMaps)
cnt = 1;
%% extract results from each subject
for i = subsToExtract
    start = tic;
    subStrSrc = sprintf('results_VocalDataSet_FFX_ND_*shuf*%3.3d*.mat',i);
    [firstlevelfold,~] = fileparts(ffxResFold);
    ff = findFilesBVQX(firstlevelfold,subStrSrc);
    load(ff{1})
    fprintf('B = sub %d has %d nans\n',i,sum(isnan(median(ansMat,2))))
    modeuse = 'equal-min'; % modes to deal with zeros also 'equal-zero', 'equal-min' and 'weight'
    ansMat = squeeze(ansMat(:,:,1)); % first val is multi t 2013
    fixedAnsMat = fixAnsMat(ansMat,locations,modeuse); % fix ansMat for zeros
    ansMatOut(:,:,cnt) = fixedAnsMat;
    cnt = cnt + 1;
    fprintf('A = sub %d has %d nans\n\n',i,sum(isnan(median(fixedAnsMat,2))))
end
% find out how many shufs you have
numshufs = size(ansMatOut,2)-1;


%% compute the MSCM maps
[avgAnsMat,stlzerPermsAnsMat] = createStelzerPermutations(ansMatOut,numMaps,'mean');
clear ansMat;

%% save the file
numsubs = size(ansMatOut,3);
[pn,fn]= fileparts(ffxResFold);
fnTosave = sprintf(...
    'ND_FFX_VDS_%d-subs_%d-slsze_%d-fld_%dshufs_%d-stlzer_mode-%s_newT2013.mat',...
    numsubs,...
    params.regionSize,...
    fold,...
    numshufs,...
    numMaps,...
    modeuse);
save(fullfile(ffxResFold,fnTosave),...
    'avgAnsMat','locations',...
    'stlzerPermsAnsMat',...
    'mask','fnTosave','subsToExtract','params');

end
