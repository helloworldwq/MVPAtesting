function plotVMPmapForJonathanCVpaperMultitVsSVM()
% p= genpath('D:\Roee_Main_Folder\1_AnalysisFiles\Poldrack_RFX\toolboxes');addpath(p);
% n = neuroelf;
vmp = BVQXfile(fullfile(pwd,'blank_MNI_3x3res.vmp'));
resdir = 'D:\Roee_Main_Folder\1_AnalysisFiles\Poldrack_RFX\Publish_Ready_Process\results\results_VocalDataSet_FIR_AR6_FFX_ND_norm_400-shuf_SLsize-27\2nd_level';
vmprearrange = BVQXfile(fullfile(resdir,'Multi-T_nofolds_vsSVM_5fold_5Kstzler.vmp'));

for i = 1:vmprearrange.NrOfMaps
    vmpdat(:,i) = vmprearrange.Map(i).VMPData(:);
    fprintf('map %d\t %s\n',vmprearrange.Map(i).Name)
end

svmidxs = unique([find(vmpdat(:,1)==1) ; find(vmpdat(:,2)==1)]);
mttidxs = unique([find(vmpdat(:,3)==1) ; find(vmpdat(:,4)==1)]);
% common idxs 
commonidxs = intersect(mttidxs,svmidxs);
% unique svm idxs 
svmidxsunq = setxor(commonidxs,svmidxs);
% unique multit idxs 
mttidxsunq = setxor(commonidxs,mttidxs);

curMapNum = 1;
% svm only 
vmp.NrOfMaps = curMapNum;
vmp.Map(curMapNum) = vmprearrange.Map(1); 
vmp.Map(curMapNum).Name = 'svm only'; 
vmp.Map(curMapNum).VMPData(:) = 0; 
vmp.Map(curMapNum).VMPData(svmidxsunq) = 1; 
    colorToUse = [255 0 0];
    vmp.Map(curMapNum).LowerThreshold = 0;
    vmp.Map(curMapNum).UpperThreshold = 2;%XXX cutOff;
    vmp.Map(curMapNum).UseRGBColor = 1;
    vmp.Map(curMapNum).RGBLowerThreshNeg = colorToUse;
    vmp.Map(curMapNum).RGBUpperThreshNeg = colorToUse;
    vmp.Map(curMapNum).RGBLowerThreshPos = colorToUse ;
    vmp.Map(curMapNum).RGBUpperThreshPos = colorToUse;
curMapNum = curMapNum +1; 

% multit 
vmp.NrOfMaps = curMapNum;
vmp.Map(curMapNum) = vmprearrange.Map(1); 
vmp.Map(curMapNum).Name = 'multi-t only'; 
vmp.Map(curMapNum).VMPData(:) = 0; 
vmp.Map(curMapNum).VMPData(mttidxsunq) = 1; 
    colorToUse = [0 255 0];
    vmp.Map(curMapNum).LowerThreshold = 0;
    vmp.Map(curMapNum).UpperThreshold = 2;%XXX cutOff;
    vmp.Map(curMapNum).UseRGBColor = 1;
    vmp.Map(curMapNum).RGBLowerThreshNeg = colorToUse;
    vmp.Map(curMapNum).RGBUpperThreshNeg = colorToUse;
    vmp.Map(curMapNum).RGBLowerThreshPos = colorToUse ;
    vmp.Map(curMapNum).RGBUpperThreshPos = colorToUse;
curMapNum = curMapNum +1; 

% common
vmp.NrOfMaps = curMapNum;
vmp.Map(curMapNum) = vmprearrange.Map(1); 
vmp.Map(curMapNum).Name = 'common only'; 
vmp.Map(curMapNum).VMPData(:) = 0; 
vmp.Map(curMapNum).VMPData(commonidxs) = 1; 
    colorToUse = [0 0 255];
    vmp.Map(curMapNum).LowerThreshold = 0;
    vmp.Map(curMapNum).UpperThreshold = 2;%XXX cutOff;
    vmp.Map(curMapNum).UseRGBColor = 1;
    vmp.Map(curMapNum).RGBLowerThreshNeg = colorToUse;
    vmp.Map(curMapNum).RGBUpperThreshNeg = colorToUse;
    vmp.Map(curMapNum).RGBLowerThreshPos = colorToUse ;
    vmp.Map(curMapNum).RGBUpperThreshPos = colorToUse;


vmpfn ='forJonathanMultiT_nofolds_vsSVM5folds.vmp';
vmp.SaveAs(fullfile(resdir,vmpfn));
vmp.ClearObject;
clear vmp;
end