function compare_FuA_values_DirectionalNonDirecitonal()
numsubs = [20,150];
alpha = 0.05;
printvmp = 0;
%% params set
params.slsize       = 9; % searchlight size to use
params.usetop100    = 0; % use top 100 voxels from D / ND analysis
params.use20regin   = 0;  % use the regions from 20 subjects to compute FuA in 150 subjects
params.measureuse   = 'drrealdata';% which symmetry measure to use (FuA unit normed, FuA non unit normed, Symmetry, directioanl multi-t)
% rawFuA_nonNormalized , rawFuA_symmetry, rawFuA_unitNormalized, rawFuA_skewness
% drrealdata, rawFuA_normdiff_unitnorm, rawFuA_normdiff_nonunitnorm
params.withcommn    = 0; % 'D only'; % D only or D + common in comparison
params.printvmp     = 1; % print vmp with results
params.figfold      = fullfile('..','..','figures','FuA_temp');
params.useshuf      = 0; % use shuffle data
slsize = params.slsize;

for i = 1:length(numsubs)
    %% load fa
    rootDir = fullfile('..','..','results',sprintf('results_VocalDataSet_FIR_AR6_FFX_ND_norm_400-shuf_SLsize-%d',slsize));
    if params.useshuf
        fnload = sprintf('RAW_FA_VALS_ar6_subs-%d_slsize-%d_shuf.mat',numsubs(i),slsize);
    else
        fnload = sprintf('RAW_FA_VALS_ar6_subs-%d_slsize-%d.mat',numsubs(i),slsize);
    end
    load(fullfile(rootDir,fnload));
    
    %% load Directional and non directional
    rootDir2ndlvl = fullfile('..','..','results',sprintf('results_VocalDataSet_FIR_AR6_FFX_ND_norm_400-shuf_SLsize-%d',slsize),'2nd_level');
    %% directional
    dirfnm  = sprintf('results_DR_shufs-5000_subs-%d_slsize-%d.mat',numsubs(i),slsize);
    load(fullfile(rootDir2ndlvl,dirfnm),'pval','mask','locations','drrealdata');
    sigfdr = fdr_bh(pval,alpha,'pdep','yes');
    idxdir = find(sigfdr==1);
    if params.usetop100 % Take only top 100 dir idxs
        [vals ixs] = sort(drrealdata(idxdir));
        idxdir = idxdir(ixs(end-300:end));
    end
    %% non directional
    ndrfnm  = sprintf('ND_FFX_VDS_%d-subs_%d-slsze_1-fld_400shufs_5000-stlzer_mode-equal-min_newT2013.mat',numsubs(i),slsize);
    load(fullfile(rootDir2ndlvl,ndrfnm),'pval','mask','locations','ndrrrealdata')
    sigfdr = fdr_bh(pval,alpha,'pdep','yes');
    idxndr = find(sigfdr==1);
    if params.usetop100 % Take only top 100 dir idxs
        [vals ixs] = sort(ndrrrealdata(idxndr));
        idxndr = idxndr(ixs(end-300:end));
    end
    
    if params.use20regin
        if numsubs(i) == 20
            commonidx = intersect(idxdir,idxndr);
            idxndonly = setdiff(idxndr,idxdir);
            idxdronly = setdiff(idxdir,idxndr);
            idxcommon = intersect(idxdir,idxndr);
        end
    else
        commonidx = intersect(idxdir,idxndr);
        idxndonly = setdiff(idxndr,idxdir);
        idxdronly = setdiff(idxdir,idxndr);
        idxcommon = intersect(idxdir,idxndr);
    end
    %% load measure to plot 
    fadat     = eval(params.measureuse); %rawFuA_nonCentered ; rawFuA_symmetry; drrealdata; ndrrrealdata
    %% data to plot
    if params.withcommn % use common as well
        x = fadat([idxdronly idxcommon])'; % XX
        labelusedir = sprintf('D + common (%d)',length(x));
    else
        x = fadat([idxdronly ])'; % XX
        labelusedir = sprintf('D only (%d)',length(x));
    end
    cat = repmat({labelusedir},length(x),1);
    x = [x ; fadat([idxndonly])'];
    labelusendr = sprintf('ND only (%d)',length(idxndonly));
    cat = [cat ; repmat({labelusendr},length(idxndonly),1)];
    datplot(i).subs = numsubs(i);
    datplot(i).cat = cat;
    datplot(i).x   = x;
    
    %% print FuA in VMP
    if params.printvmp
        idxs{1} = idxndonly; idxs{2} = idxdronly; idxs{3} = idxcommon;
        minmaps = min(fadat(unique([idxndonly ,idxdronly, idxcommon])));
        maxmaps = max(fadat(unique([idxndonly ,idxdronly, idxcommon])));
        mapn{1} = 'idxndonly'; mapn{2} = 'idxdronly'; mapn{3} = 'idxcommon';
        vmpraw = BVQXfile(fullfile(pwd,'blank_MNI_3x3res.vmp'));
        vmp = BVQXfile(fullfile(pwd,'blank_MNI_3x3res.vmp'));
        mapstruc = vmp.Map(1);
        for m = 1:3
            vmp.NrOfMaps = m;
            tmp = zeros(size(fadat));
            tmp(idxs{m}) = fadat(idxs{m});
            vmpdat = scoringToMatrix(mask,double(tmp'),locations); % note that SigFDR must be row vector
            vmp.Map(m) = vmp.Map(1);
            vmp.Map(m).VMPData = vmpdat;
            vmp.Map(m).Name    = sprintf('%s (%d)',mapn{m},length(idxs{m}));
            vmp.Map(m).LowerThreshold = minmaps;
            vmp.Map(m).UpperThreshold = maxmaps;
            vmp.Map(m).UseRGBColor = 0;
        end
        vmp.NrOfMaps = 3;
        msruse = genvarname(getLabel(params.measureuse));
        vmp.SaveAs(fullfile(rootDir2ndlvl,[fnTosave(1:end-4) '_' msruse '_DandNDoverlay' '.vmp']));
        vmp.ClearObject;
        clear vmp;
    end
    clear cat x fadat;
end

%% plot figure
for i = 1:length(numsubs)
    g(1,i)=gramm('x',datplot(i).x,'color',datplot(i).cat);
    g(1,i).stat_bin('geom','overlaid_bar',... %  bar, line, overlaid_bar, stacked_bars,stairs,point
        'normalization','probability',... % count, probability, countdensity, pdf, cumcount, cdf
        'nbins',60,...
        'fill','transparent');
    g(1,i).set_color_options('map',[1 0 0; 0 1 0]);
    g(1,i).set_names('x',getLabel(params.measureuse),...
        'y','Probability of result',...
        'color','Regions Selected:')
    ttluse = sprintf('%d subjects',datplot(i).subs);
    g(1,i).set_title(ttluse, 'FontSize', 16);
end
hfig = figure;
hfig.Position = [1000         790        1300         548];
if params.useshuf
    ttluse = sprintf('Directional vs Nondirectional Shuffeled - Measure = %s , slsize %d',...
        getLabel(params.measureuse),params.slsize);
else
    ttluse = sprintf('Directional vs Nondirectional - Measure = %s , slsize %d',...
        getLabel(params.measureuse),params.slsize);
end
g.set_title(ttluse);
g.draw();

fnsvefig = sprintf('DvsND_slsize-%d_ust100-%d_use20r-%d_mesure-%s_comm-%d_shuf-%d.pdf',...
    params.slsize,params.usetop100,params.use20regin,params.measureuse,params.withcommn,params.useshuf);
hfig.PaperPositionMode = 'auto';
saveas(hfig,fullfile(params.figfold,fnsvefig));
% close(hfig);
% fns = fullfile(fullfile(rootDir,'result_figs','D-only_v_ND-only_20_subs_matlab_histogram.pdf'));
% printFigToPDFa4(hfig,fns)
end

function label = getLabel(str)
% rawFuA_nonNormalized , rawFuA_symmetry, rawFuA_unitNormalized, drrealdata

switch str
    case 'rawFuA_nonNormalized'
        label = 'FuA Non Unit Normalized';
    case 'rawFuA_symmetry'
        label = 'Symmetry Measure';
    case 'rawFuA_unitNormalized'
        label = 'FuA Unit Normalized';
    case 'drrealdata'
        label = 'Muni Meng Directional';
    case 'rawFuA_normdiff_unitnorm'
        label = 'Norm Diff (Unit Normalized)';
    case 'rawFuA_normdiff_nonunitnorm'
        label = 'Norm Diff (Non Unit Normalized)';
    case 'rawFuA_skewness'
        label = 'Distnace Skewness';
end
end