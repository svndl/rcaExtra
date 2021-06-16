function plotContainerStruct = rcaExtra_addPlotOptionsToData(dataArray)
% function will add several plotting-related fields
% to a given dataArray

    % data dims: nF x nRC x nC x nS (optional number of subjects)
    plotContainerStruct.dataToPlot = dataArray;
    % generate default 
    plotContainerStruct.conditionLabels = {}; % condition labels
    plotContainerStruct.dataLabel = {};  % group label
    
    plotContainerStruct.conditionColors = [];
    plotContainerStruct.conditionMarkers = {};
    plotContainerStruct.markerStyles = {};
    plotContainerStruct.markerSize = 12;
    plotContainerStruct.lineStytles = {};
    plotContainerStruct.LineWidths = 2;
end