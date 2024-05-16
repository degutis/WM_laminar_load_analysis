function [cluster_above_chance, cluster_below_chance, clusters, p_values_clusters] = permutationTest_timecourse(M,M_shuffle,twoway)

    rng(round(M(1,1)*M(1,1)))

    timeDim = size(M,2);

    M_s  = reshape(M_shuffle,[size(M_shuffle,1),size(M_shuffle,2)*size(M_shuffle,3)]);
    
    M = M';
    
    [clusters, p_values_clusters, ~, ~] = permutest(M, M_s, 0, 0.05, 10000, twoway);

    cluster_above_chance = zeros(timeDim,1);
    for c=1:length(clusters)
        if p_values_clusters(c)<0.05
            cluster_above_chance(clusters{c})=1;
        end
    end
    
    cluster_below_chance = zeros(timeDim,1);
    for c=1:length(clusters)
        if p_values_clusters(c)<0.20 && p_values_clusters(c)>=0.05
            cluster_below_chance(clusters{c})=1;
        end
    end

    cluster_above_chance(cluster_above_chance==0) = NaN;
    cluster_below_chance(cluster_below_chance==0) = NaN;

end