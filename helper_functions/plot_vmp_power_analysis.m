function plot_vmp_power_analysis()
%% set params 
params.results_dir         = fullfile('..','..','results');
params.reslts_fold_nocv    = 'results_VocalDataSet_FIR_AR6_FFX_ND_norm_400-shuf_SLsize-27'; 
params.reslts_fold_cv      = 'results_VocalDataSet_avg-abs-vals_linear_FIR_AR6_FFX_ND_repart-mode-rand_400-shuf_SLsize-27_folds-5';
params.outfold_nocv        = fullfile(params.results_dir,params.reslts_fold_nocv,'2nd_level','power');
params.outfold_cv          = fullfile(params.results_dir,params.reslts_fold_cv,'2nd_level','power');
cutOff                     = 0.95; % need to use this externally since pararms get loaded 
%% 

%% lower power results and compute group replicability 
% no cv 
skip = 1;
if skip
    ff = findFilesBVQX(params.outfold_nocv,'ND_FFX_power-*.mat');
    for i = 1:length(ff)
        load(ff{i},'pval*','sigfdr*','mask','locations');
        sig_raw(:,i) = sigfdr_multit_no_cv;
    end
    params.cutoff              = cutOff; % cut off to use for maps
    perc_maps = sum(sig_raw,2)./size(sig_raw,2);
    figure;histogram(perc_maps);
    title(sprintf('%% over %f %d num maps %d multi-t nocv',params.cutoff,sum(perc_maps>params.cutoff),size(sig_raw,2)));
end
mapscomputed(3)  = length(ff); 
% cv maps 
ff = findFilesBVQX(params.outfold_cv,'ND_FFX_power-*.mat'); 
for i = 1:length(ff)
    load(ff{i},'pval*','sigfdr*','mask','locations');
    sig_raw_mtt(:,i) = double(sigfdr_multit_cv);
    sig_raw_svm(:,i) = double(sigfdr_svm_cv);
end
mapscomputed(1)  = length(ff); mapscomputed(2)  = length(ff); 
params.cutoff              = cutOff; % cut off to use for maps 
perc_maps_mtt = sum(sig_raw_mtt,2)./size(sig_raw_mtt,2);
perc_maps_svm = sum(sig_raw_svm,2)./size(sig_raw_svm,2);
figure;histogram(perc_maps_mtt);
title(sprintf('%% over %f %d num maps %d multi-t cv',params.cutoff,sum(perc_maps_mtt>params.cutoff),size(perc_maps_mtt,2)));
figure;histogram(perc_maps_svm);
title(sprintf('%% over %f, %d num maps %d svm cv',params.cutoff,sum(perc_maps_svm>params.cutoff),size(perc_maps_svm,2)));

%% plot vmp 
% create dat struc for maps to plot 
% var look for 
varsuse = {'perc_maps_mtt', 'perc_maps_svm','perc_maps'};
mapnames = {'Multi-T using CV', 'SVM using CV','Multit-T no cv'};
colorsUse = [255 0 0 ; 0 0 255; 255 0 0 ];
cnt = 1; 
for i = 1:length(varsuse)
    if exist(varsuse{i},'var')
        dat(cnt).plotmap  = eval(varsuse{i});
        dat(cnt).plotname = sprintf('%s (%% %0.2f vox passing = %d)[#reselections %d]',...
                                  mapnames{i},...
                                  params.cutoff,...
                                  sum(eval(varsuse{i})>params.cutoff),...
                                  mapscomputed(cnt));
        dat(cnt).coloruse = colorsUse(i,:);
        cnt = cnt + 1; 
    end
end
%p= genpath('D:\Roee_Main_Folder\1_AnalysisFiles\Poldrack_RFX');addpath(p);
n = neuroelf;
% load sample example MNI .nii
vmp = BVQXfile(fullfile(pwd,'blank_MNI_3x3res.vmp'));
%vmp = n.importvmpfromspms(fullfile(pwd,'blank_MNI_3x3res.nii'),'a',[],3);

mapType = 1;
curMapNum = 1; 

for i = 1:length(dat)
    mapTitle = dat(i).plotname;
    dataFromAnsMatBackIn3d = scoringToMatrix(mask,dat(i).plotmap,locations);
    vmp.NrOfMaps = curMapNum;
    % set some map properties
    vmp.Map(curMapNum) = vmp.Map(1); % get dummy map structure in place
    vmp.Map(curMapNum).VMPData = dataFromAnsMatBackIn3d;
    vmp.Map(curMapNum).LowerThreshold = 0.8;
    vmp.Map(curMapNum).UpperThreshold = 1;%XXX cutOff;
    vmp.Map(curMapNum).UseRGBColor = 1;
    vmp.Map(curMapNum).RGBLowerThreshNeg = dat(i).coloruse;
    vmp.Map(curMapNum).RGBUpperThreshNeg = dat(i).coloruse;
    vmp.Map(curMapNum).RGBLowerThreshPos = dat(i).coloruse ;
    vmp.Map(curMapNum).RGBUpperThreshPos = dat(i).coloruse;
    vmp.Map(curMapNum).Name = mapTitle;
    vmp.Map(curMapNum).Type = mapType;
    vmpfn ='group_rep_power.vmp';
    curMapNum = curMapNum + 1;
end
vmp.SaveAs(fullfile(params.outfold_cv,vmpfn));
vmp.ClearObject;
clear vmp;

%% 


end