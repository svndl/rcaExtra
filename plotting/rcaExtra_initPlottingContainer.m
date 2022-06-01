function plotContainer = rcaExtra_initPlottingContainer(rcResultStructure)
% quick init function for plotting
% Alexandra Yakovleva, Stanford University 2021 


    switch rcResultStructure.rcaSettings.domain
        case 'freq'
            % add frequency-specific data
            plotContainer = rcaExtra_addPlotOptionsToData(rcResultStructure.projAvg);
            
            % create x-axis labels and frequency values
            freqIdx = cellfun(@(x) str2double(x(1)), rcResultStructure.rcaSettings.useFrequencies, 'uni', true);
            freqVals = rcResultStructure.rcaSettings.useFrequenciesHz*freqIdx;
            plotContainer.xDataLabel = cellfun(@(x) x(1:2), rcResultStructure.rcaSettings.useFrequencies, 'uni', false);
            plotContainer.xDataValues = freqVals;
        case 'time'
            % init with empty argument 
            plotContainer = rcaExtra_addPlotOptionsToData([]);
            % add relevant data
            plotContainer.dataToPlot.mu = rcResultStructure.mu_cnd;
            plotContainer.dataToPlot.s = rcResultStructure.s_cnd;
            % use rcAnalysisInfo timecourse
            plotContainer.xDataLabel = 'Time, msec';
            plotContainer.xDataValues = rcResultStructure.timecourse;
        otherwise
            
    end
    if (isfield(rcResultStructure.rcaSettings, 'computeStats'))
        if (rcResultStructure.rcaSettings.computeStats)
            plotContainer.statData = rcaExtra_runStatsAnalysis(rcResultStructure, []);
        end
    end
    plotContainer.yDataLabel = 'Amplitude, \muV';
    plotContainer.dataLabel = {rcResultStructure.rcaSettings.label};
    
    plotContainer.markerSize = 12; 
    plotContainer.LineWidths = 3;
    plotContainer.significanceSaturation = 0.15;
    plotContainer.patchSaturation = 0.15;
    
     default_markers = '^';
%     default_styles = 'filled';
%     default_lines = '-';
    % by default, styles of markers and lines 
    plotContainer.conditionMarkers = {'^', 'v', default_markers, default_markers, default_markers, default_markers};
    plotContainer.markerStyles = {'filled', 'filled', 'filled', 'filled', 'filled', 'filled'};
    plotContainer.lineStytles = {'-', '-', '-', '-', '-', '-'};    
end