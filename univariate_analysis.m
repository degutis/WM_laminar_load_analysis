function univariate_analysis(roi)
% roi = 'dlPFC', 'COP', 'dlPFC_right', 'COP_right'

participants = {'S01','S02','S03','S04','S05','S06','S07','S08','S09'};
participant_dir = '../data/';

path2outputDir = '../results/univariate/';

mkdir(path2outputDir);     
   
for p=1:length(participants)
    resultsSub = [];
    resultsSub_sizes = [];
    participant_name = ['Sub',num2str(p)];

    scans_p1 = dir(fullfile(participant_dir,participants{p},'func','Load_long_TENTzero_res*_High_prcchg.nii'));
    scans_p2 = dir(fullfile(participant_dir,participants{p},'func','Load_long_TENTzero_res*_Low_prcchg.nii'));
    scans_p3 = dir(fullfile(participant_dir,participants{p},'func','Motor_long_TENTzero_res*_Press_prcchg.nii'));
    scans_p4 = dir(fullfile(participant_dir,participants{p},'func','Motor_long_TENTzero_res*_NoPress_prcchg.nii'));
             
    scans_p = [scans_p1;scans_p2;scans_p3;scans_p4];
    
    if strcmp(roi,'dlPFC')
        mask_dir = fullfile('..','data',participants(p),'anat','dlpfc_l_parcel_map.nii');
    elseif strcmp(roi,'COP')
        mask_dir = fullfile('..','data',participants(p),'anat','cop_l_parcel_map.nii');
    elseif strcmp(roi,'dlPFC_right')
        mask_dir = fullfile('..','data',participants(p),'anat','fpn_r_parcel_map.nii');
    elseif strcmp(roi,'COP_right')
        mask_dir = fullfile('..','data',participants(p),'anat','cop_r_parcel_map.nii');
    else
        error("No such ROI")
    end

    currentMask_dir = dir(mask_dir{:});
    currentMask_header = spm_vol([currentMask_dir.folder,'/',currentMask_dir.name]);
    currentMask = spm_read_vols(currentMask_header);

    currentMask(currentMask~=0)=1;
    
    currentLayer_header = spm_vol([currentMask_dir.folder,'/ds_scaled_rim_layers_equidist_3layers.nii']);
    currentLayer = spm_read_vols(currentLayer_header);
    
    currentMask = currentMask.*currentLayer;
   
    for s=1:length(scans_p)
        currentNifti=niftiread([scans_p(s).folder, '/',scans_p(s).name]);

        mask_sup = double(currentMask==3);
        mask_deep = double(currentMask==1);               
        
        mask_sup = repmat(mask_sup,[1,1,1,size(currentNifti,4)]);
        mask_deep = repmat(mask_deep,[1,1,1,size(currentNifti,4)]);
        
        %EPI manipulation
        
        currentNifti_deep = mask_deep.*currentNifti;
        currentNifti_sup = mask_sup.*currentNifti;

        currentNifti_sup=reshape(currentNifti_sup,[size(currentNifti,1)*size(currentNifti,2)*size(currentNifti,3),size(currentNifti,4)]); 
        currentNifti_deep=reshape(currentNifti_deep,[size(currentNifti,1)*size(currentNifti,2)*size(currentNifti,3),size(currentNifti,4)]); 

        currentNifti_sup(currentNifti_sup==0)=NaN;
        currentNifti_sup(currentNifti_sup==abs(Inf))=NaN;
        
        currentNifti_deep(currentNifti_deep==0)=NaN;
        currentNifti_deep(currentNifti_deep==abs(Inf))=NaN;
                       
        ROI_sizeSup = sum(~isnan(currentNifti_sup(:,1)));
        ROI_sizeDeep = sum(~isnan(currentNifti_deep(:,1)));
        
        currentNifti_sup = mean(currentNifti_sup,'omitnan');
        currentNifti_deep = mean(currentNifti_deep,'omitnan');
        
        currentNifti_sup = [0,currentNifti_sup,0];
        currentNifti_deep = [0,currentNifti_deep,0];
                      
        resultsSub = [resultsSub; currentNifti_sup; currentNifti_deep];
        resultsSub_sizes = [resultsSub_sizes; ROI_sizeSup; ROI_sizeDeep];

    %structure: LoadHigh_sup, LoadHigh_deep, LoadLow_sup,
    %LoadLow_deep, MotorPress_sup, MotorPress_deep,
    %MotorNP_sup, MotorNP_deep
    end

    results_full(:,:,p) = [resultsSub];
    results_full_size(:,:,p) = [resultsSub_sizes];

end
save(fullfile(path2outputDir,[roi,'.mat']),'results_full','results_full_size')
end
