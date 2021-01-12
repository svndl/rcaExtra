function figureHandles = rcaExtra_plotSignificantAmplitudes(varargin)
    
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
    groupWidth = min(0.8, nGroups/(nGroups + 1.5));
    nF = numel(xLabel);
    
    xBarsPos = zeros(nF, nGroups);
    
    % xE will indicate position and width of the bars 
    for b = 1:nGroups
        xBarsPos(:, b) = (1:nF) - groupWidth/2 + (2*b -1 )*groupWidth / (2*nGroups);
    end   
    figureHandles = cell(nRCs, nCnds);
    try
        for rc = 1:nRCs
            legendLabels = cell(nGroups, 1);
            legendHandles = cell(nGroups, 1);
            for nc = 1:nCnds
                %for each RC/condition, new figure                
                figureHandles{rc, nc} = figure;
                for ng = 1:nGroups
                    % extract data index and data labels
                    
                    % double
                    rcIdx = groups{ng}.rcsToPlot(rc);
                    cndIdx = groups{ng}.cndsToPlot(nc);
                    
                    % char
                    groupLabel = groups{ng}.dataLabel{:};
                    conditionLabel = groups{ng}.conditionLabels{nc};
                    
                    % data values, errors, significance
                    xPos = xBarsPos(:, ng);
                    dataToPlot_amp = groups{ng}.dataToPlot.amp(:, rcIdx, cndIdx, :);
                    dataToPlot_ampErr = groups{ng}.dataToPlot.errA(:, rcIdx, cndIdx, :);
                    significance = boolean(groups{ng}.statData.sig(:, rcIdx, cndIdx));
                    
                    % labels for legend/figure title
                    legendLabels{ng} = sprintf('%s %s RC %d', groupLabel, conditionLabel, rcIdx);
                    
                    % significant color
                    cndColor = groups{ng}.conditionColors(nc, :);
                    patchColor = cndColor + (1 - cndColor)*(1 - groups{ng}.patchSaturation);
                    
                    % non-significant color
                    satColor = cndColor + (1 - cndColor)*(1 - groups{ng}.significanceSaturation);
                    patchSatColor = satColor + (1 - satColor)*(1 - groups{ng}.patchSaturation);
                    
                    % plot all amplitudes (significat settings)
                    try
                        bar(xPos, dataToPlot_amp, ...
                            'BarWidth', 0.8*groupWidth/nGroups, ...
                            'LineWidth', groups{ng}.LineWidths, ...
                            'EdgeColor', cndColor, ...
                            'FaceColor', patchColor, 'FaceAlpha',0.3); hold on;
                    
                        legendHandles{ng} = errorbar(xPos, dataToPlot_amp,...
                            dataToPlot_ampErr(:, 1), dataToPlot_ampErr(:, 2),...   
                            'Color', cndColor, ...
                            'LineWidth', groups{ng}.LineWidths, ...
                            'LineStyle', 'none'); hold on;        
                    catch 
                        % no significant values, pass error handle to
                        % non-significant 
                        % 
                    end
                   % saturate non-significant amplitudes;
                   try
                       bar(xPos(~significance), dataToPlot_amp(~significance), ...
                           'BarWidth', 0.8*groupWidth/nGroups, ...
                           'LineWidth', groups{ng}.LineWidths, ...
                           'EdgeColor', satColor, ...
                           'FaceColor', patchSatColor, 'FaceAlpha',0.3); hold on;
                       
                        legendHandles{ng} = errorbar(xPos(~significance), dataToPlot_amp(~significance),...
                           dataToPlot_ampErr(~significance, 1), dataToPlot_ampErr(~significance, 2),...
                           'Color', satColor, ...
                           'LineWidth', groups{ng}.LineWidths, ...
                           'LineStyle', 'none'); hold on;
                   catch
                   end
                end
                % update axes, vert limits, add legends
                figureHandles{rc, nc}.Name = sprintf('Amplitude Values RC %d', rc);
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