function generateFigureUnivariate(rightPFC)
rng(1991013)
subs=9;
if rightPFC==1
    addText='right_';
else
    addText='';
end

if rightPFC==1
    dirPFC = dir('../results/univariate/dlPFC_right.mat/');
    dirCOP = dir('../results/univariate/COP_right.mat/');
else
    dirPFC = dir('../results/univariate/dlPFC.mat/');
    dirCOP = dir('../results/univariate/COP.mat/');
end    

PFC = load(fullfile(dirPFC.folder,dirPFC.name));
COP = load(fullfile(dirCOP.folder,dirCOP.name));

delayPeriod = [6:8];
responsePeriod = [11:13];

roi_1 = struct();
roi_2 = struct();

roi_1.superficialLoadHigh = squeeze(PFC.results_full(1,:,:));
roi_1.superficialLoadLow = squeeze(PFC.results_full(3,:,:));
roi_1.deepLoadHigh = squeeze(PFC.results_full(2,:,:));
roi_1.deepLoadLow = squeeze(PFC.results_full(4,:,:));

roi_1.superficialMotorPress = squeeze(PFC.results_full(5,:,:));
roi_1.superficialMotorAbstain = squeeze(PFC.results_full(7,:,:));
roi_1.deepMotorPress = squeeze(PFC.results_full(6,:,:));
roi_1.deepMotorAbstain = squeeze(PFC.results_full(8,:,:));

roi_1.superficialLoadEffect_delay = mean(roi_1.superficialLoadHigh(delayPeriod,:)-roi_1.superficialLoadLow(delayPeriod,:));
roi_1.deepLoadEffect_delay = mean(roi_1.deepLoadHigh(delayPeriod,:)-roi_1.deepLoadLow(delayPeriod,:));
roi_1.superficialLoadEffect_probe = mean(roi_1.superficialLoadHigh(responsePeriod,:)-roi_1.superficialLoadLow(responsePeriod,:));
roi_1.deepLoadEffect_probe = mean(roi_1.deepLoadHigh(responsePeriod,:)-roi_1.deepLoadLow(responsePeriod,:));

roi_1.superficialMotorEffect_delay = mean(roi_1.superficialMotorPress(delayPeriod,:)-roi_1.superficialMotorAbstain(delayPeriod,:));
roi_1.deepMotorEffect_delay = mean(roi_1.deepMotorPress(delayPeriod,:)-roi_1.deepMotorAbstain(delayPeriod,:));
roi_1.superficialMotorEffect_probe = mean(roi_1.superficialMotorPress(responsePeriod,:)-roi_1.superficialMotorAbstain(responsePeriod,:));
roi_1.deepMotorEffect_probe = mean(roi_1.deepMotorPress(responsePeriod,:)-roi_1.deepMotorAbstain(responsePeriod,:));


roi_2.superficialLoadHigh = squeeze(COP.results_full(1,:,:));
roi_2.superficialLoadLow = squeeze(COP.results_full(3,:,:));
roi_2.deepLoadHigh = squeeze(COP.results_full(2,:,:));
roi_2.deepLoadLow = squeeze(COP.results_full(4,:,:));

roi_2.superficialMotorPress = squeeze(COP.results_full(5,:,:));
roi_2.superficialMotorAbstain = squeeze(COP.results_full(7,:,:));
roi_2.deepMotorPress = squeeze(COP.results_full(6,:,:));
roi_2.deepMotorAbstain = squeeze(COP.results_full(8,:,:));

roi_2.superficialLoadEffect_delay = mean(roi_2.superficialLoadHigh(delayPeriod,:)-roi_2.superficialLoadLow(delayPeriod,:));
roi_2.deepLoadEffect_delay = mean(roi_2.deepLoadHigh(delayPeriod,:)-roi_2.deepLoadLow(delayPeriod,:));
roi_2.superficialLoadEffect_probe = mean(roi_2.superficialLoadHigh(responsePeriod,:)-roi_2.superficialLoadLow(responsePeriod,:));
roi_2.deepLoadEffect_probe = mean(roi_2.deepLoadHigh(responsePeriod,:)-roi_2.deepLoadLow(responsePeriod,:));

roi_2.superficialMotorEffect_delay = mean(roi_2.superficialMotorPress(delayPeriod,:)-roi_2.superficialMotorAbstain(delayPeriod,:));
roi_2.deepMotorEffect_delay = mean(roi_2.deepMotorPress(delayPeriod,:)-roi_2.deepMotorAbstain(delayPeriod,:));
roi_2.superficialMotorEffect_probe = mean(roi_2.superficialMotorPress(responsePeriod,:)-roi_2.superficialMotorAbstain(responsePeriod,:));
roi_2.deepMotorEffect_probe = mean(roi_2.deepMotorPress(responsePeriod,:)-roi_2.deepMotorAbstain(responsePeriod,:));

%% Plot figure

time = 1:17;

fig1 = figure(1)

set(fig1, 'PaperUnits', 'inches');
x_width=8 ;y_width=6;
set(fig1, 'PaperPosition', [0 0 x_width y_width]); %

%% dlPFC Load
colors = cbrewer('div', 'PuOr', 11);
colors = [colors(1,:);colors(3,:)];
subplot(4,3,1)
hold on;
bl = boundedline(time, double(mean(roi_1.superficialLoadHigh,2)'), double(std(roi_1.superficialLoadHigh,[],2)/sqrt(subs)), ...
    time, double(mean(roi_1.superficialLoadLow,2)'), double(std(roi_1.superficialLoadLow,[],2)/sqrt(subs)), ...
    'cmap', colors, ... 
    'alpha');

xlim([1 max(time)]); ylim([-0.3 2])
yline(0,'LineStyle','--')
xticks([5,10,15]); xticklabels({'9.4','18.8','28.2'})
ylabel('Superficial layer BOLD (% change)','FontSize',7)

hold off;
title('DLPFC load trials','FontSize',10,'FontWeight','Normal')

% Deep layer

subplot(4,3,2)
hold on;
bl = boundedline(time, double(mean(roi_1.deepLoadHigh,2)'), double(std(roi_1.deepLoadHigh,[],2)/sqrt(subs)), ...
    time, double(mean(roi_1.deepLoadLow,2)'), double(std(roi_1.deepLoadLow,[],2)/sqrt(subs)), ...
    'cmap', colors, ... 
    'alpha');

xlim([1 max(time)]); ylim([-0.3 2])
yline(0,'LineStyle','--')
xticks([5,10,15]); xticklabels({'9.4','18.8','28.2'})
ylabel('Deep layer BOLD (% change)','FontSize',7)

hold off;

%% COP Load 

subplot(4,3,7)
hold on;
bl = boundedline(time, double(mean(roi_2.superficialLoadHigh,2)'), double(std(roi_2.superficialLoadHigh,[],2)/sqrt(subs)), ...
    time, double(mean(roi_2.superficialLoadLow,2)'), double(std(roi_2.superficialLoadLow,[],2)/sqrt(subs)), ...
    'cmap', colors, ... 
    'alpha');

xlim([1 max(time)]); ylim([-0.3 2])
yline(0,'LineStyle','--')
xticks([5,10,15]); xticklabels({'9.4','18.8','28.2'})

title('COP Load trials','FontSize',10,'FontWeight','Normal')

% Deep layer

subplot(4,3,8)
hold on;
bl = boundedline(time, double(mean(roi_2.deepLoadHigh,2)'), double(std(roi_2.deepLoadHigh,[],2)/sqrt(subs)), ...
    time, double(mean(roi_2.deepLoadLow,2)'), double(std(roi_2.deepLoadLow,[],2)/sqrt(subs)), ...
    'cmap', colors, ... 
    'alpha');

xlim([1 max(time)]); ylim([-0.3 2])
yline(0,'LineStyle','--')
xticks([5,10,15]); xticklabels({'9.4','18.8','28.2'})

lh = legend(bl);
legnames = {'Load high', 'Load low'};
for i = 1:length(legnames)
    str{i} = ['\' sprintf('color[rgb]{%f,%f,%f} %s', colors(i, 1), colors(i, 2), colors(i, 3), legnames{i})];
end
lh.String = str;
lh.Box = 'off';

%move a bit closer
lpos = lh.Position;
lpos(1) = lpos(1);
lh.Position = lpos;
hold off;

%% dlPFC Motor
colors = cbrewer('div', 'PRGn', 11);
colors = [colors(1,:);colors(3,:)];
subplot(4,3,4)
hold on;
bl = boundedline(time, double(mean(roi_1.superficialMotorPress,2)'), double(std(roi_1.superficialMotorPress,[],2)/sqrt(subs)), ...
    time, double(mean(roi_1.superficialMotorAbstain,2)'), double(std(roi_1.superficialMotorAbstain,[],2)/sqrt(subs)), ...
    'cmap', colors, ... 
    'alpha');

xlim([1 max(time)]); ylim([-0.3 2])
yline(0,'LineStyle','--')
xticks([5,10,15]); xticklabels({'9.4','18.8','28.2'})

hold off;
title('DLPFC motor trials','FontSize',10,'FontWeight','Normal')

% Deep layer

subplot(4,3,5)
hold on;
bl = boundedline(time, double(mean(roi_1.deepMotorPress,2)'), double(std(roi_1.deepMotorPress,[],2)/sqrt(subs)), ...
    time, double(mean(roi_1.deepMotorAbstain,2)'), double(std(roi_1.deepMotorAbstain,[],2)/sqrt(subs)), ...
    'cmap', colors, ... 
    'alpha');

xlim([1 max(time)]); ylim([-0.3 2])
yline(0,'LineStyle','--')
xticks([5,10,15]); xticklabels({'9.4','18.8','28.2'})

hold off;

%% COP Motor 

subplot(4,3,10)
hold on;
bl = boundedline(time, double(mean(roi_2.superficialMotorPress,2)'), double(std(roi_2.superficialMotorPress,[],2)/sqrt(subs)), ...
    time, double(mean(roi_2.superficialMotorAbstain,2)'), double(std(roi_2.superficialMotorAbstain,[],2)/sqrt(subs)), ...
    'cmap', colors, ... 
    'alpha');

xlim([1 max(time)]); ylim([-0.3 2])
yline(0,'LineStyle','--')
xticks([5,10,15]); xticklabels({'9.4','18.8','28.2'})

hold off;
title('COP motor trials','FontSize',10,'FontWeight','Normal')

% Deep layer

subplot(4,3,11)
hold on;
bl = boundedline(time, double(mean(roi_2.deepMotorPress,2)'), double(std(roi_2.deepMotorPress,[],2)/sqrt(subs)), ...
    time, double(mean(roi_2.deepMotorAbstain,2)'), double(std(roi_2.deepMotorAbstain,[],2)/sqrt(subs)), ...
    'cmap', colors, ... 
    'alpha');

xlim([1 max(time)]); ylim([-0.3 2])
yline(0,'LineStyle','--')
xticks([5,10,15]); xticklabels({'9.4','18.8','28.2'})

lh = legend(bl);
legnames = {'Motor press', 'Motor abstain'};
for i = 1:length(legnames)
    str{i} = ['\' sprintf('color[rgb]{%f,%f,%f} %s', colors(i, 1), colors(i, 2), colors(i, 3), legnames{i})];
end
lh.String = str;
lh.Box = 'off';

% move a bit closer
lpos = lh.Position;
lpos(1) = lpos(1);
lh.Position = lpos;
hold off;


%% Layer comparison
subplot(4,3,3)
colors = cbrewer('div', 'RdGy', 11);
colors = colors([2,11],:);
 
hold on;

violinplot([roi_1.superficialLoadEffect_delay; roi_1.deepLoadEffect_delay; roi_1.superficialLoadEffect_probe; roi_1.deepLoadEffect_probe]', [],'ViolinColor',  [colors(2,:);colors(1,:);colors(2,:);colors(1,:)],'Width',0.4)

hold on 
for p=1:subs
    jitter = (rand(1)-0.5)/20;
    plot([1.25, 1.75],[roi_1.superficialLoadEffect_delay(p)+jitter,roi_1.deepLoadEffect_delay(p)+jitter],...
        'k',...
        'LineWidth',0.5);
    hold on

    plot([3.25,3.75],[roi_1.superficialLoadEffect_probe(p)+jitter, roi_1.deepLoadEffect_probe(p)+jitter],...
    'k',...
    'LineWidth',0.5);
    hold on
end

set(gca, 'xtick', [1.5 3.5], 'xticklabel', {'Delay', 'Response'}, ...
    'ylim', [-0.75 1.5], ... 
    'xlim', [0 4.5]);
xlabel('Trial period');
 
[~,pvalLoadDelay_dlPFC,ciLoadDelay_dlPFC,statsLoadDelay_dlPFC] = ttest(roi_1.superficialLoadEffect_delay, roi_1.deepLoadEffect_delay);
effect_load_dlPFC_delay = computeCohen_d(roi_1.superficialLoadEffect_delay, roi_1.deepLoadEffect_delay,'paired');
mysigstar(gca, [0.6 1.2], 0.85, pvalLoadDelay_dlPFC);
text(0.6,0.95,['p=',num2str(round(pvalLoadDelay_dlPFC,4))],'FontSize',5)
[~,pvalLoadResponse_dlPFC,ciLoadResponse_dlPFC,statsLoadResponse_dlPFC] = ttest(roi_1.superficialLoadEffect_probe, roi_1.deepLoadEffect_probe);
effect_load_dlPFC_response = computeCohen_d(roi_1.superficialLoadEffect_probe, roi_1.deepLoadEffect_probe,'paired');
mysigstar(gca, [2 2.6], 0.85, pvalLoadResponse_dlPFC);
text(2,0.95,['p=',num2str(round(pvalLoadResponse_dlPFC,4))],'FontSize',5)

%Motor
subplot(4,3,6)
hold on;

violinplot([roi_1.superficialMotorEffect_probe; roi_1.deepMotorEffect_probe]', [],'ViolinColor',  [colors(2,:);colors(1,:)],'Width',0.4)

hold on 
for p=1:subs
    jitter = (rand(1)-0.5)/20;
    plot([1.25, 1.75],[roi_1.superficialMotorEffect_probe(p)+jitter,roi_1.deepMotorEffect_probe(p)+jitter],...
        'k',...
        'LineWidth',0.5);
    hold on
end



set(gca, 'xtick', [1.5], 'xticklabel', {'Retrieval'}, ...
    'ylim', [-0.75 1.5], ... 
    'xlim', [0 4.5]);
xlabel('Trial period');

[~,pvalMotorResponse_dlPFC,ciMotorResponse_dlPFC,statsMotorResponse_dlPFC] = ttest(roi_1.superficialMotorEffect_probe, roi_1.deepMotorEffect_probe);
effect_motor_dlPFC_response = computeCohen_d(roi_1.superficialMotorEffect_probe, roi_1.deepMotorEffect_probe,'paired');
mysigstar(gca, [0.6 1.2], 0.85, pvalMotorResponse_dlPFC);
text(0.6,0.95,['p=',num2str(round(pvalMotorResponse_dlPFC,4))],'FontSize',5)


%% COP Layer comparison
subplot(4,3,9)
colors = cbrewer('div', 'RdGy', 11);
colors = colors([2,11],:);
  
violinplot([roi_2.superficialLoadEffect_delay; roi_2.deepLoadEffect_delay; roi_2.superficialLoadEffect_probe; roi_2.deepLoadEffect_probe]', [],'ViolinColor',  [colors(2,:);colors(1,:);colors(2,:);colors(1,:)],'Width',0.4)

hold on 
for p=1:subs
    jitter = (rand(1)-0.5)/20;
    plot([1.25, 1.75],[roi_2.superficialLoadEffect_delay(p)+jitter,roi_2.deepLoadEffect_delay(p)+jitter],...
        'k',...
        'LineWidth',0.5);
    hold on

    plot([3.25,3.75],[roi_2.superficialLoadEffect_probe(p)+jitter, roi_2.deepLoadEffect_probe(p)+jitter],...
    'k',...
    'LineWidth',0.5);
    hold on
end


set(gca, 'xtick', [1.5 3.5], 'xticklabel', {'Delay', 'Response'}, ...
    'ylim', [-0.75 1.5], ... 
    'xlim', [0 4.5]);
xlabel('Trial period');
 
[~,pvalLoadDelay_COP,ciLoadDelay_COP,statsLoadDelay_COP] = ttest(roi_2.superficialLoadEffect_delay, roi_2.deepLoadEffect_delay);
effect_load_COP_delay = computeCohen_d(roi_2.superficialLoadEffect_delay, roi_2.deepLoadEffect_delay,'paired');
mysigstar(gca, [0.6 1.2], 0.85, pvalLoadDelay_COP);
text(0.6,0.95,['p=',num2str(round(pvalLoadDelay_COP,4))],'FontSize',5)
[~,pvalLoadResponse_COP,ciLoadResponse_COP,statsLoadResponse_COP] = ttest(roi_2.superficialLoadEffect_probe, roi_2.deepLoadEffect_probe);
effect_load_COP_response = computeCohen_d(roi_2.superficialLoadEffect_probe, roi_2.deepLoadEffect_probe,'paired');
mysigstar(gca, [2 2.6], 0.85, pvalLoadResponse_COP);
text(2,0.95,['p=',num2str(round(pvalLoadResponse_COP,4))],'FontSize',5)

hold off;

%Motor
subplot(4,3,12)
hold on;

violinplot([roi_2.superficialMotorEffect_probe; roi_2.deepMotorEffect_probe]', [],'ViolinColor',  [colors(2,:);colors(1,:)],'Width',0.4)

hold on 
for p=1:subs
    jitter = (rand(1)-0.5)/20;
    plot([1.25, 1.75],[roi_2.superficialMotorEffect_probe(p)+jitter,roi_2.deepMotorEffect_probe(p)+jitter],...
        'k',...
        'LineWidth',0.5);
    hold on
end


set(gca, 'xtick', [1.5], 'xticklabel', {'Retrieval'}, ...
    'ylim', [-0.75 1.5], ... 
    'xlim', [0 4.5]);
xlabel('Trial period');
  
[~,pvalMotorResponse_COP,ciMotorResponse_COP,statsMotorResponse_COP] = ttest(roi_2.superficialMotorEffect_probe, roi_2.deepMotorEffect_probe);
effect_motor_COP_response = computeCohen_d(roi_2.superficialMotorEffect_probe, roi_2.deepMotorEffect_probe,'paired');
mysigstar(gca, [0.6 1.2], 0.85, pvalMotorResponse_COP);
text(0.6,0.95,['p=',num2str(round(pvalMotorResponse_COP,4))],'FontSize',5)

hold off;

if rightPFC==1
    addText = 'RightPFC';
elseif rightPFC==0
    addText = 'LeftPFC';
end

saveas(fig1,['../results/univariate/Univariate_',addText,'_violinPlot.svg'])   
save(['../results/univariate/Univar_stats',addText,'.mat'],...
    'pvalMotorResponse_COP','ciMotorResponse_COP','statsMotorResponse_COP',...
    'pvalLoadResponse_COP','ciLoadResponse_COP','statsLoadResponse_COP',...
    'pvalLoadDelay_COP','ciLoadDelay_COP','statsLoadDelay_COP',...
    'pvalMotorResponse_dlPFC','ciMotorResponse_dlPFC','statsMotorResponse_dlPFC',...
    'pvalLoadResponse_dlPFC','ciLoadResponse_dlPFC','statsLoadResponse_dlPFC',...
    'pvalLoadDelay_dlPFC','ciLoadDelay_dlPFC','statsLoadDelay_dlPFC',...
    'effect_load_dlPFC_delay','effect_load_dlPFC_response',...
    'effect_load_COP_delay','effect_load_COP_response',...
    'effect_motor_COP_response','effect_motor_dlPFC_response')
end




