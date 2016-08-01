function MAIN_doSearchLight_Directional()
% This function runs a Directional FFX searchlight 
slsize = 27;
numshufs = 2;
ffxResFold = fullfile('..','..','data','stats_normalized_sep_beta_FIR_ar6');
resultsDir  = ffxResFold;
params = getParams;
params.numShuffels = numshufs;
params.regionSize = slsize;

subsToExtract = [20,150];
subsToExtract = 20;
start = tic;
% pool = parpool('local',7);
for i = 1:length(subsToExtract) % loop on fold 20 / 150 subjects
    substorun = subsUsedGet(subsToExtract(i)); % 150 / 20 for vocal data set
    fnTosave = sprintf('results_DR_shufs-%d_subs-%d_slsize-%d.mat', numshufs,subsToExtract(i),slsize) ;
    timeVec = [];
    for k = 1:numshufs % loop on shuffels
        for s = 1:length(substorun) % get data from each subject
            % find the data for this subject:
            ff = findFilesBVQX(ffxResFold,sprintf('data_%.3d*.mat',substorun(s)));
            load(ff{1},'data','mask','labels','locations');
            %don't shuffle first itiration
            if k ==1 % don't shuffle data
                labelsuse = labels;
            else % shuffle data
                rng('shuffle');
                labelsuse = labels(randperm(length(labels)));
            end
            dataX = mean(data(labelsuse==1,:),1); % mean delta x
            dataY = mean(data(labelsuse==2,:),1); % mean delta y
            delta(s,:) = dataX-dataY;
            % get delta data from each subject according to the shuff matrix
        end
        
        idx = knnsearch(locations, locations, 'K', slsize);
        for j=1:size(idx,1) % loop onvoxels
            deltabeam = delta(:,idx(j,:));
            [ansMat(j,k,:) ] = calcTstatDirectional(deltabeam);
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
end

%% push message that finished subject 
p = Pushbullet('o.6i6t6UA0GYvxXgtKZpVjJUIazDFHeF6e');
secsjobtook = toc(startjobtime);
durjob = sprintf('job took: %s',datestr(secsjobtook/86400, 'HH:MM:SS.FFF'));
p.pushNote([],'Finished Directional ',[fnTosave 'in'  durjob ])
%% 
end
