function plot_Example


%     plotContainerStruct.rcaData = rcaData;
%     % generate default 
%     plotContainerStruct.conditionLabels = {}; % condition labels
%     plotContainerStruct.dataLabel = {};  % group label
%     
%     plotContainerStruct.conditionColors = [];
%     plotContainerStruct.conditionMarkers = {};
%     plotContainerStruct.markerStyles = {};
%     plotContainerStruct.markerSize = 12;
%     plotContainerStruct.lineStytles = {};
%     plotContainerStruct.LineWidths = 2;
% 
    %load data
    
    plotContainerStruct_Controls = rcaExtra_addPlotOptionsToData(controls_avg);

    % add stats
    plotContainerStruct_Controls.statData_controls = rcaExtra_runStatsAnalysis(controls_avg, []);

    plotContainerStruct_Controls.rcsToPlot = [1 2 3];
    plotContainerStruct_Controls.cndsToPlot = [1 2];

    % plot individual (conditions together)

    % plot multiple (comp), if two, calc stats and plot it as well
    
    
    % plot Amplitude
    % plot Latency
    % plot Lolliplots

