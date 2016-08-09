function compare_FuA_values_Anatomical_Labels()
% This function creats the WM,CSF and GM masks in the MNI space.
% add path 
p = genpath('D:\Roee_Main_Folder\1_AnalysisFiles\Poldrack_RFX\');addpath(p);
%% load raw FA maps
filesFA = {'RAW_FA_VALS_ar6_27-subs_20-slsize','RAW_FA_VALS_ar6_27-subs_150-slsize'};
numsubstot = [20, 150];
slsize = 27; 
params.measureuse   = 'rawFuA_skewness';% which symmetry measure to use (FuA unit normed, FuA non unit normed, Symmetry, directioanl multi-t)
% rawFuA_nonNormalized , rawFuA_symmetry, rawFuA_unitNormalized, rawFuA_skewness
% drrealdata, rawFuA_normdiff_unitnorm, rawFuA_normdiff_nonunitnorm
for ns = 1
    numsubs= numsubstot(ns);
    resDir = fullfile('..','..','results',...
        sprintf('results_VocalDataSet_FIR_AR6_FFX_ND_norm_400-shuf_SLsize-%d',slsize));
    %load([filesFA{ns} '.mat']);
    % vmpbasefn = filesFA{ns}; % just GM has 1
    % vmp = BVQXfile(fullfile(resDir,[vmpbasefn  '.vmp']));
    %% directional (load dir data 
    rootDir2ndlvl = fullfile('..','..','results',...
        sprintf('results_VocalDataSet_FIR_AR6_FFX_ND_norm_400-shuf_SLsize-%d',slsize),...
        '2nd_level');
    dirfnm  = sprintf('results_DR_shufs-5000_subs-%d_slsize-%d.mat',numsubstot(ns),slsize);
    load(fullfile(rootDir2ndlvl,dirfnm),'drrealdata','mask','locations');
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
    
    %% load FuA values and move to 3d 
    % RAW_FA_VALS_ar6_27-subs_150-slsize
    % RAW_FA_VALS_ar6_subs-150_slsize-27
    fnToload = sprintf('RAW_FA_VALS_ar6_subs-%d_slsize-%d.mat',...
        numsubstot(ns),slsize);
    load(fullfile(resDir,fnToload));
    rawFA = scoringToMatrix(mask,double(eval(params.measureuse)'),locations); %  SigFDR must be row vector % rawFuA_symmetry % rawFuA_nonCentered
    rawDir3d = scoringToMatrix(mask,double(drrealdata'),locations); %  SigFDR must be row vector % rawFuA_symmetry % rawFuA_nonCentered
    
    % rawFA = vmp.Map(1).VMPData; % map number 4 is SL size 47
    rawVals = double(rawFA);
    %% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%     load(fullfile(resDir,'FAepiVsRealin3d.mat'));
%     faControl = eval(sprintf('faEPI3D%.3d',numsubs) );
    faControl = rawDir3d; %% TEMP to do SL size 9
    rawValsControl = double(faControl); 
    idxsZeroVals = find(rawVals==0);
    % cortical data
    for j = 1:length(areaIdxs);
        faData(j).mapName = vmpatlas.Map(areaIdxs(j)).Name;
        idxsOfLabel = find(vmpatlas.Map(areaIdxs(j)).VMPData==1);
        idxsOfLabelWithDataFA = setdiff(idxsOfLabel,idxsZeroVals);
        valsInLabel = rawVals(idxsOfLabelWithDataFA);
        valsInLabel_Dir = rawDir3d( idxsOfLabelWithDataFA);
        faData(j).vals = valsInLabel;
        faData(j).vals_dir = valsInLabel_Dir;
        faData(j).mean = mean(valsInLabel);
        faData(j).mean_dir = mean(valsInLabel_Dir);
        faData(j).median = median(valsInLabel);
        faData(j).median_dir = median(valsInLabel_Dir);
        faData(j).sd = std(valsInLabel);
        faData(j).sem = std(valsInLabel)/sqrt(length(valsInLabel)); % standard error of the mean
        faData(j).sem_dir = std(valsInLabel_Dir)/sqrt(length(valsInLabel_Dir)); % standard error of the mean
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
        valsInLabel_Dir = rawDir3d( idxsOfLabelWithDataFA);
        faData(j).vals = valsInLabel;
        faData(j).vals_dir = valsInLabel_Dir;
        faData(j).mean = mean(valsInLabel);
        faData(j).mean_dir = mean(valsInLabel_Dir);
        faData(j).median = median(valsInLabel);
        faData(j).median_dir = median(valsInLabel_Dir);
        faData(j).sd = std(valsInLabel);
        faData(j).sem = std(valsInLabel)/sqrt(length(valsInLabel)); % standard error of the mean
        faData(j).sem_dir = std(valsInLabel_Dir)/sqrt(length(valsInLabel_Dir)); % standard error of the mean
        faData(j).control = rawValsControl(idxsOfLabelWithDataFA);
        faData(j).Means_control = mean(rawValsControl(idxsOfLabelWithDataFA));
        faData(j).Median_control = median(rawValsControl(idxsOfLabelWithDataFA));
        faData(j).idxsIn3Dspace = idxsOfLabelWithDataFA;
    end
    faTable = struct2table(faData);
    
    %% scatter of measure vs dr real data in all of brain 
    hfig = figure; 
    scatter(eval(params.measureuse),drrealdata,0.5);
    xlabel(getLabel(params.measureuse)); ylabel('Directional M&M');
    title(sprintf('%s values vs Directional M&M (subs-%d)',...
        getLabel(params.measureuse),numsubs),'FontSize',10);
    fnms = sprintf('CORR_measure-%s_subs-%.3d_slsize-%.2d.jpeg',...
        genvarname(params.measureuse),numsubs,slsize);
    dirsave = 'D:\Roee_Main_Folder\1_AnalysisFiles\Poldrack_RFX\Publish_Ready_Process\figures\FuA_temp';
    hfig.PaperPositionMode = 'auto';
    saveas(hfig,fullfile(dirsave,fnms));
    xlimsuse = xlim; ylimsuse = ylim;
    close(hfig); 
    
    %% organize data for gramm structure 
    FuA = []; MandMdir = []; labelidx = []; labelstr = {}; 
    cm = colormap(parula(20));
    %figure;
    %hold on;
    hfig = figure('visible','on','Position',[428         364        1132         974]);
    hold on; 
    for i = 1:size(faTable,1)
        FuA = [FuA ; faTable.vals{i}];
        MandMdir = [MandMdir ; faTable.vals_dir{i}];
        labelstr = [labelstr; repmat(faTable.mapName(i),length(faTable.vals_dir{i}),1)];
        labelidx = [labelidx; repmat(i,length(faTable.vals_dir{i}),1)];
        y = faTable.vals_dir{i};
        subplot(4,3,i);
        scatter( faTable.vals{i},y, 3,cm(i,:));
        xlim(xlimsuse); ylim(ylimsuse); 
        title(faTable.mapName{i},'FontSize',10);
        
        xlabel(getLabel(params.measureuse),'FontSize',8); ylabel('Directional M&M','FontSize',8);
        [rowuse,coluse] = ind2sub([4,3],i+1);
        g(rowuse,coluse) = gramm('x',faTable.vals{i},'y',y);
        g(rowuse,coluse).set_names('x',getLabel(params.measureuse),'y','Directional M&M');
        g(rowuse,coluse).set_title(faTable.mapName{i});
        g(rowuse,coluse).geom_point();
        g(rowuse,coluse).facet_grid('scale','fixed')
        %xlim([0.9 1.16]);
        title(faTable.mapName{i});
        regiongname = genvarname(faTable.mapName{i});
    end
    suptitle(sprintf('%s vs DR m&m (%.3d subs)',...
        getLabel(params.measureuse),numsubs));
    fnms = sprintf('SCATTER_measure-%s_subs-%.3d_slsize-%.2d.jpeg',...
        genvarname(params.measureuse),numsubs,slsize);

    dirsave = 'D:\Roee_Main_Folder\1_AnalysisFiles\Poldrack_RFX\Publish_Ready_Process\figures\FuA_temp';
    hfig.PaperPositionMode = 'auto';
    saveas(hfig,fullfile(dirsave,fnms));
    close(hfig);
    
    labels = faTable.mapName;
    g = gramm('x',FuA,'y',MandMdir,'color',labelidx); 
    g.facet_grid([],labelstr,'scale','fixed');
    g.facet_wrap(labelstr,'ncols',4);
    % figure;
    % g.draw;
    
    g(1,1).stat_ellipse(); 
    g(1,1).set_names('x' , getLabel(params.measureuse), 'y', 'MandMDir','Color', 'Regions:');
    g.set_title([getLabel(params.measureuse) ' vs M&M'],'FontSize',10); 
%     hfig  = figure;
%     g.draw;
    %% create bar graphs of all regions:
    means = [faTable.median];
    sem  = [faTable.sem];
    hfig = figure; hold on;
    set(gcf,'Position',[1000         667        1279         671])
    cm = colormap(parula(14));
    for i = 1:size(faTable,1); bar(i,means(i),'FaceColor',cm(i,:));end
    ylim([min(means)*0.9 max(means)*1.1])
    set(gca,'XTick',1:size(faTable,1))
    labels = faTable.mapName;
    for i = 1:size(faTable,1); labels{i} = sprintf('%2d. %s',i,labels{i}); end
    legend(labels,'Location','northeastoutside');
    
    errorbar(1:length(faData),means,sem,'.',...
        'LineWidth',2)
    ylabel(getLabel(params.measureuse));
    xlabel('ROI #');
    title(sprintf('%s values higher in primary auditory regions %d subs',...
        getLabel(params.measureuse),numsubs));
    
    dirsave = 'D:\Roee_Main_Folder\1_AnalysisFiles\Poldrack_RFX\Publish_Ready_Process\figures\FuA_temp';
    fnms = sprintf('BAR_measure-%s_subs-%.3d_slsize-%.2d.pdf',...
        genvarname(params.measureuse),numsubs,slsize);
    hfig.PaperPositionMode = 'auto';
    saveas(hfig,fullfile(dirsave,fnms));
    close(hfig); 
    % printFigToPDFa4(hfig,figname)
    
    return ; 
    
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
end
end