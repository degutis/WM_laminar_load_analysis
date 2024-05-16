function M = generateNullDist(lengthTime,timecourse_baseline,numBootSamples,num2mean,layer,seed)

rng(seed)
    
nullFiles = dir(fullfile(timecourse_baseline,'*.mat'));

if length(nullFiles)==1
    currentFile = load(fullfile(nullFiles(1).folder,nullFiles(1).name));
    currentFile_sup = cat(4,currentFile.mean_sup_extended{:});
    currentFile_deep = cat(4,currentFile.mean_deep_extended{:}); 
    
    subjectBaselines_sup = zeros(lengthTime,250,num2mean);
    subjectBaselines_deep = zeros(lengthTime,250,num2mean);
    for subject = 1:num2mean
        H_sup = squeeze(currentFile_sup(:,:,subject,:));
        subjectBaselines_sup(:,:,subject) = reshape(H_sup(logical(repmat(eye(size(H_sup(:,:,1))),1,1,250))),lengthTime,[]);        
        H_deep = squeeze(currentFile_deep(:,:,subject,:));
        subjectBaselines_deep(:,:,subject) = reshape(H_deep(logical(repmat(eye(size(H_deep(:,:,1))),1,1,250))),lengthTime,[]);        
    end


else
    for f=1:numel(nullFiles)
        currentFile = load(fullfile(nullFiles(f).folder,nullFiles(f).name));
        currentFile_sup = cat(4,currentFile.mean_sup_extended{:});
        currentFile_deep = cat(4,currentFile.mean_deep_extended{:});        
        
        for subject = 1:num2mean
            H_sup = squeeze(currentFile_sup(:,:,subject,:));
            subjectBaselines_sup(:,(f-1)*50+1:f*50,subject) = reshape(H_sup(logical(repmat(eye(size(H_sup(:,:,1))),1,1,50))),lengthTime,[]);        
            
            H_deep = squeeze(currentFile_deep(:,:,subject,:));
            subjectBaselines_deep(:,(f-1)*50+1:f*50,subject) = reshape(H_deep(logical(repmat(eye(size(H_deep(:,:,1))),1,1,50))),lengthTime,[]);        
        end
    end
end

if strcmp(layer,'sup')
    subjectBaselines = subjectBaselines_sup-50; %get rid of theoretical baseline;
elseif strcmp(layer,'deep')
    subjectBaselines = subjectBaselines_deep-50; %get rid of theoretical baseline;
elseif strcmp(layer,'both')
    subjectBaselines = subjectBaselines_sup-subjectBaselines_deep;
end

M = zeros(lengthTime,numBootSamples,num2mean);

for t =1:lengthTime
    for ss=1:num2mean
        M(t,:,ss) = datasample(subjectBaselines(t,:,ss),numBootSamples,'Replace',true);
    end
end

end