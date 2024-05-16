function [outputIndex] = runFeatureSelection(dataSet_iter, labels_iter,percentSelect)

    fstatWhole = zeros(size(dataSet_iter,2),1);
    selectVoxels = ceil(size(dataSet_iter,2)*percentSelect);
    
    for feature = 1:size(dataSet_iter,2)
        
        currData = [dataSet_iter(labels_iter==1,feature),dataSet_iter(labels_iter==2,feature)];
        [~,fCurr,~] = anova1(currData,[],'off');
        fstatWhole(feature) = fCurr{2,5};  
    end
    
    [~,sortFstat] = sort(fstatWhole,'descend');
    outputIndex = sortFstat(1:selectVoxels);
    
end