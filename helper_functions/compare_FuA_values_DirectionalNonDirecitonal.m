function compare_FuA_values_DirectionalNonDirecitonal()
numsubs = 20;
alpha = 0.05;
%% load fa 
rootDir = fullfile('..','..','results','results_VocalDataSet_FIR_AR6_FFX_ND_norm_400-shuf_SLsize-27');
fnload = sprintf('RAW_FA_VALS_ar6_27-subs_%d-slsize.mat',numsubs);
load(fullfile(rootDir,fnload)); 

%% load Directional and non directional  
rootDir2ndlvl = fullfile('..','..','results','results_VocalDataSet_FIR_AR6_FFX_ND_norm_400-shuf_SLsize-27','2nd_level');
% directional 
dirfnm  = 'results_DR_shufs-5000_subs-20_slsize-27.mat';
load(fullfile(rootDir2ndlvl,dirfnm),'ansMat','mask','locations');
pval= calcPvalVoxelWise(ansMat);
sigfdr = fdr_bh(pval,alpha,'pdep','yes');
idxdir = find(sigfdr==1); 
clear ansMat ansMatReal
% non directional 
ndrfnm  = 'ND_FFX_VDS_20-subs_27-slsze_1-fld_400shufs_5000-stlzer_mode-equal-min_newT2013.mat';
load(fullfile(rootDir2ndlvl,ndrfnm),'avgAnsMat','mask','locations')
pval= calcPvalVoxelWise(avgAnsMat);
sigfdr = fdr_bh(pval,alpha,'pdep','yes');
idxndr = find(sigfdr==1); 
clear avgAnsMat; 

commonidx = intersect(idxdir,idxndr);
idxndonly = setdiff(idxndr,idxdir); 
idxdronly = setdiff(idxdir,idxndr); 
idxcommon = intersect(idxdir,idxndr);
fadat     = rawFANonCentered; 

%% print FuA in VMP 
vmp = BVQXfile(fullfile(pwd,'blank_MNI_3x3res.vmp'));
mapstruc = vmp.Map;
vmpdat = scoringToMatrix(mask,double(rawFANonCentered'),locations); % note that SigFDR must be row vector
vmp.Map.VMPData = vmpdat;
vmp.Map(1).LowerThreshold = min(vmpdat(:));
vmp.Map(1).UpperThreshold = max(vmpdat(:));
vmp.Map(1).UseRGBColor = 0;
vmp.SaveAs(fullfile(resultsDir,[fnTosave(1:end-4),'.vmp']));
vmp.ClearObject;
clear vmp;


%% print figure 
figure; 
hold on;
t{1} = fadat([idxdronly,idxcommon]); legenduse{1} = 'D-only'; %D
t{2} = fadat([idxndonly]); legenduse{2} = 'ND-only'; % ND


%t{3} = fadat(idxcommon); legenduse{3} = 'Common' ;% Common 
hold on;
colorsuse = [0 0 1; 1 0 0];
for i = 1:length(t)
    histogram(t{i},...
        'BinWidth',0.001,...
        'Normalization','probability',...
        'DisplayStyle','bar',...
        'EdgeColor',colorsuse(i,:),...
        'FaceColor',colorsuse(i,:),...
        'FaceAlpha',0.7,...
        'EdgeAlpha',0.7,...
        'LineWidth',0.5)
end
legend(legenduse,'Location','NorthWest');



xlim([0 1]);
ttlStr = sprintf('D only / ND only');
title(ttlStr);
xlabel('Normalized FA values')
ylabel('Probability of result');
fns = fullfile(fullfile(rootDir,'result_figs','D-only_v_ND-only_20_subs_matlab_histogram.pdf'));
printFigToPDFa4(hfig,fns)
end