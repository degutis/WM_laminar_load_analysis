dirLoad = dir('../results/decoding/Load_dlPFC.mat');

loadDecoding = load(fullfile(dirLoad.folder,dirLoad.name));

dynamicCoding=1;
subs=9;
highEnd = 10;
lowEnd = -5;

superficialTemp = mean(loadDecoding.averageAccuracy_gen_sup(3:16,3:16,:),3); 
deepTemp = mean(loadDecoding.averageAccuracy_gen_deep(3:16,3:16,:),3); 

superficialTemp = superficialTemp-50;
deepTemp = deepTemp-50;

superficialTemp_all = loadDecoding.averageAccuracy_gen_sup(3:16,3:16,:)-50;
deepTemp_all = loadDecoding.averageAccuracy_gen_deep(3:16,3:16,:)-50;

superficialTemp_allShuffle = zeros(size(superficialTemp_all,1),size(superficialTemp_all,2),1000);
selectionSup = superficialTemp_all(:);

deepTemp_allShuffle = zeros(size(superficialTemp_all,1),size(superficialTemp_all,2),1000);
selectionDeep = deepTemp_all(:);

[cluster_above_chance_sup, pvals_sup, clusters_sup] = permutationTest_cluster_psvr(superficialTemp_all);
[cluster_above_chance_deep, pvals_deep, clusters_deep] = permutationTest_cluster_psvr(deepTemp_all);

effect_clusters_sup = computeCohen_d_clusterMean_crossTemporal(superficialTemp_all,zeros(1,subs),clusters_sup);
effect_clusters_deep = computeCohen_d_clusterMean_crossTemporal(deepTemp_all,zeros(1,subs),clusters_deep);
    

if dynamicCoding==1
    dynamicSup = dynamicCoding_signInversion(superficialTemp_all);
    dynamicDeep = dynamicCoding_signInversion(deepTemp_all); 
end

xticklabels_name = {'6','10','14','18','22','26','30'};
xticks_num = [2,4,6,8,10,12,14];

fig = figure(1)
subplot(4,4,[1 2 5 6]); 
imagesc(superficialTemp');
 
set(gca, 'ydir', 'normal');
axis square;

runBoundary(cluster_above_chance_sup)
runBoundary(dynamicSup,'r')

xticks(xticks_num)
yticks(xticks_num)
xticklabels(xticklabels_name)
yticklabels(xticklabels_name)
 
handles = colorbar;
caxis([lowEnd,highEnd])
handles.TickDirection = 'out';
handles.Box = 'off';
handles.Label.String = '% Decoding accuracy';
drawnow;
 
axpos = get(gca, 'Position');
cpos = handles.Position;
cpos(3) = 0.5*cpos(3);
handles.Position = cpos;
drawnow;
 
set(gca, 'position', axpos);
drawnow;


subplot(4,4,[9 10 13 14])

imagesc(deepTemp');
 
set(gca, 'ydir', 'normal');
axis square;

runBoundary(cluster_above_chance_deep)
runBoundary(dynamicDeep,'r')


xticks(xticks_num)
yticks(xticks_num)
xticklabels(xticklabels_name)
yticklabels(xticklabels_name)

handles = colorbar;
caxis([lowEnd,highEnd])
handles.TickDirection = 'out';
handles.Box = 'off';
handles.Label.String = '% Decoding accuracy';
drawnow;
 
axpos = get(gca, 'Position');
cpos = handles.Position;
cpos(3) = 0.5*cpos(3);
handles.Position = cpos;
drawnow;
 
set(gca, 'position', axpos);
drawnow;
 
[ax1, h1]=suplabel('Training time point (s)','x')
set(h1,'FontSize',10)
[ax2, h2]=suplabel('Testing time point (s)','y')
set(h2,'FontSize',10)

subplot(4,4,4)

time = 1:size(deepTemp,1);
colors = cbrewer('div', 'PuOr', 11);
colors = [colors(1,:);colors(3,:)];

hold on;
bl = boundedline(time, mean(squeeze((superficialTemp_all(4,:,:))),2)', std(squeeze((superficialTemp_all(4,:,:))),[],2)/sqrt(9)', ...
    time, mean(squeeze((deepTemp_all(4,:,:))),2)', std(squeeze((deepTemp_all(4,:,:))),[],2)/sqrt(9)', ...
    'cmap', colors, ... 
    'alpha');

xlim([1 max(time)]); ylim([-10 15])
yline(0,'LineStyle','--')
xticks(xticks_num)
xticklabels(xticklabels_name)
title('Trained on 10s')

subplot(4,4,8)

colors = cbrewer('div', 'PuOr', 11);
colors = [colors(1,:);colors(3,:)];

hold on;
bl = boundedline(time, mean(squeeze((superficialTemp_all(7,:,:))),2)', std(squeeze((superficialTemp_all(7,:,:))),[],2)/sqrt(9)', ...
    time, mean(squeeze((deepTemp_all(7,:,:))),2)', std(squeeze((deepTemp_all(7,:,:))),[],2)/sqrt(9)', ...
    'cmap', colors, ... 
    'alpha');

xlim([1 max(time)]); ylim([-10 15])
yline(0,'LineStyle','--')
xticks(xticks_num)
xticklabels(xticklabels_name)
title('Trained on 16s')

subplot(4,4,12)

colors = cbrewer('div', 'PuOr', 11);
colors = [colors(1,:);colors(3,:)];

hold on;
bl = boundedline(time, mean(squeeze((superficialTemp_all(11,:,:))),2)', std(squeeze((superficialTemp_all(11,:,:))),[],2)/sqrt(9)', ...
    time, mean(squeeze((deepTemp_all(11,:,:))),2)', std(squeeze((deepTemp_all(11,:,:))),[],2)/sqrt(9)', ...
    'cmap', colors, ... 
    'alpha');

xlim([1 max(time)]); ylim([-10 15])
yline(0,'LineStyle','--')
xticks(xticks_num)
xticklabels(xticklabels_name)
title('Trained on 24s')

saveas(fig,['../results/decoding/CrossTemporal_Load_dlPFC_left.svg']);
save(['../results/decoding/Stats_CrossTemporal_Load_dlPFC_left.mat'],'cluster_above_chance_sup', 'pvals_sup', 'clusters_sup');

