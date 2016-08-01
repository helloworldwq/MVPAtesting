function MAIN_doSearchLight_Directional_FFX_SVM_fixed()
% This function runs FFX directional SVM
slsize = 27;
ffxResFold = fullfile('..','..','data','stats_normalized_sep_beta_FIR_ar6');
resultsDir  = ffxResFold;
params.numShuffels = 1e3;
params.regionSize = slsize;
params.cvfold_folds = 5 ;

fnTosave = sprintf('results_VocalDataSet_CVonce_FFX_DR_SVM_%d-shuf_SLsize-%d_folds_-%.3d_.mat',...
                    params.numShuffels,params.regionSize,params.cvfold_folds);


s20 = subsUsedGet(20);
substorun = s20;
start = tic;
%pool = parpool('local',20);

[dataout, labels, locations, mask] = loadData(substorun,ffxResFold); % data out trials x voxels x subjects 
idx = knnsearch(locations, locations, 'K', slsize);

%rng(1); 
rng('shuffle');
c = cvpartition(length(substorun),'Kfold',params.cvfold_folds); % partition on every shuffle 
for k = 1:params.numShuffels + 1  % loop on shuffels
    rng('shuffle');
    dataToAvg.data = dataout; 
    dataToAvg.labels = labels; 
    [dataoutAvg] = averagAndShuffleData(dataToAvg,k,'labelperms'); 
    c = cvpartition(length(substorun),'Kfold',params.cvfold_folds); % cvfold for average data - balanced

    for f = 1:params.cvfold_folds % loop on fold 
       [traindata_avg, testdata_avg] = partitionDataAfterAverage(dataoutAvg.data,dataoutAvg.labels,dataoutAvg.subj, c,f);
       for j=1:size(idx,1) % loop onvoxels
           % create train and test set.
           model = svmtrainwrapper2(traindata_avg.labels',traindata_avg.data(:,idx(j,:)) );
           [predicted_label, accuracy, third] = ...
               svmpredictwrapper(testdata_avg.labels',testdata_avg.data(:,idx(j,:)),model);
           tmp(f,j) = accuracy(1);% folds x voxels
           % calc multi-t on train data 
           beam = traindata_avg.data(:,idx(j,:));
           delta_beam = beam(traindata_avg.labels==1,:) - beam(traindata_avg.labels==2,:);
           tmp_multi_t(f,j) = calcTstatDirectional(delta_beam); 
       end
    end
    ansMat_SVM(:,k) = mean(tmp,1); % ans mat is voxels x shuffels 
    ansMat_Multit(:,k) = mean(tmp_multi_t,1);
    clc
    timeVec(k) = toc(start); reportProgress(fnTosave,k,params, timeVec);
end
    
kernal_used = 'linear';
pval_multit = calcPvalVoxelWise(ansMat_Multit);
pval_svm = calcPvalVoxelWise(ansMat_SVM);
SigFDR_multit = fdr_bh(pval_multit,0.05,'pdep','no');
SigFDR_svm = fdr_bh(pval_svm,0.05,'pdep','no');
subsExtracted = substorun;
save(fullfile(resultsDir,fnTosave),...
    'ansMat_SVM','ansMat_Multit','pval_multit','pval_svm',...
    'locations','mask','fnTosave','subsExtracted','SigFDR_multit','SigFDR_svm');
end

function [dataout, labels, locations, mask] = loadData(substorun,ffxResFold)
for s = 1:length(substorun) % get data from each subject
    % find the data for this subject:
    subnum = substorun(s);
    fn = sprintf('data_%.3d.mat',subnum);
    ff = fullfile(ffxResFold,fn);
    load(ff,'data','mask','locations','labels');
    dataout(:,:,s) = data;
end

end

function [traindata, testdata] = partitionData(dataout,labels,c,fold)
% data out trials x voxels x subjects 

traindata.labels = labels; 
traindata.data = dataout(:,:,c.training(fold)); 

testdata.labels = labels; 
testdata.data = dataout(:,:,c.test(fold)); 
end

function avgdata = averagAndShuffleData(data,k)
% data out trials x voxels x subjects 
cnt = 1;
for i = 1:size(data.data,3) % looop on subjects
    if k ==1 % don't shuffle data
        labelsuse = data.labels;
    else % shuffle data
	rng('shuffle');
        labelsuse = data.labels(randperm(length(data.labels)));
    end
    avgdata.data(cnt,:) = double(mean(data.data(labelsuse==1,:,i),1));
    avgdata.labels(cnt) = 1; 
    cnt = cnt + 1; 
    avgdata.data(cnt,:) = double(mean(data.data(labelsuse==2,:,i),1));
    avgdata.labels(cnt) = 2; 
    cnt = cnt + 1; 
end
end

function [traindata, testdata] = partitionDataAfterAverage(dataout,labels,subj,c,fold)
subj_idxs_train = find(c.training(fold) == 1); % get the subject numbers to train  
idxs_train = find(ismember(subj,subj_idxs_train)==1);

subj_idxs_test = find(c.test(fold) == 1); % get the subject numbers to test  
idxs_test = find(ismember(subj,subj_idxs_test)==1);

traindata.labels = labels(idxs_train);
traindata.data = dataout(idxs_train,:);

testdata.labels = labels(idxs_test);
testdata.data = dataout(idxs_test,:);

end
