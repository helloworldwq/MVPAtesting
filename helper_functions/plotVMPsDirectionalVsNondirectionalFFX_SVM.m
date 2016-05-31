function plotVMPsDirectionalVsNondirectionalFFX_SVM()
p= genpath('D:\Roee_Main_Folder\1_AnalysisFiles\Poldrack_RFX');addpath(p);
n = neuroelf;
% load sample example MNI .nii
vmp = n.importvmpfromspms(fullfile(pwd,'temp.nii'),'a',[],3);
rootDir = 'F:\vocalDataSet\processedData\matFilesProcessedData\vocalDataSetResults\results_VocalDataSet_FFX_ND_norm_1000shuf_SL27_reg_perm_ar3';
nd_fn = 'ND_FFX_VDS_150-subs_27-slsze_1-fld_1000shufs_1000-stlzer_mode-equal-min_newT2013';
d_fn = 'DR_FFX_VDS_150-subs_27-slsze_1-fld_1000shufs_1000-stlzer_mode-equal-min_newT2013';
fa_vals = 'RAW_FA_VALS_ar3_27-subs_150-slsize.mat';
load(fullfile(rootDir,fa_vals));
% get d idxs
load(fullfile(rootDir,d_fn));
ansMat = squeeze(ansMat(:,:,1));
pval = calcPvalVoxelWise(ansMat);
sigfdr = fdr_bh(pval,0.05,'pdep','no');
idx_dr = find(sigfdr==1);
% get nd idxs
load(fullfile(rootDir,nd_fn));
pval = calcPvalVoxelWise(avgAnsMat);
sigfdr = fdr_bh(pval,0.05,'pdep','no');
idx_ndr = find(sigfdr==1);
% get D only ND only and common idxs (1 = dr only, 2 = nd only 3 = common)
idxstouse{1} = setdiff(idx_dr,idx_ndr); % dir only 
idxstouse{2} = setdiff(idx_ndr,idx_dr); % nd only  
idxstouse{3} = intersect(idx_ndr,idx_dr); % common  
mapType = 1;
%% plot VMPs with 3 colors 
curMapNum = 1;
for j = 1:3
    switch j
        case 1
            typean = 'direcidxsonly';
            idxuse = idxstouse{j};
            colorToUse = [255 0 0];
        case 2
            typean = 'nondiidxsonly';
            idxuse = idxstouse{j};
            colorToUse = [0 255 0];
        case 3
            typean = 'comonidxsonly';
            idxuse = idxstouse{j};
            colorToUse = [0 0 255];
    end
    dataToPlot = zeros(size(locations,1),1);
    dataToPlot(idxuse) = 1;%rois(i).normMaps.fa(idxuse); % XXX just get boolean values
    mapTitle = sprintf('%s (%d) FDR 0.05 %d subs %d cvfold',...
        typean,...
        length(idxuse),...
        length(subsExtracted),...
        21);
    fprintf('%s\n',mapTitle);
    dataFromAnsMatBackIn3d = scoringToMatrix(mask,dataToPlot,locations);
    vmp.NrOfMaps = curMapNum;
    % set some map properties
    vmp.Map(curMapNum) = vmp.Map(1);
    vmp.Map(curMapNum).VMPData = dataFromAnsMatBackIn3d;
    vmp.Map(curMapNum).LowerThreshold = 0;
    vmp.Map(curMapNum).UpperThreshold = 2;%XXX cutOff;
    vmp.Map(curMapNum).UseRGBColor = 1;
    vmp.Map(curMapNum).RGBLowerThreshNeg = colorToUse;
    vmp.Map(curMapNum).RGBUpperThreshNeg = colorToUse;
    vmp.Map(curMapNum).RGBLowerThreshPos = colorToUse ;
    vmp.Map(curMapNum).RGBUpperThreshPos = colorToUse;
    vmp.Map(curMapNum).Name = mapTitle;
    vmp.Map(curMapNum).Type = mapType;
    curMapNum = curMapNum + 1;
end

vmpfn = sprintf('D_ND_FFX_FDR_005_%d_subs_%d_cvfold.vmp',...
        length(subsExtracted),...
        21);

vmp.SaveAs(fullfile(rootDir,vmpfn));
vmp.ClearObject;
clear vmp;

vmp = n.importvmpfromspms(fullfile(pwd,'temp.nii'),'a',[],3);
curMapNum = 1;
%% plot VMP with FA overlayed 
for j = 1:3
    switch j
        case 1
            typean = 'direcidxsonly';
            idxuse = idxstouse{j};
            colorToUse = [255 0 0];
        case 2
            typean = 'nondiidxsonly';
            idxuse = idxstouse{j};
            colorToUse = [0 255 0];
        case 3
            typean = 'comonidxsonly';
            idxuse = idxstouse{j};
            colorToUse = [0 0 255];
    end
    %     idxuse = 1:size(locations,1);% XX FA maps whole brain
    dataToPlot = zeros(size(locations,1),1);
    dataToPlot(idxuse) = rawFA(idxuse); % raw FA is the version NOT demeaned 
    minfa = min(rawFA(idxuse));
    maxfa = max(rawFA(idxuse));
    mapTitle = sprintf('%s (%d) FDR 0.05 %d subs %d cvfold',...
        typean,...
        length(idxuse),...
        length(subsExtracted),...
        21);
    fprintf('%s\n',mapTitle);
    dataFromAnsMatBackIn3d = scoringToMatrix(mask,dataToPlot,locations);
    vmp.NrOfMaps = curMapNum;
    % set some map properties
    vmp.Map(curMapNum) = vmp.Map(1);
    vmp.Map(curMapNum).VMPData = dataFromAnsMatBackIn3d;
    vmp.Map(curMapNum).LowerThreshold = minfa;
    vmp.Map(curMapNum).UpperThreshold = maxfa;%XXX cutOff;
    vmp.Map(curMapNum).UseRGBColor = 0;
    vmp.Map(curMapNum).RGBLowerThreshNeg = colorToUse;
    vmp.Map(curMapNum).RGBUpperThreshNeg = colorToUse;
    vmp.Map(curMapNum).RGBLowerThreshPos = colorToUse ;
    vmp.Map(curMapNum).RGBUpperThreshPos = colorToUse;
    vmp.Map(curMapNum).Name = mapTitle;
    vmp.Map(curMapNum).Type = mapType;
    curMapNum = curMapNum + 1;
end

vmpfn = sprintf('D_ND_FFX_FDR_005_%d_subs_%d_cvfold_FAoverlay.vmp',...
        length(subsExtracted),...
        21);

vmp.SaveAs(fullfile(rootDir,vmpfn));
end