function axHandles = plotRCWaveforms(plotHandle, tc, data_mu, data_s, labels1, labels2, dataType)
    load('colorbrewer');    
        
    % specify palette depending on grouptype
    switch dataType
        case 'gc'
            plotLabel = 'Group x Factor';
            PaletteN = 9;
            blues = colorbrewer.seq.Blues{PaletteN}/255;
            reds = colorbrewer.seq.Reds{PaletteN}/255;
            oranges = colorbrewer.seq.Oranges{PaletteN}/255;
            greens = colorbrewer.seq.Greens{PaletteN}/255;
            warmColors = interleave(1 ,reds(end:-1:2, :), oranges(end:-1:2, :));
            coldColors = interleave(1, blues(end:-1:2, :), greens(end:-1:2, :));
            c_rg = interleave(1, coldColors(2:nGroups + 1, :), ...
                warmColors(2:nGroups + 1, :));           
        case 'g'
            plotLabel = 'Group';
            c_rg = [colorbrewer.qual.Dark2{8}; colorbrewer.qual.Accent{4}]/255;
        case 'c'
            plotLabel = ['Factor ' labels1];
            PaletteN = 9;
            blues = colorbrewer.seq.Blues{PaletteN}/255;
            reds = colorbrewer.seq.Reds{PaletteN}/255;
            c_rg = interleave(1, blues(end:-1:1, :), ...
                reds(end:-1:1, :));
        otherwise
    end
    nPlots = size(data_mu, 1);
    
    legend_patch = cell(nPlots, 1);
    Label = [plotLabel ' Waveforms'];
    for p = 1:nPlots
        legend_patch{p} = customErrPlot(plotHandle, tc', data_mu(p, :), data_s(p, :), c_rg(p, :), 25, Label, '--');
    end
    legend(plotHandle, [legend_patch{:}], labels2(:));
    
    
end
