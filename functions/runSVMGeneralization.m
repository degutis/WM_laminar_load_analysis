function [accuracyAverage] = runSVMGeneralization(dataSet, labels,numRuns,meanTR,featureSelect,featureZscore,shuffleLabels)

% linear classification
runwise=0;
shuffleLabels = 0;

numIterations = size(dataSet,3)-meanTR;
dataSet = permute(dataSet,[2 1 3]);
accuracyAverage = zeros(numIterations,1);

parfor trainIndex = 1:numIterations

    testIndex=trainIndex;
    testValIndex = zeros(size(dataSet,1),numRuns);

    if runwise==0

        testValIndex = eye(size(dataSet,1));
        numIterations_within = size(testValIndex,2);

    elseif runwise==2
        labels_1 = find(labels==1);
        labels_2 = find(labels==2);

        labels_1 = labels_1(randperm(length(labels_1)));
        labels_2 = labels_2(randperm(length(labels_2)));

        testValIndex = zeros(size(dataSet,1),numel(labels_1)/2);

        for iter = 1:2:numel(labels_1)
            testValIndex([labels_1(iter),labels_1(iter+1),labels_2(iter),labels_2(iter+1)],iter) = 1;
        end

        testValIndex = testValIndex(:,1:2:numel(labels_1));

        numIterations_within = size(testValIndex,2);    
    end

    testValIndex = testValIndex==1;
    trainValIndex = ~testValIndex;

    predicted_label = {};
    accuracy = {};
    prob_values = {};
    model ={};

    for iteration=1:numIterations_within

        dataSelect_iter = mean(dataSet(trainValIndex(:,iteration),:,trainIndex:trainIndex+meanTR),3);

%        dataSelect_iter = dataSelect_iter(:,outputIndex);
%        dataSelect_iter = zscore(dataSelect_iter);
%        dataSelect_iter = normalize(dataSelect_iter,'range');

%         if featureZscore==1
%             dataSelect_iter = zscore(dataSelect_iter')';
%         end

        dataTest_iter = mean(dataSet(testValIndex(:,iteration),:,testIndex:testIndex+meanTR),3);
%         dataTest_iter = dataTest_iter(:,outputIndex);
%         dataTest_iter = zscore(dataTest_iter);
%         dataTest_iter = normalize(dataTest_iter,'range');
%         if featureZscore==1
%             dataTest_iter = zscore(dataTest_iter')';
%         end

        if shuffleLabels==1
            labels_train = labels(trainValIndex(:,iteration));
            labels_train = labels_train(randperm(length(labels_train)));
        else
            labels_train = labels(trainValIndex(:,iteration));
        end        

        model{iteration} = svmtrain(labels_train,dataSelect_iter, '-s 0 -t 0 -c 1 -b 0.1 -q');
        [predicted_label{iteration}, accuracy{iteration}, prob_values{iteration}] = svmpredict(labels(testValIndex(:,iteration)), dataTest_iter, model{iteration}, '-b 0.1');  
    end

    accuracyAverage(trainIndex,1) = mean(cellfun(@(x) x(1), accuracy));
end


end