function codeToFlattenVocalDataSet_AR3()
%% Flatten Data
% Input : Cbeta.nii estimates 
% Output: .mat files that flattens .nii to 2D matrices 
% Uses  : Precomputed group mask file. 

path2add = genpath('/home/rack-hezi-03/home/roigilro/dataForAnalysis/PoldrackRFX_Ttest/NeuroElf_v10_5153');
addpath(path2add);
dirStatsReasults = '/home/hezi/roee/vocalDataSet/extractedDataVocalDataSet/';
statsResultsFodlers = ...
    {'stats','stats_normalized_only','stats_normalized_sep_beta','stats_smoothed_sep_beta'};
matFilesDir = '/home/rack-hezi-01/home/roigilro/data/vocal_data_set/';

%% loop on subjects
load(fullfile(...
    matFilesDir,'groupMaskFromRFXvocalDataSet.mat'))

n =  neuroelf;
subFolders = findFilesBVQX(dirStatsReasults,'sub*',struct('dirs',1,'depth',1));
cnt =1;
for i = 1:length(subFolders)
    findar3fold = findFilesBVQX(subFolders{i},'stats_normalized_sep_beta_FIR_ar3',...
        struct('dirs',1));
if ~isempty(findar3fold)
    if exist(fullfile(findar3fold{1},'Cbeta_0040.nii'),'file')
        % find mask files:
        % find beta files
        betaFiles  = findFilesBVQX(...
            fullfile(findar3fold{1},'Cbeta*.nii'));
        subStr= regexp(subFolders{i},'[0-9]+','match');
        % loop on betas from the different conditions
        locations = getLocations(mask);
        rawLabel = {};
        start=tic;
        for k = 1:40
            [pn,betafn] = fileparts(betaFiles{k});
            vmp = n.importvmpfromspms(betaFiles{k},'a',[],3); % import at resolution 3mm
            rawLabel{k} = vmp.Map.Name;
            dataRaw = vmp.Map.VMPData;
            vmp.ClearObject;
            clear vmp
            data(k,:) = reverseScoringToMatrix1rowAnsMat(dataRaw,locations);
            if k <= 20
                labels(k) = 1;
            else
                labels(k) = 2;
            end
        end
        matFileToSave = fullfile(dirStatsReasults,'stats_normalized_sep_beta_FIR_ar3',...
            ['data_' subStr{1} '.mat']);
        save(matFileToSave,'data','locations','mask','labels','rawLabel');
        fprintf('%d. %s done in %f\n',cnt,subStr{1},toc(start));
        cnt = cnt+1;
        clear data locations labels rawLabel
    end
end
end

end
