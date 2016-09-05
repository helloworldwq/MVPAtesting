function export_DirectionalNonDirecitonal_to_nii_for_neurovolt()
numsubs = 20;
alpha = 0.05;
%% params set
params.slsize       = 27; % searchlight size to use
params.usetop100    = 0; % use top 100 voxels from D / ND analysis
params.use20regin   = 0;  % use the regions from 20 subjects to compute FuA in 150 subjects
params.measureuse   = 'ndrrrealdata';% which symmetry measure to use (FuA unit normed, FuA non unit normed, Symmetry, directioanl multi-t)
% rawFuA_nonNormalized , rawFuA_symmetry, rawFuA_unitNormalized, rawFuA_skewness
% drrealdata, rawFuA_normdiff_unitnorm, rawFuA_normdiff_nonunitnorm,real_acc_DR_svm_linear
% real_acc_ND_svm_linear, ndrrrealdata
params.withcommn    = 1; % 'D only'; % D only or D + common in comparison
params.printvmp     = 1; % print vmp with results
params.figfold      = fullfile('..','..','figures','FuA_temp');
params.useshuf      = 0; % use shuffle data
slsize = params.slsize;
cnt = 1;
%% load Directional and non directional
rootDir2ndlvl = fullfile('..','..','results',sprintf('results_VocalDataSet_FIR_AR6_FFX_ND_norm_400-shuf_SLsize-%d',slsize),'2nd_level');
%% directional
dirfnm  = sprintf('results_DR_shufs-5000_subs-%d_slsize-%d.mat',numsubs,slsize);
load(fullfile(rootDir2ndlvl,dirfnm),'pval','mask','locations','drrealdata','real_acc_DR_svm_linear');
% save data:
dat(cnt).data         = pval;
dat(cnt).mapname      = 'p-values Directional T2008 - Unthresholded'; cnt = cnt + 1;

dat(cnt).data         = drrealdata;
dat(cnt).mapname      = 'Directional T2008 - Unthresholded'; cnt = cnt + 1;

%% non directional
ndrfnm  = sprintf('ND_FFX_VDS_%d-subs_%d-slsze_1-fld_400shufs_5000-stlzer_mode-equal-min_newT2013.mat',numsubs,slsize);
load(fullfile(rootDir2ndlvl,ndrfnm),'pval','mask','locations','ndrrrealdata','real_acc_ND_svm_linear')
% save data
dat(cnt).data         = pval;
dat(cnt).mapname      = 'p-values Non-directional T2013 - Unthresholded'; cnt = cnt + 1;

dat(cnt).data         = ndrrrealdata;
dat(cnt).mapname      = 'Non-directional T2013 - Unthresholded'; cnt = cnt + 1;
%% print VMP to use for export
vmpraw = BVQXfile(fullfile(pwd,'blank_MNI_3x3res.vmp'));
vmp = BVQXfile(fullfile(pwd,'blank_MNI_3x3res.vmp'));
mapstruc = vmp.Map(1);
for m = 1:length(dat)
    vmp.NrOfMaps        = m;
    vmpdat              = scoringToMatrix(mask,dat(m).data',locations); % note that SigFDR must be row vector
    vmp.Map(m)          = vmp.Map(1);
    vmp.Map(m).VMPData  = vmpdat;
    vmp.Map(m).Name     = dat(m).mapname;
    vmp.Map(m).LowerThreshold = min(dat(m).data(:));
    vmp.Map(m).UpperThreshold = max(dat(m).data(:));
    vmp.Map(m).UseRGBColor = 0;
    vmp.Map(m).LUTName = 'RoeeCmap2.olt';
end
vmp.NrOfMaps = length(dat);
vmp.SaveAs(fullfile(rootDir2ndlvl,['D_ND_FFX_for_export_nii.vmp']));
export_vmp_to_nii(vmp,rootDir2ndlvl)
vmp.ClearObject;
clear vmp;



end

function label = getLabel(str)
% rawFuA_nonNormalized , rawFuA_symmetry, rawFuA_unitNormalized, drrealdata

switch str
    case 'rawFuA_nonNormalized'
        label = 'FuA Non Unit Normalized';
    case 'rawFuA_symmetry'
        label = 'Symmetry Measure';
    case 'rawFuA_unitNormalized'
        label = 'FuA Unit Normalized';
    case 'drrealdata'
        label = 'Muni Meng Directional';
    case 'rawFuA_normdiff_unitnorm'
        label = 'Norm Diff (Unit Normalized)';
    case 'rawFuA_normdiff_nonunitnorm'
        label = 'Norm Diff (Non Unit Normalized)';
    case 'rawFuA_skewness'
        label = 'Distnace Skewness';
    case 'ndrrrealdata'
        label = 'Non-directional real data';
    case 'real_acc_ND_svm_linear'
        label = 'Accuracy Non-Directional Linear SVM - 5fold CV';
    case 'real_acc_DR_svm_linear'
        label = 'Accuracy Directional Linear SVM - 5fold CV';
end
end