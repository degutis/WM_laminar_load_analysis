function cohen_d_clusters = computeCohen_d_clusterMean(x1,x2,clusters)

cohen_d_clusters = cell(length(clusters),1);
for c = 1:length(clusters)
    if sum(abs(x2)) == 0
        cohen_d_clusters{c} = computeCohen_d(mean(x1(clusters{c},:),1),x2,'paired');
    else
        cohen_d_clusters{c} = computeCohen_d(mean(x1(clusters{c},:),1),mean(x2(clusters{c},:),1),'paired');
    end
end

end