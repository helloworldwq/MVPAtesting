function plotVMPsuperSimple()
p= genpath('D:\Roee_Main_Folder\1_AnalysisFiles\Poldrack_RFX\toolboxes');addpath(p);
n = neuroelf;
ismni = input('MNI (1) or TAL (0) ? \n'); 
% load sample example MNI .nii
if ismni
    vmp = BVQXfile(fullfile(pwd,'blank_MNI_3x3res.vmp'));
else
    vmp = BVQXfile(fullfile(pwd,'blank_vmp_tal_3x3res.vmp'));
end

% how many second levels files do you want to plot? 
mapnum = input('how many sec level files do you want to plot? \n'); 

curMapNum = 1;
for i = 1:mapnum
    alpha = 0.005;
    [seclevfn,pn] = uigetfile('*.mat','choose second level file'); 
    load(fullfile(pn,seclevfn)); 
    fprintf('these are the vars:\n'); 
    eval('whos'); 
    % nameofavgfile = input('type name of avg file \n','s'); 
    nameofavgfile = 'avgAnsMat';
    avgFile = eval(nameofavgfile); 
    pval = calcPvalVoxelWise(avgFile);
    sigfdr = fdr_bh(eval(['pval']),alpha,'pdep','yes');
    idx_plot = find(sigfdr==1);
    dataToPlot = zeros(size(locations,1),1);
    dataToPlot(idx_plot) = 1;%rois(i).normMaps.fa(idxuse); % XXX just get boolean values
    dataFromAnsMatBackIn3d = scoringToMatrix(mask,dataToPlot,locations);
    vmp.NrOfMaps = curMapNum;
    colorToUse = [255 0 0];
    fprintf('filename %s\n',seclevfn);
    mapttl = input('type map title \n','s'); 
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
    vmp.Map(curMapNum).Name = mapttl;
    vmp.Map(curMapNum).Type = 1;
    curMapNum = curMapNum + 1;

end
dir2save = uigetdir(pwd,'select dir to save map in'); 
vmpfn = input('select vmp fn to save \n','s'); 
vmp.SaveAs(fullfile(dir2save,vmpfn));
vmp.ClearObject;
clear vmp;
end