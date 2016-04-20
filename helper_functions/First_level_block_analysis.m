function 	First_level_block_analysis(subject,script_folder,gp_folder)

% 1st level block design analysis
% takes as input the list of subjects directories (subject as cell)
% and the script folder to load SPM batch files already prepared, from
% which one inputs data, and the gp_folder in which we can already store
% some results

spm_jobman('initcfg')

% -------------------------------------------------------------------------
% 1. run preprocess batchs (slice timing, realign, coregister and reslice T1
% to meanEPI, coregister coregT1 to 152MNI and apply to EPI (ie make 0 close to AC)
% segment, normalize, smooth
% 2. run QA tools to generate extraregressor for motion and globals
% 3. stats + contrasts
% 4. threshold voice>non-voice using Gamma-Gaussian Mixture model (move to
% dedicated folder)
% 5. unstandardize residuals for connectivity analyses
% -------------------------------------------------------------------------
% NOTE spm_defaults edited defaults.stats.maxres = Inf; allowing to get all
% residuals, but also influcence the smoothness estimation
% spm_spm edited, commenting lines that delete residuals
% -------------------------------------------------------------------------
for s=1: size(subject,2)
    cd(subject{s});
    fprintf('processing_subject %g \n %s \n',s,subject{s});   
    load([script_folder filesep 'pre_process1.mat'])    
    
    % 0. ensure the origin is at the right place
    % -----------------------------------------------
    vg = spm_vol(fullfile(spm('Dir'),'canonical','avg152T1.nii'));
    cd('ana'); anat = dir('*.nii'); vf = spm_vol(anat.name);
    M  = spm_affreg(vg,vf,struct('regtype','rigid'));
    [U,~,V] = svd(M(1:3,1:3));
    M(1:3,1:3) = U*V';
    N  = nifti(strtrim(vf.fname));
    N.mat = M*N.mat;
    create(N);
    
    cd ..; cd('func'); data = dir('*.nii');
    disp('setting the origin ..')
    for d=5:310
        fprintf('processing image %g/310\n',d);
        ima(d-4,:) = {[pwd filesep data(d).name]};
        vf = spm_vol([pwd filesep data(d).name]);
        M  = spm_affreg(vg,vf,struct('regtype','rigid'));
        [U,~,V] = svd(M(1:3,1:3));
        M(1:3,1:3) = U*V';
        N  = nifti(strtrim(vf.fname));
        N.mat = M*N.mat;
        create(N);
    end
    
    % 1. run preprocess batch
    % -------------------------
    
    % slice timing - skip first 4 images
    matlabbatch{1}.spm.temporal.st.scans{1} = ima;
    
    % realign all EPI and create mean EPI
    % matlabbatch{2}.spm.spatial.realign.estwrite <-- dependencies
    
    % coregister T1 to mean EPI 
    cd ..; cd('ana'); source = dir('*.nii');
    matlabbatch{3}.spm.spatial.coreg.estimate.source = {[pwd filesep source.name]};
        
    % segment the coregistered T1
    % matlabbatch{4}.spm.spatial.preproc.channel.vols <-- dependencies
    spmDir = which('spm');
    [spmDir,~] = fileparts(spmDir);
    tpmniifile = fullfile(spmDir,'tpm','TPM.nii');
    for k = 1:length(matlabbatch{4}.spm.spatial.preproc.tissue)
        matlabbatch{4}.spm.spatial.preproc.tissue(k).tpm = {sprintf('%s,%d',tpmniifile,k)};
    end
    % normalise bias corrected T1
    % matlabbatch{5}.spm.spatial.normalise.write % <-- dependencies
    
    % normalise EPI
    % matlabbatch{6}.spm.spatial.normalise.write % <-- dependencies
    
    % smooth EPI
    % matlabbatch{7}.spm.spatial.smooth % <-- dependencies
    cd ..
    
    save preprocess1 matlabbatch; 
    
    spm_jobman('run', [pwd filesep 'preprocess1.mat']);
    clear data ima source matlabbatch 

    % 2. run QA tools to generate augnmented regressors 
    % ie the motion param + motion outliers + global outliers
    % -------------------------------------------------------
    cd('ana'); name = dir('w*.nii');
    T1_name = [pwd filesep name.name]; cd ..
    
    cd('func')
    I=dir('swa*.nii');% was swa but I am not doing smoothign  
    for i=1:306
        Images{i}= [pwd filesep I(i).name];
    end
    
    cd(script_folder)
    flags = struct('motion_parameters','on','globals','on','volume_distance','off','movie','off', ...
        'AC', [40 57 36], 'average','on', 'T1', 'on');
    spmup_first_level_qa(T1_name,Images',flags); 
    
    return 
    % 3. stats + contrasts
    % ---------------------
    cd(subject{s}); cd('func'); 
    load([script_folder filesep  'stats1.mat'])
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = Images'; % could optionally add ,1
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {[pwd filesep 'multiple_regressors.txt']};
    mkdir('stats'); cd('stats');
    matlabbatch{1}.spm.stats.fmri_spec.dir = {pwd};
    
    % matlabbatch{2}.spm.stats.fmri_est % <-- dependencies
    % matlabbatch{3}.spm.stats.con % <-- dependencies
    
    cd(subject{s}); save stats matlabbatch;
    spm_jobman('run', [pwd filesep 'stats.mat']);
    clear I Images matlabbatch 
    
    % 4. threshold voice>non-voice using Gamma-Gaussian Mixture model
    % (move to dedicated folder)
    % ----------------------------------------------------------------
    cd('func/stats');
    [~,name]=fileparts(subject{s});
    mask_filename = [pwd filesep 'mask.nii'];
    spm_mat_file  = [pwd filesep 'SPM.mat'];
    
    for con_index = 1:3
        stat_filename = [pwd filesep 'spmT_000' num2str(con_index) '.nii'];
        adaptive_thresholding(stat_filename, mask_filename, spm_mat_file, con_index) 
        try
            copyfile([pwd filesep 'spmT_000' num2str(con_index) '_thr.nii'],[gp_folder filesep 'single_subjects_maps' filesep name '_spmT_000' num2str(con_index) '_thr.nii']);
        end
        if con_index == 3 % also keep the histograms but just for the contrast of intertest
            saveas(gcf,['GGMM_' num2str(con_index) '.eps'],'psc2'); 
            copyfile(['GGMM_' num2str(con_index) '.eps'],[gp_folder filesep 'single_subjects_maps' filesep name '_GGMM_' num2str(con_index) '.eps']);
        end
        close(gcf);
    end
      
    
    % 5. Data cleanup (saves space)
    % ---------------
    cd ..
    EPI_data = dir('sub*.nii');
    for n=1:size(EPI_data,1)
        data{n}= [pwd filesep EPI_data(n).name];
    end
    gzip(data,'raw_data')
    for n=1:size(EPI_data,1)
        delete(data{n})
    end
    clear data
        
    EPI_data=dir('asub*.nii');
     for n=1:size(EPI_data,1)
        data{n}= [pwd filesep EPI_data(n).name];
    end
    gzip(data,'realigned_data')
    for n=1:size(EPI_data,1)
        delete(data{n})
    end
    clear data
    
    EPI_data=dir('wasub*.nii');
    for n=1:size(EPI_data,1)
        data{n}= [pwd filesep EPI_data(n).name];
    end
    zip('normalized_data',data)
    for n=1:size(EPI_data,1)
        delete(data{n})
    end    
    clear data
    
end


