function f = rcaExtra_barplot_freq(frequencies, vals, errs, colors, labels)
    
    [nF, nCnd] = size(vals);    
    
    xlabels = arrayfun( @(x) strcat(num2str(x), 'Hz'), frequencies, 'uni', false);
    x = repmat((1:nF)', [1 nCnd]);
   
    nGroups = nF;
    nBars = nCnd;
    groupWidth = min(0.8, nBars/(nBars + 1.5));
    xE = zeros(nGroups, nBars);
    for b = 1:nBars
        xE(:, b) = (1:nGroups) - groupWidth/2 + (2*b -1 )*groupWidth / (2*nBars);
    end
    f = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    
    barsHandle = bar(x, vals, 'LineWidth', 2); hold on;
    if (nCnd > 1)
        beh = errorbar(xE, vals, squeeze(errs(:, :, 1)), squeeze(errs(:, :, 2)), ...
            'LineStyle', 'none', 'LineWidth', 2);
    else
       beh = errorbar(xE, vals, squeeze(errs(:, 1)), squeeze(errs(:, 2)), ...
            'LineStyle', 'none', 'LineWidth', 2);
    end    
    patchSaturation = 0.15;
    for c = 1:nCnd
        patchColor = colors(c, :) + (1 - colors(c, :))*(1 - patchSaturation);
        set(barsHandle(c), 'EdgeColor', colors(c, :));
        set(barsHandle(c), 'FaceColor', patchColor);
        set(beh(c), 'color', colors(c, :));
    end
    
    try
        xticklabels(xlabels(:));
    catch
        xlabel(xlabels);
    end
    if (~isempty(labels))
        legend(barsHandle, labels{:}, 'Interpreter', 'none',  'FontSize', 30, 'EdgeColor', 'none', 'Color', 'none');
    end
    currYLimit = ylim(gca);
    ylim([0, 1.2*currYLimit(2)]);
    title('Amplitude Values');
    set(gca,'FontSize', 30, 'fontname', 'helvetica', 'FontAngle', 'italic');
    ylabel('Amplitude (\muV)');
    pbaspect(gca, [1 1 1]);
end
