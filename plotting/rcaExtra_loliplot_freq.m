function fh_Lolliplots = rcaExtra_loliplot_freq(amps, freqs, ellipseErr, colors, labels)

    [nFreqs, nCnd] = size(amps);
    fh_Lolliplots = figure;
    ax = cell(nFreqs, 1);
    for nf = 1:nFreqs 
        ax{nf} = subplot(1, nFreqs, nf, 'Parent', fh_Lolliplots);
        for nc = 1:nCnd
            colorGroup = colors(nc, :);
            
            alpha = freqs(nf, nc);
            L = amps(nf, nc);
            try
                ellipseCalc = ellipseErr{nc};
            catch
                ellipseCalc = err;
            end
            x = L.*cos(alpha);
            y = L.*sin(alpha);
            e_x = 0;
            e_y = 0;
            try
                e0 = ellipseCalc{nf};
            catch
                e0 = ellipseCalc(nf);
            end
            if (~isempty(e0))
                e_x = e0(:, 1) + x;
                e_y = e0(:, 2) + y;
                %                     e_x = e0(:, 1);
                %                     e_y = e0(:, 2);
            end
            props = { 'linewidth', 2, 'color', colorGroup};
            patchSaturation = 0.5;
            patchColor =  colorGroup + (1 - colorGroup)*(1 - patchSaturation);
            errLine = line(e_x, e_y, 'LineWidth', 2); hold on;
            set(errLine,'color', patchColor);
            legendRef{nc} = plot(ax{nf}, [0, x], [0, y], props{:}); hold on;
        end
        set(ax{nf},'FontSize', 30, 'fontname', 'helvetica', 'FontAngle', 'italic');        
        setAxisAtTheOrigin(ax{nf});
        title(strcat(num2str(nf), 'F'), 'Interpreter', 'none');
        pbaspect(ax{nf}, [1 1 1]);
        %descr = ['Conditions ' freqLabels{nf}];
        if (~isempty(labels))
            legend([legendRef{:}], labels, 'Interpreter', 'none', 'FontSize', 30, ...
            'EdgeColor', 'none', 'Color', 'none');
        end
    end
end
