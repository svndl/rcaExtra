function figureHandles = rcaExtra_plotPolarAmp(varargin)
% function plots Amplitude and loliplots (1F, 2F)

    nGroups = nargin;
    groups = varargin;
    

    %% argcheck 1, make sure we have same number of conditions and RCs to loop over
    nRCs = unique(cellfun(@(x) numel(x.rcsToPlot), groups, 'uni', true));
    nCnds = unique(cellfun(@(x) numel(x.cndsToPlot), groups, 'uni', true));
    
    % same x and y-labels for all data plots
    
    xLabel = groups{1}.xDataLabel;
    yLabel = groups{1}.yDataLabel;

    nPages = nCnds;
    figureHandles = gobjects(nRCs, nPages);
    
    if (numel(nRCs) > 1 || numel(nCnds) > 1)
        disp('Number of conditions or RCs to use must be the same for each dataArray, quitting \n');
        return;
    end
    
    
    %% bars width
    barWidthBase = nGroups;
    groupWidth = max(0.8, barWidthBase/(barWidthBase + 1.5));
    nF = numel(xLabel);
    xBarsPos = zeros(nF, barWidthBase);
    
    % xE will indicate position and width of the bars 
    for b = 1:barWidthBase
        xBarsPos(:, b) = (1:nF) - groupWidth/2 + (2*b -1 )*groupWidth / (2*barWidthBase);
    end
    
    % labels for x-axis
    try
        for rc = 1:nRCs
            legendLabels = cell(nGroups, 1);
            legendHandles = cell(nGroups, 1);
            ax_b = cell(nCnds, 1);
            for nc = 1:nCnds
                %for each RC/condition, new figure                
                figureHandles(rc, nc) = figure('units','normalized','outerposition',[0 0 1 1]);
                
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
                    dataToPlot_lat = groups{ng}.dataToPlot.phase(:, rcIdx, cndIdx, :);
                    dataToPlot_Err = groups{ng}.dataToPlot.ellipseErr{cndIdx}(:, rcIdx);
                    dataToPlot_ampErr = groups{ng}.dataToPlot.errA(:, rcIdx, cndIdx, :);
                    % labels for legend/figure title
                    legendLabels{ng} = sprintf('%s %s RC %d', groupLabel, conditionLabel, rcIdx);
                    cndColor = groups{ng}.conditionColors(nc, :);
                    patchColor = cndColor + (1 - cndColor)*(1 - groups{ng}.patchSaturation);    

                    %% plot bars
                    ax_b{nc} = subplot(2, 2, [1 3]);
                    pbaspect(ax_b{nc}, [1 2 1]);

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
                    catch err
                        rcaExtra_displayError(err);
                        % no significant values, pass error handle to
                        % non-significant
                        %
                    end

                    %nFreqs = size(dataToPlot_amp, 1);
                    nFreqs = 2;
                    %% plot loliplots
                    try              
                        ax_f = cell(nFreqs, 1);
                        for nf = 1:nFreqs
                            % plot at subplot (2, 2, 2) and (2,2, 4)
                            ax_f{nf} = subplot(2, 2, 2*nf, 'Parent', figureHandles(rc, nc));
                                
                            alpha = dataToPlot_lat(nf);
                            L = dataToPlot_amp(nf);
                            x = L.*cos(alpha);
                            y = L.*sin(alpha);
                            e_x = 0;
                            e_y = 0;
                            try
                                e0 = dataToPlot_Err{nf};
                            catch
                                e0 = ellipseCalc(nf);
                            end
                            if (~isempty(e0))
                                e_x = e0(:, 1) + x;
                                e_y = e0(:, 2) + y;
                            end
                            props = { 'linewidth', 2, 'color', cndColor};
                            errLine = line(e_x, e_y, 'LineWidth', 2); hold on;
                            set(errLine, 'color', cndColor);
                            legendHandles{ng} = plot(ax_f{nf}, [0, x], [0, y], props{:}); hold on;
                            title(xLabel(nf), 'Interpreter', 'none');
                            %pbaspect(ax{nf}, [1 1 1]);
                        end
                   
                    catch err
                        rcaExtra_displayError(err)
                        % 
                    end
                end
                %% legends and axes appearances for lolliplots
                cellfun(@(x) setAxisAtTheOrigin(x), ax_f, 'uni', false);
                
                setArgs = {'FontSize', 30, 'fontname', 'helvetica', 'FontAngle', 'italic'};
                cellfun(@(x) set(x, setArgs{:}), ax_f, 'uni', false);
                %cellfun(@(x) pbaspect(x, [1 1 1]), ax, 'uni', false);
                
                legendArgs = { 'Interpreter', 'none', 'FontSize', 30, ...
                                    'EdgeColor', 'none', 'Color', 'none'};
                
                % add legend to first axes only
                
                legend([legendHandles{:}], legendLabels{:}, legendArgs{:});
                figureHandles(rc, nc).Name = sprintf('Lolliplot Values RC %d', rc);
                
                %% legends and axes appearances for barplots
                
                setArgs = {'FontSize', 30, 'fontname', 'helvetica', 'FontAngle', 'italic'};
                cellfun(@(x) set(x, setArgs{:}), ax_b, 'uni', false);
                
                currYLimit = ylim(ax_b{1});
                ylim(ax_b{1}, [0, currYLimit(2)]);

                %cellfun(@(x) pbaspect(x, [1 1 1]), ax, 'uni', false);
                legend([legendHandles{:}], legendLabels{:}, ...
                    'Interpreter', 'none',  'FontSize', 30, 'EdgeColor', 'none', 'Color', 'none');


                try
                    cellfun(@(x) set(x, 'XTick', 1:numel(xLabel)), ax_b, 'uni', false);
                    cellfun(@(x) set(x, 'XTickLabel', xLabel), ax_b, 'uni', false);                    
                catch
                end
            end
            linkaxes([ax_b{:}], 'xy');         
        end
    catch err
        rcaExtra_displayError(err)       
    end
end