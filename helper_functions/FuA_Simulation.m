function FuA_Simulation()
rowvars = [];
colvars = [];
cntg = 1; 
for m = 1:2
    ndims = 27; % XX
    nsubs = 150;
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
    epsrand   = mvnrnd(zeros(1,ndims),ones(1,ndims).*0.001, nsubs);
    data = data + epsrand;
    cnt = 1; 
    ndims = 3; % XX 
    for j = 40:2:(nsubs*0.9);
        allidx = 1:j;
        c2 = cvpartition(allidx,'Kfold',2);
        idxpos = find(c2.training(1)==1);
        idxneg = find(c2.test(1)==1);
        data(idxpos,1:ndims) = repmat(ones(1,ndims),c2.TrainSize(1),1) + mvnrnd(zeros(1,ndims),ones(1,ndims).*0.001, c2.TrainSize(1));
        data(idxneg,1:ndims) = repmat(ones(1,ndims).*pointuse,c2.TestSize(1),1) + mvnrnd(zeros(1,ndims),ones(1,ndims).*0.001, c2.TestSize(1));
        FuAnew(cnt) = calcSymmetryMeasure(data');
        FuAdir(cnt) = calcTstatDirectional(data);
        FuAold(cnt) = calcClumpingIndexSVD(data',1);
        FuAoldn(cnt) = calcClumpingIndexSVD(data',0);
        FuAnormdiff(cnt) = calcNormDiffMeasure(data');
        FuAskew(cnt)     = calcSkewnessMeasure(data');
        perinquad(cnt) = sum(sum(sign(data(:,1:ndims)),2)==ndims)/nsubs;
        cnt = cnt + 1; 
    end
    muse = m; if m == 2 ; muse = m + 1;  end
    g(muse,1) = gramm('x',data(:,1),'y',data(:,2));
    g(muse,1).geom_jitter('dodge',1.5,'width',0.5,'height',0.5);
    g(muse,1).set_title('Ending Point Data');
    
    rowvars(cntg) = m; colvars(cntg) = 1; cntg = cntg + 1;
    conds = {'dir' , 'old', 'oldn','new','normdiff','skew'};
    titlsuse = {'Muni Meng Directional','FuA - Unit Normalized','FuA - Non-normalized',...
                'Symmetery Measure','Norm Diff','Distance Skewness'};
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
        g(muse,iuse) = gramm('x',perinquad,'y',FuA);
        g(muse,iuse).geom_point();
        g(muse,iuse).set_names('x','percent subs in quadrant 1','y',titlsuse{i});
        g(muse,iuse).set_title(titlsuse{i},'FontSize',12);
        rowvars(cntg) = muse; colvars(cntg) = iuse; cntg = cntg + 1;
    end
    clear FuAnew FuAold FuA
end
figure('Position',[392         588        1390         762]);
g.draw;


end