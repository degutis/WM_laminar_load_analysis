rng(19910113)

participants = {'S01','S02','S03','S04','S05','S06','S07','S08','S09'};
numP = length(participants);
responseSubj = cell(numP,12);


for p  = 1:numP
    csvFiles_load = dir(fullfile('..','data',participants{p},'beh','*load*.csv'));
    
    subjectAv_lowLoad = [];
    subjectAv_highLoad = [];
    subjectAv_lowLoad_face = [];
    subjectAv_lowLoad_scene = [];
    subjectAv_highLoad_face = [];
    subjectAv_highLoad_scene = [];
    
    
    for r = 1:2
        
        run = readtable(fullfile(csvFiles_load(r).folder,csvFiles_load(r).name));
        
        subjectAv_lowLoad = [subjectAv_lowLoad;run.keyResp_corr(run.load==1)];
        subjectAv_highLoad = [subjectAv_highLoad;run.keyResp_corr(run.load==4)];
    
        subjectAv_lowLoad_face = [subjectAv_lowLoad_face;run.keyResp_corr(run.load==1 & (contains(run.category,'ff') | contains(run.category,'fm')))];
        subjectAv_lowLoad_scene = [subjectAv_lowLoad_scene;run.keyResp_corr(run.load==1 & (contains(run.category,'so') | contains(run.category,'si')))];

        subjectAv_highLoad_face = [subjectAv_highLoad_face;run.keyResp_corr(run.load==4 & (contains(run.category,'ff') | contains(run.category,'fm')))];
        subjectAv_highLoad_scene = [subjectAv_highLoad_scene;run.keyResp_corr(run.load==4 & (contains(run.category,'so') | contains(run.category,'si')))];
        
    end
   
    responseSubj(p,1) = {mean(subjectAv_lowLoad)};
    responseSubj(p,2) = {mean(subjectAv_highLoad)};
    responseSubj(p,3) = {mean(subjectAv_lowLoad_face)};
    responseSubj(p,4) = {mean(subjectAv_lowLoad_scene)};
    responseSubj(p,5) = {mean(subjectAv_highLoad_face)};
    responseSubj(p,6) = {mean(subjectAv_highLoad_scene)};

    
    csvFiles_motor = dir(fullfile('..','data',participants{p},'beh','*motor*.csv'));
    
    subjectAv_response = [];
    subjectAv_abstain = [];
    subjectAv_response_face = [];
    subjectAv_response_scene = [];
    subjectAv_abstain_face = [];
    subjectAv_abstain_scene = [];

 
    for r = 1:2
        
        run = readtable(fullfile(csvFiles_motor(r).folder,csvFiles_motor(r).name));
        
        subjectAv_response = [subjectAv_response; run.keyResp_corr(contains(run.arrowDir,'?') & ~contains(run.keyResp_keys,'None'))];
        subjectAv_abstain = [subjectAv_abstain;run.keyResp_corr(contains(run.arrowDir,'x'))];
    
        subjectAv_response_face = [subjectAv_response_face;run.keyResp_corr(contains(run.arrowDir,'?') & (contains(run.category,'ff') | contains(run.category,'fm')))];
        subjectAv_response_scene = [subjectAv_response_scene;run.keyResp_corr(contains(run.arrowDir,'?') & (contains(run.category,'so') | contains(run.category,'si')))];

        subjectAv_abstain_face = [subjectAv_abstain_face;run.keyResp_corr(contains(run.arrowDir,'x') & (contains(run.category,'ff') | contains(run.category,'fm')))];
        subjectAv_abstain_scene = [subjectAv_abstain_scene;run.keyResp_corr(contains(run.arrowDir,'x') & (contains(run.category,'so') | contains(run.category,'si')))];    
    end     
    
    responseSubj(p,7) = {length(subjectAv_response)/16};
    responseSubj(p,8) = {mean(subjectAv_abstain)};
    responseSubj(p,9) = {mean(subjectAv_response_face)};
    responseSubj(p,10) = {mean(subjectAv_response_scene)};
    responseSubj(p,11) = {mean(subjectAv_abstain_face)};
    responseSubj(p,12) = {mean(subjectAv_abstain_scene)};
    
end


responseSubj = cell2table(responseSubj);
responseSubj.Properties.VariableNames = {'LowLoad','HighLoad','LowLoadFace','LowLoadScene','HighLoadFace','HighLoadScene','Response','Abstain','ResponseFace','ResponseScene','AbstainFace','AbstainScene'};

responseSubj_mean  = varfun(@mean, responseSubj, 'InputVariables', @isnumeric);
responseSubj_std  = varfun(@std, responseSubj, 'InputVariables', @isnumeric);

[~,load_p,load_ci,load_t] = ttest(responseSubj.LowLoad,responseSubj.HighLoad);
[~,motor_p,motor_ci,motor_t] = ttest(responseSubj.Response,responseSubj.Abstain);

effect_load = computeCohen_d(responseSubj.LowLoad,responseSubj.HighLoad,'paired');
effect_motor = computeCohen_d(responseSubj.Response,responseSubj.Abstain,'paired');

fig1=figure(1)
colors = cbrewer('div', 'PuOr', 11);
colors = [colors(1,:);colors(3,:)];
colors_2 = cbrewer('div', 'PRGn', 11);
colors_2 = [colors_2(1,:);colors_2(3,:)];

colors = [colors;colors_2];

hold on;

subplot(1,2,1)

violinplot([responseSubj.HighLoad, responseSubj.LowLoad], [],'ViolinColor',  [colors(1,:);colors(2,:)],'Width',0.4)
for p=1:size(responseSubj,1)
    jitter = (rand(1)-0.5)/20;
    plot([1.25, 1.75],[responseSubj.HighLoad(p)+jitter,responseSubj.LowLoad(p)+jitter],'k',...
        'LineWidth',0.5);
    hold on
end

set(gca, 'xtick', [1 2], 'xticklabel', {'High load', 'Low load'}, ...
    'ylim', [0.5 1.3],'xlim',[0 3]);
xlabel('Trial type');
ylabel('Proportion correct')
yticks([0.5, 0.75, 1])

mysigstar(gca, [1 2], 1.2, load_p);
box off

subplot(1,2,2)

violinplot([responseSubj.Response, responseSubj.Abstain], [],'ViolinColor',  [colors(3,:);colors(4,:)],'Width',0.4)
hold on 
for p=1:size(responseSubj,1)
    jitter = (rand(1)-0.5)/20;
    plot([1.25, 1.75],[responseSubj.Response(p)+jitter,responseSubj.Abstain(p)+jitter],'k',...
        'LineWidth',0.5);
    hold on
end


set(gca, 'xtick', [1 2], 'xticklabel', {'Response', 'Abstain'}, ...
    'ylim', [0.5 1.3],'xlim',[0 3]);
xlabel('Trial type');
ylabel('Proportion correct')
yticks([0.5, 0.75, 1])

mysigstar(gca, [1 2], 1.2, motor_p);
box off

mkdir("../results/beh")
saveas(fig1,['../results/beh/FigBeh.svg'])
save(['../results/beh/StatsBeh.mat'],...
    'load_p','load_ci','load_t',...
    'motor_p','motor_ci','motor_t',...
    'effect_motor','effect_load','responseSubj');

