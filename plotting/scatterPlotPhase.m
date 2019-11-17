function scatterPlotPhase(h, values, errors, plottitle, cndtitle, yl, colors, f, delay)
    
    axes(h);
    
    nCnd = size(values, 2);
    nF = size(values, 1);
    xlabels = cellfun( @(x) strcat(num2str(x), 'F'), num2cell(1:1:nF), 'uni', false);
    
    x = repmat((1:nF)', [1 nCnd]);    
    % convert to degs
    %% phase wrapping
    
    while (values(2, 1)<values(1, 1))
        values(2, 1) = values(2, 1) + 2*pi;
    end
    
    while (values(3, 1)<values(2, 1))
        values(3, 1) = values(3, 1) + 2*pi;
    end
    while (values(4, 1) < values(3, 1))
        values(4, 1) = values(4, 1) + 2*pi;
    end
    while (values(2, 2)<values(1, 2))
        values(2, 2) = values(2, 2) + 2*pi;
    end
 
    while (values(3, 2)<values(2, 2))
        values(3, 2) = values(3, 2) + 2*pi;        
    end
    while (values(4, 2)<values(3, 2))
        values(4, 2) = values(4, 2) + 2*pi;
    end

    if(values(4, 1) - values(3, 1) < pi/2)
        values(4, 1) = values(4, 1) +2*pi;
    end
    
    if(values(4, 2) - values(3, 2) < pi/2)
        values(4, 2) = values(4, 2) +2*pi;
    end
   
    % errors are in degs
    err_Lo = squeeze(errors(: ,:, 1));
    err_Hi = squeeze(errors(: ,:, 2));
    
    ebh = errorbar(x, values, err_Lo, err_Hi, ...
         '*', 'LineStyle', 'none', 'LineWidth', 2, 'MarkerSize', 10); hold on;
     
    [P1, S1] = polyfit(f*x(:, 1), values(:, 1), 1);
    [P2, S2] = polyfit(f*x(:, 2), values(:, 2), 1);
    
%     ci_1 = polyparci(P1, S1);
%     ci_2 = polyparci(P2, S2);
    
    yfit_1 = f*P1(1)*x(:, 1) + P1(2);
    yfit_2 = f*P2(1)*x(:, 1) + P2(2);
    
    %% display slope
    latency_1 = 1000*P1(1)/(2*pi);
    latency_2 = 1000*P2(1)/(2*pi);
    
    if (~isempty(delay))
        latency_1 = latency_1 - delay;
        latency_2 = latency_2 - delay;
    end
    d1 = (yfit_1 - values(:, 1)).^2;
    d2 = (yfit_2 - values(:, 2)).^2;
    
    dd1 = (sqrt( sum(d1)/nF )); 
    dd2 = (sqrt( sum(d2)/nF ));
    
    t1 = text(3, values(3, 1), sprintf('%.2f \\pm %.1f (msec)', latency_1, dd1), ...
        'FontSize', 30, 'Interpreter', 'tex', 'color',  colors(1, :));
    t2 = text(3, values(3, 2), sprintf('%.2f \\pm %.1f (msec)', latency_2, dd2), ...
        'FontSize', 30, 'Interpreter', 'tex', 'color',  colors(2, :));
    
    %set(t1, 'Rotation', 180 - rad2deg(P1(1)));
    %set(t2,' Rotation', 180 - rad2deg(P2(1)));
    
    plot(x(:, 1), yfit_1, '-.', 'color', colors(1, :)); hold on;
    plot(x(:, 1), yfit_2, '-.', 'color', colors(2, :)); hold on;
    
    title(plottitle, 'Interpreter', 'tex');    
    legend(cndtitle{:});
    
    for c = 1:nCnd
        set(ebh(c), 'color', colors(c, :));
    end
    
    try
        xticks(1:nF);
        xticklabels(xlabels);
    catch
        xticks(1:nF);        
        xlabel(xlabels);
    end
end

