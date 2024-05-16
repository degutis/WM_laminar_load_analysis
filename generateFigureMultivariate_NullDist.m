function generateFigureMultivariate_NullDist(rightPFC)

rng(199101)

subs=9;

if rightPFC==1
    dirLoad = dir('../results/decoding/Load_dlPFC_right.mat');
    dirLoad_COP = dir('../results/decoding/Load_COP_right.mat');
    dirMotor = dir('../results/decoding/Motor_dlPFC_right.mat');
    dirMotor_COP = dir('../results/decoding/Motor_COP_right.mat');
else
    dirLoad = dir('../results/decoding/Load_dlPFC.mat');
    dirLoad_COP = dir('../results/decoding/Load_COP.mat');
    dirMotor = dir('../results/decoding/Motor_dlPFC.mat');
    dirMotor_COP = dir('../results/decoding/Motor_COP.mat');
end 

loadDecoding = load(fullfile(dirLoad.folder,dirLoad.name));
loadDecoding_COP = load(fullfile(dirLoad_COP.folder,dirLoad_COP.name));

motorDecoding = load(fullfile(dirMotor.folder,dirMotor.name));
motorDecoding_COP = load(fullfile(dirMotor_COP.folder,dirMotor_COP.name));

loadSup = [];
loadDeep = [];
loadSup_COP = [];
loadDeep_COP = [];
motorSup = [];
motorDeep = [];
motorSup_COP = [];
motorDeep_COP = [];

for s=1:subs
    loadSup(:,s) = diag(loadDecoding.averageAccuracy_gen_sup(:,:,s))-50;
    loadDeep(:,s) = diag(loadDecoding.averageAccuracy_gen_deep(:,:,s))-50;
    loadSup_COP(:,s) = diag(loadDecoding_COP.averageAccuracy_gen_sup(:,:,s))-50;
    loadDeep_COP(:,s) = diag(loadDecoding_COP.averageAccuracy_gen_deep(:,:,s))-50;
    motorSup(:,s) = diag(motorDecoding.averageAccuracy_gen_sup(:,:,s))-50;
    motorDeep(:,s) = diag(motorDecoding.averageAccuracy_gen_deep(:,:,s))-50; 
    motorSup_COP(:,s) = diag(motorDecoding_COP.averageAccuracy_gen_sup(:,:,s))-50;
    motorDeep_COP(:,s) = diag(motorDecoding_COP.averageAccuracy_gen_deep(:,:,s))-50; 
end

%% Boostrap null distribution

timecourseBaselineDir = '../results/decoding/permuted/';

if rightPFC==1
    addText = 'right_';
else
    addText='';
end

timecourseBaselineDir_current = [timecourseBaselineDir,'dlPFC_',addText,'Load'];

disp('Running load dlPFC')

[circle_pvalues_load_sup, circle_pvalues_load_sup_below, clusters_load_sup, pvalues_load_sup] = permutationTest_timecourse(loadSup',generateNullDist(16,timecourseBaselineDir_current,10000,subs,'sup',1),0);
[circle_pvalues_load_deep, circle_pvalues_load_deep_below, clusters_load_deep, pvalues_load_deep] = permutationTest_timecourse(loadDeep',generateNullDist(16,timecourseBaselineDir_current,10000,subs,'deep',2),0);
[circle_pvalues_load, circle_pvalues_load_below, clusters_load, pvalues_load] = permutationTest_timecourse(loadSup'-loadDeep',generateNullDist(16,timecourseBaselineDir_current,10000,subs,'both',3),true);

effect_clusters_load_sup = computeCohen_d_clusterMean(loadSup,zeros(1,subs),clusters_load_sup);
effect_clusters_load_deep = computeCohen_d_clusterMean(loadDeep,zeros(1,subs),clusters_load_deep);
effect_clusters_load = computeCohen_d_clusterMean(loadSup,loadDeep,clusters_load);

timecourseBaselineDir_current = [timecourseBaselineDir,'/COP_',addText,'Load'];

disp('Running load COP')

[circle_pvalues_load_sup_COP, circle_pvalues_load_sup_below_COP, clusters_load_sup_COP, pvalues_load_sup_COP] = permutationTest_timecourse(loadSup_COP',generateNullDist(16,timecourseBaselineDir_current,10000,subs,'sup',4),0);
[circle_pvalues_load_deep_COP, circle_pvalues_load_deep_below_COP, clusters_load_deep_COP, pvalues_load_deep_COP] = permutationTest_timecourse(loadDeep_COP',generateNullDist(16,timecourseBaselineDir_current,10000,subs,'deep',5),0);
[circle_pvalues_load_COP, circle_pvalues_load_below_COP, clusters_load_COP, pvalues_load_COP] = permutationTest_timecourse(loadSup_COP'-loadDeep_COP',generateNullDist(16,timecourseBaselineDir_current,10000,subs,'both',6),true);

effect_clusters_load_sup_COP = computeCohen_d_clusterMean(loadSup_COP,zeros(1,subs),clusters_load_sup_COP);
effect_clusters_load_deep_COP = computeCohen_d_clusterMean(loadDeep_COP,zeros(1,subs),clusters_load_deep_COP);
effect_clusters_load_COP = computeCohen_d_clusterMean(loadSup_COP,loadDeep_COP,clusters_load_COP);


timecourseBaselineDir_current = [timecourseBaselineDir,'/dlPFC_',addText,'Motor'];

disp('Running motor dlPFC')

[circle_pvalues_motor_sup, circle_pvalues_motor_sup_below, clusters_motor_sup, pvalues_motor_sup] = permutationTest_timecourse(motorSup',generateNullDist(16,timecourseBaselineDir_current,10000,subs,'sup',7),0);
[circle_pvalues_motor_deep, circle_pvalues_motor_deep_below, clusters_motor_deep, pvalues_motor_deep] = permutationTest_timecourse(motorDeep',generateNullDist(16,timecourseBaselineDir_current,10000,subs,'deep',8),0);
[circle_pvalues_motor, circle_pvalues_motor_below, clusters_motor, pvalues_motor] = permutationTest_timecourse(motorSup'-motorDeep',generateNullDist(16,timecourseBaselineDir_current,10000,subs,'both',9),true);

effect_clusters_motor_sup = computeCohen_d_clusterMean(motorSup,zeros(1,subs),clusters_motor_sup);
effect_clusters_motor_deep = computeCohen_d_clusterMean(motorDeep,zeros(1,subs),clusters_motor_deep);
effect_clusters_motor = computeCohen_d_clusterMean(motorSup,motorDeep,clusters_motor);

timecourseBaselineDir_current = [timecourseBaselineDir,'/COP_',addText,'Motor'];

disp('Running motor COP')

[circle_pvalues_motor_sup_COP, circle_pvalues_motor_sup_below_COP, clusters_motor_sup_COP, pvalues_motor_sup_COP] = permutationTest_timecourse(motorSup_COP',generateNullDist(16,timecourseBaselineDir_current,10000,subs,'sup',7),0);
[circle_pvalues_motor_deep_COP, circle_pvalues_motor_deep_below_COP, clusters_motor_deep_COP, pvalues_motor_deep_COP] = permutationTest_timecourse(motorDeep_COP',generateNullDist(16,timecourseBaselineDir_current,10000,subs,'deep',8),0);
[circle_pvalues_motor_COP, circle_pvalues_motor_below_COP, clusters_motor_COP, pvalues_motor_COP] = permutationTest_timecourse(motorSup_COP'-motorDeep_COP',generateNullDist(16,timecourseBaselineDir_current,10000,subs,'both',9),true);

effect_clusters_motor_sup_COP = computeCohen_d_clusterMean(motorSup_COP,zeros(1,subs),clusters_motor_sup_COP);
effect_clusters_motor_deep_COP = computeCohen_d_clusterMean(motorDeep_COP,zeros(1,subs),clusters_motor_deep_COP);
effect_clusters_motor_COP = computeCohen_d_clusterMean(motorSup_COP,motorDeep_COP,clusters_motor_COP);


%% Load

xticklabels_name = {'2','6','10','14','18','22','26','30'};

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


% COP
subplot(3,3,2)
hold on;
bl = boundedline(time, mean(loadSup_COP,2)', std(loadSup_COP,[],2)/sqrt(subs)', ...
    time, mean(loadDeep_COP,2)', std(loadDeep_COP,[],2)/sqrt(subs)', ...
    'cmap', colors, ... 
    'alpha');

xlim([1 max(time)]); ylim([-10 15])
yline(0,'LineStyle','--')
xticks([2,4,6,8,10,12,14,16])
xticklabels(xticklabels_name)

scatter(time, circle_pvalues_load_sup_COP./circle_pvalues_load_sup_COP*-4,(circle_pvalues_load_sup_COP+1).^2,colors(1,:),'filled','d')
scatter(time, circle_pvalues_load_deep_COP./circle_pvalues_load_deep_COP*-8,(circle_pvalues_load_deep_COP+1).^2,colors(2,:),'filled','d')
scatter(time, circle_pvalues_load_COP./circle_pvalues_load_COP*13,(circle_pvalues_load_COP+1).^2,[0,0,0],'filled','d')

title('Left Control Regions','FontSize',10,'FontWeight','Normal')

hold off;



%% Motor

colors = cbrewer('div', 'PRGn', 11);
colors = [colors(1,:);colors(3,:)];

subplot(3,3,4)
hold on;
bl2 = boundedline(time, mean(motorSup,2)', std(motorSup,[],2)/sqrt(subs)', ...
    time, mean(motorDeep,2)', std(motorDeep,[],2)/sqrt(subs)', ...
    'cmap', colors, ... 
    'alpha');

xlim([1 max(time)]); ylim([-10 15])
yline(0,'LineStyle','--')
xticks([2,4,6,8,10,12,14,16])
xticklabels(xticklabels_name)

scatter(time, circle_pvalues_motor_sup./circle_pvalues_motor_sup*-4,(circle_pvalues_motor_sup+1).^2,colors(1,:),'filled','d')
scatter(time, circle_pvalues_motor_deep./circle_pvalues_motor_deep*-8,(circle_pvalues_motor_deep+1).^2,colors(2,:),'filled','d')
scatter(time, circle_pvalues_motor./circle_pvalues_motor*13,(circle_pvalues_motor+1).^2,[0,0,0],'filled','d')

% instead of a legend, show colored text

lh2 = legend(bl2);
legnames2 = {'Superficial Motor', 'Deep Motor'};
for i = 1:length(legnames2)
    str2{i} = ['\' sprintf('color[rgb]{%f,%f,%f} %s', colors(i, 1), colors(i, 2), colors(i, 3), legnames2{i})];
end
lh2.String = str2;
lh2.Box = 'off';

% move a bit closer
lpos2 = lh2.Position;
lpos2(1) = lpos2(1) + 0.6;
lh2.Position = lpos2;
hold off;

% COP
subplot(3,3,5)
hold on;
bl = boundedline(time, mean(motorSup_COP,2)', std(motorSup_COP,[],2)/sqrt(subs)', ...
    time, mean(motorDeep_COP,2)', std(motorDeep_COP,[],2)/sqrt(subs)', ...
    'cmap', colors, ... 
    'alpha');

xlim([1 max(time)]); ylim([-10 15])
yline(0,'LineStyle','--')
xticks([2,4,6,8,10,12,14,16])
xticklabels(xticklabels_name)

scatter(time, circle_pvalues_motor_sup_COP./circle_pvalues_motor_sup_COP*-4,(circle_pvalues_motor_sup_COP+1).^2,colors(1,:),'filled','d')
scatter(time, circle_pvalues_motor_deep_COP./circle_pvalues_motor_deep_COP*-8,(circle_pvalues_motor_deep_COP+1).^2,colors(2,:),'filled','d')
scatter(time, circle_pvalues_motor_COP./circle_pvalues_motor_COP*13,(circle_pvalues_motor_COP+1).^2,[0,0,0],'filled','d')


hold off;

[ax1, h1]=suplabel('Decoding Accuracy (above chance)','y')
set(h1,'FontSize',10)
[ax2, h2]=suplabel('Seconds','x')
set(h2,'FontSize',10)


if rightPFC==1
    addText = 'RightPFC';
else
    addText = 'LeftPFC';
end

saveas(fig1,['../results/decoding/',addText,'.svg'])   

save(['../results/decoding/Multivar_stats_',addText,'.mat'],...
    'circle_pvalues_motor_sup', 'circle_pvalues_motor_sup_below', 'clusters_motor_sup', 'pvalues_motor_sup',...
    'circle_pvalues_motor_deep', 'circle_pvalues_motor_deep_below', 'clusters_motor_deep', 'pvalues_motor_deep',...
    'circle_pvalues_motor', 'circle_pvalues_motor_below', 'clusters_motor', 'pvalues_motor',...
    'circle_pvalues_motor_sup_COP', 'circle_pvalues_motor_sup_below_COP', 'clusters_motor_sup_COP', 'pvalues_motor_sup_COP',...
    'circle_pvalues_motor_deep_COP', 'circle_pvalues_motor_deep_below_COP', 'clusters_motor_deep_COP', 'pvalues_motor_deep_COP',...
    'circle_pvalues_motor_COP', 'circle_pvalues_motor_below_COP', 'clusters_motor_COP', 'pvalues_motor_COP',...
    'circle_pvalues_load_sup', 'circle_pvalues_load_sup_below', 'clusters_load_sup', 'pvalues_load_sup',...
    'circle_pvalues_load_deep', 'circle_pvalues_load_deep_below', 'clusters_load_deep', 'pvalues_load_deep',...
    'circle_pvalues_load', 'circle_pvalues_load_below', 'clusters_load', 'pvalues_load',...
    'circle_pvalues_load_sup_COP', 'circle_pvalues_load_sup_below_COP', 'clusters_load_sup_COP', 'pvalues_load_sup_COP',...
    'circle_pvalues_load_deep_COP', 'circle_pvalues_load_deep_below_COP', 'clusters_load_deep_COP', 'pvalues_load_deep_COP',...
    'circle_pvalues_load_COP', 'circle_pvalues_load_below_COP', 'clusters_load_COP', 'pvalues_load_COP',...
    'effect_clusters_load_sup','effect_clusters_load_deep','effect_clusters_load',...
    'effect_clusters_load_sup_COP','effect_clusters_load_deep_COP','effect_clusters_load_COP',...
    'effect_clusters_motor_sup_COP','effect_clusters_motor_deep_COP','effect_clusters_motor_COP',...
    'effect_clusters_motor_sup','effect_clusters_motor_deep','effect_clusters_motor')
end
