function fh_PhasesFreqs = rcaExtra_plotLatencies(rcaResult, plotSettings)

% Function will plot amplitude bars for a given RC result structure.
% input arguments: rcaResult structure       
    
    if (isempty(plotSettings))
       % fill settings template
       plotSettings = rcaExtra_getPlotSettings(rcaResult);       
       plotSettings.Title = 'Latency Plot';
       plotSettings.RCsToPlot = 1:3;
       % legend background (transparent)
       % xTicks labels
       % xAxis, yAxis labels
       % hatching (yes/no) 
       % plot title         
    end
    
    freqIdx = cellfun(@(x) str2double(x(1)), rcaResult.rcaSettings.useFrequencies, 'uni', true);
    freqVals = rcaResult.rcaSettings.useFrequenciesHz*freqIdx;
    fh_PhasesFreqs = cell(numel(plotSettings.RCsToPlot), 1);
    for cp = 1:numel(plotSettings.RCsToPlot)
        rc = plotSettings.RCsToPlot(cp);
        %dims nF by nConditions
        rcaAngles = squeeze(rcaResult.projAvg.phase(:, rc, :));
        rcaAngErrs = squeeze(rcaResult.projAvg.errP(:, rc, :, :));
        fh_PhasesFreqs{cp} = rcaExtra_latplot_freq(freqVals, rcaAngles, rcaAngErrs, ...
            plotSettings.useColors, plotSettings.legendLabels);
        fh_PhasesFreqs{cp}.Name = strcat('Latencies RC ', num2str(rc),...
            ' F = ', num2str(rcaResult.rcaSettings.useFrequenciesHz));        
        title(fh_PhasesFreqs{cp}.Name);
        try
            saveas(fh_PhasesFreqs{cp}, ...
                fullfile(rcaResult.rcaSettings.destDataDir_FIG, [fh_PhasesFreqs{cp}.Name '.fig']));
        catch err
            rcaExtra_displayError(err);
        end
    end
end