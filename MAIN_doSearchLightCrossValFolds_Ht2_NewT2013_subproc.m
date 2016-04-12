function MAIN_doSearchLightCrossValFolds_Ht2_NewT2013_subproc(subnum)
datadir = '/home/roee/MultiT/Data/stats_normalized_sep_beta';
slSize = 27; 
fnTosave = sprintf('results_VocalDataSet_FFX_ND_norm_50shuf_SL%d_sub_%.3d_SVM',slSize,subnum);
resultsDir = fullfile(pwd, sprintf('results_VocalDataSet_FFX_ND_norm_50shuf_SL%d_SVM',slSize));
mkdir(resultsDir);

fn = sprintf('data_%.3d.mat',subnum);
load(fullfile(datadir,fn));
params = getParams();
addPathsForServer()
params.numShuffels = 50;
params.regionSize = slSize;


%% loop on all voxels in the brain to create T map
start = tic;
%% XXXX THIS PURGES ZERO VOXELS 
% load(fullfile(datadir,'idxzerosall153subs.mat'));
% idxskeep = setdiff(1:size(locations,1),idxzer);
% locations = locations(idxskeep,:);
%% XXXX 
idx = knnsearch(locations, locations, 'K', params.regionSize);
% preallocate for memory
params.NumTests = 1;
%ansMat = zeros(size(idx,1),1+params.numShuffels,params.NumTests);
shufMatrix = createShuffMatrixFFX(data,params);

for i = 1:(params.numShuffels + 1) % loop on shuffels 
    %don't shuffle first itiration
    if i ==1 % don't shuffle data
        labelsuse = labels;
    else % shuffle data
        labelsuse = labels(shufMatrix(:,i-1));
    end
    
    %% XXXXXX ARBITRARY PAIRING 
    [idxX, idxY, pairingname ] = getRealLabelIdxsDiffPairings(i) ;
%     idxX = find(labelsuse==1);
%     idxX = idxX(randperm(length(idxX)));
%     idxY = find(labelsuse==2);
%     idxY = idxY(randperm(length(idxX)));
    %%%%%% 
    for j=1:size(idx,1) % loop onvoxels 
        dataX = data(idxX,idx(j,:));
        dataY = data(idxY,idx(j,:));
        [ansMat(j,i,:) ] = calcTstatMuniMengTwoGroup(dataX,dataY);
        [ansMatOld(j,i,:) ] = calcTstatAll(params,dataX-dataY);
        [ansMatSVM(j,i,:) ] = calcSVM(dataX,dataY);
    end
    timeVec(i) = toc(start); reportProgress(fnTosave,i,params, slSize, timeVec);
end

fnOut = [fnTosave datestr(clock,30) '.mat'];
save(fullfile(resultsDir,fnOut));
msgtitle = sprintf('Finished sub %.3d ',subnum);
mailFromMatlab(msgtitle,'-');
end
