function MAIN_doSearchLightCrossValFolds_Ht2_NewT2013_subproc(subnum)
%% set path 
addpath(genpath(pwd));
cd('helper_functions'); 
[params, settings] = get_and_set_params();
%% load data / file naming / saving vocal 
datadir = settings.datadir;
fn = sprintf(settings.fnsearchstr,subnum);
load(fullfile(datadir,fn));
fnTosave = sprintf('%s%d-shuf_SLsize-%d_sub_-%.3d_',...
    settings.resprefix,params.numShuffels,params.regionSize,subnum);

resultsdir = fullfile('..','..','results');
resultsDirName = fullfile(resultsdir,sprintf('%s%d-shuf_SLsize-%d',...
    settings.resfoldprefix,params.numShuffels,params.regionSize));
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
    idxX = find(labelsuse==1);
	idxY = find(labelsuse==2);
    for j=1:size(idx,1) % loop on voxels 
        dataX = data(idxX,idx(j,:));
        dataY = data(idxY,idx(j,:));
        [ansMat(j,i,:) ] = calcTstatMuniMengTwoGroup(dataX,dataY);
    end
    timeVec(i) = toc(start); reportProgress(fnTosave,i,params, timeVec);
end
fnOut = [fnTosave datestr(clock,30) '_.mat'];
save(fullfile(resultsDirName,fnOut));
msgtitle = sprintf('Finished sub %.3d ',subnum);

%% push message that finished subject 
p = Pushbullet(settings.pushbullettok);
secsjobtook = toc(start);
durjob = sprintf('job took: %s',datestr(secsjobtook/86400, 'HH:MM:SS.FFF'));
p.pushNote([],'Finished Subject ',[msgtitle  fnOut])

end