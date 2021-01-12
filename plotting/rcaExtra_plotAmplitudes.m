function fh_AmplitudesFreqs = rcaExtra_plotAmplitudes(rcaResult, plotSettings)
% Function will plot amplitude bars for a given RC result structure.
% input arguments: rcaResult structure       
    
    if (isempty(plotSettings))
       % fill settings template
       plotSettings = rcaExtra_getPlotSettings(rcaResult);       
       plotSettings.Title = 'Amplitude Plot';
       plotSettings.RCsToPlot = 1:3;
    end
    
    freqIdx = cellfun(@(x) str2double(x(1)), rcaResult.rcaSettings.useFrequencies, 'uni', true);
    freqVals = rcaResult.rcaSettings.useFrequenciesHz*freqIdx;
    fh_AmplitudesFreqs = cell(numel(plotSettings.RCsToPlot), 1);
    for cp = 1:numel(plotSettings.RCsToPlot)
        
        rc = plotSettings.RCsToPlot(cp);
        
        groupAmps = squeeze(rcaResult.projAvg.amp(:, rc, :));
        groupAmpErrs = squeeze(rcaResult.projAvg.errA(:, rc, :, :));
        fh_AmplitudesFreqs{cp} = rcaExtra_barplot_freq(freqVals, groupAmps, groupAmpErrs, ...
            plotSettings.useColors, plotSettings.legendLabels);
        fh_AmplitudesFreqs{cp}.Name = strcat('Amplitudes RC ', num2str(rc),...
            ' F = ', num2str(rcaResult.rcaSettings.useFrequenciesHz));        
        title(fh_AmplitudesFreqs{cp}.Name);
        try
            saveas(fh_AmplitudesFreqs{cp}, ...
                fullfile(rcaResult.rcaSettings.destDataDir_FIG, [fh_AmplitudesFreqs{cp}.Name '.fig']));
        catch err
            rcaExtra_displayError(err);
        end
    end
end