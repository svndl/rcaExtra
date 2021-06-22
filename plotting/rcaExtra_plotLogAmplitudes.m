function figureHandles = rcaExtra_plotSignificantLogAmplitudes(varargin)
    
% function plots amplitudes against each other

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
    
    figureHandles = cell(nRCs, nCnds);
    try
        for rc = 1:nRCs
            legendLabels = cell(nGroups, 1);
            legendHandles = cell(nGroups, 1);
            for nc = 1:nCnds
                %for each RC/condition, new figure                
                figureHandles{rc, nc} = figure('units','normalized','outerposition',[0 0 1 1]);
                for ng = 1:nGroups
                    % extract data index and data labels
                    
                    % double
                    rcIdx = groups{ng}.rcsToPlot(rc);
                    cndIdx = groups{ng}.cndsToPlot(nc);
                    
                    % char
                    groupLabel = groups{ng}.dataLabel{:};
                    conditionLabel = groups{ng}.conditionLabels{nc};
                    
                    % data values, errors, significance
                    freqVals = cellfun(@(x) str2double({x(1:end-2)}), xLabel, 'uni', true);
                    dataToPlot_amp = groups{ng}.dataToPlot.amp(:, rcIdx, cndIdx, :);
                    dataToPlot_ampErr = groups{ng}.dataToPlot.errA(:, rcIdx, cndIdx, :);
                    
                    % try-catch for stats, if they are not added  
                    try
                        significance = boolean(groups{ng}.statData.sig(:, rcIdx, cndIdx)); 
                    catch 
                        disp('No significance found, all data points will be treated as significant');
                        significance = ones(size(dataToPlot_amp));
                    end
                        
                    % labels for legend/figure title
                    legendLabels{ng} = sprintf('%s %s RC %d', groupLabel, conditionLabel, rcIdx);
                    
                    % significant color
                    cndColor = groups{ng}.conditionColors(nc, :);
                    
                    % non-significant color
                    satColor = cndColor + (1 - cndColor)*(1 - groups{ng}.significanceSaturation);
                    
                    % plot all amplitudes (significat settings)
                    
                    switch (groups{ng}.markerStyles{nc})
                        case 'filled'
                            MarkerEdgeColor = cndColor;
                        case 'open'
                            MarkerEdgeColor = 'none';
                    end
                    markerOpts = {'MarkerSize', groups{ng}.markerSize};
                    MarkerType = groups{ng}.conditionMarkers{nc};
                    
                    %% fit significant amplitude and calculate slope
%                     freqsSig = freqVals(significance);
%                     ampsSig = dataToPlot_amp(significance);
%                     
%                     % if we have at least two signifant harmonic multiples:
%                     if (numel(freqsSig) > 1)                   
%                         [Pc, ~] = polyfit(freqsSig, ampsSig, 1);
%                         yfit = Pc(1)*freqsSig + Pc(2);
%                         
%                         yPlot = Pc(1)*freqVals + Pc(2);
%                         %
%                         slopeEstimate = 1000*Pc(1)/(2*pi);
%                         d = (yfit(:) - ampsSig(:)).^2;
%                         dMs = 1000*d/(2*pi);
%                         
%                         %dd = sqrt(sum(d)/(nF - 2));
%                         slopeError = sqrt(sum(dMs)/(numel(freqsSig) - 2));
%                         middle_y = mean(dataToPlot_amp);
%                         middle_x = round(numel(dataToPlot_amp)/2) + 1;
%                         % add estimates
%                         t1 = text(middle_x, middle_y, sprintf('%.2f \\pm %.1f (msec)', slopeEstimate, slopeError), ...
%                             'FontSize', 30, 'Interpreter', 'tex', 'color',  cndColor); hold on;
%                         % display line full color
%                         semilogy(freqVals, yPlot, '--', 'LineWidth', groups{ng}.LineWidths, 'color', cndColor); hold on;                        
%                     end

                    try
                        if (sum(significance))                        
                            semilogy(freqVals, dataToPlot_amp, MarkerType, ...
                                'LineWidth', groups{ng}.LineWidths, ...
                                markerOpts{:}, ...
                                'MarkerEdgeColor', MarkerEdgeColor,...
                                'MarkerFaceColor', cndColor); hold on;        
                    
                            legendHandles{ng} = errorbar(freqVals, dataToPlot_amp,...
                                dataToPlot_ampErr(:, 1), dataToPlot_ampErr(:, 2),...   
                                'Color', cndColor, ...
                                'LineWidth', groups{ng}.LineWidths, ...
                                'LineStyle', 'none'); hold on; 
                        end
                    catch err
                        rcaExtra_displayError(err)
                            % no significant values, pass error handle to
                            % non-significant 
                            % 
                    end
                   % saturate non-significant amplitudes;
                   try
                       if (~sum(~significance))
                           semilogy(freqVals(~significance), dataToPlot_amp(~significance), ...
                               'LineWidth', groups{ng}.LineWidths, ...
                                markerOpts{:}, ...
                                'MarkerEdgeColor', satColor,...
                                'MarkerFaceColor', satColor); hold on;        
                       
                       % do not store non-significant error intervals
                       
                            errorbar(freqVals(~significance), dataToPlot_amp(~significance),...
                                dataToPlot_ampErr(~significance, 1), dataToPlot_ampErr(~significance, 2),...
                                'Color', satColor, ...
                                'LineWidth', groups{ng}.LineWidths, ...
                                'LineStyle', 'none'); hold on;
                       end
                   catch err
                       rcaExtra_displayError(err);
                   end
                end
                % update axes, vert limits, add legends
                figureHandles{rc, nc}.Name = sprintf('Amplitude Values RC %d', rc);
                xticks(freqVals)
                set(gca, 'XTickLabel', xLabel);
                legend([legendHandles{:}], legendLabels{:}, ...
                    'Interpreter', 'none',  'FontSize', 30, 'EdgeColor', 'none', 'Color', 'none');
                
                currYLimit = ylim(gca);
                ylim([0, 1.2*currYLimit(2)]);
                set(gca,'FontSize', 30, 'fontname', 'helvetica', 'FontAngle', 'italic');
                ylabel(yLabel);
                pbaspect(gca, [1 1 1]);
            end 
        end
    catch err
        rcaExtra_displayError(err);
    end
end