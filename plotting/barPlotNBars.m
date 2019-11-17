function barPlotNBars(h, values, errors, plottitle, cndtitle, yl, colors)
    
    axes(h);
    
    nCnd = size(values, 2);
    nF = size(values, 1);
    xlabels = cellfun( @(x) strcat(num2str(x), 'F'), num2cell(1:1:nF), 'uni', false);
    
    x = repmat((1:nF)', [1 nCnd]);
   
    nGroups = nF;
    nBars = nCnd;
    groupWidth = min(0.8, nBars/(nBars + 1.5));
    xE = zeros(nGroups, nBars);
    for b = 1:nBars
        xE(:, b) = (1:nGroups) - groupWidth/2 + (2*b -1 )*groupWidth / (2*nBars);
    end
    
    bh = bar(x, values); hold on;
    beh = errorbar(xE, values, squeeze(errors(:, :, 1)), squeeze(errors(:, :, 2)), ...
        'LineStyle', 'none', 'LineWidth', 2);
    
    patchSaturation = 0.15;

    for c = 1:nCnd
        patchColor = colors(c, :) + (1 - colors(c, :))*(1 - patchSaturation);
        set(bh(c), 'EdgeColor', colors(c, :));
        set(bh(c), 'FaceColor', patchColor);
        set(beh(c), 'color', colors(c, :));
    end
    title(plottitle, 'Interpreter', 'none');    
    legend(cndtitle{:});
    try
        xticklabels(xlabels(:));
    catch
        xlabel(xlabels);
    end
    ylabel(yl);
    set(gca,'FontSize', 30);
end