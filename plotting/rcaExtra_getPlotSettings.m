function plotSettings = rcaExtra_getPlotSettings(rcaResult)
% Function generates template structure for plotting RCA

    % Alexandra Yakovleva, Stanford University 2020

    plotSettings.domain = rcaResult.rcaSettings.domain;
    lineStyles = {'-', '--', '-.', ':', 'none'};
    markerStyles = {'none', 'o', '+', '*', '.', 'x', '_',...
        '|', 's', 'd', '^', 'v', '>', '<', 'p', 'h', 'none'};
    
    plotSettings.fontSize = 25;

    defaultaxesprops = {'FontSize',  plotSettings.fontSize + 5, 'fontname', 'helvetica', 'fontangle', 'italic', ...
    'LineWidth', 2, 'box', 'off', 'color', 'none'};

    try
        load('colorbrewer');
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
    
        nConditions = size(rcaResult.projectedData, 2);
    
        plotSettings.lineStyles = repmat(lineStyles(1), [nConditions 1]);
        plotSettings.markerStyles = repmat(markerStyles(end), [nConditions, 1]);
        plotSettings.useColors = plotSettings.colors.accents';
        
    catch
         plotSettings.useColors = [];
    end
    
    switch plotSettings.domain
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
            freqIdx = cellfun(@(x) str2double(x(1)), rcaResult.rcaSettings.useFrequencies, 'uni', true);
            freqVals = rcaResult.rcaSettings.useFrequenciesHz*freqIdx;
            plotSettings.xLabels = num2str(freqVals);
            % settings for stats
            plotSettings.statsSettings = {'HorizontalAlignment', 'center','VerticalAlignment','top', ...
                'FontSize',  plotSettings.fontSize + 5, 'fontname', 'helvetica', 'fontangle', 'italic' };
            
            % settings for markers
            plotSettings.ampPlotSettings = rcaExtra_generateBarPlotSettings;
            plotSettings.latPotSettings = rcaExtra_generateLatPlotSettings;
        otherwise
    end
    
    plotSettings.legendLabels = arrayfun(@(x) strcat('Condition ', num2str(x)), 1:nConditions, ...
        'uni', false);
    %% colors for various plotting styles
    
    
    % plot general settings
    
    plotSettings.resultsDir = rcaResult.rcaSettings.destDataDir_FIG;
end