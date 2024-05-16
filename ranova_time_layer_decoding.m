rng(1200)

path2outputDir = '../results/response_to_reviewers/decoding';
mkdir(path2outputDir)

resultsANOVA = cell(2,4);
num_layers = 2;
num_subjects = 9;

for l = 1:4
    if l==1
        load("../results/decoding/Load_dlPFC.mat")
    elseif l==2
        load("../results/decoding/Load_dlPFC_right.mat")
    elseif l==3
        load("../results/decoding/Load_COP.mat")
    elseif l==4
        load("../results/decoding/Load_COP_right.mat")
    end

    loadSup = zeros(16,9);
    loadDeep = zeros(16,9);
    
    for s=1:num_subjects
        loadSup(:,s) = diag(averageAccuracy_gen_sup(:,:,s))-50;
        loadDeep(:,s) = diag(averageAccuracy_gen_deep(:,:,s))-50;
    end
    
    loadSup = loadSup(5:end-3,:);
    loadDeep = loadDeep(5:end-3,:);
    
    A_1 = mean(loadSup(1:3,:),1); 
    A_2 = mean(loadSup(4:7,:),1); 
    A_3 = mean(loadSup(8:9,:),1); 
    
    B_1 = mean(loadDeep(1:3,:),1); 
    B_2 = mean(loadDeep(4:7,:),1); 
    B_3 = mean(loadDeep(8:9,:),1); 
    
    A_new = [A_1;A_2;A_3];
    B_new = [B_1;B_2;B_3];
    
    num_time = size(A_new,1);
    
    % subject, load, time, data
    combo = [A_new',B_new'];
    
    data = array2table(combo);
    [f_true, AT] = run_ranova(data,num_layers,num_time);
    
    f_null = zeros(1000,1);
    for s = 1:1000
        combo_shuffled = zeros(size(combo));
        for sub=1:num_subjects
            combo_now = combo(sub,:);
            combo_shuffled(sub,:) = combo_now(randperm(length(combo_now)));
        end
        [f_null(s),~] = run_ranova(array2table(combo_shuffled),num_layers,num_time);
    end
    
    p_value = sum(f_null>f_true)/1000;
    np = AT{7,1}/(AT{8,1}+AT{7,1});

    resultsANOVA{1,l} = p_value;
    resultsANOVA{2,l} = np;
    %disp(anovaTable(AT,"Layer*Time"))
    
end

resultsANOVA = cell2table(resultsANOVA,...
"VariableNames",["DLPFC" "COP" "DLPFC Right" "COP Right"],...
"RowNames",["pval","etaSq"]);

save(fullfile(path2outputDir,'ANOVA.mat'),...
    'resultsANOVA');


function [f_interaction, AT] = run_ranova(data,num_layers,num_time)

    variableNames = strings(num_layers*num_time,1);
    update=1;
    for l = 1:num_layers
        layerString = strcat("l",num2str(l));
        for t = 1:num_time
            timeString = strcat("t",num2str(t));
            variableNames(update) = strcat(layerString,timeString);
            update = update+1;
        end
    end
    
    data.Properties.VariableNames = variableNames;
    WithinStructure = table([repmat(1,num_time,1);repmat(2,num_time,1)],repmat(1:num_time,1,num_layers)','VariableNames',{'Layer','Time'});
    WithinStructure.Layer = categorical(WithinStructure.Layer);
    WithinStructure.Time = categorical(WithinStructure.Time);
    
    rm = fitrm(data, strcat(variableNames(1),'-',variableNames(length(variableNames)),' ~ 1'), 'WithinDesign', WithinStructure);
    
    AT = ranova(rm, 'WithinModel', 'Layer*Time');
    % output an improved version of the anova table
    %disp(anovaTable(AT, 'Value'));

    f_interaction = AT{7,4};
end

function [s] = anovaTable(AT, dvName)

c = table2cell(AT);
% remove erroneous entries in F and p columns 
for i=1:size(c,1)       
        if c{i,4} == 1
            c(i,4) = {''};
        end
        if c{i,5} == .5
            c(i,5) = {''};
        end
end
% use conventional labels in Effect column
effect = AT.Properties.RowNames;
for i=1:length(effect)
    tmp = effect{i};
    tmp = erase(tmp, '(Intercept):');
    tmp = strrep(tmp, 'Error', 'Participant');
    effect(i) = {tmp}; 
end
% determine the required width of the table
fieldWidth1 = max(cellfun('length', effect)); % width of Effect column
fieldWidth2 = 57; % field needed for df, SS, MS, F, and p columns
barDouble = sprintf('%s\n', repmat('=', 1, fieldWidth1 + fieldWidth2));
barSingle = sprintf('%s\n', repmat('-', 1, fieldWidth1 + fieldWidth2));
% re-organize the data 
c = c(2:end,[2 1 3 4 5]);
c = [num2cell(repmat(fieldWidth1, size(c,1), 1)), effect(2:end), c]';
% create the ANOVA table
s = sprintf('ANOVA table for %s\n', dvName);
s = [s barDouble];
s = [s sprintf('%-*s %4s %10s %14s %10s %10s\n', fieldWidth1, 'Effect', 'df', 'SS', 'MS', 'F', 'p')];
s = [s barSingle];
s = [s, sprintf('%-*s %4d %14.3f %14.3f %10.3f %10.4f\n', c{:})];
s = [s, barDouble];
end


