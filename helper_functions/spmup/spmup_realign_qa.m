function spmup_realign_qa(P,flags)

% implement different quality control 'tools' for
% fMRI realigned data using SPM
%
% FORMAT realign_qa ( = do it all)
%        realign_qa(P,flags)
%
% INPUT flags is a structure listing the options available for qa
%             flags.motion_parameters = 'on'; 
%                   --> plot motion paramters and 1st derivatives
%                   --> generate new regressor.txt file with motion parameters and outliers detected using Carling's modified boxplot rule
%             flags.globals = 'on';
%                   --> compute and plot globals (see spm_globals)
%                   --> append the regressor.txt file with global outliers detected using Carling's modified boxplot rule
%             flags.volume_distance = 'on';
%                   --> compute the distance of each volume to the mean
%             flags.movie = 'on';
%             flags.AC = [x,y,z]; 
%                   --> generate three movies along the x, y, z planes defined based on the AC point
%                   --> if flags.AC is empty, the user is asked to input this coordinate
%       P is a matrix with the full name of files (see spm_select)
%
% see also spm_select spm_globals
%
%  Cyril Pernet January 2013
% --------------------------------------------------------------------------
% Copyright (c) SPM U+ toolbox

%% validate inputs
spm('Defaults','fmri')
current = pwd;
 
% check flags
def_flags.motion_parameters = 'on';
def_flags.globals = 'on';
def_flags.volume_distance = 'on';
def_flags.movie = 'on';
if nargin == 0;
    flags = def_flags;
end
% update flags fields
if ~isfield(flags,'motion_parameters'); flags.motion_paramters = 'off'; end
if ~isfield(flags,'globals'); flags.globals = 'off'; end
if ~isfield(flags,'volume_distance'); flags.volume_distance = 'off'; end
if ~isfield(flags,'movie'); flags.movie = 'off'; end

% check P
if nargin <= 1
    % if globals, or distance, or movies we need P
    if strcmp(flags.globals,'on') || strcmp(flags.volume_distance,'on') || strcmp(flags.movie,'on')
        P = spm_select(Inf,'image','select realigned images');
    end
end

[folder,name,ext] = fileparts(P(1,:));
cd(folder); 
average = dir('mean*.nii');
if isempty(average)
    average = dir('mean*.img');
end

% if distance we need the mean image
if strcmp(flags.volume_distance,'on')
    if isempty(average)
        disp('mean image not found')
        average = spm_select(1,'image','select mean image');
    else
        average =  [folder filesep average(1).name];
    end
end

% if movie we need AC
if strcmp(flags.movie,'on')
    if ~isfield(flags,'AC') && strcmp(flags.volume_distance,'off')
        % get mean image
        if isempty(average)
            disp('mean image not found')
            average = spm_select(1,'image','select mean image');
        else
            average =  [folder filesep average.name];
        end
    end
    % display
    spm_image('init',average)
    flags.AC = spm_input('enter a AC voxel coordinates',1);
    close all
end
    
 

%% look at motion parameters
if strcmp(flags.motion_parameters,'on')
    
    motion_file = dir('rp*.txt');
    motion_param = load(motion_file.name);
    [n,p]=size(motion_param);
    
    disp('computing motion displacement for outliers ... ')
    % find outliers for high motion
    temp_motion = motion_param;
    temp_motion(:,4:6)= temp_motion(:,4:6)*180/pi; % use deg rather than radian
    derivatives = diff(temp_motion);
    
    delta = zeros(n,1);  % Mean square displacement in two scans
    for i = 2:n
        delta(i) = sqrt((temp_motion(i-1,1) - temp_motion(i,1))^2 + ...
            (temp_motion(i-1,2) - temp_motion(i,2))^2 +...
            (temp_motion(i-1,3) - temp_motion(i,3))^2 +...
            1.28*(temp_motion(i-1,4) - temp_motion(i,4))^2 +...
            1.28*(temp_motion(i-1,5) - temp_motion(i,5))^2 +...
            1.28*(temp_motion(i-1,6) - temp_motion(i,6))^2);
    end
    
    % interquartile range
    y=sort(delta);
    j=floor(length(delta)/4 + 5/12);
    g=(length(delta)/4)-j+(5/12);
    ql=(1-g).*y(j)+g.*y(j+1); % lower quartile
    k=length(delta)-j+1;
    qu=(1-g).*y(k)+g.*y(k-1); % higher quartile
    value=qu-ql; % inter-quartile range
    
    % robust outliers
    M = median(delta);
    k=(17.63*n-23.64)/(7.74*n-3.71); % Carling's k
    m_outliers=delta<(M-k*value) | delta>(M+k*value);
    
    if sum(m_outliers) > 0
        moutlier_matrix = zeros(size(motion_param,1),sum(m_outliers));
        indices = find(m_outliers);
        for i=1:sum(m_outliers)
            moutlier_matrix(indices(i),i) = 1;
        end
    else
        moutlier_matrix = [];
    end
    
    % figure
    figure('Name','Motion outlier detection','Visible','Off');
    set(gcf,'Color','w','InvertHardCopy','off', 'units','normalized', 'outerposition',[0 0 1 1]); 
    subplot(3,2,1); plot(temp_motion(:,1:3),'LineWidth',3);
    axis tight; grid on; title('Translation','Fontsize',14)
    xlabel('scans'); ylabel('mm');
    subplot(3,2,2); plot(temp_motion(:,4:6),'LineWidth',3);
    axis tight; grid on; title('Rotation','Fontsize',14)
    xlabel('scans'); ylabel('degrees');
    subplot(3,2,3); plot(derivatives(:,1:3),'LineWidth',3);
    axis tight; grid on; title('scan to scan translation','Fontsize',14)
    xlabel('scans'); ylabel('mm');
    subplot(3,2,4); plot(derivatives(:,4:6),'LineWidth',3);
    axis tight; grid on; title('scan to scan rotation','Fontsize',14)
    xlabel('scans'); ylabel('degrees');
    subplot(3,2,5:6); plot(delta,'LineWidth',3); hold on;
    plot(m_outliers.*max(delta),'or','LineWidth',3);
    axis tight; grid on; title('Mean square displacement','FontSize',14);
    xlabel('scans'); ylabel('displacement');
    saveas(gcf, 'motion outlier detection.fig','fig'); close(gcf)
end


%% look at globals
if strcmp(flags.globals,'on')
    
    % find outliers in global mean intensity
    disp('computing globals for outliers ... ')
    glo = zeros(size(P,1),1);
    for s=1:size(P,1)
        glo(s) = spm_global(spm_vol(P(s,:)));
    end
    glo = detrend(glo); % since in spm the data are detrended
    
    if glo ~=0
        % interquartile range
        y=sort(glo);
        j=floor(length(glo)/4 + 5/12);
        g=(length(glo)/4)-j+(5/12);
        ql=(1-g).*y(j)+g.*y(j+1); % lower quartile
        k=length(glo)-j+1;
        qu=(1-g).*y(k)+g.*y(k-1); % higher quartile
        value=qu-ql; % inter-quartile range
        
        % robust outliers
        M = median(glo);
        k=(17.63*n-23.64)/(7.74*n-3.71); % Carling's k
        g_outliers=glo<(M-k*value) | glo>(M+k*value);
        
        if sum(g_outliers) > 0
            goutlier_matrix = zeros(size(motion_param,1),sum(g_outliers));
            indices = find(g_outliers);
            for i=1:sum(g_outliers)
                goutlier_matrix(indices(i),i) = 1;
            end
        else
            goutlier_matrix = [];
        end
        
        % figure
        figure('Name','Globals outlier detection','Visible','Off');
        set(gcf,'Color','w','InvertHardCopy','off', 'units','normalized', 'outerposition',[0 0 1 1]);
        plot(glo,'LineWidth',3); hold on; plot(g_outliers.*(max(glo)-mean(glo))+mean(glo),'or','LineWidth',2);
        grid on; axis tight; title('Global intensity','FontSize',14); xlabel('scans'); ylabel('mean intensity')
        saveas(gcf, 'globals outlier detection.fig','fig'); close(gcf)
    else
        goutlier_matrix = [];
    end
end

%% update the motion parameter file

if isempty(goutlier_matrix) && isempty(moutlier_matrix)
    multiple_regressors = motion_param;
else
    if strcmp(flags.motion_parameters,'on') && strcmp(flags.globals,'on')
        % check a volume is not indexed twice
        out = [moutlier_matrix goutlier_matrix];
        for j=1:size(out,2); w(j) = find(out(:,j)==1); end
        [ww,index]=unique(w); out = zeros(n,length(index));
        for j=1:size(out,2); out(ww(j),index(j)) = 1; end
        multiple_regressors = [motion_param out];
    elseif strcmp(flags.motion_parameters,'on') && strcmp(flags.globals,'off')
        multiple_regressors = [motion_param moutlier_matrix];
    elseif strcmp(flags.motion_parameters,'off') && strcmp(flags.globals,'on')
        multiple_regressors = [motion_param goutlier_matrix];
    end
end
save multiple_regressors.txt multiple_regressors -ascii


%% check distances to the mean and volume to volume
if strcmp(flags.volume_distance, 'on')
    
    V = spm_vol(P);
    n = size(P,1);
    distance_to_mean = zeros(n,1);
    distance_between = zeros(n-1,1);
    mean_data = spm_read_vols(spm_vol(average));
    mask = mean_data > 0;
    
    for i=1:n
        fprintf('computing mean square distances, volume %g/%g \n',i,n)
        vol = spm_read_vols(V(i));
        dist = (mean_data(mask) - vol(mask)).^2;
        distance_to_mean(i) = sum(dist(~isnan(dist)))/numel(~isnan(dist));
        if i<n
            vol2 = spm_read_vols(V(i+1));
            dist = (vol2(mask) - vol(mask)).^2;
            distance_between(i) = sum(dist(~isnan(dist)))/numel(~isnan(dist));
        end
    end
      
    figure('Name','Mean square distances between volumes','Visible','Off');
    set(gcf,'Color','w','InvertHardCopy','off', 'units','normalized', 'outerposition',[0 0 1 1]); 
    subplot(2,1,1); plot([1:n],distance_to_mean,'o','LineWidth',3);
    axis tight; grid on; xlabel('scans'); ylabel('square difference');
    title('Mean square distance to the average','FontSize',14);
    subplot(2,1,2); plot([1:n],[NaN; distance_between],'o','LineWidth',3);
    hold on;  plot(distance_between,'r','LineWidth',2);
    axis tight; grid on; xlabel('scans'); ylabel('square difference');
    title('Volume to volume mean square distance','FontSize',14);
    saveas(gcf,'distances.fig','fig'); close(gcf)
    
end

%% make movies
if strcmp (flags.movie, 'on')

    if strcmp(def_flags.volume_distance, 'off')
        V = spm_vol(P);
    end
    Images = spm_read_vols(V);
    X = squeeze(Images(flags.AC(1),:,:,:));
    Y = squeeze(Images(:,flags.AC(2),:,:));
    Z = squeeze(Images(:,:,flags.AC(3),:));
    clear Images
    
    for plane = 1:3
        figure; colormap('gray')
        
        % make video object
        if plane == 1
            vidObj = VideoWriter('sagital.avi');
        elseif plane == 2
            vidObj = VideoWriter('coronal.avi');
        elseif plane == 3
            vidObj = VideoWriter('axial.avi');
        end
        open(vidObj);
        set(gca,'NextPlot','replacechildren')
        
        % make pictures and get frames
        for i=1:n
            if plane == 1
                imagesc(X(:,:,i)');axis tight
            elseif plane == 2
                imagesc(Y(:,:,i)');axis tight
            elseif plane == 3
                imagesc(Z(:,:,i)');axis tight
            end
            title(['volume ' num2str(i)]);
            currFrame = getframe;
            writeVideo(vidObj,currFrame);
        end
        close(vidObj);close
    end

end

cd(current)
disp('realign QA done');
