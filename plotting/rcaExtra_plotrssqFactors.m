function figureHandles = rcaExtra_plotrssqFactors(varargin)
% function will plot rssq factors 
    groupsToPlot = varargin;
    
    % if one group, split plot container by conditions and plot as if each condition was a group
    
    if nargin == 1
        
        groupsToPlot = rcaExtra_splitPlotDataByCondition(groupsToPlot);
        
    end

    nGroups = nargin;
    groups = groupsToPlot;
    
     
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
    
    % specify bar width    
    barWidthBase = nGroups;
    nPages = nCnds;
    nItems = nGroups;
          
    % adjusting bar width according to number of conditions
    groupWidth = min(0.8, barWidthBase/(barWidthBase + 1.5));
    nF = numel(xLabel);
    
    xBarsPos = zeros(nF, barWidthBase);
    
    % xE will indicate position and width of the bars 
    for b = 1:barWidthBase
        xBarsPos(:, b) = (1:nF) - groupWidth/2 + (2*b -1 )*groupWidth / (2*barWidthBase);
    end
    
    figureHandles = gobjects(nRCs, nPages);
    try
        % each RC to plot would yield a new figure
        for rc = 1:nRCs           
            legendLabels = cell(nGroups, 1);
            legendHandles = cell(nGroups, 1);
            
            % nPages is the number of conditions for two or more groups
            % for one group, nPages is ONE (each condition treated as group)
            
            for np = 1:nPages                
                % create figure page            
                figureHandles(rc, np) = figure('units','normalized','outerposition',[0 0 1 1]);
                % nItems is the number of groups, for two or more input arguments;
                % nItems is the number of , for two or more input arguments;
                for ni = 1:nItems
                    % extract data index and data labels
                    
                    % double
                    rcIdx = groups{ni}.rcsToPlot(rc);
                    cndIdx = groups{ni}.cndsToPlot(np);
                    
                    % char
                    groupLabel = groups{ni}.dataLabel{:};
                    conditionLabel = groups{ni}.conditionLabels{np};
                    
                    % data values, errors, significance
                    xPos = xBarsPos(:, ni);
                    dataToPlot_amp = groups{ni}.dataToPlot.amp(:, rcIdx, cndIdx, :);
                    dataToPlot_ampErr = groups{ni}.dataToPlot.errA(:, rcIdx, cndIdx, :);
                    
                    % try-catch for stats, if they are not added  
                    try
                        significance = boolean(groups{ni}.statData.sig(:, rcIdx, cndIdx)); 
                    catch 
                        disp('No significance found, all data points would be trated as significant');
                        significance = ones(size(dataToPlot_amp));
                    end
                        
                    % labels for legend/figure title
                    legendLabels{ni} = sprintf('%s %s RC %d', groupLabel, conditionLabel, rcIdx);
                    
                    % significant color
                    cndColor = groups{ni}.conditionColors(np, :);
                    patchColor = cndColor + (1 - cndColor)*(1 - groups{ni}.patchSaturation);
                    
                    % non-significant color
                    satColor = cndColor + (1 - cndColor)*(1 - groups{ni}.significanceSaturation);
                    patchSatColor = satColor + (1 - satColor)*(1 - groups{ni}.patchSaturation);
                    
                    % plot all amplitudes (significat settings)
                    try
                        bar(xPos, dataToPlot_amp, ...
                            'BarWidth', 0.8*groupWidth/nGroups, ...
                            'LineWidth', groups{ni}.LineWidths, ...
                            'EdgeColor', cndColor, ...
                            'FaceColor', patchColor, 'FaceAlpha',0.3); hold on;
                        
                        legendHandles{ni} = errorbar(xPos, dataToPlot_amp,...
                            dataToPlot_ampErr(:, 1), dataToPlot_ampErr(:, 2),...
                            'Color', cndColor, ...
                            'LineWidth', groups{ni}.LineWidths, ...
                            'LineStyle', 'none'); hold on;
                    catch err
                        rcaExtra_displayError(err);
                        % no significant values, pass error handle to
                        % non-significant
                        %
                    end
                end
                % update axes, vert limits, add legends
                figureHandles(rc, np).Name = sprintf('Amplitude Values RC %d', rc);
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
                pbaspect(gca, [1 2 1]);
            end 
        end
    catch err
        rcaExtra_displayError(err);
    end
    allaxes = arrayfun(@(x) get(x, 'CurrentAxes'), figureHandles, 'uni', true);
    linkaxes(allaxes(:), 'xy');    
end