function plotSettings = getOnOffPlotSettings(type, domain)
    
    plotSettings.linestyles = {'-', '-', '-', '-', '-', '-', '-', '-'};
    fontSize = 25;
    defaultaxesprops = {'FontSize',  fontSize + 5, 'fontname', 'helvetica', 'fontangle', 'italic', ...
        'LineWidth', 2, 'box', 'off', 'color', 'none'};
    
   
    switch domain
        case 'Time'                    
            showlegends = true;
            plotSettings.xl = 'Time (msec)';
            plotSettings.yl = 'Amplitude (\muV)';          
            axessettings = [defaultaxesprops, 'XMinorTick', 'on', 'XAxisLocation', 'bottom', 'TickLength', [.05 .01]];
            statssettings = {};
        case 'Frequency'           
            plotSettings.xl = 'Freq';
            plotSettings.yl = 'Amplitude (\muV)';
            showlegends = true;
            axessettings = defaultaxesprops;
            statssettings = {'HorizontalAlignment', 'center','VerticalAlignment','top', ...
                'FontSize',  fontSize + 5, 'fontname', 'helvetica', 'fontangle', 'italic' };  
        otherwise
    end
    load('colorbrewer');
    
    switch type
        case 'brewer_groups'
            showlegends = true;
            
            colors = [colorbrewer.qual.Dark2{8}; colorbrewer.qual.Accent{4}]/255;
          
        case 'brewer_conditions'
            PaletteN = 9;
            blues = colorbrewer.seq.Blues{PaletteN}/255;
            reds = colorbrewer.seq.Reds{PaletteN}/255;
            colors = interleave(1, blues(end:-1:1, :), ...
                reds(end:-1:1, :));
                        
        case 'brewer_groupsconditions'
            showlegends = true;
            PaletteN = 9;
            blues = colorbrewer.seq.Blues{PaletteN}/255;
            reds = colorbrewer.seq.Reds{PaletteN}/255;
            oranges = colorbrewer.seq.Oranges{PaletteN}/255;
            greens = colorbrewer.seq.Greens{PaletteN}/255;
            
            warmColors = interleave(1 ,reds(end:-2:3, :), oranges(end:-2:3, :));
            coldColors = interleave(1, blues(end:-2:3, :), greens(end:-2:3, :));
    
            colors = cat(3, coldColors(1:end-1, :), ...
                warmColors(2:end, :));
        case 'cubehelix'
            [colors, ~] = cubehelix(10, 0.5, -1.3, 2.2, 0.85, [0.08, 0.88], [0.1, 1]);
        case 'grayscale'
            [colors_rgb, ~] = cubehelix(10, 0.5, -1.3, 2.2, 0.85, [0.08, 0.88], [0.1, 1]);
            colors = 0.2989 * colors_rgb(:, 1) + 0.5870 *colors_rgb(:, 2) + 0.1140 * colors_rgb(:, 3);
            colors = repmat(colors, [1 3]);
        otherwise
    end
    plotSettings.colors = colors;
    plotSettings.showlegends = showlegends;
    plotSettings.fontsize = fontSize;
    plotSettings.axesprops = axessettings;
    plotSettings.statssettings = statssettings;
end