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
    errorBarOpts = {'LineStyle', 'none', 'LineWidth', 2, 'MarkerSize', 12, 'CapSize', 0};
        
    sigSaturation = 0.5;
    
    if (nCnd > 1)
        err_Lo = squeeze(errs(:, :, 1));
        err_Hi = squeeze(errs(:, :, 2));
    else
        err_Lo = squeeze(errs(:, 1));
        err_Hi = squeeze(errs(:, 2));   
    end
    
    % display all errormarkers first to store legend info
    ebh_sig = errorbar(x, values_unwrapped, err_Lo, err_Hi, ...
        errorBarOpts{:}); hold on;
   
    
    if (nCnd > 1)
        % for two conditions, compute latencies and display
        % regression line. Shade non-significant frequencies
           
        for nc = 1:nCnd
            color1 = colors(:, nc);
            color0 = color1 + (1 - color1)*(1 - sigSaturation);
                    
            nsigF = frequencies(~significance);
            nsigVals =  values_unwrapped(~significance, nc)';
            
            % color significant (all) markers
            set(ebh_sig(nc), 'color', color1, 'Marker', markerOpts{1}, ...
                'MarkerFaceColor', color1, 'MarkerEdgeColor', color1);
            
            % saturate non-significant, if not empty
            try
                ebh_nsig = errorbar(nsigF, nsigVals, err_Lo(~significance, nc)', err_Hi(~significance, nc)', ...
                    errorBarOpts{:}); hold on;   
                set(ebh_nsig, 'color', color0, 'Marker', markerOpts{1}, ...
                    'MarkerFaceColor', color0, 'MarkerEdgeColor', color0);
            catch err
                rcaExtra_displayError(err)
            end
            
            % fit regression line for all points
            [Pc, ~] = polyfit(x(:, nc), values_unwrapped(:, nc), 1);    
            yfit = Pc(1)*x(:, nc) + Pc(2);
    
            % display slope
            latency = 1000*Pc(1)/(2*pi);    
            d = (yfit - values_unwrapped(:, nc)).^2;
            dMs = 1000*d/(2*pi);
        
            %dd = sqrt(sum(d)/(nF - 2)); 
            dd = sqrt(sum(dMs)/(nF - 2)); 
            
            % compute middle point for values
            middle = mean(values_unwrapped(:, nc));
            t1 = text(mean(x(:, 1)), middle, sprintf('%.2f \\pm %.1f (msec)', latency, dd), ...
                'FontSize', 30, 'Interpreter', 'tex', 'color',  color0); hold on
            % alternate filled/unfilled
            markerStyle = strcat(':');
            plot(gca, x(:, nc), yfit, markerStyle, 'LineWidth', 4, 'color', color0); hold on;       
        end
    else
        % if there's one condition, compute latency estimate 
        % only if there are 2 or more significant freqencies
        % 
        
        color1 = colors(:, 1);
        color0 = color1 + (1 - color1)*(1 - sigSaturation);
        
        nsigF = frequencies(~significance);
        nsigVals =  values_unwrapped(~significance, 1)';
        
        % color significant bar
        set(ebh_sig, 'color', color1, 'Marker', markerOpts{1}, ...
            'MarkerFaceColor', color1, 'MarkerEdgeColor', color1);
        
        % saturate non-significant points
        if (~isempty(nsigF))       
            ebh_nsig = errorbar(nsigF, nsigVals, err_Lo(~significance)', err_Hi(~significance)', ...
                errorBarOpts{:}); hold on;   
            set(ebh_nsig, 'color', color0, 'Marker', markerOpts{1}, ...
                'MarkerFaceColor', color0, 'MarkerEdgeColor', color0);
        end
        % interpolate over number of significant frequencies
        sigF = frequencies(significance);
        sigVals = values_unwrapped(significance, 1)';
        nFSig = numel(sigF);
        
        if (nFSig > 1)
            [Pc, ~] = polyfit(sigF, sigVals, 1);    
            yfit = Pc(1)*sigF + Pc(2);
            % for plotting
            yPlot = Pc(1)*x(:, 1) + Pc(2);
            % display slope
            latency = 1000*Pc(1)/(2*pi);    
            d = (yfit - sigVals).^2;
            dMs = 1000*d/(2*pi);
        
            %dd = sqrt(sum(d)/(nF - 2)); 
            dd = sqrt(sum(dMs)/(nFSig - 2)); 
            
            % compute middle point for values
            middle = mean(values_unwrapped(significance, 1));
            t1 = text(mean(x), middle, sprintf('%.2f \\pm %.1f (msec)', latency, dd), ...
            'FontSize', 30, 'Interpreter', 'tex', 'color',  color1); hold on
            % alternate filled/unfilled
            markerStyle = strcat(':');          
            plot(gca, x(:, 1), yPlot, markerStyle, 'LineWidth', 2, 'color', color1); hold on;            
        end        
    end
    
    legend(ebh_sig(:), labels{:}, 'Interpreter', 'none', 'FontSize', 30, ...
        'EdgeColor', 'none', 'Color', 'none');
    
    title('Latency Estimate', 'Interpreter', 'tex');  
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