function f = rcaExtra_latplot_freq(frequencies, vals, errs, colors, labels)
    
    [nF0, nCnd] = size(vals);
    nF = size(frequencies, 2);
    if (nF0 ~= nF)
        fprintf('Number of frequencies don''t match: %d for angles, %d for angle values \n', nF0, nF);
        f = [];
        return;
    end
        
    xlabels = arrayfun( @(x) strcat(num2str(x), 'Hz'), frequencies, 'uni', false);
    x = repmat(frequencies', [1 nCnd]);    
       
      % errors are in degs
    if (nCnd > 1)
        err_Lo = squeeze(errs(:, :, 1));
        err_Hi = squeeze(errs(:, :, 2));
    else
        err_Lo = squeeze(errs(:, 1));
        err_Hi = squeeze(errs(:, 2));        
    end
    
    values_unwrapped = unwrapPhases(vals);
    markerOpts = {'+', 'o', '*', '.', 'x', 'square', 'diamond', ...
        'v', '^', '>', '<', 'pentagram', 'hexagram', 'none'};
    
    f = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    
    ebh = errorbar(x, values_unwrapped, err_Lo, err_Hi, 'LineStyle', 'none', ...
        'LineWidth', 2, 'MarkerSize', 12, 'CapSize', 0); hold on;   
    
    p = cell(nCnd, 1);
    for nc = 1:nCnd
        
        set(ebh(nc), 'color', colors(:, nc), 'Marker', markerOpts{nc}, ...
            'MarkerFaceColor', colors(:, nc), 'MarkerEdgeColor', colors(:, nc));
        
        % interpolate over number of significant frequencies
        if (nF > 2)
            [Pc, ~] = polyfit(x(:, nc), values_unwrapped(:, nc), 1);    
            yfit = Pc(1)*x(:, nc) + Pc(2);
    
            % display slope
            latency = 1000*Pc(1)/(2*pi);    
            d = (yfit - values_unwrapped(:, nc)).^2;
            dMs = 1000*d/(2*pi);
        
            %dd = sqrt(sum(d)/(nF - 2)); 
            dd = sqrt(sum(dMs)/(nF - 2)); 
            % compute middle point for values
            middle = mean(values_unwrapped, 1);
            t1 = text(mean(x), middle, sprintf('%.2f \\pm %.1f (msec)', latency, dd), ...
            'FontSize', 30, 'Interpreter', 'tex', 'color',  colors(:, nc)); hold on
            % alternate filled/unfilled
            markerStyle = strcat(':');
            p{nc} = plot(gca, x(:, nc), yfit, markerStyle, 'LineWidth', 4, 'color', colors(:, nc)); hold on;
        end
    end
    title('Latency Estimate', 'Interpreter', 'tex');  
    if ~isempty(labels)
        legend(ebh(:), labels{:}, 'Interpreter', 'none', 'FontSize', 30, ...
            'EdgeColor', 'none', 'Color', 'none'); 
    end
    try
        xticks(frequencies);
        xticklabels(xlabels);
    catch
        xticks(frequencies);        
        xlabel(xlabels);
    end
    %square axes
    xlim([0, frequencies(end) + 1]);
    currYLimit = ylim(gca);
    % increase range by 10%
    yRange = diff(currYLimit);
    ylim([currYLimit(1) - 0.1*yRange, currYLimit(2) + 0.1*yRange]); 
    title('Latency Values');
    set(gca,'FontSize', 30, 'fontname', 'helvetica', 'FontAngle', 'italic');
    ylabel('Latency, (\pi)');
    xlabel('Frequency, (Hz)');
    pbaspect(gca, [1 1 1]);
end