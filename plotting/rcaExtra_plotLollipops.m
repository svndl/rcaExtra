function fh_Lolliplots = rcaExtra_plotLollipops(rcaResult, plotSettings)
% Function will plot amplitude bars for a given RC result structure.
% input arguments: rcaResult structure       
    
    if (isempty(plotSettings))
       % fill settings template
       plotSettings = rcaExtra_getPlotSettings(rcaResult.rcaSettings);
       plotSettings.legendLabels = arrayfun(@(x) strcat('Condition ', num2str(x)), ...
           1:rcaResult.rcaSettings.useCnds, 'uni', false);
       % default settings for all plotting: 
       % font type, font size
       
       plotSettings.Title = 'Lollipop Plot';
       plotSettings.RCsToPlot = 3;
       % legend background (transparent)
       % xTicks labels
       % xAxis, yAxis labels
       % hatching (yes/no) 
       % plot title 
        
    end
    fh_Lolliplots = cell(rcaResult.rcaSettings.nComp, 1);
    
    for cp = 1:rcaResult.rcaSettings.nComp
        
        % component's amplitudes and frequencies
        rcaLats = squeeze(rcaResult.projAvg.phase(:, cp, :));
        rcaAmps = squeeze(rcaResult.projAvg.amp(:, cp, :, :));
        
        % component's error ellipses (condition x nf cell array) 
        rcaEllipses = cellfun(@(x) x(:, cp), rcaResult.projAvg.ellipseErr, 'uni', false);
        
        fh_Lolliplots{cp} = rcaExtra_loliplot_freq(rcaResult.rcaSettings.useFrequencies, rcaAmps, rcaLats, rcaEllipses, ...
            plotSettings.colors.accents, plotSettings.legendLabels);
        
        fh_Lolliplots{cp}.Name = strcat('RC ', num2str(cp),...
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