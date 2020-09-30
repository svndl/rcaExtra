function fh_SinCos = rcaExtra_sincos_freq(freqs, ampVals, freqVals, ellipseErr, colors, labels)

    [~, nCnd] = size(ampVals);
    fh_SinCos = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    fontSettings = {'FontSize', 30, 'fontname', 'helvetica', 'FontAngle', 'italic'};
    
    ax_re = subplot(1, 2, 1, 'Parent', fh_SinCos); title('Real', fontSettings{:}); hold on;
    ax_im = subplot(1, 2, 2, 'Parent', fh_SinCos); title('Imag', fontSettings{:}); hold on;
    
    xlabels = arrayfun( @(x) strcat(num2str(x), 'Hz'), freqs, 'uni', false);
    set(ax_re, 'XTick', freqs);
    set(ax_re, 'XTickLabels', xlabels');
    
    set(ax_im, 'XTick', freqs);
    set(ax_im, 'XTickLabels', xlabels');
    
    legendRef_re = cell(nCnd, 1);
    legendRef_im = cell(nCnd, 1);
    
    for nc = 1:nCnd
        colorGroup = colors(:, nc);
        
        cndPlotStyle = {'o', 'Color', colorGroup, 'LineStyle', 'None', ...
            'MarkerSize', 12, 'MarkerEdgeColor', colorGroup, 'MarkerFaceColor', colorGroup};
        
        alpha = freqVals(:, nc);
        L = ampVals(:, nc);
        x = L.*cos(alpha);
        y = L.*sin(alpha);
        legendRef_re{nc} = plot(ax_re, freqs', x, cndPlotStyle{:}); hold on;
        legendRef_im{nc} = plot(ax_im, freqs', y, cndPlotStyle{:}); hold on;
    end
    
    if (~isempty(labels))
        legend([legendRef_re{:}], labels, 'Interpreter', 'none', 'FontSize', 30, ...
            'EdgeColor', 'none', 'Color', 'none');
        legend([legendRef_im{:}], labels, 'Interpreter', 'none', 'FontSize', 30, ...
            'EdgeColor', 'none', 'Color', 'none');
    end
    
    pbaspect(ax_re, [1 1 1]);
    pbaspect(ax_im, [1 1 1]);
    
    set(ax_re, fontSettings{:});
    set(ax_im, fontSettings{:});
    
    linkaxes([ax_re, ax_im], 'xy');
end
