function fixedAnsMat = fixAnsMat(ansMat,locations,mode)
% this function fixes ans mats that have zeros in them.
% ans mat is of the stucture  voxels x shuffels. first columns is always
% the real data shuffle
fixedAnsMat = [];
%% find problem areas and report them:

% nan's that exist in all shuffels + real 
nanAnsMat = isnan(ansMat); 
idxnans_voxels = find(sum(nanAnsMat,2) == size(ansMat,2));
tmprows = repmat(idxnans_voxels,401,1);
tmpcols = []; 
for i = 1:size(nanAnsMat,2) 
    tmpcols = [tmpcols ; ones(length(idxnans_voxels),1)*i];
end 
idxs_linear_all_shufs =  sub2ind(size(nanAnsMat),tmprows,tmpcols);
% nan's that exist only in ALL shuffels 
idxnans_shufs = find(sum(nanAnsMat(:,2:end),2) == size(ansMat,2)-1);
idxshuf_only  = setdiff(idxnans_shufs,idxnans_voxels);
% nan's that exist only in real but not in all shuffels 
idxnans_real_all = find(nanAnsMat(:,1) == 1);
idxnans_real_only = setdiff(idxnans_real_all,idxnans_voxels);
idxnans_real_only_linear = sub2ind(size(nanAnsMat),idxnans_real_only,...
    repmat(1,length(idxnans_real_only),1));
[idxrows_real_only, idxcolums_real_only] = ind2sub(size(nanAnsMat),idxnans_real_only_linear);
% nan's that exist only in some shufs 
idx_all_nans_linear = find(nanAnsMat == 1);
idx_linear_exist_only_some_shuf = setdiff(idx_all_nans_linear,idxs_linear_all_shufs);
idxrows_somshuf = setxor(idxnans_voxels,1:size(nanAnsMat,1)); 
[idxrows, idxcolums] = ind2sub(size(nanAnsMat),idx_linear_exist_only_some_shuf);
% expected total nans' 
fprintf('\t %d nans all shufs, %d unq voxels, %d unq shufs, %d real only %d expected %d found\n',...
    length(idxnans_voxels),...
    length(unique(idxrows)),...
    length(unique(idxcolums)),...
    length(idxnans_real_only),...
    length(idxnans_voxels)*size(ansMat,2) + size(idxrows,1),...
    sum(nanAnsMat(:)));


%% fix the problem
% mode = 'equal-zero';
% mode = 'equal-min';
% mode = 'weight';

fixedAnsMat = ansMat;
%idxnbrs = knnsearch(locations, locations, 'K', 10); % will take the 10 closest non nan vals
switch mode
    case 'equal-zero'
        fixedAnsMat(idxnan(:,1),:) = 0; % this creats the same value for all shuffels
    case 'weight' % this creats a diffrent value for each shuf
        for i = 1:size(idxnan,1) % loop on nan indxs
            tidx = idxnan(i,1);
            % within each shuffle, extracct the closest neighbous
            nbrs = idxnbrs(tidx,:);
            for s = 1:size(ansMat,2)
                if isnan(ansMat(nbrs(1),s)) % only replace if this shuffle has nan
                    nbrsfnd = ansMat(nbrs,s);
                    toweight = nbrsfnd(~isnan(nbrsfnd));
                    if isempty(toweight) | length(toweight) < 3 % closes 27 neibhours also nan give min val
                        replaceval = min(ansMat(:));
                        fixedAnsMat(tidx,s) = replaceval;
                    else
                        replaceval = mean(toweight(1:3));
                        fixedAnsMat(tidx,s) = replaceval;
                    end
                end
            end
        end
    case 'equal-min'
        fixedAnsMat(idxnan(:,1),:) = min(ansMat(:)); % this also creates the same val for all shufs
    case 'anatomical'
        fixedAnsMat = ansMat; 
        fixedAnsMat(isnan(ansMat)) = min(ansMat(:));
    case 'new-weight' % tailor version:
        % if nan's in all voxels they all get zero 
        if ~isempty(idxnans_voxels)
            fixedAnsMat(idxnans_voxels,:) = 0;
        end
        % if unique voxels only in shuffle get average shuff from that voxels  
        if ~isempty(idxrows)
            fixedAnsMat(idx_linear_exist_only_some_shuf) = nanmean(fixedAnsMat(idxrows,2:end),2);
        end
        % shuf only exists in real -give it max value of shuf 
        if ~isempty(idxnans_real_only_linear)
            fixedAnsMat(idxnans_real_only_linear) = nanmax(fixedAnsMat(idxrows_real_only,2:end),[],2);
        end
end

end 