function MAIN_doSearchLight_Directional_basedOnFFX_ND_stelzer_perms_simu()
% This function uses previously run ND-FFX shuf matrices
% And runs a Directional FFX searchlight
subsToExtract = [20,150];
slsize = 27;
% [fn,pn] = uigetfile('ND*.mat');
% load(fullfile(pn,fn));
% numshufs = 100;
% numstlzrshufs = size(stlzerPermsAnsMat,2);
numstlzrshufs = 50;
ffxResFold = 'F:\vocalDataSet\processedData\matFilesProcessedData\vocalDataSetResults\results_VocalDataSet_FFX_ND_norm_1000shuf_SL27_reg_perm_ar3';
resultsDir  = ffxResFold;
% params = getParams;
params.numShuffels = numstlzrshufs-1;
params.regionSize = slsize;


%% generate sim data for first 100 voxels 40 x 27 x 20
% for j = 1:100 % loop on spheres
%     for i = 1:20 % loop on subjects
%         dataout(:,idx(j,:),i) = mvnrnd(zeros(1,27),ones(1,27),40);
%         % voxel idxs not independent...
%     end
% end

subsToExtract = 20;
start = tic;
% pool = parpool('local',7);
substorun = subsUsedGet(subsToExtract(1)); % 150 / 20 for vocal data set
fnTosave = ['DR' 'simulatio'];
timeVec = [];

%% get the data sepratly bcs of seed issues 
 for s = 1:length(substorun) % get data from each subject
        % find the data for this subject:
        ff = findFilesBVQX(ffxResFold,sprintf('*sub_%.3d*.mat',substorun(s)));
        load(ff{1},'mask','labels','shufMatrix','locations'); % don't load data from each subject 
        rng(s); % use a diffeent seed for each subject to recreate sub data on each fold 
        data_sim(:,:,s) = mvnrnd(zeros(1,40),ones(1,40),32482)';
 end

%% 
for k = 1:numstlzrshufs + 1 % loop on shuffels
    for s = 1:length(substorun) % get data from each subject
        % find the data for this subject:
        %ff = findFilesBVQX(ffxResFold,sprintf('*sub_%.3d*.mat',substorun(s)));
        %load(ff{1},'mask','labels','shufMatrix','locations'); % don't load data from each subject 
        %rng(s); % use a diffeent seed for each subject to recreate sub data on each fold 
        data = data_sim(:,:,s);
        %don't shuffle first itiration
        if k ==1 % don't shuffle data
            labelsuse = labels;
            rng(s); 
            labelsuse = labels(randperm(length(labelsuse)));
        else % shuffle data
            rng('shuffle')
            labelsuse = labels(randperm(length(labels)));
        end
        dataX = mean(data(labelsuse==1,:),1); % mean delta x
        dataY = mean(data(labelsuse==2,:),1); % mean delta y
        delta(s,:) = dataX-dataY;
        % get delta data from each subject according to the shuff matrix
    end
    
    idx = knnsearch(locations, locations, 'K', slsize);
    cnt = 1; 
    for j=1:10:320*100 % size(idx,1) % loop onvoxels % SIM LIMIT ! 
        deltabeam = delta(:,idx(j,:));
%         [ansMat(j,k,:) ] = calcTstatAll([],deltabeam); %% was this also in paper version 
        [ansMat(cnt,k) ] = calcTstatDirectional(deltabeam); %% was this also in paper version 
        cnt = cnt + 1;
    end
    clc
    timeVec(k) = toc(start); reportProgress(fnTosave,k,params, timeVec);
end

pval = calcPvalVoxelWise(squeeze(ansMat(:,:,1)));
SigFDR = fdr_bh(pval,0.05,'pdep','no');
ansMatReal = squeeze(ansMat(:,1,1));
subsExtracted = substorun;
save(fullfile(resultsDir,fnTosave),...
    'ansMat','ansMatReal','pval',...
    'locations','mask','fnTosave','subsExtracted','SigFDR');

delete(pool);
end
