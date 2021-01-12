function fhSinCos = rcaExtra_plotSinCos_freq(rcaResult, plotSettings)
    if (isempty(plotSettings))
       % fill settings template
       plotSettings = rcaExtra_getPlotSettings(rcaResult);
       plotSettings.Title = 'Real/Imaginary Coeff Plot';
       plotSettings.RCsToPlot = 1:3;
    end
    fhSinCos = cell(numel(plotSettings.RCsToPlot), 1);
    freqIdx = cellfun(@(x) str2double(x(1)), rcaResult.rcaSettings.useFrequencies, 'uni', true);
    freqVals = rcaResult.rcaSettings.useFrequenciesHz*freqIdx;
    
    for cp = 1:numel(plotSettings.RCsToPlot)
        rc = plotSettings.RCsToPlot(cp);
        % component's amplitudes and frequencies
        rcaLats = squeeze(rcaResult.projAvg.phase(:, rc, :));
        rcaAmps = squeeze(rcaResult.projAvg.amp(:, rc, :));
        
        % component's error ellipses (condition x nf cell array) 
        rcaEllipses = cellfun(@(x) x(:, rc), rcaResult.projAvg.ellipseErr, 'uni', false);
        
        fhSinCos{cp} = rcaExtra_sincos_freq(freqVals, rcaAmps, rcaLats, rcaEllipses, ...
            plotSettings.useColors, plotSettings.legendLabels);
        
        fhSinCos{cp}.Name = strcat('RC ', num2str(rc),...
            ' F = ', num2str(rcaResult.rcaSettings.useFrequenciesHz));
        
        %% save figure in rcaResult.rcaSettings
        try
            saveas(fhSinCos{cp}, ...
                fullfile(rcaResult.rcaSettings.destDataDir_FIG, [fhSinCos{cp}.Name '.fig']));
        catch err
            rcaExtra_displayError(err);
        end
    end
end