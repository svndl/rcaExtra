function figureHandles = rcaExtra_plotWaveforms(varargin)

% function plots group waveforms against each other for each condition if
% there's more than one group in varargin is present 

% if varargin is one structure, all conditions will be plotted

    nItems = nargin;
    groups = varargin;
         
    %% argcheck 1, make sure we have same number of conditions and RCs to loop over
    nRCs = unique(cellfun(@(x) numel(x.rcsToPlot), groups, 'uni', true));
    nPages = unique(cellfun(@(x) numel(x.cndsToPlot), groups, 'uni', true));
    
    % same x and y-labels for all data plots
    
    
    xLabel = groups{1}.xDataLabel;
    yLabel = groups{1}.yDataLabel;
    timecourse = groups{1}.xDataValues;
    
    if (numel(nRCs) > 1 || numel(nPages) > 1)
        disp('Number of conditions or RCs to use must be the same for each dataArray, quitting \n');
        return;
    end    
    figureHandles = gobjects(nRCs, nPages);
    
    try
        % each RC to plot would yield a new figure
        for rc = 1:nRCs           
            legendLabels = cell(nPages, 1);
            legendHandles = cell(nPages, 1);
            
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
                    legendLabels{ni} = sprintf('%s %s RC %d', groupLabel, conditionLabel, rcIdx);
                    
                    cndColor = groups{ni}.conditionColors(np, :);
                    % convert to microvolts                 
                    groupMu = 1e+06*squeeze(groups{ni}.dataToPlot.mu(:, rcIdx, cndIdx));
                    groupStd = 1e+06*squeeze(groups{ni}.dataToPlot.s(:, rcIdx, cndIdx));
                    
                    h = shadedErrorBar(timecourse', ...
                        groupMu, groupStd, ...
                        {'Color', cndColor, 'LineWidth',  groups{ni}.LineWidths}); hold on;
                    legendHandles{ni} = h.mainLine;
                    
%                     if (isfield(groups{ni}, 'statData'))
%                         significance_RC = groups{ni}.statData.sig(:, rc, ni);
%                         pValues = groups{ni}.statData.pValues(:, rc, ni);
%             
%                         plot_addStatsBar_time(gca, pValues, significance_RC, timecourse');
%                     end
                    
                end
                % update axes, vert limits, add legends
                figureHandles(rc, np).Name = sprintf('Waveforms RC %d', rc);
                xlabel(xLabel);
                try
                    legend([legendHandles{:}], legendLabels{:}, ...
                        'Interpreter', 'none',  'FontSize', 30, 'EdgeColor', 'none', 'Color', 'none');
                catch
                    legend([legendHandles{ni}], legendLabels{ni}, ...
                        'Interpreter', 'none',  'FontSize', 30, 'EdgeColor', 'none', 'Color', 'none');                    
                end
                %currYLimit = ylim(gca);
                %ylim([0, 1.2*currYLimit(2)]);
                set(gca,'FontSize', 30, 'fontname', 'helvetica', 'FontAngle', 'italic');
                ylabel(yLabel);
            end
        end
    catch err
        rcaExtra_displayError(err)
    end
    % link axes
    
    allaxes = arrayfun(@(x) get(x, 'CurrentAxes'), figureHandles, 'uni', true);
    linkaxes(allaxes(:), 'xy');    
end

