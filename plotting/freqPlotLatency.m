function t1 = freqPlotLatency(h, angles, errors, colors, labels, f)
    
    axes(h);
    
    nCnd = size(angles, 2);
    nF = size(angles, 1);
    xlabels = cellfun( @(x) strcat(num2str(x), 'F'), num2cell(1:1:nF), 'uni', false);
    
    x = repmat((1:nF)', [1 nCnd]);    
       
      % errors are in degs
    err_Lo = squeeze(errors(:, :, 1));
    err_Hi = squeeze(errors(:, :, 2));
    
    values = unwrapPhases(angles);
    
    ebh = errorbar(x, values, err_Lo, err_Hi, 'LineStyle', 'none', ...
        'LineWidth', 4, 'MarkerSize', 12); hold on;
    Markers = {'o','o','^','^','>','<'};
    
    
    p = cell(nCnd, 1);
    for c = 1:nCnd
        [Pc, Sc] = polyfit(f*x(:, c), values(:, c), 1);
       
        yfit = f*Pc(1)*x(:, c) + Pc(2);
    
        % add more points to yFit for plotting
        xq = x(1, c):0.25:x(end, c);
        yFit_plot = f*Pc(1)*xq' + Pc(2);
        %% display slope
        latency = 1000*Pc(1)/(2*pi);    
        d = (yfit - values(:, c)).^2;
        dd = sqrt(sum(d)/(nF - 2)); 
    
        t1 = text(3, values(3, c), sprintf('%.2f \\pm %.1f (msec)', latency, dd), ...
            'FontSize', 30, 'Interpreter', 'tex', 'color',  colors(c, :));
        % alternate filled/unfilled
        markerStyle = strcat('-', Markers{c});
        p{c} = plot(xq, yFit_plot, markerStyle, 'LineWidth', 4, 'color', colors(c, :), ...
            'MarkerFaceColor', colors(c, :), 'MarkerSize', 12); hold on;
%         try
%             if (openMarker)
%                 openMarker = false;
%             else
%                 set(p{c}, 'MarkerFaceColor', colors(c, :))            
%                 openMarker = true;
%             end
%             catch err
%                 rcaExtra_displayError(err);
%         end
        set(ebh(c), 'color', colors(c, :));
    end
    title('Latency Estimate', 'Interpreter', 'tex');  
    if ~isempty(labels)
        legend([p{:}], labels{:}, 'Interpreter', 'none'); 
    end
    try
        xticks(1:nF);
        xticklabels(xlabels);
    catch
        xticks(1:nF);        
        xlabel(xlabels);
    end
    %square axes
    xlim([0, nF + 1]);
    yLims_curr = ylim(h);
    % increase range by 10%
    yRange = diff(yLims_curr);
    ylim([yLims_curr(1) - 0.1*yRange, yLims_curr(2) + 0.1*yRange]);
end