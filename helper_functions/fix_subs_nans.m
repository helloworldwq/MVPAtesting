function fix_subs_nans()
load(fullfile(pwd,'params_power.mat'),'params');
% subsToExtract,fold,ffxResFold,numMaps;
params.fold_rng = 1;
params.subsExtract = 1:218; % all subs

cnt = 1;
%% extract results from each subject
for i = 1:length(params.subsExtract)
    start = tic;
    subStrSrc = sprintf(params.srch_str_file,params.subsExtract(i));
    ff = findFilesBVQX(fullfile(params.results_dir,   params.reslts_fold)...
        ,subStrSrc);
    if ~isempty(ff)
        clear ansMat*
        load(ff{1},'ansMat*','locations','mask')
        for j = 1:3 % check all cases
            switch j
                case 1
                    if exist('ansMat','var')
                        ansMat_fixed       = fixZerosNans(ansMat,params.modeuse,params.subsExtract(i),locations);
                        save(ff{1},'ansMat_fixed','-append');
                    end
                case 2
                    if  exist('ansMat_Multit','var')
                        ansMat_Multit_fixed         = fixZerosNans(ansMat_Multit,params.modeuse,params.subsExtract(i),locations);
                        save(ff{1},'ansMat_Multit_fixed','-append');
                    end
                case 3
                    if  exist('ansMat_SVM','var')
                        ansMat_SVM_fixed        = fixZerosNans(ansMat_SVM,params.modeuse,params.subsExtract(i),locations);
                        save(ff{1},'ansMat_SVM_fixed','-append');
                    end
            end
        end
        fprintf('sub %.3d done in %f secs\n',params.subsExtract(i),toc(start));
    end
end

end

function fixedAnsMat = fixZerosNans(ansMat,modeuse,i,locations)
fprintf('sub %.3d \t',i);
%fprintf('B = sub %d has %d nans\n',i,sum(isnan(median(ansMat,2))))
fixedAnsMat = fixAnsMat(ansMat,locations,modeuse); % fix ansMat for zeros
%fprintf('A = sub %d has %d nans\n\n',i,sum(isnan(median(fixedAnsMat,2))))
end
