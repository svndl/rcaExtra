function f = rcaExtra_latplot_freq_stats(frequencies, vals, errs, colors, labels, significance)
    
    [nF0, nCnd] = size(vals);
    nF = size(frequencies, 2);
    if (nF0 ~= nF)
        fprintf('Number of frequencies don''t match: %d for angles, %d for angle values \n', nF0, nF);
        f = [];
        return;
    end
    % create frequency label arrays  
    xlabels = arrayfun( @(x) strcat(num2str(x), 'Hz'), frequencies, 'uni', false);
    % x-values
    x = repmat(frequencies', [1 nCnd]);    
    
    % unwrap phases
    values_unwrapped = unwrapPhases(vals);
    
    % marker options for errorbars
    markerOpts = {'+', 'o', '*', '.', 'x', 'square', 'diamond', ...
        'v', '^', '>', '<', 'pentagram', 'hexagram', 'none'};
    
    f = figure('units', 'normalized', 'outerposition', [0 0 1 1]);

    %% split into significant/no n-significant 
        
    sigVals = vals(significance, :);
    nsigVals = vals(~significance, :);
    
    sigxE  = xE(significance, :);      
    nsigxE = xE(~significance, :);
    
    sigValErrs = errs(significance, :, :);
    nsigValErrs = errs(~significance, :, :);
    
    
    if (nCnd > 1)
        % for two conditions, compute latencies and display
        % regression line. Shade non-significant frequencies
        
        err_Lo = squeeze(errs(:, :, 1));
        err_Hi = squeeze(errs(:, :, 2));
        
    else
        % if there's one condition, compute latency estimate 
        % only if there are 2 or more significant freqencies
        % 
        err_Lo = squeeze(errs(:, 1));
        err_Hi = squeeze(errs(:, 2));   
        
        
        
    end
    
    
    
    % display all errormarkers first to store legend info
    
    ebh = errorbar(x, values_unwrapped, err_Lo, err_Hi, 'LineStyle', 'none', ...
        'LineWidth', 2, 'MarkerSize', 12, 'CapSize', 0); hold on;   
    
    sigSaturation = 0.5;    
    p = cell(nCnd, 1);
    
    % loop over conditions to redraw significant markers
    % and fit regression line if 3 or more harmnic multiples are
    % significant
    for c = 1:nCnd
        % define significant/ non significant colors
        color1 = colors(c, :);
        color0 = color1 + (1 - color1)*(1 - sigSaturation);
        
        % color all markers as non-significant 
        set(ebh(c), 'color', color0, 'Marker', markerOpts{c}, ...
            'MarkerFaceColor', color0, 'MarkerEdgeColor', color0);
        
        % set significant and non-significant colors
        set(ebh(c), 'color', colors(c, :), 'Marker', markerOpts{c}, ...
            'MarkerFaceColor', colors(c, :), 'MarkerEdgeColor', colors(c, :));

        set(ebh(c), 'color', colors(c, :), 'Marker', markerOpts{c}, ...
            'MarkerFaceColor', colors(c, :), 'MarkerEdgeColor', colors(c, :));
        
        % interpolate over number of significant frequencies
        if (nF > 2)
            [Pc, ~] = polyfit(x(:, c), values_unwrapped(:, c), 1);    
            yfit = Pc(1)*x(:, c) + Pc(2);
    
            % display slope
            latency = 1000*Pc(1)/(2*pi);    
            d = (yfit - values_unwrapped(:, c)).^2;
            dMs = 1000*d/(2*pi);
        
            %dd = sqrt(sum(d)/(nF - 2)); 
            dd = sqrt(sum(dMs)/(nF - 2)); 
            % compute middle point for values
            middle = mean(values_unwrapped, 1);
            t1 = text(mean(x), middle, sprintf('%.2f \\pm %.1f (msec)', latency, dd), ...
            'FontSize', 30, 'Interpreter', 'tex', 'color',  colors(c, :)); hold on
            % alternate filled/unfilled
            markerStyle = strcat(':');
            p{c} = plot(gca, x(:, c), yfit, markerStyle, 'LineWidth', 4, 'color', colors(c, :)); hold on;
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