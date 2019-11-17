function t1 = freqPlotLatency(h, angles, errors, colors, labels, f)
    
    axes(h);
    
    nCnd = size(angles, 2);
    nF = size(angles, 1);
    xlabels = cellfun( @(x) strcat(num2str(x), 'F'), num2cell(1:1:nF), 'uni', false);
    
    x = repmat((1:nF)', [1 nCnd]);    
       
      % errors are in degs
    err_Lo = squeeze(errors(: ,:, 1));
    err_Hi = squeeze(errors(: ,:, 2));
    
    values = unwrapPhases(angles);
    
    ebh = errorbar(x, values, err_Lo, err_Hi, ...
         '*', 'LineStyle', 'none', 'LineWidth', 2, 'MarkerSize', 10); hold on;
     
    for c = 1:nCnd
        [Pc, Sc] = polyfit(f*x(:, c), values(:, c), 1);
       
        yfit = f*Pc(1)*x(:, c) + Pc(2);
    
        %% display slope
        latency = 1000*Pc(1)/(2*pi);    
        d = (yfit - values(:, c)).^2;
        dd = sqrt(sum(d)/(nF - 2)); 
    
        t1 = text(3, values(3, c), sprintf('%.2f \\pm %.1f (msec)', latency, dd), ...
            'FontSize', 30, 'Interpreter', 'tex', 'color',  colors(c, :));
        plot(x(:, c), yfit, '-.', 'color', colors(c, :)); hold on;
        set(ebh(c), 'color', colors(c, :));
    
    end
    title('Latency Estimate', 'Interpreter', 'tex');    
    legend(labels{:}); 
    try
        xticks(1:nF);
        xticklabels(xlabels);
    catch
        xticks(1:nF);        
        xlabel(xlabels);
    end
    %square axes
    
end