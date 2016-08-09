function MAIN_compute_raw_FuA_vals()
% This function creates raw FuA vals and makes a VMP out of them.

subsToExtract = [20,150];
slsize = 9;
numshufs = 100;
ffxResFold = fullfile('..','..','data','stats_normalized_sep_beta_FIR_ar6');
resultsDir  = fullfile('..','..','results','results_VocalDataSet_FIR_AR6_FFX_ND_norm_400-shuf_SLsize-27','2nd_level');
params = get_and_set_params;
params.numShuffels = numshufs;
params.regionSize = slsize;
params.numShuffels = numshufs;


for i = 1:length(subsToExtract) % loop on fold 20 / 150 subjects
    substorun = subsUsedGet(subsToExtract(i)); % 150 / 20 for vocal data set
    timeVec = [];    
    fnTosave = sprintf('RAW_FA_VALS_ar6_subs-%d_slsize-%d.mat',...
        subsToExtract(i),slsize);
    
    fnmuse = fullfile(pwd,sprintf('delta_from-%.3d_subs.mat',subsToExtract));
    if ~exist(fnmuse,'file')
        for s = 1:length(substorun) % get data from each subject
            % find the data for this subject:
            ff = findFilesBVQX(ffxResFold,sprintf('*data_%.3d*.mat',substorun(s)));
            load(ff{1},'data','mask','labels','locations');
            labelsuse = labels; % just real data no shuffle
            dataX = mean(data(labelsuse==1,:),1); % mean delta x
            dataY = mean(data(labelsuse==2,:),1); % mean delta y
            delta(s,:) = dataX-dataY;
            % get delta data from each subject according to the shuff matrix
            
            save(fnmuse,'delta','mask','locations');
        end
    else
        load(fnmuse,'delta','mask','locations');
    end
    idx = knnsearch(locations, locations, 'K', slsize);
    for j=1:size(idx,1) % loop onvoxels
        deltabeam = delta(:,idx(j,:));
        % delta beam for FA computation should be sphers x subs (hence
        % transpose)
        % [rawFA(j) ]                 = calcClumpingIndexSVD_demeaned(deltabeam');
        [rawFuA_nonNormalized(j) ]     = calcClumpingIndexSVD(deltabeam',0); % calcClumpingIndexSVD([spheres x subs],normalize) if normalize = 1 --> unit normalize spheres. 
        [rawFuA_unitNormalized(j) ]    = calcClumpingIndexSVD(deltabeam',1); % calcClumpingIndexSVD([spheres x subs],normalize) if normalize = 1 --> unit normalize spheres. 
        [rawFuA_symmetry(j) ]          = calcSymmetryMeasure(deltabeam');
        [rawFuA_normdiff(j) ]          = calcNormDiffMeasure(deltabeam');
        [rawFuA_skewness(j) ]          = calcSkewnessMeasure(deltabeam');
        
        fprintf('print %d\n',j); 
    end
    save(fullfile(resultsDir,fnTosave),...
        'rawFuA*',...
        'locations','mask','fnTosave','substorun');
    % create and save VMP with FA val
    n = neuroelf;
    vmp = BVQXfile(fullfile(pwd,'blank_MNI_3x3res.vmp'));
    mapstruc = vmp.Map;
    vmpdat = scoringToMatrix(mask,double(rawFuA_symmetry'),locations); % note that SigFDR must be row vector
    vmp.Map.VMPData = vmpdat;
    vmp.Map(1).LowerThreshold = min(vmpdat(:));
    vmp.Map(1).UpperThreshold = max(vmpdat(:));
    vmp.Map(1).UseRGBColor = 0;
    vmp.SaveAs(fullfile(resultsDir,[fnTosave(1:end-4),'.vmp']));
    vmp.ClearObject;
    clear vmp;
end



end