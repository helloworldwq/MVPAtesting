function MAIN_doSearchLightCrossValFolds_SVM_subproc(subnum)
% get params
p = genpath(pwd);
addpath(p);
params = get_and_set_params();
params.partmode = 'short'; % short, long, rand
% load data / file naming / saving
datadir = fullfile('..','..','data','stats_normalized_sep_beta_FIR_ar6');
fn = sprintf('data_%.3d.mat',subnum);
load(fullfile(datadir,fn));
fnTosave = sprintf('results_VocalDataSet_FFX_ND_SVM_repart-mode-%s_%d-shuf_SLsize-%d_sub_-%.3d_',...
    params.partmode,params.numShuffels,params.regionSize,subnum);
resultsdir = fullfile('..','..','results');
resultsDirName = fullfile(resultsdir,sprintf('results_VocalDataSet_FIR_AR6_FFX_ND_repart-mode-%s_%d-shuf_SLsize-%d',...
    params.partmode,params.numShuffels,params.regionSize));
mkdir(resultsDirName);
% pre compute values
start = tic;
idx = knnsearch(locations, locations, 'K', params.regionSize); % find searchlight neighbours
shufMatrix = createShuffMatrixFFX(data,params);

part = getPartition(params,labels);



%% loop on all voxels in the brain to create T map
for i = 1:(params.numShuffels + 1) % loop on shuffels
    %don't shuffle first itiration
    if i ==1 % don't shuffle data
        labelsuse = labels;
    else % shuffle data
        labelsuse = labels(shufMatrix(:,i-1));
    end
    for k = 1:size(part.training,2)
        % train:
        datatrain = double(data(part.training(:,k),:));
        labelstrain = labelsuse(part.training(:,k));
        % test
        datatest = double(data(part.test(:,k),:));
        labelstest = labels(part.test(:,k)); % real labels
        for j=1:size(idx,1) % loop on voxels
            % svm 
            model = svmtrainwrapper(labelstrain',datatrain(:,idx(j,:)));
            [predicted_label, accuracy, third] = ...
                svmpredictwrapper(labelstest',datatest(:,idx(j,:)),model);
            tmp(k,j) = accuracy(1);% folds x voxels
            % multi t 
            x = datatrain(labelstrain==1,idx(j,:));
            y = datatrain(labelstrain==2,idx(j,:));
            tmp_multit(k,j) = calcTstatMuniMengTwoGroup(x,y);
        end
    end
    %ansMat_SVM
    %ansMat_Multit
    ansMat_SVM(:,i)  = mean(tmp,1)'; % voxels x shuffels
    ansMat_Multit(:,i) = mean(tmp_multit,1)'; % voxels x shuffels
    timeVec(i) = toc(start); reportProgress(fnTosave,i,params, timeVec);
end
fnOut = [fnTosave datestr(clock,30) '_.mat'];
save(fullfile(resultsDirName,fnOut));
msgtitle = sprintf('Finished sub %.3d ',subnum);
end

function part = getPartition(params,labels)
switch params.partmode
    case 'rand'
        % random partition
        c = cvpartition(labels,'Kfold',params.cvfold_folds);
        for i = 1:length(params.cvfold_folds);
            part.training(:,i) = c.training(i);
            part.test(:,i)     = c.test(i);
        end
        
    case 'short'
        % close  range  1:8 first fold. 1:16 second fold
        close_range_part = repmat([ones(1,4)*1,ones(1,4)*2,ones(1,4)*3,ones(1,4)*4,ones(1,4)*5],1,2);
        for i = 1:params.cvfold_folds;
            part.training(:,i) = (close_range_part~=i);
            part.test(:,i)     = (close_range_part==i);
        end
    case 'long'
        % long  range  1 9 17 , 2 10, 18 second fold.
        long_range_part = [repmat(1:5,1,4), repmat(1:5,1,4)];
        for i = 1:params.cvfold_folds;
            part.training(:,i) = (long_range_part~=i);
            part.test(:,i)     = (long_range_part==i);
        end
end
end
