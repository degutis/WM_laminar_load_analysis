function decoding_sanityCheck(sanityCheck)

decodingName = "Load";
ROI_name = "dlPFC";

resultsName = strcat(decodingName,'_',ROI_name,'_',sanityCheck);
path2outputDir = '../results/response_to_reviewers/decoding';
mkdir(path2outputDir)

participants = {'S01','S02','S03','S04','S05','S06','S07','S08','S09'};
participant_dir = '../data/';

TR=2;

meanTR=1;
    
if strcmp(decodingName,'Load')
    selectRuns = [1];
elseif strcmp(decodingName,'Motor')
    selectRuns=[2];
elseif strcmp(decodingName,'Category')
    selectRuns=[1];
end

for p=1:length(participants)

    [correct_trials, rt] = select_trials_behavior(p,1);  

    resultsSub_sup_ET_gen = [];
    resultsSub_deep_ET_gen = [];

    resultsSub_sizes = [];

%    scans_p = dir(fullfile(participant_dir,participants{p},'func','*.nii'));
   
    scans_p = dir(fullfile("..","functional_data",[participants{p},'*.nii']));
   
    scans_load = {};
    scans_motor = {};
    
    for scan=1:length(scans_p)
        if contains(scans_p(scan).name,'_load')
            scans_load = [scans_load;scans_p(scan)];
        elseif contains(scans_p(scan).name,'_motor') 
            scans_motor = [scans_motor;scans_p(scan)];
        end
    end
    
    scans_Both = [scans_load,scans_motor];
    
    timings_dir_1 = dir(fullfile(participant_dir,participants{p},'beh','derivates','event_file_SPM_FULLDELAY_TYPE_sup*.txt'));        
    timings_dir_2 = dir(fullfile(participant_dir,participants{p},'beh','derivates','event_file_SPM_FULLDELAY_TYPE_deep*.txt'));
    
    timings_dir = [timings_dir_1,timings_dir_2];
    
    if strcmp(ROI_name,'dlPFC')
        mask_dir = fullfile('..','data',participants(p),'anat','dlpfc_l_parcel_map.nii');
    elseif strcmp(ROI_name,'COP')
        mask_dir = fullfile('..','data',participants(p),'anat','cop_l_parcel_map.nii');
    elseif strcmp(ROI_name,'dlPFC_right')
        mask_dir = fullfile('..','data',participants(p),'anat','fpn_r_parcel_map.nii');
    elseif strcmp(ROI_name,'COP_right')
        mask_dir = fullfile('..','data',participants(p),'anat','cop_r_parcel_map.nii');
    else
        error("No such ROI")
    end

    mask_dir = mask_dir{:};
    currentMask_header = spm_vol(mask_dir);
    currentMaskHem = spm_read_vols(currentMask_header);
    currentMaskHem(currentMaskHem~=0)=1;
    
    layers_dir = fullfile('..','data',participants(p),'anat','/ds_scaled_rim_layers_equidist_3layers.nii');
    layers_dir = dir(layers_dir{:});
    
    currentLayers_header = spm_vol([layers_dir.folder,'/',layers_dir.name]);
    currentLayers = spm_read_vols(currentLayers_header);
    
    currentROI = currentMaskHem.*currentLayers;
    
    trials = [];
    
    for runType = selectRuns
        
        currentNifti_sup_trialExtended_AR_Gen = [];
        currentNifti_deep_trialExtended_AR_Gen = [];
        
        currentTimings = timings_dir(:,runType);

        mask_sup = double(currentROI==3);
        mask_deep = double(currentROI==1);
        mask_sup(mask_sup==0) = NaN;
        mask_deep(mask_deep==0) = NaN;
                        
        for currRun = 1:size(currentTimings,1)
            
            currentNifti=niftiread([scans_Both{currRun,runType}.folder, '/',scans_Both{currRun,runType}.name]);
            disp(['Uploaded: ' scans_Both{currRun,runType}.name])
            disp(['Timings from file: ' timings_dir(currRun,runType).name])                      
                                
            currentNifti(isnan(currentNifti))=0;
            
            mask_sup_Nifti = repmat(mask_sup,[1,1,1,size(currentNifti,4)]);
            mask_deep_Nifti = repmat(mask_deep,[1,1,1,size(currentNifti,4)]);
            
            %EPI manipulation

            currentNifti_deep = mask_deep_Nifti.*currentNifti;
            currentNifti_sup = mask_sup_Nifti.*currentNifti;

            currentNifti_sup=reshape(currentNifti_sup,[size(currentNifti,1)*size(currentNifti,2)*size(currentNifti,3),size(currentNifti,4)]); 
            currentNifti_deep=reshape(currentNifti_deep,[size(currentNifti,1)*size(currentNifti,2)*size(currentNifti,3),size(currentNifti,4)]); 

            currentNifti_sup(currentNifti_sup==abs(Inf))=0;
            currentNifti_deep(currentNifti_deep==abs(Inf))=0;
            
            currentNifti_sup(any(isnan(currentNifti_sup), 2), :) = [];
            currentNifti_deep(any(isnan(currentNifti_deep), 2), :) = [];
                            
            currentNifti_sup = highPassFilter(currentNifti_sup',TR,1/128)';
            currentNifti_sup = normalize(currentNifti_sup')';
            currentNifti_sup = normalize(currentNifti_sup','range')';
            
            currentNifti_deep = highPassFilter(currentNifti_deep',TR,1/128)';                       
            currentNifti_deep = normalize(currentNifti_deep')';                        
            currentNifti_deep = normalize(currentNifti_deep','range')';                    
            
            ROI_sizeSup = currentNifti_sup(:,1);
            ROI_sizeSup = length(ROI_sizeSup(~isnan(ROI_sizeSup)));
            ROI_sizeDeep = currentNifti_deep(:,1);
            ROI_sizeDeep = length(ROI_sizeDeep(~isnan(ROI_sizeDeep)));
            
            % extraction of trials
            
            trials_run = tdfread(fullfile(currentTimings(currRun,1).folder,(currentTimings(currRun,1).name)));
            indexTrials = zeros(length(trials_run.condition),1);

            if strcmp(decodingName,'Load')
                for trial = 1:length(trials_run.condition)
                    if contains(trials_run.condition(trial,:),'High_')
                       indexTrials(trial-selectRuns(1)) = 1;
                    elseif contains(trials_run.condition(trial,:),'Low_')
                       indexTrials(trial-selectRuns(1)) = 2;
                    end
                end
            elseif strcmp(decodingName,'Motor')
                for trial = 1:length(trials_run.condition)
                    if contains(trials_run.condition(trial,:),'_press')
                       indexTrials(trial-selectRuns(1)) = 1;
                    elseif contains(trials_run.condition(trial,:),'_NOpress')
                       indexTrials(trial-selectRuns(1)) = 2;
                    end
                end

            elseif strcmp(decodingName,'Category')
                for trial = 1:length(trials_run.condition)
                    if contains(trials_run.condition(trial,:),'_face') %  High_ _press _face
                       indexTrials(trial-1) = 1;
                    elseif contains(trials_run.condition(trial,:),'_scene') % Low_ _NOpress _scene
                       indexTrials(trial-1) = 2;
                    end
                end
            end                        

            indexDelay = indexTrials;
            indexDelay(indexDelay==0) = [];
            indexTrials(indexTrials==2) = 1;
            indexTrials = indexTrials==1;
            
            trials = [trials,indexDelay];
            
            trials_Time = ceil(trials_run.onset(indexTrials)/TR)+1; 
            trials_TimeExtended = floor(trials_run.onset(indexTrials)/TR);
            
            trialsExtended = [];
            
            for trial =1:length(trials_Time)
                trialsExtended(:,trial) = trials_TimeExtended(trial):trials_TimeExtended(trial)+16;       
            end
                            
            currentNifti_sup_ExtendedTrial = [];
            currentNifti_deep_ExtendedTrial = [];

            for trial =1:length(indexDelay)
                currentNifti_sup_ExtendedTrial(:,:,trial) = currentNifti_sup(:,trialsExtended(:,trial));
                currentNifti_deep_ExtendedTrial(:,:,trial) = currentNifti_deep(:,trialsExtended(:,trial));
            end
            
            currentNifti_sup_ExtendedTrial_Gen = permute(currentNifti_sup_ExtendedTrial,[1 3 2]);
            currentNifti_deep_ExtendedTrial_Gen = permute(currentNifti_deep_ExtendedTrial, [1 3 2]);
            
            currentNifti_sup_trialExtended_AR_Gen = [currentNifti_sup_trialExtended_AR_Gen, currentNifti_sup_ExtendedTrial_Gen];
            currentNifti_deep_trialExtended_AR_Gen = [currentNifti_deep_trialExtended_AR_Gen, currentNifti_deep_ExtendedTrial_Gen];
            
        end

        resultsSub_sup_ET_gen = [resultsSub_sup_ET_gen;currentNifti_sup_trialExtended_AR_Gen];
        resultsSub_deep_ET_gen = [resultsSub_deep_ET_gen;currentNifti_deep_trialExtended_AR_Gen];
        
        resultsSub_sizes = [resultsSub_sizes; ROI_sizeSup; ROI_sizeDeep];
    end 
    
    %% apply some selection
    
    
    if strcmp(sanityCheck,"onlyCorrectTrials")  %rt_sanityCheck"; %onlyCorrectTrials
        correct_trials = correct_trials(1:end-1,:);
        
        resultsSub_sup_ET_gen_select = resultsSub_sup_ET_gen(:,logical(correct_trials(:)),:); 
        resultsSub_deep_ET_gen_select = resultsSub_deep_ET_gen(:,logical(correct_trials(:)),:); 

        averageAccuracy_gen_sup(:,:,p) = runSVMGeneralization_transMatrix_selectTrials(resultsSub_sup_ET_gen_select,trials,correct_trials,meanTR,1,1,0);        
        averageAccuracy_gen_deep(:,:,p) = runSVMGeneralization_transMatrix_selectTrials(resultsSub_deep_ET_gen_select,trials,correct_trials,meanTR,1,1,0);        

    
    elseif strcmp(sanityCheck, "rt_sanityCheck")
        rt = rt(1:end-1,:);
        rt_low = rt(trials==1);
        rt_high = rt(trials==2);
        rt_vect = rt(:);
        trials_vect = trials(:);

        rt_median_low  = nanmedian(rt_low(:));
        rt_median_high = nanmedian(rt_high(:));

        %rt_median = nanmedian(rt(:));
    
        trials_transformed = trials(~isnan(rt));
        resultsSub_sup_ET_gen_select = resultsSub_sup_ET_gen(:,~isnan(rt),:); 
        resultsSub_deep_ET_gen_select = resultsSub_deep_ET_gen(:,~isnan(rt),:); 

        trials_changed = trials_transformed;
        
        count = 0;
        for t = 1:length(rt_vect)
            if ~isnan(rt_vect(t)) && trials_vect(t)==1 && rt_vect(t)<=rt_median_low
                count = count+1;
                trials_changed(count) = 1;
            elseif ~isnan(rt_vect(t)) && trials_vect(t)==2 && rt_vect(t)<=rt_median_high
                count = count+1;
                trials_changed(count) = 1;
            elseif ~isnan(rt_vect(t)) && trials_vect(t)==1 && rt_vect(t)>rt_median_low
                count = count+1;
                trials_changed(count) = 2;
            elseif ~isnan(rt_vect(t)) && trials_vect(t)==2 && rt_vect(t)>rt_median_high
                count = count+1;
                trials_changed(count) = 2;
            end
        end

%         trials_changed(rt>=rt_median) = 2;
%         trials_changed(rt<rt_median) = 1;

        averageAccuracy_gen_sup(:,:,p) = runSVMGeneralization_transMatrix_selectTrials(resultsSub_sup_ET_gen_select,trials_changed, ones(length(trials_transformed),1),meanTR,1,1,0);        
        averageAccuracy_gen_deep(:,:,p) = runSVMGeneralization_transMatrix_selectTrials(resultsSub_deep_ET_gen_select,trials_changed,ones(length(trials_transformed),1),meanTR,1,1,0);        

    end

    results_full_sup_ET_gen(:,:,p) = {resultsSub_sup_ET_gen};
    results_full_deep_ET_gen(:,:,p) = {resultsSub_deep_ET_gen};

end

averageAccuracy_gen_sup = squeeze(averageAccuracy_gen_sup)-50;
averageAccuracy_gen_deep = squeeze(averageAccuracy_gen_deep)-50;

save(fullfile(path2outputDir,strcat(resultsName,'.mat')),'averageAccuracy_gen_sup','averageAccuracy_gen_deep');                     


%% Plotting

loadSup = averageAccuracy_gen_sup;
loadDeep = averageAccuracy_gen_deep;

rightPFC=0;
timecourseBaselineDir = '../results/decoding/permuted/';
if rightPFC==1
    addText = 'right_';
else
    addText='';
end
timecourseBaselineDir_current = [timecourseBaselineDir,'dlPFC_',addText,'Load'];

xticklabels_name = {'2','6','10','14','18','22','26','30'};
subs=9;

[circle_pvalues_load_sup, circle_pvalues_load_sup_below, clusters_load_sup, pvalues_load_sup] = permutationTest_timecourse(loadSup',generateNullDist(16,timecourseBaselineDir_current,10000,subs,'sup',1),0);
[circle_pvalues_load_deep, circle_pvalues_load_deep_below, clusters_load_deep, pvalues_load_deep] = permutationTest_timecourse(loadDeep',generateNullDist(16,timecourseBaselineDir_current,10000,subs,'deep',2),0);
[circle_pvalues_load, circle_pvalues_load_below, clusters_load, pvalues_load] = permutationTest_timecourse(loadSup'-loadDeep',generateNullDist(16,timecourseBaselineDir_current,10000,subs,'both',3),true);

effect_clusters_load_sup = computeCohen_d_clusterMean(loadSup,zeros(1,subs),clusters_load_sup);
effect_clusters_load_deep = computeCohen_d_clusterMean(loadDeep,zeros(1,subs),clusters_load_deep);
effect_clusters_load = computeCohen_d_clusterMean(loadSup,loadDeep,clusters_load);



time = 1:16;
colors = cbrewer('div', 'PuOr', 11);
colors = [colors(1,:);colors(3,:)];

fig1 = figure(1)
set(fig1, 'PaperUnits', 'inches');
x_width=7 ;y_width=4;
set(fig1, 'PaperPosition', [0 0 x_width y_width]); %

subplot(3,3,1)
hold on;
bl = boundedline(time, mean(loadSup(1:end,:),2)', std(loadSup(1:end,:),[],2)/sqrt(subs)', ...
    time, mean(loadDeep(1:end,:),2)', std(loadDeep(1:end,:),[],2)/sqrt(subs)', ...
    'cmap', colors, ... 
    'alpha');

xlim([1 max(time)]); ylim([-10 15])
yline(0,'LineStyle','--')
xticks([2,4,6,8,10,12,14,16])
xticklabels(xticklabels_name)

scatter(time, circle_pvalues_load_sup./circle_pvalues_load_sup*-4,(circle_pvalues_load_sup+1).^2,colors(1,:),'filled','d')
scatter(time, circle_pvalues_load_deep./circle_pvalues_load_deep*-8,(circle_pvalues_load_deep+1).^2,colors(2,:),'filled','d')
scatter(time, circle_pvalues_load./circle_pvalues_load*13,(circle_pvalues_load+1).^2,[0,0,0],'filled','d')

lh = legend(bl);
legnames = {'Superficial Load', 'Deep Load'};
for i = 1:length(legnames)
    str{i} = ['\' sprintf('color[rgb]{%f,%f,%f} %s', colors(i, 1), colors(i, 2), colors(i, 3), legnames{i})];
end
lh.String = str;
lh.Box = 'off';

% move a bit closer
lpos = lh.Position;
lpos(1) = lpos(1) + 0.6;
lh.Position = lpos;
hold off;
title('Left dlPFC','FontSize',10,'FontWeight','Normal')
saveas(fig1,fullfile(path2outputDir,strcat(resultsName,'.svg')))   

save(fullfile(path2outputDir,strcat(resultsName,'_stats.mat')),...
    'circle_pvalues_load_sup', 'circle_pvalues_load_sup_below', 'clusters_load_sup', 'pvalues_load_sup',...
    'circle_pvalues_load_deep', 'circle_pvalues_load_deep_below', 'clusters_load_deep', 'pvalues_load_deep',...
    'circle_pvalues_load', 'circle_pvalues_load_below', 'clusters_load', 'pvalues_load',...
    "effect_clusters_load","effect_clusters_load_deep","effect_clusters_load_sup");

