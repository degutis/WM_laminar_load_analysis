function runBoundary(cluster_above_chance,colorPlot)

    if nargin==2
        colorPlotVal = colorPlot;
    else
        colorPlotVal='k';
    end
    
    boundaries = bwboundaries(imresize(logical(cluster_above_chance'),32));
    numBound = size(boundaries,1);
    for k=1:numBound
        curBound = boundaries{k};
        curBound = round(curBound/32);
        curBound(:,1) = curBound(:,1)+0.5;
        curBound(:,2) = curBound(:,2)+0.5;
        hold on;
        p=plot(curBound(:,2), curBound(:,1),colorPlotVal,'LineWidth',1.5);
        p.LineStyle = '-.';
    end

end