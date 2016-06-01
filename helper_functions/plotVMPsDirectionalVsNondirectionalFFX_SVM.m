function plotVMPsDirectionalVsNondirectionalFFX_SVM()
p= genpath('D:\Roee_Main_Folder\1_AnalysisFiles\Poldrack_RFX');addpath(p);
n = neuroelf;
% load sample example MNI .nii
vmp = BVQXfile(fullfile(pwd,'blank_MNI_3x3res.vmp'));
%vmp = n.importvmpfromspms(fullfile(pwd,'blank_MNI_3x3res.nii'),'a',[],3);
rootDir = 'D:\Roee_Main_Folder\1_AnalysisFiles\Poldrack_RFX\Publish_Ready_Process\results\results_VocalDataSet_FIR_AR6_FFX_ND_SVM_400-shuf_SLsize-27\2nd_level';
nd_fn = 'ND_FFX_VDS_20-subs_27-slsze_1-fld_400shufs_1000-stlzer_mode-equal-min_newT2013';
d_fn = 'results_VocalDataSet_FFX_DR_SVM_400-shuf_SLsize-27_folds_-005_';

% rootDir = 'D:\Roee_Main_Folder\1_AnalysisFiles\Poldrack_RFX\Publish_Ready_Process\results\results_VocalDataSet_FIR_AR6_FFX_ND_norm_400-shuf_SLsize-27\2nd_level';
% nd_fn = 'ND_FFX_VDS_20-subs_27-slsze_1-fld_400shufs_1000-stlzer_mode-equal-min_newT2013';
% d_fn = 'DR_FFX_VDS_20-subs_27-slsze_1-fld_400shufs_1000-stlzer_mode-equal-min_newT2013';
mode = 'Multi-T';
alpha = 0.06;
% get d idxs
load(fullfile(rootDir,d_fn));
pval = calcPvalVoxelWise(ansMat);
sigfdr = fdr_bh(pval,alpha,'pdep','yes');
idx_dr = find(sigfdr==1);
% get nd idxs
load(fullfile(rootDir,nd_fn));
pval = calcPvalVoxelWise(avgAnsMat);
sigfdr = fdr_bh(pval,alpha,'pdep','yes');
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
    mapTitle = sprintf('%s (%d) FDR 0.06 %d subs %d cvfold %s',...
        typean,...
        length(idxuse),...
        length(subsExtracted),...
        21, mode);
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

vmpfn = sprintf('D_ND_FFX_FDR_%1.2f_%s_%d_subs.vmp',...
        alpha, mode,length(subsExtracted) );

vmp.SaveAs(fullfile(rootDir,vmpfn));
vmp.ClearObject;
clear vmp;

end