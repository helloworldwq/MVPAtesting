function computeFFXresults_power_verification(foldnum)
load(fullfile(pwd,'params_power.mat'),'params');
% subsToExtract,fold,ffxResFold,numMaps;
params.fold_rng = foldnum;
params.subsExtract = getSubsPower(params);
start = tic; 
cnt = 1;
%% extract results from each subject
for i = 1:length(params.subsExtract)
    start = tic;
    subStrSrc = sprintf(params.srch_str_file,params.subsExtract(i));
    ff = findFilesBVQX(fullfile(params.results_dir,   params.reslts_fold)...
        ,subStrSrc);
    load(ff{1},'ansMat*','locations','mask')
    for j = 1:3 % check all cases
        switch j
            case 1
                if exist('ansMat_fixed','var')
                    ansMat_out(:,:,cnt)        = ansMat_fixed;
                end
            case 2
                if  exist('ansMat_Multit_fixed','var')
                    ansMat_Multit_out(:,:,cnt)        = ansMat_Multit_fixed;
                end
            case 3
                if exist('ansMat_SVM_fixed','var')
                    ansMat_SVM_out(:,:,cnt)        = ansMat_SVM_fixed;
                end
        end
    end
    clear ansMat*fixed
    cnt = cnt + 1;
end
fprintf('load finished in %f \n',toc(start));
%% compute the MSCM maps
%check the 3 different cases for multi/svm cv and multit non cv
for i = 1:3
    switch i
        case 1
            if exist('ansMat_out','var')
                [avgAnsMat,stlzerPermsAnsMat] = createStelzerPermutations(ansMat_out,params.numMaps,'mean');
                pval_multit_no_cv = calcPvalVoxelWise(avgAnsMat);
                sigfdr_multit_no_cv = fdr_bh(pval_multit_no_cv,0.05,'pdep','yes');
            end
        case 2
            if exist('ansMat_Multit_out','var')
                [avgAnsMat,stlzerPermsAnsMat] = createStelzerPermutations(ansMat_Multit_out,params.numMaps,'mean');
                pval_multit_cv = calcPvalVoxelWise(avgAnsMat);
                sigfdr_multit_cv = fdr_bh(pval_multit_cv,0.05,'pdep','yes');
            end
        case 3
            if exist('ansMat_SVM_out','var')
                [avgAnsMat,stlzerPermsAnsMat] = createStelzerPermutations(ansMat_SVM_out,params.numMaps,'mean');
                pval_svm_cv = calcPvalVoxelWise(avgAnsMat);
                sigfdr_svm_cv = fdr_bh(pval_svm_cv,0.05,'pdep','yes');
            end
    end
end
fprintf('fold %d done in %f\n',params.fold_rng,toc(start));
%% save the file
fnTosave = sprintf(...
    'ND_FFX_power-%.4d.mat',...
    params.fold_rng);
save(fullfile(params.outfold,fnTosave),...
    'locations','mask',...
    'pval*','sigfdr*','params');

end

function fixedAnsMat = fixZerosNans(ansMat,modeuse,i,locations)
fprintf('sub %.3d \t',i);
%fprintf('B = sub %d has %d nans\n',i,sum(isnan(median(ansMat,2))))
fixedAnsMat = fixAnsMat(ansMat,locations,modeuse); % fix ansMat for zeros
%fprintf('A = sub %d has %d nans\n\n',i,sum(isnan(median(fixedAnsMat,2))))
end

function subsExtract = getSubsPower(params)
ff = findFilesBVQX(fullfile(params.results_dir, params.reslts_fold),...
    params.srch_str);
for i = 1:length(ff)
    [pn,fn] = fileparts(ff{i});
    strtmp = regexp(fn,'sub_-[0-9]+_','match');
    subfnd(i) = str2num(strtmp{1}(6:8));
end
rng(params.fold_rng);
idxs = randperm(length(ff),params.numsubschs);
subsExtract = subfnd(idxs);
end
