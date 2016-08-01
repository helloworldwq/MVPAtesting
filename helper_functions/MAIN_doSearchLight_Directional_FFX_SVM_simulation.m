function MAIN_doSearchLight_Directional_FFX_SVM_simulation()
% This function runs FFX directional SVM
slsize = 27;
ffxResFold = fullfile('..','..','data','stats_normalized_sep_beta_FIR_ar6');
resultsDir  = ffxResFold;
params.numShuffels = 100;
params.regionSize = slsize;
params.cvfold_folds = 4;

fnTosave = sprintf('results_VocalDataSet_FFX_DR_SVM_%d-shuf_SLsize-%d_folds_-%.3d_.mat',...
    params.numShuffels,params.regionSize,params.cvfold_folds);


s20 = subsUsedGet(20);
substorun = s20;
start = tic;
% pool = parpool('local',7);

[dataout, labels, locations, mask] = loadData(substorun,ffxResFold); % data out trials x voxels x subjects
idx = knnsearch(locations, locations, 'K', slsize);
% labels = labels(randperm(length(labels))); % XXXXX

%% get the data sepratly bcs of seed issues
for s = 1:size(dataout,3) % get data from each subject
    rng(s); % use a diffeent seed for each subject to recreate sub data on each fold
    data_sim(:,:,s) = mvnrnd(zeros(1,40),ones(1,40),32482)';
end
dataout = data_sim;

%%
rng(1); % set seed
for k = 1:params.numShuffels + 1  % loop on shuffels
    rng('shuffle');
    dataToAvg.data = dataout; 
    dataToAvg.labels = labels; 
%     c = cvpartition(length(substorun),'Kfold',params.cvfold_folds); % create unique fold for each shuffle
    [dataoutAvg] = averagAndShuffleData(dataToAvg,k,'labelperms'); 
    c = cvpartition(length(substorun),'Kfold',params.cvfold_folds); % cvfold for average data - balanced
    for f = 1:params.cvfold_folds % loop on fold
        %         [traindata, testdata] = partitionData(dataout,labels,c,f);
        %     traindata_avg = averagAndShuffleData(traindata,k,'labelperms'); % 'signflip' - after avg subject 'labelperms' - within each sub
        %     testdata_avg = averagAndShuffleData(testdata,k,'labelperms'); % always shuffle test data
        [traindata_avg, testdata_avg] = partitionDataAfterAverage(dataoutAvg.data,dataoutAvg.labels,dataoutAvg.subj, c,f);
        cnt = 1;
        for j=1:40:90*350%:size(idx,1) % loop onvoxels
            % create train and test set.
            model = svmtrainwrapper(traindata_avg.labels',traindata_avg.data(:,idx(j,:)) );
            [predicted_label, accuracy, third] = ...
                svmpredictwrapper(testdata_avg.labels',testdata_avg.data(:,idx(j,:)),model);
            tmp(f,cnt) = abs(accuracy(1))-50;% folds x voxels
            tmp(f,cnt) = accuracy(1);% folds x voxels % XXXX CHANGE JONATHAN
            % calc multi-t on train data
            beam = traindata_avg.data(:,idx(j,:));
            delta_beam = beam(traindata_avg.labels==1,:) - beam(traindata_avg.labels==2,:);
            tmp_multi_t(f,cnt) = calcTstatDirectional(delta_beam);
            cnt = cnt + 1;
        end
    end
    ansMat_SVM(:,k) = mean(tmp,1); % ans mat is voxels x shuffels
    ansMat_Multit(:,k) = mean(tmp_multi_t,1); % XXXX 
    clc
    timeVec(k) = toc(start); reportProgress(fnTosave,k,params, timeVec);
end

simdetails = 'refold - every perm - idx - min. ovrlap - labels - perm before folds  - 100 shufs';
pval_multit = calcPvalVoxelWise(ansMat_Multit);
pval_svm = calcPvalVoxelWise(ansMat_SVM);
hfig = figure;
subplot(1,2,1); histogram(pval_multit,50);title('multi-t');
subplot(1,2,2); histogram(pval_svm,50);title('SVM');
suptitle(simdetails);
figfold = fullfile('..','..','figures','simulations');
save(fullfile(figfold,[simdetails '.mat']),'pval_multit','pval_svm','ansMat_Multit','ansMat_SVM')
saveas(hfig,fullfile(figfold,[simdetails '.jpeg']));
return ; 
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

function avgdata = averagAndShuffleData(data,k,switchingtype)
switch switchingtype
    case 'labelperms'
        % data out trials x voxels x subjects
        cnt = 1;
        for i = 1:size(data.data,3) % looop on subjects
            if k ==1 % don't shuffle data
                labelsuse = data.labels;
                %rng(i);
                %labelsuse = data.labels(randperm(length(data.labels)));
            else % shuffle data
                rng('shuffle');
                labelsuse = data.labels(randperm(length(data.labels)));
            end
            avgdata.data(cnt,:) = double(mean(data.data(labelsuse==1,:,i),1));
            avgdata.labels(cnt) = 1;
            avgdata.subj(cnt) = i;
            cnt = cnt + 1;
            avgdata.data(cnt,:) = double(mean(data.data(labelsuse==2,:,i),1));
            avgdata.labels(cnt) = 2;
            avgdata.subj(cnt) = i;
            cnt = cnt + 1;
        end
    case 'signflip'
        labelsuse = data.labels; % don't shuffle labels at this point 
        cnt = 1; 
        for i = 1:size(data.data,3) % looop on subjects
            % labels 1: 
             avgdata.data(cnt,:) = double(mean(data.data(labelsuse==1,:,i),1)); % real labels ones 
             avgdata.labels(cnt) = 1;
             if k ~=1
                 rng('shuffle');
                 labesTmp = randperm(2);
                 avgdata.labels(cnt) = labesTmp(1); % must be yoked  / balenced
             end
             cnt = cnt + 1; 
             % labels 2:
             avgdata.data(cnt,:) = double(mean(data.data(labelsuse==2,:,i),1)); % real labels twos 
             avgdata.labels(cnt) = 2;
             if k ~=1
                 avgdata.labels(cnt) = labesTmp(2); % must be yoked  / balenced
             end
             cnt = cnt + 1;
        end
end
end
