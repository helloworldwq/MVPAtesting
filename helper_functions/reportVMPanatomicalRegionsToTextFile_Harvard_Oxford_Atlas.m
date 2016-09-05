function reportVMPanatomicalRegionsToTextFile_Harvard_Oxford_Atlas()
% this code prints a text table to command line with the anaotmical labels
% of each map in the VMP 

% load harvard oxford idxs :
load idxs_from_havard_cambridge_atlas.mat; 
% load harvard oxford vmp
fnho = 'HarvardCambrdgeCoritcal_andSubCortical_Atlas.vmp';
vmpho = BVQXfile(fullfile(pwd,fnho));
lblbrain = zeros(size(vmpho(1).VMPData));
for i = 1:vmpho.NrOfMaps
    tmpdat = vmpho(i).VMPData;
    labelsidx{i} = find(tmpdat==1);
    lblbrain(tmpdat==1) = i;
    labelsho{i} = vmpho.Map(i).Name; 
end

% load VMP results file: 
resfld = 'results_VocalDataSet_FIR_AR6_FFX_ND_norm_400-shuf_SLsize-27';
% resfld = 'results_VocalDataSet_avg-abs-vals_linear_FIR_AR6_FFX_ND_repart-mode-rand_400-shuf_SLsize-27_folds-5';
resdir  = fullfile('..','..','results',resfld,'2nd_level');
resfn   = 'RAW_FA_VALS_ar6_subs-20_slsize-27_MuniMengDirectional_DandNDoverlay.vmp';
% resfn   = 'D_ND_FFX_FDR_0.05_svm_20_subs.vmp';
vmp = BVQXfile(fullfile(resdir,resfn));
opts = struct('minsize',10,...
            'clconn','vertex',...
               'mni2tal',false,...
               'localmin', 50);

outmaps  = struct('mapname',{},'x',[],'y',[],'z',[],'ClusterSize',[],'PeakLabel',{},'detail',{});
for i = 1:vmp.NrOfMaps
    [c,t,v,vo] = vmp.ClusterTable(i,0,opts);
    for j = 1:size(c,1)
        out(j) = getLabelCluster(c(j),lblbrain,labelsho,vmp.MapNames{i});
    end
    outmaps = [outmaps , out];
    clear out; 
end
t = struct2table(outmaps);

fnmwrite ='RAW_FA_VALS_ar6_subs-20_slsize-27_DR_overlay.xls';
writetable(t,fullfile(resdir,fnmwrite));
end

function out = getLabelCluster(c,lblbrain,labels,mapname)
% add a label of "zero"; 
labels{68} = 'No Label';
out.mapname = mapname;
out.x = c.rwpeak(1); 
out.y = c.rwpeak(2); 
out.z = c.rwpeak(3); 
out.ClusterSize = c.size; 
if lblbrain(c.peak(1),c.peak(2),c.peak(3)) == 0 
    idxuse = 68;
else
    idxuse = lblbrain(c.peak(1),c.peak(2),c.peak(3));
end

if idxuse < 49
    if out.x<0
        addstr = 'Left';
    else
        addstr = 'Right';
    end
else
    addstr = '';
end

out.PeakLabel = [ addstr ' ' labels{idxuse} ]; 

for i = 1:size(c.coords,1)
    idxs(i) = lblbrain(c.coords(i,1),c.coords(i,2),c.coords(i,3)); 
    if idxs(i) < 48
        if c.rwcoords(i,1)<0 % use real world coords for label
            hemstr{i} = 'Left';
        else
            hemstr{i} = 'Right';
        end
    else
        hemstr{i} = ''; % if sub cortical don't add hemisphere
    end
end
[unqidx,stridxs] = unique(idxs);
addstr = hemstr(stridxs);
unqidx(unqidx==0) = 68; % give no label to unq idxs that don't have lavel
detail = [];
% get order of percentages 
for i = 1:length(unqidx)
    perc(i) = sum(unqidx(i)==idxs)/length(idxs);
end
[xx, idx] = sort(perc,'descend');
for i = 1:length(unqidx)
    perc = sum(unqidx(idx(i))==idxs)/length(idxs);
    detail = [detail...
        sprintf('%s |(%1.3f)|',...
        [addstr{idx(i)} ' ' labels{unqidx(idx(i))}],perc)];
end
out.detail = detail; 
end
