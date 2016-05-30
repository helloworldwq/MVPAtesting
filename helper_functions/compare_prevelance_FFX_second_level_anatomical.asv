function compare_prevelance_FFX_second_level_anatomical()
%% settings:
params.num_drawings     = 20;
params.num_subs_to_draw = 20;
params.uval_ruti        = 0.3;
params.numstlzrmaps     = 5e2;
params.numdirmaps       = 1e2; 
params.avgmod           = 'median';
params.num_partition    = 5;
params.mode_use         = 'oos'; % out of sample = oos , swr = sampling with replacement
%% load ffx data
params.foldranayze = 'results_VocalDataSet_anatomical_AR6_FFX_ND_norm_100-shuf';
reslts_dir = fullfile('..','..','results',params.foldranayze);
params.figdir = fullfile('..','..','figures',params.foldranayze); 
load(fullfile(reslts_dir,'all_ans_mats.mat')...
    ,'ansMatRaw','idxslabelsout','idxsout','mask','locations','subnums');
subnums_agre(:,1) = subnums; clear subnums
%% load data 
all_data = [];labels = []; % in case line below is commente. 
load(fullfile(reslts_dir,'all_data_150_subs.mat'),'all_data','labels','subnums')
data.all_data = all_data;
data.labels = labels; 
subnums_agre(:,2) = subnums; clear subnums

%% load pval data
ff = findFilesBVQX(reslts_dir,'allPvals*.mat');
load(ff{1},'allpvals','subnums');
subnums_agre(:,3) = subnums;

%% store some data in params 
params.idxslabelsout = idxslabelsout;
params.ansMatRaw = ansMatRaw;
params.idxsout = idxsout;
params.mask = mask;
params.locations = locations;

%% trim subjects with nans in the "real" shuffle
[data.pvals, data.ansmat, data.idx_keep] = trimnan(allpvals,ansMatRaw);
% all_data_trim = all_data(:,:,idx_keep);
switch params.mode_use
    case 'oos'
        %% loop on number of draws and calc sig maps
        cnt = 1; 
        c = cvpartition(size(data.pvals,2),'Kfold',params.num_partition);
        rng(0); % set seed
        params.c = c; 
        for i = 1:params.num_drawings
            for j  = 1:params.num_partition
                [pvals_fold, ansmat_fold, dat_fold] = extract_subs_partition(c.test(j) ,params,data );
                [rslts.sig_ruti(:,cnt), rslts.pval_ruti(:,cnt)] = calc_ruti_return_sig(pvals_fold,params);
                [rslts.sig_ffx(:,cnt), rslts.pval_ffx(:,cnt)]  = calc_ffx_return_sig(ansmat_fold,params);
%                 [rslts.sig_ffx_dir(:,cnt), rslts.pval_ffx_dir(:,cnt)]  = calc_ffx_dir_return_sig(dat_fold,params);
                cnt = cnt + 1;
            end
            plot_pvals_fig(rslts,params,data,i); % this plots first graph with out of subject effects 
%             tmp_effects = get_oos_effects(rslts,params,data);
%             tmp = getpercents(rslts); 
            [rsltsout.ruti_pr(i), rsltsout.ffx_pr(i)] =  getpercents_across_regions(rslts,params); 
%             rsltsout.sig_ruti_pecrc(:,i) =  tmp.sig_ruti_pecrc;
%             rsltsout.sig_ffx_pecrc(:,i) =  tmp.sig_ffx_pecrc;
            clear rslts ; cnt = 1; 
            rng(i); % set seed
            c = c.repartition;
        end
        % plot results 
         plot_oos_consistency_selecting_results(rsltsout,params); 
         plotstuff_oos_percent_over(params,tmp_effects);
         plotstuff_oos(params,rsltsout)
    case 'swr'
        %% calculate on out of sample fold
        for i = 1:params.num_drawings
            [pvals_fold, ansmat_fold] = extract_subs(i,params.num_subs_to_draw, pvals,ansmat);
            [rslts.sig_ruti(:,i), rslts.pval_ruti(:,i)] = calc_ruti_return_sig(pvals_fold,params);
            %     fprintf('% d sig regions\n',sum(sig_ruti(:,i)));
            [rslts.sig_ffx(:,i), rslts.pval_ffx(:,i)]  = calc_ffx_return_sig(ansmat_fold,params);
        end
        % plot results 
        plotstuff(params,rslts)
end

end

function plot_oos_consistency_selecting_results(rsltsout,params)
hfig = figure;
data = [  rsltsout.ruti_pr; rsltsout.ffx_pr]';
groupidx = [ 1; 2 ]; 
groupname = {'ruti','ffx'};
barpatch(data);
h=findobj(gca, 'Type', 'patch'); 
h(2).FaceColor = [0.6 1 0.6]; % reverse order 
h(1).FaceColor = [1 0.6 0.6]; 
legend([h(2), h(1)],{'Prevelance','ND-FFX-group'})
ylabel('% regions deemed significant out of sample')
title('Replicability prospects / analysis');

figttl = sprintf('out_of_sample_bar_plot_avg_across_regions_u-%.2f_draws-%d_subs-%d.pdf',...
        params.uval_ruti, params.num_drawings, params.c.TestSize(1));
export_fig(fullfile(params.figdir,figttl),'-dpdf','-nocrop','-transparent');
close(hfig); 

end

function plot_pvals_fig(rslts,params,data,fold) 
idxsig_ruti = find(rslts.sig_ruti(:,1)==1); 
idxsig_ffx =  find(rslts.sig_ffx(:,1)==1); 
idxsig_regins = unique([idxsig_ffx; idxsig_ruti]);
[~,patchidx] = intersect(idxsig_regins,idxsig_ruti);
rawidxs = zeros(length(idxsig_regins),1);
rawidxs(patchidx) = 1; 
patchidx = find(fliplr(rawidxs')==1); % patches are in reverse order 
rutipatch_idx= patchidx(1); 
tmp = setdiff(1:length(rawidxs),patchidx);
ffxpatch_idx = tmp(1); 

raw_oos_pvals = data.pvals(idxsig_regins,params.c.training(1))';
log_pvals = -log10(raw_oos_pvals);
% plotting 
hfig = figure;
hfig.Position = [1000         246        1426        1092];
hold on; 
notBoxPlot(log_pvals,[],0.6,'sdline')
ylabel('-log_1_0 p-value'); 
boxaxis = get(gca);
h=findobj(gca, 'Type', 'patch'); 
for i = 1:length(patchidx)
    h(patchidx(i)).FaceColor = [0.6 1 0.6];
end
set(gca,'XTickLabel',params.idxslabelsout(idxsig_regins));
set(gca,'XTickLabelRotation',20);
xlim = get(gca,'XLim');
h1 = line(xlim, [-log10(0.05) -log10(0.05)],...
    'LineStyle','--','Color',[0.5 0.5 0.5] ,'LineWidth',2);
h2 = line(xlim, [-log10(0.01) -log10(0.01)],...
    'LineStyle','--','Color',[0.2 0.2 0.2] ,'LineWidth',2);
legend([h1 h2 h(rutipatch_idx) h(ffxpatch_idx)],{'p = 0.01', 'p = 0.05', 'prevelance','ND-FFX-group'});  % Only the blue and green lines appear
figttl = sprintf('Out of sample box plot u-%.2f draws-%d subs-%d',...
        params.uval_ruti, params.num_drawings, params.c.TestSize(1));
title(figttl); 
% set font 
set(findall(hfig,'-property','FontSize'),'FontSize',12)
set(findall(hfig,'-property','Font'),'Times New Roman',12)
% fig name 
figttl = sprintf('Out_of_sample_box_plot_pvals_u-%.2f_draws-%d_fold-%d_subs-%d.pdf',...
        params.uval_ruti, params.num_drawings,fold, params.c.TestSize(1));
export_fig(fullfile(params.figdir,figttl),'-dpdf');
close(hfig); 

end



function plotstuff(params,rslts)
idxslabelsout = params.idxslabelsout;
ansMatRaw = params.ansMatRaw ;
idxsout = params.idxsout;
mask = params.mask ;
locations = params.locations ;
foldranayze = params.foldranayze;

sig_ffx = rslts.sig_ffx;
pval_ffx = rslts.pval_ffx;
sig_ruti = rslts.sig_ruti;
pval_ruti = rslts.pval_ruti;

%% plot img
figdir = fullfile('..','..','figures', foldranayze);
% plot results in imagesdf
hfig = figure;
hfig.Position = [320         278        1708        1018];
subplot(1,2,1);
himg = imagesc(sum(sig_ruti,2)/size(sig_ruti,2)); axis off;
xlabel('region');
colorbar;
title(sprintf('ruti u = %f, %d draws of %d subs',...
    params.uval_ruti, params.num_drawings, params.num_subs_to_draw));

for i = 1:length(idxslabelsout)
    text(0.5,i,idxslabelsout{i},'Color',[0.5 0.5 0.5],'FontSize',10);
end

subplot(1,2,2);
himg = imagesc(sum(sig_ffx,2)/size(sig_ffx,2)); axis off;
colorbar;
title(sprintf('ND FFX %d stlzer map (from 100), %d draws of %d subs',...
    params.numstlzrmaps, params.num_drawings, params.num_subs_to_draw));

for i = 1:length(idxslabelsout)
    text(0.5,i,idxslabelsout{i},'Color',[0.5 0.5 0.5],'FontSize',10);
end
fnmstitl = sprintf('color_bars_u-%.2f_num_subs_per_draw-%d_num_drawings-%d',...
    params.uval_ruti,params.num_subs_to_draw,params.num_drawings);
suptitle(strrep(fnmstitl,'_',' '));
fnms = [fnmstitl '.pdf'];
export_fig(fullfile(figdir,fnms),'-dpdf');
close(hfig);
%%

%% plot bar
hfig = figure;
hfig.Position = [330         270        1514        1007] ;
subplot(2,2,1);
bar(sum(sig_ruti,2)/size(sig_ruti,2));
ylabel('percent of draws declare region sig.')
title(sprintf('ruti u = %f, %d draws of %d subs',...
    params.uval_ruti, params.num_drawings, params.num_subs_to_draw));

subplot(2,2,2);
bar(sum(sig_ffx,2)/size(sig_ffx,2));
ylabel('percent of draws declare region sig.')
title(sprintf('ND FFX %d stlzer map (from 100), %d draws of %d subs',...
    params.numstlzrmaps, params.num_drawings, params.num_subs_to_draw));

% plot ruti over 0.2
subplot(2,2,3);
percentpass = sum(sig_ruti,2)/size(sig_ruti,2);
idxsplot = find(percentpass>0.2);
bar(percentpass(idxsplot));
title('ruti regions over 20%');
ylabel('percent of draws declare region sig.')
set(gca,'XTickLabel',idxslabelsout(idxsplot));
ax = gca;
ax.XTickLabelRotation = 30;

% plot ffx over 0.2
subplot(2,2,4);
percentpass = sum(sig_ffx,2)/size(sig_ffx,2);
idxsplot = find(percentpass>0.2);
bar(percentpass(idxsplot));
title('ffx regions over 20%');
ylabel('percent of draws declare region sig.')
set(gca,'XTick',1:length(idxsplot));
set(gca,'XTickLabel',idxslabelsout(idxsplot));
ax = gca;
ax.XTickLabelRotation = 40;
% save fig
fnmstitl = sprintf('bar_graphs_u-%.2f_num_subs_per_draw-%d_num_drawings-%d',...
    params.uval_ruti,params.num_subs_to_draw,params.num_drawings);
suptitle(strrep(fnmstitl,'_',' '));
fnms = [fnmstitl '.pdf'];
export_fig(fullfile(figdir,fnms),'-dpdf','-nocrop');
close(hfig);
%%

%% plot pbal
hfig = figure;
hfig.Position = [330         270        1514        1007] ;
subplot(1,2,1)
boxplot(pval_ffx')
ylabel('pval'); xlabel('regions idxs');
set(gca,'XTick',1:5:65)
title('ffx pvals')
subplot(1,2,2)
boxplot(pval_ruti')
ylabel('pval'); xlabel('regions idxs');
set(gca,'XTick',1:5:65)
title('ruti pvals')
fnmstitl = sprintf('pvals_u-%.2f_num_subs_per_draw-%d_num_drawings-%d',...
    params.uval_ruti,params.num_subs_to_draw,params.num_drawings);
suptitle(strrep(fnmstitl,'_',' '));
fnms = [fnmstitl '.pdf'];
export_fig(fullfile(figdir,fnms),'-dpdf');
close(hfig);
%%
end

function plotstuff_oos(params,rsltsout)
hfig = figure; 
conds = fieldnames(rsltsout); 
for i = 1:length(conds)
    hsub = subplot(1,2,i); 
    himg = boxplot(rsltsout.(conds{i})','plotstyle','compact'); 
    ttlstr = strrep(conds{i},'_',' ');
    title(sprintf('%s = %.2f, %d draws, % d subs using out of sample',...
        ttlstr,params.uval_ruti, params.num_drawings, params.c.TestSize(1)));
    
    for j = 1:length(params.idxslabelsout)
        %text(0.5,j,params.idxslabelsout{j},'Color',[0.5 0.5 0.5],'FontSize',10);
    end
end
hfig.Position = [1          41        2560        1323] ;
figttl = sprintf('out_of_sample_box_plot_u-%.2f_draws-%d_subs-%d.pdf',...
        params.uval_ruti, params.num_drawings, params.c.TestSize(1));
export_fig(fullfile(params.figdir,figttl),'-dpdf');
close(hfig); 
end

function plotstuff_oos_percent_over(params,rsltsout)
hfig = figure; 
conds = fieldnames(rsltsout); 
% ruti 
rsltsout.sig_ruti_oos_t_over_median
idxsuse = find(rsltsout.sig_ruti_oos_t_over_median(:,1)==1);
x = 1:sum(rsltsout.sig_ruti_oos_t_over_median(:,1))'; 
y = rsltsout.sig_ruti_oos_t_over_median(idxsuse,2:end); 
hsub = subplot(1,2,1); hold on; 
hbox = notBoxPlot(y',[],0.5,'patch');
set(gca,'XTick',1:length(idxsuse));
set(gca,'XTickLabel',params.idxslabelsout(idxsuse));
set(gca,'XTickLabelRotation',70)
figttl = sprintf('Ruti - out of sample box plot u-%.2f draws-%d subs-%d.pdf',...
        params.uval_ruti, params.num_drawings, params.c.TestSize(1));
title(figttl); 

% ffx  
idxsuse = find(rsltsout.sig_ffx_oos_t_over_median(:,1)==1);
x = 1:sum(rsltsout.sig_ffx_oos_t_over_median(:,1))'; 
y = rsltsout.sig_ffx_oos_t_over_median(idxsuse,2:end); 
hsub = subplot(1,2,2); hold on; 
hbox = notBoxPlot(y',[],0.5,'patch');
set(gca,'XTickLabel',params.idxslabelsout(idxsuse));
set(gca,'XTickLabelRotation',70)
figttl = sprintf('FFX - out of sample box plot u-%.2f draws-%d subs-%d.pdf',...
        params.uval_ruti, params.num_drawings, params.c.TestSize(1));
title(figttl); 


hfig.Position = [453         299        1389         973] ;
figttl = sprintf('out_of_sample_scatter_plot_u-%.2f_draws-%d_subs-%d.pdf',...
        params.uval_ruti, params.num_drawings, params.c.TestSize(1));
export_fig(fullfile(params.figdir,figttl),'-dpdf');
close(hfig); 

end

function [pvalsout, ansmatout, idx_keep] = trimnan(pvals,ansmat)
% trim subjects that have one nan value in one real value map
idx_bad = find(squeeze(sum(isnan(ansmat(:,1,:))))>=1);
idx_keep  = setdiff(1:size(ansmat,3),idx_bad);
pvalsout = pvals(:,idx_keep);
ansmatout = ansmat(:,:,idx_keep);
end

function [pvalsout, ansmatout] = extract_subs(fold,numsubs, allpvals,ansmat)
rng(fold);
idxsubs = randperm(size(allpvals,2),numsubs);
pvalsout = allpvals(:,idxsubs);
ansmatout = ansmat(:,:,idxsubs);
end

function [pvalsout, ansmatout, datfold] = extract_subs_partition(c,params,data)
numsubs = params.num_subs_to_draw; 
allpvals = data.pvals; 
ansmat = data.ansmat; 
if ~isempty(data.all_data)
    datfold = data.all_data(:,:,find(c==1));
else
    datfold = []; 
end
pvalsout = allpvals(:,find(c==1));
ansmatout = ansmat(:,:,find(c==1));
end

function [sigfdr, Ps] = calc_ruti_return_sig(pvals,params)
uval = params.uval_ruti;
Ps = calc_ruti_prevelance(pvals,uval);
sigfdr = fdr_bh(Ps,0.05,'pdep','no');

end

function [sigfdr, pval] = calc_ffx_return_sig(ansMat,params)
[stlzerAnsMat, stlzerPerms] = createStelzerPermutations(ansMat,params.numstlzrmaps,params.avgmod);
pval = calcPvalVoxelWise(stlzerAnsMat);
sigfdr = fdr_bh(pval,0.05,'pdep','no');
end

function [sigfdr, pval] = calc_ffx_dir_return_sig(all_data,params)
for i = 1:params.numdirmaps+1 % num permuations 
    if i == 1
        labelsuse = params.labels; 
    else 
        labelsuse = params.labels(randperm(length(params.labels)));
    end
    for k = 1:size(all_data,3)
        delta(k,:) = mean(all_data(labelsuse==1,:,k) - all_data(labelsuse==2,:,k),1);
    end
    for j = 1:size(params.idxsout,1) % loop on regions 
        ansmat(j,i) = calcTstatDirectional(delta(:,params.idxsout{j}));
    end
    fprintf('dir map %d done \n',i);
end
pval = calcPvalVoxelWise(ansmat);
sigfdr = fdr_bh(pval,0.05,'pdep','yes');
end

function ansmatout =  trim_shuffels(ansMat)
for i = 1:size(ansMat,3)
    idx_bad{i,:} = find(sum(isnan(ansMat(:,:,i)))>0);
    maps(i) = length(idx_bad{i,:} );
end
max_bad_map = max(maps);
fprintf('bad maps %d \n',max_bad_map);
ansmatout  = [] ;
end

function rslt = calc_agrement(nums)
if nums(1) == nums(2)
    rslt = 1;
else
    rslt = 0;
end
end

function rsltsout = getpercents(rslts)
idxs = [ 1 3]; 
fieldnamesused = fieldnames(rslts); 
for i = 1:length(idxs) % loop on ruti / ffx  
    tmp = rslts.(fieldnamesused{idxs(i)});
    srttmp = sort(tmp,2,'descend'); % get cases in which at least one test sig. 
    idxsig = find(srttmp(:,1)==1);
    rsltsout.([fieldnamesused{idxs(i)} '_pecrc']) = sum(srttmp(:,2:end),2)/size(srttmp(:,2:end),2);
end
end

function [ruti_pr, ffx_pr] = getpercents_across_regions(rslts,params); 
% ffx 
tmp = rslts.sig_ffx;
idxsig = find(tmp(:,1)==1);
allrgns = (sum(tmp(idxsig,2:end),2)/length(tmp(idxsig,2:end)));
ffx_pr = mean( allrgns );
% ruti 
tmp = rslts.sig_ruti;
idxsig = find(tmp(:,1)==1);
allrgns = (sum(tmp(idxsig,2:end),2)/length(tmp(idxsig,2:end)));
ruti_pr = mean( allrgns );

end

function rsltsout = get_oos_effects(rslts,params,data)
idxs = [ 1 3]; % this carries which tests were sig either ffx / ruti 
fieldnamesused = fieldnames(rslts); 
for i = 1:length(idxs) % loop on ruti / ffx  
    tmp = rslts.(fieldnamesused{idxs(i)});
    srttmp = sort(tmp,2,'descend'); % get cases in which at least one test sig. 
    idxsig = find(srttmp(:,1)==1);
    for j = 1:length(idxsig) % for each sig region 
        dat{idxsig(j),1} = median(data.ansmat(j,1,params.c.test(1)));
        percovr(idxsig(j),1) = 1; % indicating this is sig region 
        for k = 2:params.c.NumTestSets % number of out of sample maps 
            dat{idxsig(j),k} = squeeze(data.ansmat(j,1,params.c.test(k)));
            percovr(idxsig(j),k) = sum(dat{idxsig(j),k}>=dat{idxsig(j),1})/length(dat{idxsig(j),k});
        end
    end
    rsltsout.([fieldnamesused{idxs(i)} '_raw_oos_t']) = dat;
    rsltsout.([fieldnamesused{idxs(i)} '_oos_t_over_median']) = percovr;
end
end

