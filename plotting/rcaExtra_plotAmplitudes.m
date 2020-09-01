function fh_AmplitudesFreqs = rcaExtra_plotAmplitudes(rcaResult, plotSettings)
% Function will plot amplitude bars for a given RC result structure.
% input arguments: rcaResult structure       
    
    if (isempty(plotSettings))
       % fill settings template
       plotSettings = rcaExtra_getPlotSettings(rcaResult.rcaSettings);
       plotSettings.legendLabels = arrayfun(@(x) strcat('Condition ', num2str(x)), ...
           1:size(rcaResult.projAvg.ellipseErr, 1), 'uni', false);
       % default settings for all plotting: 
       % font type, font size
       
       plotSettings.Title = 'Amplitude Plot';
       plotSettings.RCsToPlot = 3;
       % legend background (transparent)
       % xTicks labels
       % xAxis, yAxis labels
       % hatching (yes/no) 
       % plot title 
        
    end
    
    freqIdx = cellfun(@(x) str2double(x(1)), rcaResult.rcaSettings.useFrequencies, 'uni', true);
    freqVals = rcaResult.rcaSettings.useFrequenciesHz*freqIdx;
    fh_AmplitudesFreqs = cell(rcaResult.rcaSettings.nComp, 1);
    for cp = 1:rcaResult.rcaSettings.nComp
        
        %
        groupAmps = squeeze(rcaResult.projAvg.amp(:, cp, :));
        groupAmpErrs = squeeze(rcaResult.projAvg.errA(:, cp, :, :));
        fh_AmplitudesFreqs{cp} = rcaExtra_barplot_freq(freqVals, groupAmps, groupAmpErrs, ...
            plotSettings.useColors, plotSettings.legendLabels);
        fh_AmplitudesFreqs{cp}.Name = strcat('Amplitudes RC ', num2str(cp),...
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