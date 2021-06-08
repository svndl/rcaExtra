function plotContainer = rcaExtra_initPlottingContainer(rcAverageStruct, rcAnalysisInfo)
% quick init function

    plotContainer = rcaExtra_addPlotOptionsToData(rcAverageStruct.projAvg);
    plotContainer.statData = rcaExtra_runStatsAnalysis(rcAverageStruct, []);

    freqIdx = cellfun(@(x) str2double(x(1)), rcAnalysisInfo.useFrequencies, 'uni', true);
    %freqVals = rcAnalysisInfo.useFrequenciesHz*freqIdx;
    
    plotContainer.yDataLabel = 'Amplitude, \muV';
    plotContainer.xDataLabel = freqIdx;
    plotContainer.dataLabel = {rcAnalysisInfo.label};
    plotContainer.conditionMarkers = {'^', 'v'};
    plotContainer.markerStyles = {'filled', 'filled'};
    plotContainer.markerSize = 12;
    plotContainer.lineStytles = {'-', '-'};
    plotContainer.LineWidths = 3;
    plotContainer.significanceSaturation = 0.15;
    plotContainer.patchSaturation = 0.15;
end