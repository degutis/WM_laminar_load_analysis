function [accuracyAverage] = runSVMGeneralization_transMatrix_selectTrials(dataSet,labels,select_trials,meanTR,featureSelect,featureZscore,shuffleLabels)

% linear classification
rng(13011991)
labels_trans = zeros(size(labels));

for c = 1:size(labels,2)
    for i = 1:length(labels)-1
        if labels(i,c)==1
            if labels(i+1,c)==1
                labels_trans((i+1),c) = 11;
            elseif labels(i+1,c)==2
                labels_trans((i+1),c) = 12;
            end
        elseif labels(i,c)==2
            if labels(i+1,c)==1
                labels_trans((i+1),c) = 21;
            elseif labels(i+1,c)==2
                labels_trans((i+1),c) = 22;
            end
        end
    end
end

labels_trans = labels_trans(logical(select_trials));
labels = labels(logical(select_trials));

[GC, GN] = groupcounts(labels_trans);

[~,iMin] = min(GC(2:end));
GN_min = GN(2:end);
GN_min = GN_min(iMin);

GN_min_occ = find(labels_trans==GN_min);
minTrain = length(GN_min_occ)-1;

GN_min_train = combntns(GN_min_occ,minTrain);
GN_min_train = [GN_min_train;GN_min_train;GN_min_train;GN_min_train]; %this inreases the number of training/testing loops
GN_min_train = GN_min_train(randperm(length(GN_min_train)),:);


GN_rem = GN(2:end);
GN_rem = GN_rem(GN_rem~=GN_min);

GN_rem1_occ = find(labels_trans==GN_rem(1));
GN_rem1_train = combntns(GN_rem1_occ,minTrain);
if length(GN_rem1_train)>=length(GN_min_train)
    GN_rem1_train = GN_rem1_train(randperm(length(GN_rem1_train)),:);
    GN_rem1_train = GN_rem1_train(1:length(GN_min_train),:);
else
%     error('nope')
    GN_rem1_train_1 = GN_rem1_train(randperm(length(GN_rem1_train)),:);
    GN_rem1_train_2 = GN_rem1_train(randperm(length(GN_rem1_train)),:);
    
    GN_rem1_train = [GN_rem1_train_1; GN_rem1_train_2];

    try
        GN_rem1_train = GN_rem1_train(1:length(GN_min_train),:);
    catch
        GN_rem2_train = [GN_rem1_train;GN_rem1_train_1; GN_rem1_train_2];
        GN_rem1_train = GN_rem2_train(1:length(GN_min_train),:);
    end

end


GN_rem2_occ = find(labels_trans==GN_rem(2));
GN_rem2_train = combntns(GN_rem2_occ,minTrain);
if length(GN_rem2_train)>=length(GN_min_train)
    GN_rem2_train = GN_rem2_train(randperm(length(GN_rem2_train)),:);
    GN_rem2_train = GN_rem2_train(1:length(GN_min_train),:);
else
%     error('nope')
    GN_rem2_train_1 = GN_rem2_train(randperm(length(GN_rem2_train)),:);
    GN_rem2_train_2 = GN_rem2_train(randperm(length(GN_rem2_train)),:);
    
    GN_rem2_train = [GN_rem2_train_1; GN_rem2_train_2];

    try
        GN_rem2_train = GN_rem2_train(1:length(GN_min_train),:);
    catch
        GN_rem2_train = [GN_rem2_train;GN_rem2_train_1; GN_rem2_train_2];
        GN_rem2_train = GN_rem2_train(1:length(GN_min_train),:);
    end

end

GN_rem3_occ = find(labels_trans==GN_rem(3));
GN_rem3_train = combntns(GN_rem3_occ,minTrain);
if length(GN_rem3_train)>=length(GN_min_train)
    GN_rem3_train = GN_rem3_train(randperm(length(GN_rem3_train)),:);
    GN_rem3_train = GN_rem3_train(1:length(GN_min_train),:);
else
%     error('nope')
    GN_rem3_train_1 = GN_rem3_train(randperm(length(GN_rem3_train)),:);
    GN_rem3_train_2 = GN_rem3_train(randperm(length(GN_rem3_train)),:);
    
    GN_rem3_train = [GN_rem3_train_1; GN_rem3_train_2];
    try
        GN_rem3_train = GN_rem3_train(1:length(GN_min_train),:);
    catch
        GN_rem3_train = [GN_rem3_train;GN_rem3_train_1; GN_rem3_train_2];
        GN_rem3_train = GN_rem3_train(1:length(GN_min_train),:);
    end
end

trainValIndex = zeros(length(labels),length(GN_min_train));

for it = 1:length(GN_min_train)
    trainValIndex(GN_min_train(it,:),it)=1;
    trainValIndex(GN_rem1_train(it,:),it)=1;
    trainValIndex(GN_rem2_train(it,:),it)=1;
    trainValIndex(GN_rem3_train(it,:),it)=1;
end

testValIndex = ~trainValIndex;
trainValIndex = ~testValIndex;
% testValIndex(1,:)=0;
% testValIndex(1+length(labels)/2,:)=0;

numIterations = size(dataSet,3)-meanTR;
numIterations_within = length(GN_min_train);

dataSet = permute(dataSet,[2 1 3]);
accuracyAverage = zeros(numIterations,numIterations);

parfor trainIndex = 1:numIterations

    testIndex=trainIndex;
    
    predicted_label = {};
    accuracy = {};
    prob_values = {};
    model ={};

    for iteration=1:numIterations_within
        dataSelect_iter = mean(dataSet(trainValIndex(:,iteration),:,trainIndex:trainIndex+meanTR),3);
        outputIndex = runFeatureSelection(dataSelect_iter,labels(trainValIndex(:,iteration)),featureSelect);
        dataSelect_iter = dataSelect_iter(:,outputIndex);

%         dataSelect_iter = zscore(dataSelect_iter);
%         dataSelect_iter = normalize(dataSelect_iter,'range');

        if featureZscore==1
            dataSelect_iter = zscore(dataSelect_iter')';
        end

        dataTest_iter = mean(dataSet(testValIndex(:,iteration),:,testIndex:testIndex+meanTR),3);
        dataTest_iter = dataTest_iter(:,outputIndex);

%         dataTest_iter = zscore(dataTest_iter);
%         dataTest_iter = normalize(dataTest_iter,'range');

        if featureZscore==1
            dataTest_iter = zscore(dataTest_iter')';
        end

        if shuffleLabels==1
            labels_train = labels(trainValIndex(:,iteration));
            labels_train = labels_train(randperm(length(labels_train)));
        else
            labels_train = labels(trainValIndex(:,iteration));
        end        

        model{iteration} = svmtrain(labels_train,dataSelect_iter, '-s 0 -t 0 -c 1 -b 0 -q');
        [predicted_label{iteration}, accuracy{iteration}, prob_values{iteration}] = svmpredict(labels(testValIndex(:,iteration)), dataTest_iter, model{iteration}, '-b 0');  
    end

    accuracyAverage(trainIndex,1) = mean(cellfun(@(x) x(1), accuracy));
%     end
end

accuracyAverage_matrix = zeros(numIterations,numIterations);
for ii = 1:numIterations
    accuracyAverage_matrix(ii,ii) = accuracyAverage(ii);
end

accuracyAverage = accuracyAverage_matrix(logical(eye(numIterations)));

end