function [stlzerAnsMat, stlzerPerms] = createStelzerPermutations(ansMat,nummapscreate,avgmode)
%% This function create stelzer permutations given
% ansMat struc - voxels X shuffels X subjects 
start = tic; 
% QA 
if size(ansMat,2) < 2
    error('You do not have any shuffles in this data'); 
else
%     fprintf('creating %d stlzer shuffels from %d real shufs\n',...
%         nummapscreate,size(ansMat,2));
end
t = isnan(ansMat);
if ~sum(t(:))==0
    warning('You have NaNs in your avg ans mat data'); 
    ansMat(isnan(ansMat)) = 0; 
end
% check that you have shuffels and report what you will do 
% check that you don't have any nans 
numrealshufs = size(ansMat,2) - 1;
stlzerAnsMat = zeros(size(ansMat,1),nummapscreate+1);
rng('shuffle');
for j = 1:nummapscreate+1
        if j == 1 % real map
            tmp = squeeze(ansMat(:,1,:));
            stlzerAnsMat(:,j) = avgmap(tmp,avgmode);
        else
            %% new way 
            %{
            idxmaps = randperm(numrealshufs,size(ansMat,3)) + 1;
            stlzerPerms(:,j) = idxmaps; 
            idx_linear = sub2ind(size(ansMat),...
                repmat(1:size(ansMat,1),1,length(idxmaps))',... % voxels 
                reshape(repmat(idxmaps,size(ansMat,1),1),[],1),... % maps 
                reshape(repmat(1:size(ansMat,3),size(ansMat,1),1),[],1)); % subjects 
            stlzerAnsMat(:,j) = avgmap(squeeze(reshape(ansMat(idx_linear),size(ansMat,1),1,size(ansMat,3))),avgmode) ; 
            %}
            %% 
            %% legacy 
             
            idxmaps = randperm(numrealshufs,size(ansMat,3)) + 1;
            numSubs = size(ansMat,3);
            for k = 1:numSubs% extract rand map from each sub
                idxMap = idxmaps(k); % first map is real
                tmp(:,k) = ansMat(:,idxMap,k);
                stlzerPerms(k,j) = idxMap;
            end
            stlzerAnsMat(:,j) = avgmap(tmp,avgmode);
            %}
            %% 
        end
        clear tmp;
%         fprintf('finished comp map %d stlzr style\n',j);
end
fprintf('finished comp maps in %f \n',toc(start));
end

function outmap = avgmap(data,mode)
switch mode
    case 'mean'
        outmap = mean(data,2);
    case 'median'
        outmap = median(data,2);
    case 'nanmean'
        outmap = nanmean(data,2);
    case 'nanmedian'
        outmap = nanmedian(data,2);
end
        
end