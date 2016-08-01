function compare_FuA_values_Anatomical_Labels()
% This function creats the WM,CSF and GM masks in the MNI space.
% add path 
p = genpath('D:\Roee_Main_Folder\1_AnalysisFiles\Poldrack_RFX\');addpath(p);
%% load raw FA maps
filesFA = {'RAW_FA_VALS_ar3_27-subs_20-slsize','RAW_FA_VALS_ar3_27-subs_150-slsize'};
rootDirOriginalData = 'F:\vocalDataSet\processedData\matFilesProcessedData\stats_normalized_sep_beta_ar3';
numsubstot = [20, 150];
for ns = 1:2
    numsubs= numsubstot(ns);
    resDir = 'F:\vocalDataSet\processedData\matFilesProcessedData\vocalDataSetResults\results_VocalDataSet_FFX_ND_norm_1000shuf_SL27_reg_perm_ar3';
    vmpbasefn = filesFA{ns}; % just GM has 1
    vmp = BVQXfile(fullfile(resDir,[vmpbasefn  '.vmp']));
    %% load MNI anatomical labels cortical
    rootDir = 'D:\Roee_Main_Folder\1_AnalysisFiles\Poldrack_RFX\matlabCode\atlasLabels';
    vmplabels = 'HarvardCambrdgeCoritcalAtlas'; % just GM has 1
    vmpatlas = BVQXfile(fullfile(rootDir,[vmplabels  '.vmp']));
    
    %% load MNI anatomical labels sub-cortical
    rootDir = 'D:\Roee_Main_Folder\1_AnalysisFiles\Poldrack_RFX\matlabCode\atlasLabels';
    vmplabels = 'HarvardCambrdgeCoritcalAtlas_sub_cortical'; % just GM has 1
    vmpatlassuybcor = BVQXfile(fullfile(rootDir,[vmplabels  '.vmp']));
    
    
    faData = struct('mapName',[],'vals',[]);
%     areaIdxs = [45 46 21 9 10 8 5 6 43 42 2 36];
    % H1, PT, STGp,STGa,M1,S1, IC, OP
    areaLegnds = {'H1', 'PT', 'STGp', 'STGa','M1','S1', 'IC', 'OP'};
    areaIdxs = [45 46 10 9 7 17 24 48]; 
    
    load(fullfile(resDir,'FAepiVsRealin3d.mat'));
    rawFA = vmp.Map(1).VMPData; % map number 4 is SL size 47
    rawVals = double(rawFA);
    
    faControl = eval(sprintf('faEPI3D%.3d',numsubs) );
    rawValsControl = double(faControl); 
    idxsZeroVals = find(rawVals==0);
    % cortical data
    for j = 1:length(areaIdxs);
        faData(j).mapName = vmpatlas.Map(areaIdxs(j)).Name;
        idxsOfLabel = find(vmpatlas.Map(areaIdxs(j)).VMPData==1);
        idxsOfLabelWithDataFA = setdiff(idxsOfLabel,idxsZeroVals);
        valsInLabel = rawVals(idxsOfLabelWithDataFA);
        faData(j).vals = valsInLabel;
        faData(j).mean = mean(valsInLabel);
        faData(j).median = median(valsInLabel);
        faData(j).sd = std(valsInLabel);
        faData(j).sem = std(valsInLabel)/sqrt(length(valsInLabel)); % standard error of the mean
        faData(j).control = rawValsControl(idxsOfLabelWithDataFA);
        faData(j).Means_control = mean(rawValsControl(idxsOfLabelWithDataFA));
        faData(j).Median_control = median(rawValsControl(idxsOfLabelWithDataFA));
        faData(j).idxsIn3Dspace = idxsOfLabelWithDataFA;
    end
    
    %% add some some cortical regions
    cnt = length(faData) + 1;
    idx{1} = [3 14] ; % lateral ventricles
    idx{2} = [1 12]; % white mattter
    labelsToUse = {'CSF','WM'};
    for i = 1:2 % add wm and CSF
        j = cnt; cnt = cnt+1;
        faData(j).mapName = labelsToUse{i};
        idxsOfLabel = [] ;
        for k = 1:2 % add both hemispheres
            tmp = find(vmpatlassuybcor.Map(idx{i}(k)).VMPData==1);
            idxsOfLabel = [ tmp ; idxsOfLabel];
        end
        idxsOfLabelWithDataFA = setdiff(idxsOfLabel,idxsZeroVals);
        valsInLabel = rawVals(idxsOfLabelWithDataFA);
        faData(j).vals = valsInLabel;
        faData(j).mean = mean(valsInLabel);
        faData(j).median = median(valsInLabel);
        faData(j).sd = std(valsInLabel);
        faData(j).sem = std(valsInLabel)/sqrt(length(valsInLabel)); % standard error of the mean
        faData(j).control = rawValsControl(idxsOfLabelWithDataFA);
        faData(j).Means_control = mean(rawValsControl(idxsOfLabelWithDataFA));
        faData(j).Median_control = median(rawValsControl(idxsOfLabelWithDataFA));
        faData(j).idxsIn3Dspace = idxsOfLabelWithDataFA;
    end
    faTable = struct2table(faData);
    
    %% create bar graphs of all regions:
    means = [faTable.median];
    sem  = [faTable.sem];
    hfig = figure; hold on;
    set(gcf,'Position',[1000         667        1279         671])
    cm = colormap(parula(14));
    for i = 1:size(faTable,1); bar(i,means(i),'FaceColor',cm(i,:));end
    % ylim([0.15 0.25])
    set(gca,'XTick',1:size(faTable,1))
    labels = faTable.mapName;
    for i = 1:size(faTable,1); labels{i} = sprintf('%2d. %s',i,labels{i}); end
    legend(labels,'Location','northeastoutside');
    
    errorbar(1:length(faData),means,sem,'.',...
        'LineWidth',2)
    ylim([0.19 0.27])
    ylabel('Median FA values');
    xlabel('ROI #');
    title(sprintf('FA values higher in primary auditory regions %d subs',numsubs));
    
    figname = fullfile(resDir,sprintf('%s_bar.pdf',filesFA{ns}));
    printFigToPDFa4(hfig,figname)
    
    
    %% create vmp of FA values as % over wm in anatomical regions 
    load(fullfile(resDir,'rawData_ar3_FFX.mat'),'locations','mask');
    vmpfa = vmp;
    zerosmap = zeros(size(vmp.Map(1).VMPData));
    wmmedian = faTable.median(end);
    % get each fa value and store it in a map 
    vmpfa.NrOfMaps = size(faTable,1)-2;
    allvals = {faData.vals};
    % concat all vals to establish interquartile ranges 
    cnct=[]; for i = 1:size(faTable,1)-2; cnct = [cnct; allvals{i}]; end;
    allvals = (cnct/wmmedian-1)*100;
    minval = quantile(allvals,0.25); maxval = quantile(allvals,0.75);
    for i = 1:size(faTable,1)-2;
        tmpvals = ((faTable.vals{i}/wmmedian)-1)*100;
        vmpfa.Map(i) = vmp.Map(1); %dummy map struc
        tmpmap = zerosmap;
        tmpmap(faData(i).idxsIn3Dspace) = tmpvals;
        vmpfa.Map(i).VMPData = tmpmap;
        vmpfa.Map(i).Name = labels{i};
        vmpfa.Map(i).LowerThreshold = minval;
        vmpfa.Map(i).UpperThreshold = maxval;
        vmpfa.Map(i).RGBLowerThreshNeg = [85 255 255 ];
        vmpfa.Map(i).RGBUpperThreshNeg = [85 255 255 ] ;
        vmpfa.Map(i).RGBLowerThreshPos = [85 255 255 ] ;
        vmpfa.Map(i).RGBUpperThreshPos = [255 85 0 ] ;
        vmpfa.Map(i).UseRGBColor = 1;
    end
    
    vmpfa.SaveAs(fullfile(resDir,[filesFA{ns} '_anatomical_per_over_wm.vmp']));
    %% create bar graphs as % over wm 
    
    means = [faTable.median];
    wmmedian = faTable.median(end);
    meansMed_wm = ((means / wmmedian) - 1 )* 100;
    % calc sem by deviding by wmmedian 
    sem = [] ;
    for i = 1:size(faTable,1)-2;
        tmp = faTable.vals{i}/wmmedian;
        sem(i) = std(tmp)/sqrt(length(tmp));
    end
    hfig = figure; hold on;
    set(gcf,'Position',[1000         667        1279         671])
    cm = colormap(parula(size(faTable,1)));
    for i = 1:size(faTable,1)-2; bar(i,meansMed_wm(i),'FaceColor',cm(i,:));end
    % ylim([0.15 0.25])
    set(gca,'XTick',1:size(faTable,1)-2)
    labels = faTable.mapName(1:size(faTable,1)-2);
    for i = 1:size(faTable,1)-2; labels{i} = sprintf('%2d. %s',i,labels{i}); end
    legend(labels,'Location','northeastoutside');
    
    errorbar(1:size(faTable,1)-2,meansMed_wm(1:size(faTable,1)-2),sem,'.',...
        'LineWidth',2)
    dat = meansMed_wm(1:size(faTable,1)-2);
    ylim([floor(min(dat)) ceil(max(dat))])
    ylim([0 ceil(max(dat))])
    ylabel('% Increase in median FA value vs WM');
    xlabel('ROI #');
    title(sprintf('FA values higher in primary auditory regions %d subs',numsubs));
    
    figname = fullfile(resDir,sprintf('%s_bar_over_wm.pdf',filesFA{ns}));
    printFigToPDFa4(hfig,figname)

    %% create bar graphs as % over wm control data EPI mean image 
    means = [faTable.Median_control];
    wmmedian = faTable.Median_control(end);
    meansMed_wm = ((means / wmmedian) - 1 )* 100;
    % calc sem by deviding by wmmedian 
    sem = [] ;
    for i = 1:size(faTable,1)-2;
        tmp = faTable.control{i}/wmmedian;
        sem(i) = std(tmp)/sqrt(length(tmp));
    end
    hfig = figure; hold on;
    set(gcf,'Position',[1000         667        1279         671])
    cm = colormap(parula(size(faTable,1)));
    for i = 1:size(faTable,1)-2; bar(i,meansMed_wm(i),'FaceColor',cm(i,:));end
    % ylim([0.15 0.25])
    set(gca,'XTick',1:size(faTable,1)-2)
    labels = faTable.mapName(1:size(faTable,1)-2);
    for i = 1:size(faTable,1)-2; labels{i} = sprintf('%2d. %s',i,labels{i}); end
    legend(labels,'Location','northeastoutside');
    
    errorbar(1:size(faTable,1)-2,meansMed_wm(1:size(faTable,1)-2),sem,'.',...
        'LineWidth',2)
    %ylim([floor(min(dat)) ceil(max(dat))])
    ylabel('% Increase in median FA value vs WM');
    xlabel('ROI #');
    title(sprintf('FA values in control regions %d subs',numsubs));
    
    figname = fullfile(resDir,sprintf('%s_bar_wm_control_scaled.pdf',filesFA{ns}));
    printFigToPDFa4(hfig,figname)
    %% create box plots of the data:
    % convert data for boxplot
    boxplotdata = [];
    boxplotgrouping = [];
    colorsBoxPlots  =  [255     0     0 ;0   255     0 ; 0   170     0; ...
     255   170     0; 85     0   255]/255;
    colorsBoxPlots = [0 0 0];
    for i = 1:length(faData)
        tempdata = faData(i).vals;
        tempgrp = repmat(i,size(tempdata,1),1);
        labelsNames{i} = sprintf('%d. %s',i, faData(i).mapName);
        boxplotdata = [boxplotdata; tempdata];
        boxplotgrouping = [boxplotgrouping; tempgrp];
    end
    hfig = figure;
    hold on;
    set(gcf,'Position',[1000         667        1279         671])
    hbp = boxplot(boxplotdata,boxplotgrouping,'jitter',1,...
        'plotstyle','traditional','colors',...
        colorsBoxPlots);
    ylim([min(boxplotdata) max(boxplotdata)])
    legend(labels,'Location','northeastoutside');
    ylabel('Mean FA values');
    xlabel('ROI #');
    title(sprintf('FA values higher in primary auditory regions %d subs',numsubs));
    hLegend = legend(findall(gca,'Tag','Box'), labelsNames,...
        'Location','southwest');
    figname = fullfile(resDir,sprintf('%s_boxplots.pdf',filesFA{ns}));
    printFigToPDFa4(hfig,figname)
    %% create box plots of the data control:
    % convert data for boxplot
    boxplotdata = [];
    boxplotgrouping = [];
    colorsBoxPlots  =  [255     0     0 ;0   255     0 ; 0   170     0; ...
     255   170     0; 85     0   255]/255;
    colorsBoxPlots = [0 0 0];
    for i = 1:length(faData)
        tempdata = faData(i).control;
        tempgrp = repmat(i,size(tempdata,1),1);
        labelsNames{i} = sprintf('%d. %s',i, faData(i).mapName);
        boxplotdata = [boxplotdata; tempdata];
        boxplotgrouping = [boxplotgrouping; tempgrp];
    end
    hfig = figure;
    hold on;
    set(gcf,'Position',[1000         667        1279         671])
    hbp = boxplot(boxplotdata,boxplotgrouping,'jitter',1,...
        'plotstyle','traditional','colors',...
        colorsBoxPlots);
    %ylim([min(boxplotdata) max(boxplotdata)])
    legend(labels,'Location','northeastoutside');
    ylabel('Mean Control FA values');
    xlabel('ROI #');
    title(sprintf('FA values in control EPI means auditory regions %d subs',numsubs));
    hLegend = legend(findall(gca,'Tag','Box'), labelsNames,...
        'Location','southwest');
    
    figname = fullfile(resDir, sprintf('%s_control_boxplots.pdf',filesFA{ns}));
    printFigToPDFa4(hfig,figname)
    %% create box plots of the data - divide by WM mean:
    % convert data for boxplot
    means = [faTable.mean];
    wmmean = means(end);
    boxplotdata = [];
    boxplotgrouping = [];
    colorsBoxPlots  =  [255     0     0 ;0   255     0 ; 0   170     0; ...
     255   170     0; 85     0   255]/255;
    colorsBoxPlots = [0 0 0];
    for i = 1:length(faData)
        tempdata = faData(i).vals;
        tempgrp = repmat(i,size(tempdata,1),1);
        labelsNames{i} = sprintf('%d. %s',i, faData(i).mapName);
        boxplotdata = [boxplotdata; tempdata];
        boxplotgrouping = [boxplotgrouping; tempgrp];
    end
    boxplotdata = boxplotdata/wmmean;
    hfig = figure;
    hold on;
    set(gcf,'Position',[1000         667        1279         671])
    hbp = boxplot(boxplotdata,boxplotgrouping,'jitter',1,...
        'plotstyle','traditional','colors',...
        colorsBoxPlots);
    ylim([min(boxplotdata) max(boxplotdata)])
    legend(labels,'Location','northeastoutside');
    ylabel('FA values / Mean FA value in WM (%)');
    xlabel('ROI #');
    title(sprintf('FA values higher in primary auditory regions %d subs',numsubs));
    
    figname = fullfile(resDir,sprintf('%s_boxplots_as_percent_over_wm.pdf',filesFA{ns}));
    printFigToPDFa4(hfig,figname)
    %% create box plots of the data control - divide by WM mean:
    % convert data for boxplot
    means = [faTable.Means_control];
    wmmean = means(end);
    boxplotdata = [];
    boxplotgrouping = [];
    colorsBoxPlots  =  [255     0     0 ;0   255     0 ; 0   170     0; ...
     255   170     0; 85     0   255]/255;
    colorsBoxPlots = [0 0 0];
    for i = 1:length(faData)
        tempdata = faData(i).control;
        tempgrp = repmat(i,size(tempdata,1),1);
        labelsNames{i} = sprintf('%d. %s',i, faData(i).mapName);
        boxplotdata = [boxplotdata; tempdata];
        boxplotgrouping = [boxplotgrouping; tempgrp];
    end
    boxplotdata = boxplotdata/wmmean;
    hfig = figure;
    hold on;
    set(gcf,'Position',[1000         667        1279         671])
    hbp = boxplot(boxplotdata,boxplotgrouping,'jitter',1,...
        'plotstyle','traditional','colors',...
        colorsBoxPlots);
    %ylim([min(boxplotdata) max(boxplotdata)])
    legend(labels,'Location','northeastoutside');
    ylabel('Rest FA values / Mean Rest FA value in WM (%)');
    xlabel('ROI #');
    title(sprintf('FA values in control EPI means auditory regions %d subs',numsubs));
%     hLegend = legend(findall(gca,'Tag','Box'), labelsNames,...
%         'Location','southwest');
    
    figname = fullfile(resDir, sprintf('%s_control_boxplots_as_percent_wm.pdf',filesFA{ns}));
    printFigToPDFa4(hfig,figname)
end
end