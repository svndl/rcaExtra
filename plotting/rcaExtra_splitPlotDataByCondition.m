function varargout  = rcaExtra_splitPlotDataByCondition(plotContainerStruct)

    nConditions = numel(plotContainerStruct.cndsToPlot);
    outContainers = cell(nConditions, 1);
    for nc = 1:nConditions
        plotContainerStruct_cnd = plotContainerStruct;
        % add dataToPlot split
        plotContainerStruct_cnd.conditionMarkers = plotContainerStruct.conditionMarkers(nc);
        plotContainerStruct_cnd.markerStyles = plotContainerStruct.markerStyles(nc);
        plotContainerStruct_cnd.lineStytles = plotContainerStruct.lineStytles(nc);
        plotContainerStruct_cnd.conditionLabels = plotContainerStruct.conditionLabels(nc);
        plotContainerStruct_cnd.cndsToPlot = plotContainerStruct.cndsToPlot(nc);
        plotContainerStruct_cnd.conditionColors = plotContainerStruct.conditionColors(nc, :);
        
        outContainers{nc} = plotContainerStruct_cnd;
    end
    varargout = outContainers;
end