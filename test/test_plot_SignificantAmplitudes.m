function test_plot_SignificantAmplitudes


    load('~/Downloads/rcResultStruct_cnd_123_HIGH.mat');
    load('~/Downloads/rcResultStruct_cnd_123_LOW.mat');

    % results stored in 
    % rcResultStruct_cnd_123_HIGH
    % rcResultStruct_cnd_123_LOW

%     also need axis labels(!)

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
    % transpose data
    rcResultStruct_cnd_123_HIGH.projectedData = rcResultStruct_cnd_123_HIGH.projectedData';
    rcResultStruct_cnd_123_LOW.projectedData = rcResultStruct_cnd_123_LOW.projectedData';
    
    cnd123_high = rcaExtra_computeAverages(rcResultStruct_cnd_123_HIGH);
    cnd123_low = rcaExtra_computeAverages(rcResultStruct_cnd_123_LOW);
    
    plotContainerStruct_HIGH = rcaExtra_addPlotOptionsToData(cnd123_high.projAvg);
    plotContainerStruct_LOW = rcaExtra_addPlotOptionsToData(cnd123_low.projAvg);

    % add stats
    plotContainerStruct_HIGH.statData = rcaExtra_runStatsAnalysis(cnd123_high, []);
    plotContainerStruct_LOW.statData = rcaExtra_runStatsAnalysis(cnd123_low, []);

    freqIdx = cellfun(@(x) str2double(x(1)), cnd123_high.rcaSettings.useFrequencies, 'uni', true);
    freqVals = cnd123_high.rcaSettings.useFrequenciesHz*freqIdx;
    xLabel = arrayfun( @(x) strcat(num2str(x), 'Hz'), freqVals, 'uni', false);
    yLabel = 'Amplitude, \muV';
    % specify plotting styles data for each container
    
    plotContainerStruct_HIGH.xDataLabel = xLabel;
    plotContainerStruct_HIGH.yDataLabel = yLabel;
    
    rcsToPlot = [1 2 3];
    cndsToPlot = [1 2];
    
    % specify plotting styles data for each container    
    plotContainerStruct_HIGH.rcsToPlot = rcsToPlot;
    plotContainerStruct_HIGH.cndsToPlot = cndsToPlot;    
    plotContainerStruct_HIGH.conditionLabels = {'Faces', 'Not Faces'};
    plotContainerStruct_HIGH.dataLabel = {'High Readers'};
    plotContainerStruct_HIGH.conditionColors = [0.65, 0.65, 0.65; 0.15, 0.15, 0.15];
    plotContainerStruct_HIGH.conditionMarkers = {'v', 'd'};
    plotContainerStruct_HIGH.markerStyles = {'filled', 'filled'};
    plotContainerStruct_HIGH.markerSize = 12;
    plotContainerStruct_HIGH.lineStytles = {'-', '-'};
    plotContainerStruct_HIGH.LineWidths = 2;
    plotContainerStruct_HIGH.significanceSaturation = 0.15;
    plotContainerStruct_HIGH.patchSaturation = 0.15;
    
    % 'MarkerFaceColor' for filled
    plotContainerStruct_LOW.xDataLabel = xLabel;
    plotContainerStruct_LOW.yDataLabel = yLabel;

    plotContainerStruct_LOW.rcsToPlot = rcsToPlot;
    plotContainerStruct_LOW.cndsToPlot = cndsToPlot;    
    plotContainerStruct_LOW.conditionLabels = {'Faces', 'Not Faces'};
    plotContainerStruct_LOW.dataLabel = {'Low Readers'};
    plotContainerStruct_LOW.conditionColors = [0.65, 0.5, 0.15; 0.35, 0.45, 0.45];
    plotContainerStruct_LOW.conditionMarkers = {'v', 'd'};
    plotContainerStruct_LOW.markerStyles = {'open', 'open'};
    plotContainerStruct_LOW.markerSize = 12;
    plotContainerStruct_LOW.lineStytles = {'-', '-'};
    plotContainerStruct_LOW.LineWidths = 2;
    plotContainerStruct_LOW.significanceSaturation = 0.15;
    plotContainerStruct_LOW.patchSaturation = 0.15;
    
    % plot individual (conditions together)
    
    out = rcaExtra_plotSignificantAmplitudes(plotContainerStruct_LOW, plotContainerStruct_HIGH);    
    statsBetween = rcaExtra_runStatsAnalysis(cnd123_high, cnd123_low);
    % add between-stats
    
    
    for nc = 1:numel(cndsToPlot)
        nc0 = cndsToPlot(nc);
        for rc = 1:numel(rcsToPlot)
            rc0 = rcsToPlot(rc);
            figHandle = out{rc, nc};
            currAxisHandle = get(figHandle, 'CurrentAxes');
            plot_addStatsBar_freq(currAxisHandle, statsBetween.pValues(:, rc0, nc0), ...
                freqVals');
        end
    end
    
    % plot Amplitude
    % plot Latency
    % plot Lolliplots
end



