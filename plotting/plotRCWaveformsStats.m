function plotRCWaveformsStats(plotHandle, tc, data_mu, data_s, labels1, labels2, dataType, pval)
    load('colorbrewer');    
    fontSize = 25;    
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
        legend_patch{p} = customErrPlot(plotHandle, tc', data_mu(p, :), data_s(p, :), c_rg(p, :), Label, '--');
    end
    legend(plotHandle, [legend_patch{:}], labels2(:), 'FontSize', fontSize);
    currAxisHandle = gca;
    
    %% ADD STATS
    % sigPos is the lower and upper bound of the part of the plot        
    yLims = ylim;
    xLims = xlim;
    sigPos = min(yLims) + diff(yLims).*[0 .1];

    % coloring in the uncorrected t-values
    tHotColMap = jmaColors('pval'); 
    tHotColMap(end, :) = [1 1 1]; 
    
    pixWidth = 30;
    curP = repmat( pval', pixWidth, 1);
    hImg = image([min(tc), max(tc)],[sigPos(1), sigPos(2)], curP, 'CDataMapping', 'scaled', 'Parent', currAxisHandle);
    
    colormap(currAxisHandle, tHotColMap);
    cMapMax = .05 + 2*.05/(size(tHotColMap, 1));
    set(currAxisHandle, 'CLim', [ 0 cMapMax ] ); % set range for color scale
    uistack(hImg,'bottom'); hold on;
    ylim(yLims);
    xlim(xLims);
    %% ADD EXTRA TICKS

    % minor ticks every 10s, major every 50s    
    
    minor_xTicks = 0:10:tc(end);
    minor_xTickData = {'XTick', minor_xTicks, 'ticklength',[.01, .01], ...
        'TickDir', 'out', 'xticklabels', [], 'yticklabels', []};
    set(currAxisHandle, minor_xTickData{:});
        
    major_xTicks = 0:50:tc(end);   
    major_xTickData = {'XTick', major_xTicks, 'ticklength',[.02, .02],  'TickDir', 'out'};
    % re-set the labels/fonts
    
    ax_pos = currAxisHandle.Position; % position of first axes   
    ax2 = axes('Position', ax_pos,...
        'XAxisLocation','bottom',...
        'YAxisLocation', 'left',...
        'Color','none', 'XLim', currAxisHandle.XLim, ...
        'YLim', currAxisHandle.YLim, 'FontSize', fontSize,...
        'XScale', 'linear', 'YScale', 'linear');
    set(ax2, major_xTickData{:});
    xlabel('Time, ms') % x-axis label
    ylabel('Amplitude, \muV') % y-axis label
    set(ax2, 'FontSize', fontSize + 5);
end
