function plotSettings = rcaExtra_getPlotSettings(infoStruct)
% Function generates template structure for plotting RCA

% Alexandra Yakovleva, Stanford University 2020

   plotSettings.domain = infoStruct.domain;
   plotSettings.lineStyles = {'-', '-', '-', '-', '-', '-', '-', '-'};
   plotSettings.fontSize = 25;
   defaultaxesprops = {'FontSize',  plotSettings.fontSize + 5, 'fontname', 'helvetica', 'fontangle', 'italic', ...
        'LineWidth', 2, 'box', 'off', 'color', 'none'};
    
   load('colorbrewer');

    switch infoStruct.domain
        case 'time'
            % plot settings time
            plotSettings.showLegends = true;
            plotSettings.xLabel = 'Time (msec)';
            plotSettings.yLabel = 'Amplitude (\muV)';          
            plotSettings.axesSettings = [defaultaxesprops, 'XMinorTick', 'on', 'XAxisLocation', 'bottom', 'TickLength', [.05 .01]];
            % settings for stats
            plotSettings.statsSettings = {};          
        case 'freq'
            % plot settings frequency
            plotSettings.xLabel = 'Harmonics';
            plotSettings.yLabel = 'Amplitude (\muV)';
            plotSettings.showLegends = true;
            plotSettings.axesSettings = defaultaxesprops;
            % settings for stats
            plotSettings.statsSettings = {'HorizontalAlignment', 'center','VerticalAlignment','top', ...
                'FontSize',  fontSize + 5, 'fontname', 'helvetica', 'fontangle', 'italic' };  
        otherwise
    end
    %% colors for various plotting styles
    % 'accents' colormap        
    plotSettings.colors.accents = [colorbrewer.qual.Dark2{8}; colorbrewer.qual.Accent{4}]/255;
    
    % 'bluered' colormap
    PaletteN = 9;
    blues = colorbrewer.seq.Blues{PaletteN}/255;
    reds = colorbrewer.seq.Reds{PaletteN}/255;
    plotSettings.colors.bluered = interleave(1, blues(end:-1:1, :), ...
        reds(end:-1:1, :));
            
    % 'interleaved' colormaps
            
    PaletteN = 9;
    blues = colorbrewer.seq.Blues{PaletteN}/255;
    reds = colorbrewer.seq.Reds{PaletteN}/255;
    oranges = colorbrewer.seq.Oranges{PaletteN}/255;
    greens = colorbrewer.seq.Greens{PaletteN}/255;
    
    warmColors = interleave(1 ,reds(end:-2:3, :), oranges(end:-2:3, :));
    coldColors = interleave(1, blues(end:-2:3, :), greens(end:-2:3, :));
    
    plotSettings.colors.interleaved = cat(3, coldColors(1:end - 1, :), ...
        warmColors(2:end, :));
    % plot general settings
    
    %plotSettings.runDate = runDate; % runtime info
    plotSettings.resultsDir = infoStruct.path.destDataDir_FIG;
    % type of plot: exploratory or comparison    
    plotSettings.plotType = {};
end