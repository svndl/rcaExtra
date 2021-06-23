function plotContainer = rcaExtra_initPlottingContainer(rcAverageStruct, rcAnalysisInfo)
% quick init function for plotting
% Alexandra Yakovleva, Stanford University 2021 


    switch rcAnalysisInfo.domain
        case 'freq'
            % add frequency-specific data
            plotContainer = rcaExtra_addPlotOptionsToData(rcAverageStruct.projAvg);
            
            % create x-axis labels and frequency values
            freqIdx = cellfun(@(x) str2double(x(1)), rcAnalysisInfo.useFrequencies, 'uni', true);
            freqVals = rcAnalysisInfo.useFrequenciesHz*freqIdx;
            plotContainer.xDataLabel = cellfun(@(x) x(1:2), rcAnalysisInfo.useFrequencies, 'uni', false);
            plotContainer.xDataValues = freqVals;
        case 'time'
            % init with empty argument 
            plotContainer = rcaExtra_addPlotOptionsToData([]);
            % add relevant data
            plotContainer.dataToPlot.mu = rcAverageStruct.mu_cnd;
            plotContainer.dataToPlot.s = rcAverageStruct.s_cnd;
            % use rcAnalysisInfo timecourse
            plotContainer.xDataLabel = 'Time, msec';
            plotContainer.xDataValues = rcAverageStruct.timecourse;
        otherwise
            
    end
    if (isfield(rcAnalysisInfo, 'computeStats'))  
        plotContainer.statData = rcaExtra_runStatsAnalysis(rcAverageStruct, []);
    end
    plotContainer.yDataLabel = 'Amplitude, \muV';
    plotContainer.dataLabel = {rcAnalysisInfo.label};
    
    plotContainer.markerSize = 12; 
    plotContainer.LineWidths = 3;
    plotContainer.significanceSaturation = 0.15;
    plotContainer.patchSaturation = 0.15;
    
    % by default, two styles of markers and lines 
    plotContainer.conditionMarkers = {'^', 'v'};
    plotContainer.markerStyles = {'filled', 'filled'};
    plotContainer.lineStytles = {'-', '-'};    
end