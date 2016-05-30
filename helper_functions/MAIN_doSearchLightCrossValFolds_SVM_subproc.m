function MAIN_doSearchLightCrossValFolds_SVM_subproc(subnum)
% get params 
p = genpath(pwd);
addpath(p); 
params = get_and_set_params();
% load data / file naming / saving 
datadir = fullfile('..','..','data','stats_normalized_sep_beta_FIR_ar6'); 
fn = sprintf('data_%.3d.mat',subnum);
load(fullfile(datadir,fn));
fnTosave = sprintf('results_VocalDataSet_FFX_ND_norm_%d-shuf_SLsize-%d_sub_-%.3d_',...
                    params.numShuffels,params.regionSize,subnum);
resultsdir = fullfile('..','results'); 
resultsDirName = fullfile(resultsdir,sprintf('results_VocalDataSet_FIR_AR6_FFX_ND_norm_%d-shuf_SLsize-%d',...
                            params.numShuffels,params.regionSize));
mkdir(resultsDirName);
% pre compute values 
start = tic;
idx = knnsearch(locations, locations, 'K', params.regionSize); % find searchlight neighbours 
shufMatrix = createShuffMatrixFFX(data,params);

%% loop on all voxels in the brain to create T map
for i = 1:(params.numShuffels + 1) % loop on shuffels 
    %don't shuffle first itiration
    if i ==1 % don't shuffle data
        labelsuse = labels;
    else % shuffle data
        labelsuse = labels(shufMatrix(:,i-1));
    end
    % create train and test set. 
    c = cvpartition(labelsuse,'Kfold',params.cvfold_folds);
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
    csave(i) = c;
    c = c.repartition;
    [ansMat(:,i) ] = mean(tmp,1)'; % voxels x shuffels 
    timeVec(i) = toc(start); reportProgress(fnTosave,i,params, timeVec);
end
fnOut = [fnTosave datestr(clock,30) '_.mat'];
save(fullfile(resultsDirName,fnOut));
msgtitle = sprintf('Finished sub %.3d ',subnum);
end