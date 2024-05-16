function decoding(decodingName,ROI_name,crossDecoding) 

participants = {'S01','S02','S03','S04','S05','S06','S07','S08','S09'};
participant_dir = '../data/';

TR=2;

meanTR=1;
    
if strcmp(decodingName,'Load')
    selectRuns = [1];
elseif strcmp(decodingName,'Motor')
    selectRuns=[2];
end

resultsName = [decodingName,'_',ROI_name,'.mat'];
path2outputDir = '../results/decoding/';

mkdir(path2outputDir);

for p=1:length(participants)

    resultsSub_sup_ET_gen = [];
    resultsSub_deep_ET_gen = [];

    resultsSub_sizes = [];

    scans_p = dir(fullfile(participant_dir,participants{p},'func','*.nii'));
   
    scans_load = {};
    scans_motor = {};
    
    for scan=1:length(scans_p)
        if contains(scans_p(scan).name,'Load')
            scans_load = [scans_load;scans_p(scan)];
        elseif contains(scans_p(scan).name,'Motor') 
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
    
    results_full_sup_ET_gen(:,:,p) = {resultsSub_sup_ET_gen};
    results_full_deep_ET_gen(:,:,p) = {resultsSub_deep_ET_gen};
                
    trials_p(:,:,p) = [trials];
    results_full_size(:,:,p) = [resultsSub_sizes];


    %% Run decoding
    
    if crossDecoding==0
        averageAccuracy_gen_sup(:,:,p) = runSVMGeneralization_transMatrix(resultsSub_sup_ET_gen,trials,meanTR,1,1,0);        
        averageAccuracy_gen_deep(:,:,p) = runSVMGeneralization_transMatrix(resultsSub_deep_ET_gen,trials,meanTR,1,1,0);
    elseif crossDecoding==1
        averageAccuracy_gen_sup(:,:,p) = runSVMGeneralization_transMatrix_fullTemporal(resultsSub_sup_ET_gen,trials,meanTR,1,1,0);        
        averageAccuracy_gen_deep(:,:,p) = runSVMGeneralization_transMatrix_fullTemporal(resultsSub_deep_ET_gen,trials,meanTR,1,1,0);
    end

end
save(fullfile(path2outputDir,resultsName),'results_full_size','trials_p','averageAccuracy_gen_sup','averageAccuracy_gen_deep')                     

end
