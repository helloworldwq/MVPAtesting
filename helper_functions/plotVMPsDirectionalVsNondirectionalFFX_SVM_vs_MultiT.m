function plotVMPsDirectionalVsNondirectionalFFX_SVM_vs_MultiT()
%p= genpath('D:\Roee_Main_Folder\1_AnalysisFiles\Poldrack_RFX');addpath(p);
n = neuroelf;
% load sample example MNI .nii
vmp = BVQXfile(fullfile(pwd,'blank_MNI_3x3res.vmp'));
%vmp = n.importvmpfromspms(fullfile(pwd,'blank_MNI_3x3res.nii'),'a',[],3);

results_dir = fullfile('..','..','results');
ffldrs = findFilesBVQX(results_dir,'results_VocalDataSet_*',...
    struct('dirs',1));
fprintf('The following results folders were found:\n');
for i = 1:length(ffldrs)
    [pn,fn] = fileparts(ffldrs{i});
    fprintf('[%d]\t%s\n',i,fn);
end

% folders to analyize
idxuse =  11 ; % folder to choose 

%% load non CV multi-t
fldrusemt = fullfile(ffldrs{4},'2nd_level');
fnmtnocv = 'ND_FFX_VDS_20-subs_27-slsze_1-fld_400shufs_5000-stlzer_mode-equal-min_newT2013.mat';
fnmdr = 'results_DR_shufs-5000_subs-20_slsize-27.mat';
load(fullfile(fldrusemt,fnmtnocv),'pval');
sigfdr_nd = fdr_bh(pval,0.05,'pdep','yes');
load(fullfile(fldrusemt,fnmdr),'pval');
sigfdr_dr = fdr_bh(pval,0.05,'pdep','yes');

idxmultit_nocv_dr = find(sigfdr_dr==1); 
idxmultit_nocv_nd = find(sigfdr_nd==1); 
idxMultiT_nocv = unique([find(sigfdr_nd==1), find(sigfdr_dr==1)]);
%% 
% loop
vmp = BVQXfile(fullfile(pwd,'blank_MNI_3x3res.vmp'));
%vmp = n.importvmpfromspms(fullfile(pwd,'blank_MNI_3x3res.nii'),'a',[],3);
rootDir = fullfile(ffldrs{idxuse},'2nd_level');
nd_fn = 'ND_FFX_20-subs_27-slsze_400shufs_5000-stlzer_newT2013.mat';
d_fn = 'results_DR_cvEvery_PermB4fold_SL-size-27_fold-5.mat';
cases_use = {'multit','svm'};
alpha = 0.05;
curMapNum = 1;

for z = 1:2
    mode = cases_use{z};
    % get d idxs
    load(fullfile(rootDir,d_fn),'pval*','sub*','locations','mask');
    sigfdr = fdr_bh(eval(['pval_' mode]),alpha,'pdep','yes');
    idx_dr = find(sigfdr==1);
    eval(sprintf('idx_dr_%s = idx_dr',cases_use{z}));
    % get nd idxs
    load(fullfile(rootDir,nd_fn),'pval*');
    sigfdr = fdr_bh(eval(['pval_' mode]),alpha,'pdep','yes');
    idx_ndr = find(sigfdr==1);
    eval(sprintf('idx_ndr_%s = idx_ndr',cases_use{z}));
    % get D only ND only and common idxs (1 = dr only, 2 = nd only 3 = common)
    idxstouse{1} = setdiff(idx_dr,idx_ndr); % dir only
    idxstouse{2} = setdiff(idx_ndr,idx_dr); % nd only
    idxstouse{3} = intersect(idx_ndr,idx_dr); % common
    mapType = 1;
    %% plot VMPs with 3 colors
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
        mapTitle = sprintf('%s (%d) FDR 0.05 %d subs %d cvfold %s',...
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
    
    
end
vmpfn = sprintf('D_ND_FFX_FDR_%1.2f_%s_%d_subs.vmp',...
    alpha, mode,length(subsExtracted) );
percent_ndr_mt = sum(ismember(idx_ndr_multit,idx_ndr_svm))/length(idx_ndr_svm);
percent_dr_mt = sum(ismember(idx_dr_multit,idx_dr_svm))/length(idx_dr_svm);
fprintf('ND: multi-t finds %%%.1f of svm voxels\n',percent_ndr_mt*100);
fprintf('DR: multi-t finds %%%.1f of svm voxels\n',percent_dr_mt*100);

multitidx = unique([idx_ndr_multit, idx_dr_multit]);
svm_idx = unique([idx_ndr_svm, idx_dr_svm]);
percent_mt_svm = sum(ismember(multitidx,svm_idx))/length(svm_idx);
fprintf('overall: multi-t finds %%%.1f of svm voxels\n',percent_mt_svm*100);

percent_svm_mt = sum(ismember(svm_idx,multitidx))/length(multitidx);
fprintf('overall: svm finds %%%.1f of multit voxels\n',percent_svm_mt*100);
%% multi t no cv report 
% svm 
percent_svm_mt = sum(ismember(svm_idx,idxMultiT_nocv))/length(idxMultiT_nocv);
fprintf('overall: svm finds %%%.1f of multit voxels\n',percent_svm_mt*100);
percent_svm_mt = 1-sum(ismember(idxMultiT_nocv,svm_idx))/length(svm_idx);
fprintf('overall: only %%%.1f of SVM voxels were not found by multi-t\n',percent_svm_mt*100);
% multi -t 
percent_svm_mt = sum(ismember(idxMultiT_nocv,svm_idx))/length(svm_idx);
fprintf('overall: multit finds %%%.1f of svm voxels\n',percent_svm_mt*100);
percent_svm_mt = 1-sum(ismember(svm_idx,idxMultiT_nocv))/length(idxMultiT_nocv);
fprintf('overall: only %%%.1f of multi-t voxels were not found by svm-t\n',percent_svm_mt*100);

%% report no cv vs multi-t Roy new version 
% directional 
percent_svm_mt = sum(ismember(idxmultit_nocv_dr,idx_dr_svm))/length(idx_dr_svm);
fprintf('overall DR: multit finds %%%.1f of svm voxels\n',percent_svm_mt*100);
percent_svm_mt = sum(ismember(idx_dr_svm,idxmultit_nocv_dr))/length(idxmultit_nocv_dr);
fprintf('overall DR: svm finds %%%.1f of multit voxels\n',percent_svm_mt*100);
% non directioal 
percent_svm_mt = sum(ismember(idxmultit_nocv_nd,idx_ndr_svm))/length(idx_ndr_svm);
fprintf('overall ND: multit finds %%%.1f of svm voxels\n',percent_svm_mt*100);
percent_svm_mt = sum(ismember(idx_ndr_svm,idxmultit_nocv_nd))/length(idxmultit_nocv_nd);
fprintf('overall ND: svm finds %%%.1f of multit voxels\n',percent_svm_mt*100);

% idxmultit_nocv_dr = find(sigfdr_dr==1); 
% idxmultit_nocv_nd = find(sigfdr_nd==1); 

%% 
vmp.SaveAs(fullfile(rootDir,vmpfn));
vmp.ClearObject;
clear vmp;

end
