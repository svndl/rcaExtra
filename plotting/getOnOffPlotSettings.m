function plotSettings = getOnOffPlotSettings(type, domain)
    
    plotSettings.linestyles = {'-', '-', '-', '-', '-', '-', '-', '-'};
    fontSize = 25;
    defaultaxesprops = {'FontSize',  fontSize + 5, 'fontname', 'helvetica', 'fontangle', 'italic', ...
        'LineWidth', 2, 'box', 'off', 'color', 'none'};
    
    load('colorbrewer');
   
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

    switch type
        case 'groups'
            showlegends = true;
            
            colors = [colorbrewer.qual.Dark2{8}; colorbrewer.qual.Accent{4}]/255;
            
        case 'conditions'
            PaletteN = 9;
            blues = colorbrewer.seq.Blues{PaletteN}/255;
            reds = colorbrewer.seq.Reds{PaletteN}/255;
            colors = interleave(1, blues(end:-1:1, :), ...
                reds(end:-1:1, :));
                        
        case 'groupsconditions'
            
            PaletteN = 9;
            blues = colorbrewer.seq.Blues{PaletteN}/255;
            reds = colorbrewer.seq.Reds{PaletteN}/255;
            oranges = colorbrewer.seq.Oranges{PaletteN}/255;
            greens = colorbrewer.seq.Greens{PaletteN}/255;
            
            warmColors = interleave(1 ,reds(end:-2:3, :), oranges(end:-2:3, :));
            coldColors = interleave(1, blues(end:-2:3, :), greens(end:-2:3, :));
    
            colors = cat(3, coldColors(1:end, :), ...
                warmColors(1:end, :));
        otherwise
    end
    plotSettings.colors = colors;
    plotSettings.showlegends = showlegends;
    plotSettings.fontsize = fontSize;
    plotSettings.axesprops = axessettings;
    plotSettings.statssettings = statssettings;
end