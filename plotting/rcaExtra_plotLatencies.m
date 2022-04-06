function figureHandles = rcaExtra_plotLatencies(varargin)
    
% function plots amplitudes against each other per condition
% Alexandra Yakovleva, Stanford University 2021

    nGroups = nargin;
    groups = varargin;
    
       
    %% argcheck 1, make sure we have same number of conditions and RCs to loop over
    nRCs = unique(cellfun(@(x) numel(x.rcsToPlot), groups, 'uni', true));
    nCnds = unique(cellfun(@(x) numel(x.cndsToPlot), groups, 'uni', true));
    
    % same x and y-labels for all data plots
    
    xLabel = groups{1}.xDataLabel;
    xValues = groups{1}.xDataValues;
    
    yLabel = 'Radians, \pi';
    
    if (numel(nRCs) > 1 || numel(nCnds) > 1)
        disp('Number of conditions or RCs to use must be the same for each dataArray, quitting \n');
        return;
    end
    % labels for x-axis
       
    % adjusting bar width according to number of conditions
    nPages = nCnds;
    figureHandles = gobjects(nRCs, nPages);
    try
        for rc = 1:nRCs
            legendLabels = cell(nGroups, 1);
            legendHandles = cell(nGroups, 1);
            for nc = 1:nCnds
                %for each RC/condition, new figure                
                figureHandles(rc, nc) = figure('units','normalized','outerposition',[0 0 1 1]);
                for ng = 1:nGroups
                    
                    % index
                    rcIdx = groups{ng}.rcsToPlot(rc);
                    cndIdx = groups{ng}.cndsToPlot(nc);
                    
                    % char
                    groupLabel = groups{ng}.dataLabel{:};
                    conditionLabel = groups{ng}.conditionLabels{nc};
                    
                    % data values, errors, significance
                    %freqVals = cellfun(@(x) str2double({x(1:end-2)}), xLabel, 'uni', true);
                    freqVals = xValues;
                    
                    dataToPlot_lat = groups{ng}.dataToPlot.phase(:, rcIdx, cndIdx, :);
                    
                    %try-catch for significant/stat testing  
                    try
                        significance = boolean(groups{ng}.statData.sig(:, rcIdx, cndIdx));
                    catch 
                        disp('No significance found, all data points would be trated as significant');
                        significance = ones(size(dataToPlot_lat));
                    end
                    
                    
                    % labels for legend/figure title
                    legendLabels{ng} = sprintf('%s %s RC %d', groupLabel, conditionLabel, rcIdx);
                    
                    % significant color
                    cndColor = groups{ng}.conditionColors(nc, :);
                    %patchColor = cndColor + (1 - cndColor)*(1 - groups{ng}.patchSaturation);
                    
                    % non-significant color
                    satColor = cndColor + (1 - cndColor)*(1 - groups{ng}.significanceSaturation);
                    %patchSatColor = satColor + (1 - satColor)*(1 - groups{ng}.patchSaturation);
                    
                    if (~isfield(groups{ng}, 'unwrapAngles'))
                    % unwrap before plotting and fitting linear function                    
                        valsUnwrapped = unwrapPhases(dataToPlot_lat);
                    else
                        valsUnwrapped = dataToPlot_lat;
                    end

                    
                    % compute slope and error estimate for significant 
                    
                    freqsSig = freqVals(significance>0);
                    phasesSig = valsUnwrapped(significance>0);
                    
                    % if we have at least two signifant harmonic multiples:
                    if (numel(freqsSig) > 1)                   
                        [Pc, ~] = polyfit(freqsSig, phasesSig, 1);
                        yfit = Pc(1)*freqsSig + Pc(2);
                        
                        yPlot = Pc(1)*freqVals + Pc(2);
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
                        plot(freqVals, yPlot, '--', 'LineWidth', groups{ng}.LineWidths, 'color', cndColor); hold on;                        
                    end
                    
                    % compile marker options
                    switch (groups{ng}.markerStyles{nc})
                        case 'filled'
                            MarkerEdgeColor = cndColor;
                            MarkerEdgeSatColor = satColor;
                        case 'open'
                            MarkerEdgeColor = 'none';
                            MarkerEdgeSatColor = 'none';
                    end
                    markerOpts = {'MarkerSize', groups{ng}.markerSize};

                    % plot all values (significat settings)
                    dataToPlot_larErr = squeeze(groups{ng}.dataToPlot.errP(:, rcIdx, cndIdx, :));                    
                    try                    
                        legendHandles{ng} = errorbar(freqVals, valsUnwrapped, ...
                            dataToPlot_larErr(:, 1), dataToPlot_larErr(:, 2),...   
                            groups{ng}.conditionMarkers{nc}, 'Color', cndColor, ...
                            'LineWidth', groups{ng}.LineWidths, ...
                            'LineStyle', 'none', 'CapSize', 0, ...
                            markerOpts{:}, ...
                            'MarkerEdgeColor', MarkerEdgeColor,...
                            'MarkerFaceColor', cndColor); hold on;        
                    catch err
                        rcaExtra_displayError(err);
                        % no significant values, pass error handle to
                        % non-significant
                        %
                    end
                    % fade non-significant phase values;
                    if (any(~significance))
                        
                        try
                            %legendHandles{ng} =
                            errorbar(freqVals(~significance), valsUnwrapped(~significance),...
                                dataToPlot_larErr(~significance, 1), dataToPlot_larErr(~significance, 2),...
                                groups{ng}.conditionMarkers{nc}, 'Color', satColor, ...
                                'LineWidth', groups{ng}.LineWidths, ...
                                'LineStyle', 'none', 'CapSize', 0, ...
                                markerOpts{:}, ...
                                'MarkerEdgeColor', MarkerEdgeSatColor,...
                                'MarkerFaceColor', satColor); hold on;
                        catch err
                            rcaExtra_displayError(err);
                        end
                    end
                end
                % update axes, vert limits, add legends
                figureHandles(rc, nc).Name = sprintf('Phase Values RC %d', rc);
                try
                    xticks(freqVals)
                    %set(gca, 'XTick', 1:numel(xLabel))
                    set(gca, 'XTickLabel', xLabel);
                catch
                    xlabel(xLabel);
                end
                currXLimit = xlim(gca);
                xlim([0, currXLimit(2)]);
                legend([legendHandles{:}], legendLabels{:}, ...
                    'Interpreter', 'none',  'FontSize', 30, 'EdgeColor', 'none', 'Color', 'none');
                
                currYLimit = ylim(gca);
                ylim([0, 1.2*currYLimit(2)]);
                set(gca,'FontSize', 30, 'fontname', 'helvetica', 'FontAngle', 'italic');
                % use radians
                ylabel(yLabel);
                pbaspect(gca, [1 1 1]);
            end 
        end
    catch err
        rcaExtra_displayError(err);
    end
    % link axes
    allaxes = arrayfun(@(x) get(x, 'CurrentAxes'), figureHandles, 'uni', true);
    linkaxes(allaxes(:), 'xy');
end