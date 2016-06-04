function computeFFXresults_repart_comp(subsToExtract,fold,ffxResFold,numMaps)
cnt = 1;
%% extract results from each subject
for i = subsToExtract
    start = tic;
    subStrSrc = sprintf('results_VocalDataSet_FFX_ND_SVM_*shuf*%3.3d*.mat',i);
    [firstlevelfold,~] = fileparts(ffxResFold);
    ff = findFilesBVQX(firstlevelfold,subStrSrc);
    load(ff{1},'ansMat_Multit','ansMat_SVM','locations')
    list = whos('ansMat*'); 
    modeuse = 'equal-min'; % modes to deal with zeros also 'equal-zero', 'equal-min' and 'weight'
    ansMat_Multit_out(:,:,cnt) = fixZerosNans(ansMat_Multit,modeuse,i,locations);
    clear ansMat_Multit
    ansMat_SVM_out(:,:,cnt) = fixZerosNans(ansMat_SVM,modeuse,i,locations);
    clear ansMat_SVM
    cnt = cnt + 1;
end
% find out how many shufs you have
numshufs = size(ansMat_Multit_out,2)-1;


%% compute the MSCM maps
[avgAnsMat_multit,stlzerPermsAnsMat] = createStelzerPermutations(ansMat_Multit_out,numMaps,'mean');
pval_multit = calcPvalVoxelWise(avgAnsMat_multit);
sigfdr_multit = fdr_bh(pval_multit,0.05,'pdep','yes');

[avgAnsMat_svm,stlzerPermsAnsMat] = createStelzerPermutations(ansMat_SVM_out,numMaps,'mean');
pval_svm = calcPvalVoxelWise(avgAnsMat_svm);
sigfdr_svm = fdr_bh(pval_svm,0.05,'pdep','yes');


clear ansMat;

%% save the file
numsubs = size(ansMat_Multit_out,3);
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
    'avgAnsMat_multit','avgAnsMat_svm','pval_multit','pval_svm','sigfdr_multit','sigfdr_svm',...
    'stlzerPermsAnsMat','locations',...
    'mask','fnTosave','subsToExtract','params');

end

function fixedAnsMat = fixZerosNans(ansMat,modeuse,i,locations)
    fprintf('B = sub %d has %d nans\n',i,sum(isnan(median(ansMat,2))))    
    fixedAnsMat = fixAnsMat(ansMat,locations,modeuse); % fix ansMat for zeros
    fprintf('A = sub %d has %d nans\n\n',i,sum(isnan(median(fixedAnsMat,2))))
end
