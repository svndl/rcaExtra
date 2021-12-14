function varargout = rcaExtra_barplot_freq(axisHandle, frequencies, vals, errs, colors, labels)
    
    [nF, nCnd] = size(vals);    
    
    xlabels = arrayfun( @(x) strcat(num2str(x), 'F'), frequencies, 'uni', false);
    x = repmat((1:nF)', [1 nCnd]);
   
    nGroups = nF;
    nBars = nCnd;
    groupWidth = min(0.8, nBars/(nBars + 1.5));
    xE = zeros(nGroups, nBars);
    for b = 1:nBars
        xE(:, b) = (1:nGroups) - groupWidth/2 + (2*b -1 )*groupWidth / (2*nBars);
    end
    if (isempty(axisHandle))    
        f = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
        ah = get(f,'CurrentAxes');
        varargout = f;
    else
        gca = axisHandle;
    end
    
    errorLineProps = {'LineStyle', 'none', 'LineWidth', 2};
   
    barsHandle = bar(x, vals, 'LineWidth', 2); hold on;
    if (nCnd > 1)
        beh = errorbar(xE, vals, squeeze(errs(:, :, 1)), squeeze(errs(:, :, 2)), ...
            errorLineProps{:});
    else
       beh = errorbar(xE, vals, squeeze(errs(:, 1)), squeeze(errs(:, 2)), ...
            errorLineProps{:});
    end    
    patchSaturation = 0.15;
    for nc = 1:nCnd
        patchColor = colors(:, nc) + (1 - colors(:, nc))*(1 - patchSaturation);
        set(barsHandle(nc), 'EdgeColor', colors(:, nc));
        set(barsHandle(nc), 'FaceColor', patchColor);
        set(beh(nc), 'color', colors(:, nc));
    end
    
    try
        xticklabels(xlabels(:));
    catch
        xlabel(xlabels);
    end
    if (~isempty(labels))
        legend(barsHandle, labels{:}, 'Interpreter', 'none',  'FontSize', 17, 'EdgeColor', 'none', 'Color', 'none');
    end
    currYLimit = ylim(gca);
    ylim([0, 1.2*currYLimit(2)]);
    %title('Amplitude Values');
    set(gca,'FontSize', 20, 'fontname', 'helvetica', 'FontAngle', 'italic');
    ylabel('Amplitude (\muV)');    
    %pbaspect(gca, [1 1 1]);
end
