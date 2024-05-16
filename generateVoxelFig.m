name_ROIs = {"Left dlPFC","Left control", "Right dlPFC", "Right control"};
load_ROIs = {"Load_dlPFC","Load_COP","Load_dlPFC_right","Load_COP_right"};

p = cell(4,1);
ci = cell(4,1);
t = cell(4,1);
effect_size = cell(4,1);
for r = 1:length(load_ROIs)
    load(strcat("../results/decoding/",load_ROIs{r},".mat"))

    superficial_layer = squeeze(results_full_size(1,:,:));
    deep_layer = squeeze(results_full_size(2,:,:));
    
    [~,p_now,ci_now,t_now] = ttest(superficial_layer,deep_layer);
    
    effect_size(r) = {computeCohen_d(superficial_layer, deep_layer, "paired")};


    p(r) = {p_now};
    ci(r) = {ci_now};
    t(r) = {t_now};

    fig1=figure(1)
    colors = cbrewer('div', 'RdGy', 11);
    colors = colors([2,11],:);
    
    subplot(2,2,r)

    violinplot([superficial_layer, deep_layer], [],'ViolinColor',  [colors(2,:);colors(1,:)],'Width',0.4)
    for part=1:9
        jitter = (rand(1)-0.5)/20;
        plot([1.25, 1.75],[superficial_layer(part)+jitter,deep_layer(part)+jitter],'k',...
            'LineWidth',0.5);
        hold on
    end
    
    set(gca, 'xtick', [1 2], 'xticklabel', {'Superficial', 'Deep'}, ...
        'ylim', [1000 5000],'xlim',[0 3]);
    xlabel('Layers');
    ylabel('Number of voxels')
    yticks([1000 2000 3000 4000 5000])
    title(name_ROIs{r})
    
    mysigstar(gca, [1 2], 5000, p{r});
end

saveas(fig1,['../results/response_to_reviewers/voxels/NumVox.svg'])   

save(['../results/response_to_reviewers/voxels/NumVox_stats.mat'],...
    "p","t","ci","effect_size");

