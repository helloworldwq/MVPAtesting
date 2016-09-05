function FuA_Simulation()
rowvars = [];
colvars = [];
cntg = 1; 
labes = {} ; 
mout = [] ; concatx = []; concaty = []; labsout = {};
cntplt = 1; 
for m = 1:2
    ndims = 27; % XX
    nsubs = 150;
    std_use = 0.05; 
    vals = [1 -1];
    data = zeros(nsubs,ndims);
    for i = 1:nsubs
        for j = 1:ndims
            ix = randperm(2,1);
            data(i,j) = vals(ix);
        end
    end
    rng(1);
    if m == 1
        pointuse =  1;
    else
        pointuse = -1;
    end
    epsrand   = mvnrnd(zeros(1,ndims),ones(1,ndims).*std_use, nsubs);
    data = data + epsrand;
    cnt = 1; 
    ndims = 26; % XX 
    for j = 10:2:(nsubs*0.9);
        allidx = 1:j;
        c2 = cvpartition(allidx,'Kfold',2);
        idxpos = find(c2.training(1)==1);
        idxneg = find(c2.test(1)==1);
        data(idxpos,1:ndims) = repmat(ones(1,ndims),c2.TrainSize(1),1) + mvnrnd(zeros(1,ndims),ones(1,ndims).*std_use, c2.TrainSize(1));
        data(idxneg,1:ndims) = repmat(ones(1,ndims).*pointuse,c2.TestSize(1),1) + mvnrnd(zeros(1,ndims),ones(1,ndims).*std_use, c2.TestSize(1));
        FuAnew(cnt) = calcSymmetryMeasure(data');
        FuAdir(cnt) = calcTstatDirectional(data);
        FuAold(cnt) = calcClumpingIndexSVD(data',1);
        FuAoldn(cnt) = calcClumpingIndexSVD(data',0);
        FuAnormdiff(cnt) = calcNormDiffMeasure(data');
        FuAskew(cnt)     = calcSkewnessMeasure(data');
        perinquad(cnt) = sum(sum(sign(data(:,1:ndims)),2)==ndims)/nsubs;
        cnt = cnt + 1; 
        if j == 10 
        [concatx, concaty, labsout, mout] = ... 
            concatData(concatx,concaty,data(:,1),data(:,2),labsout, {'Start Point'},mout, m);
            plotdat(cntplt).x = data(:,1); plotdat(cntplt).y = data(:,2); plotdat(cntplt).ttl = 'Start Point'; 
            plotdat(cntplt).xlbl = ' '; plotdat(cntplt).ylbl = ' ';
            plotdat(cntplt).ylim = [-2 2];
            cntplt = cntplt + 1;
        end
        if j == 72 
        [concatx, concaty, labsout, mout] = ... 
            concatData(concatx,concaty,data(:,1),data(:,2),labsout, {'Mid Point'},mout, m);
            plotdat(cntplt).x = data(:,1); plotdat(cntplt).y = data(:,2); plotdat(cntplt).ttl = 'Mid Point';  
            plotdat(cntplt).ylim = [-2 2];
            cntplt = cntplt + 1;
            
        end
    end
    [concatx, concaty, labsout, mout] = ... 
            concatData(concatx,concaty,data(:,1),data(:,2),labsout, {'End Point'},mout,m);
    plotdat(cntplt).x = data(:,1); plotdat(cntplt).y = data(:,2); plotdat(cntplt).ttl = 'End Point';
    plotdat(cntplt).ylim = [-2 2];
    cntplt = cntplt + 1;
    
    muse = m; if m == 2 ; muse = m + 1;  end
    g(muse,1) = gramm('x',data(:,1),'y',data(:,2));
    g(muse,1).geom_jitter('dodge',1.5,'width',0.5,'height',0.5);
    g(muse,1).set_title('Ending Point Data');
    
    rowvars(cntg) = m; colvars(cntg) = 1; cntg = cntg + 1;
    conds = {'dir' , 'old', 'oldn','new','normdiff','skew'};
    titlsuse = {'Muni Meng Directional','FuA - Unit Normalized','FuA - Non-normalized',...
                'Symmetery Measure','Norm Diff','Distance Skewness'};
            
    conds = {'dir' , 'oldn','skew'};
    titlsuse = {'Directional T^D','FuA',...
                'Distance Skewness'};
    ylimsuse(1,:) = [-1 600];
    ylimsuse(2,:) = [0.4 1.2];
    ylimsuse(3,:) = [-0.1 0.8];
    for i = 1:length(conds)
        FuA = eval(sprintf('FuA%s',conds{i}));
        muse = m;
        iuse = i+1; 
        if muse ==2
            muse = m + 1;
            if i > 3
                muse = m + 2;
                iuse = i- 2;
            end
        else
        if i > 3
            muse = m + 1;
            iuse = i- 2;
        end
        end
        plotdat(cntplt).x = perinquad; plotdat(cntplt).y = FuA; plotdat(cntplt).ttl = titlsuse{i}; 
        plotdat(cntplt).xlbl = '% subs in 1^s^t quadrant'; plotdat(cntplt).ylbl = [titlsuse{i} ];
        plotdat(cntplt).ylim = ylimsuse(i,:);
        cntplt = cntplt + 1;
        g(muse,iuse) = gramm('x',perinquad,'y',FuA);
        g(muse,iuse).geom_point();
        g(muse,iuse).set_names('x','percent subs in quadrant 1','y',titlsuse{i});
        g(muse,iuse).set_title(titlsuse{i},'FontSize',12);
        rowvars(cntg) = muse; colvars(cntg) = iuse; cntg = cntg + 1;
        [concatx, concaty, labsout, mout] = ...
            concatData(concatx,concaty,perinquad',FuA',labsout, {titlsuse{i}},mout, m );

    end
    clear FuAnew FuAold FuA
end
hfig = figure('Position',[744         170        1099         880]); 
for i = 1:length(plotdat)
    subplot(4,3,i)
    s = scatter(plotdat(i).x,plotdat(i).y,20,'r','filled'); 
    ylim(plotdat(i).ylim)
    xlabel(plotdat(i).xlbl);
    ylabel(plotdat(i).ylbl);
    title(plotdat(i).ttl);
    s.MarkerEdgeColor = 'b';
    s.MarkerFaceColor = [0 0.5 0.5];
    set(gca,'FontSize',10)
end
settings.figfolder = fullfile('..','..','figures','simulations'); 
fnmsv ='fua_sims.pdf';
fullfnmsv = fullfile(settings.figfolder,fnmsv);
hfig.PaperPositionMode = 'auto';
hfig.Units = 'inches';
hfig.PaperOrientation = 'landscape';
hfig.PaperPosition = [.01 .01 [11 8.5]-0.01];
print(hfig,'-dpdf',fullfnmsv);
close(hfig);
return ; 
g = gramm('x',concatx,'y',concaty); 
g.geom_point(); 
g.facet_grid(mout,labsout,'scale','independent')
%g.facet_wrap(labsout,'ncols',4,'scale','free')
%figure('Position',[392         588        1390         762]);
figure;
g.draw;


end

function [concatx, concaty, labsout, mout] = concatData(x,y,xnew,ynew,labs, stringadd,madd, m)
concatx = [x; xnew];
concaty = [y; ynew];


labsadd = repmat(stringadd,length(xnew),1);
labsout = [labs;labsadd];
mrep = repmat(m,length(xnew),1);
mout    = [madd; mrep]; 


end