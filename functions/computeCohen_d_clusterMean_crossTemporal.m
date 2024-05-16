function cohen_d_clusters = computeCohen_d_clusterMean_crossTemporal(x1,x2,clusters)

cohen_d_clusters = cell(length(clusters),1);
for c = 1:length(clusters)
    x1_transformed = zeros(length(clusters{c}),9);
    for s = 1:9
        x1_current = x1(:,:,s);
        x1_transformed(:,s) = x1_current(clusters{c});
    end
    cohen_d_clusters{c} = computeCohen_d(mean(x1_transformed,1),x2,'paired');
end

end