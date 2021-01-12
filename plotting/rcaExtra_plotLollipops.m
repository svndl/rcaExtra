function fh_Lolliplots = rcaExtra_plotLollipops(rcaResult, plotSettings)
% Function will plot lolliplots for a given RC result structure.
% input arguments: rcaResult structure, plotSettings (can be [])       
    
    if (isempty(plotSettings))
       % fill settings template
       plotSettings = rcaExtra_getPlotSettings(rcaResult);
       plotSettings.Title = 'Lollipop Plot';
       plotSettings.RCsToPlot = 1:3;
    end        
    fh_Lolliplots = cell(numel(plotSettings.RCsToPlot), 1);
    
    for cp = 1:numel(plotSettings.RCsToPlot)
        rc = plotSettings.RCsToPlot(cp);
        % component's amplitudes and frequencies
        rcaLats = squeeze(rcaResult.projAvg.phase(:, rc, :));
        rcaAmps = squeeze(rcaResult.projAvg.amp(:, rc, :));
        
        % component's error ellipses (condition x nf cell array) 
        rcaEllipses = cellfun(@(x) x(:, rc), rcaResult.projAvg.ellipseErr, 'uni', false);
        
        fh_Lolliplots{cp} = rcaExtra_loliplot_freq(rcaResult.rcaSettings.useFrequencies, rcaAmps, rcaLats, rcaEllipses, ...
            plotSettings.useColors, plotSettings.legendLabels);
        
        fh_Lolliplots{cp}.Name = strcat('RC ', num2str(rc),...
            ' F = ', num2str(rcaResult.rcaSettings.useFrequenciesHz));
        
        %% save figure in rcaResult.rcaSettings
        try
            saveas(fh_Lolliplots{cp}, ...
                fullfile(rcaResult.rcaSettings.destDataDir_FIG, [fh_Lolliplots{cp}.Name '.fig']));
        catch err
            rcaExtra_displayError(err);
        end
    end
end