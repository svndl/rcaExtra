function bh = freqplotBar(h, values, errors, colors, labels)
    
    axes(h);
    nF = size(values, 1);    
    nCnd = size(values, 2); 
    
    xlabels = cellfun( @(x) strcat(num2str(x), 'F'), num2cell(1:1:nF), 'uni', false);
    x = repmat((1:nF)', [1 nCnd]);
   
    nGroups = nF;
    nBars = nCnd;
    groupWidth = min(0.8, nBars/(nBars + 1.5));
    xE = zeros(nGroups, nBars);
    for b = 1:nBars
        xE(:, b) = (1:nGroups) - groupWidth/2 + (2*b -1 )*groupWidth / (2*nBars);
    end
    
    bh = bar(x, values, 'LineWidth', 2); hold on;
    if (nCnd > 1)
        beh = errorbar(xE, values, squeeze(errors(:, :, 1)), squeeze(errors(:, :, 2)), ...
            'LineStyle', 'none', 'LineWidth', 2);
    else
       beh = errorbar(xE, values, squeeze(errors(:, 1)), squeeze(errors(:, 2)), ...
            'LineStyle', 'none', 'LineWidth', 2);
    end    
    patchSaturation = 0.15;
    for c = 1:nCnd
        patchColor = colors(c, :) + (1 - colors(c, :))*(1 - patchSaturation);
        set(bh(c), 'EdgeColor', colors(c, :));
        set(bh(c), 'FaceColor', patchColor);
        set(beh(c), 'color', colors(c, :));
    end
    %title('Amplitudes', 'Interpreter', 'none');
    try
        xticklabels(xlabels(:));
    catch
        xlabel(xlabels);
    end
%     hatchOpts = {'HatchAngle', 45, 'HatchDensity', 35, 'SpeckleMarkerStyle', 'o'};
%     hatchPatterns = {'single', 'cross', 'speckle', 'single', 'fill'};
%     hatchHandle = cell(numel(bh), 1);
%     for b = 1:numel(bh)
%         hatchHandle{b} = hatchfill2(bh(b), hatchPatterns{b}, hatchOpts{:});
%     end
%     if (~isempty(labels))
%         legend([hatchHandle{:}], labels{:}, 'Interpreter', 'none');
%     end
    if (~isempty(labels))
        legend(bh, labels{:}, 'Interpreter', 'none',  'FontSize', 30, 'EdgeColor', 'none', 'Color', 'none');
    end
    currYLimit = ylim(gca);
    ylim([0, 1.2*currYLimit(2)]);
    title('Amplitude Values');
    set(gca,'FontSize', 30, 'fontname', 'helvetica', 'FontAngle', 'italic');
    ylabel('Amplitude (\muV)');
    % set square
    
end
