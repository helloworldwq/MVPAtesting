function MAIN_doSearchLightCrossValFolds_SVM_subproc(subnum)
% get params 
p = genpath(pwd);
addpath(p); 
params = get_and_set_params();
% load data / file naming / saving 
datadir = fullfile('..','..','data','stats_normalized_sep_beta_FIR_ar6'); 
fn = sprintf('data_%.3d.mat',subnum);
load(fullfile(datadir,fn));
fnTosave = sprintf('results_VocalDataSet_FFX_ND_SVM_%d-shuf_SLsize-%d_sub_-%.3d_',...
                    params.numShuffels,params.regionSize,subnum);
resultsdir = fullfile('..','results'); 
resultsDirName = fullfile(resultsdir,sprintf('results_VocalDataSet_FIR_AR6_FFX_ND_norm_%d-shuf_SLsize-%d',...
                            params.numShuffels,params.regionSize));
mkdir(resultsDirName);
% pre compute values 
start = tic;
idx = knnsearch(locations, locations, 'K', params.regionSize); % find searchlight neighbours 
shufMatrix = createShuffMatrixFFX(data,params);

% close range 1:8 first fold. 1:16 second fold 
% long range - 1 9 17 , 2 10, 18 second fold. 
% create train and test set.
% random 

% random partition 
c = cvpartition(labels,'Kfold',params.cvfold_folds);
for i = 1:length(params.cvfold_folds); 
    part.training(:,i) = (long_range_part~=i);
    part.test(:,i)     = (long_range_part==i);
end

% close  range  
close_range_part = repmat([ones(1,4)*1,ones(1,4)*2,ones(1,4)*3,ones(1,4)*4,ones(1,4)*5],1,2);
for i = 1:params.cvfold_folds; 
    part.training(:,i) = (close_range_part~=i);
    part.test(:,i)     = (close_range_part==i);
end

% long range 
c = cvpartition(repmat(1:5,1,8),'Kfold',params.cvfold_folds);



%% loop on all voxels in the brain to create T map
for i = 1:(params.numShuffels + 1) % loop on shuffels 
    %don't shuffle first itiration
    if i ==1 % don't shuffle data
        labelsuse = labels;
    else % shuffle data
        labelsuse = labels(shufMatrix(:,i-1));
    end
    for k = 1:c.NumTestSets
        % train: 
        datatrain = double(data(c.training(k),:));
        labelstrain = labelsuse(c.training(k));
        % test
        datatest = double(data(c.test(k),:));
        labelstest = labels(c.test(k)); % real labels 
        for j=1:size(idx,1) % loop on voxels
            model = svmtrainwrapper(labelstrain',datatrain(:,idx(j,:)));
            [predicted_label, accuracy, third] = ...
                svmpredictwrapper(labelstest',datatest(:,idx(j,:)),model);
            tmp(k,j) = accuracy(1);% folds x voxels 
        end
    end
    [ansMat(:,i) ] = mean(tmp,1)'; % voxels x shuffels 
    timeVec(i) = toc(start); reportProgress(fnTosave,i,params, timeVec);
end
fnOut = [fnTosave datestr(clock,30) '_.mat'];
save(fullfile(resultsDirName,fnOut));
msgtitle = sprintf('Finished sub %.3d ',subnum);
end
