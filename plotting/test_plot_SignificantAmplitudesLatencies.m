function test_plot_SignificantAmplitudesLatencies


    load('~/Downloads/rcResultStruct_cnd_123_HIGH.mat');
    load('~/Downloads/rcResultStruct_cnd_123_LOW.mat');

    % transpose data if needed so it would be Subjects x Conditions 
%     rcResultStruct_cnd_123_HIGH.projectedData = rcResultStruct_cnd_123_HIGH.projectedData';
%     rcResultStruct_cnd_123_LOW.projectedData = rcResultStruct_cnd_123_LOW.projectedData';
    
    % compute averages
    cnd123_high = rcaExtra_computeAverages(rcResultStruct_cnd_123_HIGH);
    cnd123_low = rcaExtra_computeAverages(rcResultStruct_cnd_123_LOW);
    
    % add average data to plotting structures
    plotContainerStruct_HIGH = rcaExtra_addPlotOptionsToData(cnd123_high.projAvg);
    plotContainerStruct_LOW = rcaExtra_addPlotOptionsToData(cnd123_low.projAvg);

    % add stats to plotting structures (each condition tests against 0) 
    plotContainerStruct_HIGH.statData = rcaExtra_runStatsAnalysis(cnd123_high, []);
    plotContainerStruct_LOW.statData = rcaExtra_runStatsAnalysis(cnd123_low, []);

    % create x-labels, must be real 
    freqIdx = cellfun(@(x) str2double(x(1)), cnd123_high.rcaSettings.useFrequencies, 'uni', true);
    freqVals = cnd123_high.rcaSettings.useFrequenciesHz*freqIdx;
    xLabel = arrayfun( @(x) strcat(num2str(x), 'Hz'), freqVals, 'uni', false);
    yLabel = 'Latency, \Radians';
    % specify plotting styles data for each container
    
    plotContainerStruct_HIGH.xDataLabel = xLabel;
    plotContainerStruct_HIGH.yDataLabel = yLabel;
    
    % specify RCs and conditions to plot against each other 
    rcsToPlot = [1 2 3];
    cndsToPlot = [1 2];
    
    % specify plotting styles data for each container    
    plotContainerStruct_HIGH.rcsToPlot = rcsToPlot;
    plotContainerStruct_HIGH.cndsToPlot = cndsToPlot;    
    plotContainerStruct_HIGH.conditionLabels = {'Condition 1', 'Condition 2'};
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
    plotContainerStruct_LOW.conditionLabels = {'Condition 1', 'Condition 2'};
    plotContainerStruct_LOW.dataLabel = {'Low Readers'};
    plotContainerStruct_LOW.conditionColors = [0.65, 0.5, 0.15; 0.35, 0.45, 0.45];
    plotContainerStruct_LOW.conditionMarkers = {'v', 'd'};
    plotContainerStruct_LOW.markerStyles = {'open', 'open'};
    plotContainerStruct_LOW.markerSize = 12;
    plotContainerStruct_LOW.lineStytles = {'-', '-'};
    plotContainerStruct_LOW.LineWidths = 2;
    plotContainerStruct_LOW.significanceSaturation = 0.15;
    plotContainerStruct_LOW.patchSaturation = 0.15;
    
    % plot Latencies 
    
    out_latencies = rcaExtra_plotSignificantLatencies(plotContainerStruct_LOW, plotContainerStruct_HIGH);  
    out_amplitudes = rcaExtra_plotSignificantAmplitudes(plotContainerStruct_LOW, plotContainerStruct_HIGH);
    out_lolliplots = rcaExtra_plotSignificantLollipops(plotContainerStruct_LOW, plotContainerStruct_HIGH);
    
    % Test significance between groups 
    statsBetween = rcaExtra_runStatsAnalysis(cnd123_high, cnd123_low);
    % add between-group stats (might work but won't make sense for comparing 2+ groups)
    xLocations = 1:numel(freqIdx);
    
    for nc = 1:numel(cndsToPlot)
        nc0 = cndsToPlot(nc);
        for rc = 1:numel(rcsToPlot)
            rc0 = rcsToPlot(rc);
            figHandle = out_amplitudes{rc, nc};
            currAxisHandle = get(figHandle, 'CurrentAxes');
            plot_addStatsBar_freq(currAxisHandle, statsBetween.pValues(:, rc0, nc0), ...
                freqVals');
        end
    end
        
    %% comparing data within the group
    % Comparing amplitude conditions per group with added noise (old code plotting)
    
    plotSettings_High = rcaExtra_getPlotSettings(rcResultStruct_cnd_123_HIGH);
    plotSettings_High.Title = 'Amplitude High Readers';
    plotSettings_High.RCsToPlot = 1;
    % display noise floor (default = 0), set to 1 if noise data is present
    % and correctly averaged
    % plotSettings_High.displayNoise = 1;
    plotSettings_High.legendLabels = plotContainerStruct_HIGH.conditionLabels;
    
    
    colors_black = [0.15, 0.15, 0.15];
    colors_gray = [0.45, 0.45, 0.45];
    coors_light = [0.75, 0.75, 0.75];
    gs_colors = cat(1, coors_light, colors_gray, colors_black);
    plotSettings_High.useColors = gs_colors';
 
    % display within-group data alltogether
    figHandle_high_lolliplots = rcaExtra_plotLollipops(rcResultStruct_cnd_123_HIGH, plotSettings_High);
    figHandle_high_amplitudes = rcaExtra_plotAmplitudes(rcResultStruct_cnd_123_HIGH, plotSettings_High);
    
    % display only 2 conditions
    
    rcResult_high_c12 = rcaExtra_selectConditionsSubset(rcResult_cnt, [1 2]);
    % adjust colors if needed
    plotSettings_High_c12 = plotSettings_High;
    plotSettings_High_c12.useColors = (cat(1, colors_gray, colors_black))';
    plotSettings_High.legendLabels = plotContainerStruct_HIGH.conditionLabels([1 2]);
    
    figHandle_high_amplitudes_c12 = rcaExtra_plotAmplitudes(rcResult_high_c12, plotSettings_High_c12);

    % to add significance, split conditions
    rcResult_high_c1 = rcaExtra_selectConditionsSubset(rcResult_high_c12, 1);    
    rcResult_high_c2 = rcaExtra_selectConditionsSubset(rcResult_high_c12, 2);
    
    % compute stats
    statsWithin_high_c12 = rcaExtra_runStatsAnalysis(rcResult_high_c1, rcResult_high_c2, 1);
    
    % add stats to RC1 
    currAxisHandle_high_c12 = get(figHandle_high_amplitudes_c12{1}, 'CurrentAxes');
    plot_addStatsBar_freq(currAxisHandle_high_c12, statsWithin_high_c12.pValues(:, 1), ...
        xLocations');
    
end

