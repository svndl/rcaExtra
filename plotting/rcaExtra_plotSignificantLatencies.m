function figureHandles = rcaExtra_plotSignificantLatencies(varargin)
    
% function plots amplitudes against each other
% tests for significanse when varargin is 2 plot containters

    nGroups = nargin;
    groups = varargin;
    
    figureHandles = cell(nGroups, 1);
       

    %% argcheck 1, make sure we have same number of conditions and RCs to loop over
    nRCs = unique(cellfun(@(x) numel(x.rcsToPlot), groups, 'uni', true));
    nCnds = unique(cellfun(@(x) numel(x.cndsToPlot), groups, 'uni', true));
    
    % same x and y-labels for all data plots
    
    xLabel = groups{1}.xDataLabel;
    yLabel = groups{1}.yDataLabel;
    
    if (numel(nRCs) > 1 || numel(nCnds) > 1)
        disp('Number of conditions or RCs to use must be the same for each dataArray, quitting \n');
        return;
    end
    % labels for x-axis
       
    % adjusting bar width according to number of conditions
    figureHandles = cell(nRCs, nCnds);
    try
        for rc = 1:nRCs
            legendLabels = cell(nGroups, 1);
            legendHandles = cell(nGroups, 1);
            for nc = 1:nCnds
                %for each RC/condition, new figure                
                figureHandles{rc, nc} = figure;
                for ng = 1:nGroups
                    
                    % index
                    rcIdx = groups{ng}.rcsToPlot(rc);
                    cndIdx = groups{ng}.cndsToPlot(nc);
                    
                    % char
                    groupLabel = groups{ng}.dataLabel{:};
                    conditionLabel = groups{ng}.conditionLabels{nc};
                    
                    % data values, errors, significance
                    freqVals = cellfun(@(x) str2double(x(:, end-2)), xLabel, 'uni', true);
                    dataToPlot_lat = groups{ng}.dataToPlot.phase(:, rcIdx, cndIdx, :);
                    significance = boolean(groups{ng}.statData.sig(:, rcIdx, cndIdx));
                    
                    % labels for legend/figure title
                    legendLabels{ng} = sprintf('%s %s RC %d', groupLabel, conditionLabel, rcIdx);
                    
                    % significant color
                    cndColor = groups{ng}.conditionColors(nc, :);
                    patchColor = cndColor + (1 - cndColor)*(1 - groups{ng}.patchSaturation);
                    
                    % non-significant color
                    satColor = cndColor + (1 - cndColor)*(1 - groups{ng}.significanceSaturation);
                    patchSatColor = satColor + (1 - satColor)*(1 - groups{ng}.patchSaturation);
                    
                    % unwrap before plotting and fit linear function with                   
                    valsUnwrapped = unwrapPhases(dataToPlot_lat);
                    
                    % compute slope and error estimate for significant 
                    
                    freqsSig = freqVals(significance);
                    phasesSig = valsUnwrapped(significance);
                    
                    % if we have at least two signifant harmonic multiples:
                    if (numel(freqsSig) > 1)                   
                        [Pc, ~] = polyfit(freqsSig, phasesSig, 1);
                        yfit = Pc(1)*freqsSig + Pc(2);
                        
                        %
                        latencyEstimate = 1000*Pc(1)/(2*pi);
                        d = (yfit(:) - phasesSig(:)).^2;
                        dMs = 1000*d/(2*pi);
                        
                        %dd = sqrt(sum(d)/(nF - 2));
                        latencyError = sqrt(sum(dMs)/(numel(freqsSig) - 2));
                        middle_y = mean(valsUnwrapped);
                        middle_x = round(numel(valsUnwrapped)/2) + 1;
                        % add estimates
                        t1 = text(middle_x, middle_y, sprintf('%.2f \\pm %.1f (msec)', latencyEstimate, latencyError), ...
                            'FontSize', 30, 'Interpreter', 'tex', 'color',  cndColor); hold on;
                        % display line full color
                        plot(freqsSig, yfit, 'LineWidth', groups{ng}.LineWidths, 'color', cndColor); hold on;                        
                    end
                    
                    % plot all values (significat settings)
                    dataToPlot_larErr = squeeze(groups{ng}.dataToPlot.errP(:, rcIdx, cndIdx, :));                    
                    try                    
                        legendHandles{ng} = errorbar(freqVals, valsUnwrapped, ...
                            dataToPlot_larErr(:, 1), dataToPlot_larErr(:, 2),...   
                            'Color', cndColor, ...
                            'LineWidth', groups{ng}.LineWidths, ...
                            'LineStyle', 'none'); hold on;        
                    catch 
                        % no significant values, pass error handle to
                        % non-significant 
                        % 
                    end
                   % saturate non-significant phase values;
                   try                       
                        legendHandles{ng} = errorbar(freqVals(~significance), valsUnwrapped(~significance),...
                           dataToPlot_larErr(~significance, 1), dataToPlot_larErr(~significance, 2),...
                           'Color', satColor, ...
                           'LineWidth', groups{ng}.LineWidths, ...
                           'LineStyle', 'none'); hold on;
                   catch
                   end
                end
                % update axes, vert limits, add legends
                figureHandles{rc, nc}.Name = sprintf('Phase Values RC %d', rc);
                try
                    set(gca, 'XTick', 1:numel(xLabel))
                    set(gca, 'XTickLabel', xLabel);
                catch
                    xlabel(xLabel);
                end
                legend([legendHandles{:}], legendLabels{:}, ...
                    'Interpreter', 'none',  'FontSize', 30, 'EdgeColor', 'none', 'Color', 'none');
                
                currYLimit = ylim(gca);
                ylim([0, 1.2*currYLimit(2)]);
                set(gca,'FontSize', 30, 'fontname', 'helvetica', 'FontAngle', 'italic');
                ylabel(yLabel);
                pbaspect(gca, [1 1 1]);
            end 
        end
    catch 
    end
end