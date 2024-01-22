function figureHandles = rcaExtra_plotLollipopsSubj(varargin)
% function plots loliplots against each other

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
    % labels for x-axis
    try
        for rc = 1:nRCs
            legendLabels = cell(nGroups, 1);
            legendHandles = cell(nGroups, 1);
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
                    dataToPlot_amp = groups{ng}.dataToPlot.amp(:, rcIdx, cndIdx, :);
                    dataToPlot_lat = groups{ng}.dataToPlot.phase(:, rcIdx, cndIdx, :);
                    dataToPlot_Err = groups{ng}.dataToPlot.ellipseErr{cndIdx}(:, rcIdx);
                    
                    % labels for legend/figure title
                    legendLabels{ng} = sprintf('%s %s RC %d', groupLabel, conditionLabel, rcIdx);
                    cndColor = groups{ng}.conditionColors(nc, :);
                    lineStyle = groups{ng}.lineStytles{nc};
                    
                    nFreqs = size(dataToPlot_amp, 1);
                    %nFreqs = 2;
                    % plot loliplots
                    subjsAmp_real = cat(3, groups{ng}.dataToPlot.subjsRe{:, cndIdx});
                    subjsAmp_imag = cat(3, groups{ng}.dataToPlot.subjsIm{:, cndIdx});

                    % subjAmps = sqrt(subjsAmp_real.^2 + subjsAmp_imag.^2);
                    % subjPhase = angle()
                    % subjAmps_to_plot = squeeze(subjAmps(:, rcIdx, :));
                    
                    try              
                        ax = cell(nFreqs, 1);
                        for nf = 1:nFreqs
                            ax{nf} = subplot(1, nFreqs, nf, 'Parent', figureHandles(rc, nc));
                                
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
                            props = { 'linewidth', 2, 'color', cndColor, 'LineStyle', lineStyle};
                            errLine = line(e_x, e_y, 'LineWidth', 2, 'LineStyle', lineStyle); hold on;
                            set(errLine, 'color', cndColor);
                            legendHandles{ng} = plot(ax{nf}, [0, x], [0, y], props{:}); hold on;
                            title(xLabel(nf), 'Interpreter', 'none');
                            %pbaspect(ax{nf}, [1 1 1]);
                            
                            %% compute subjs data
                            subjs_thisRC_nF_Real = squeeze(subjsAmp_real(nf, rcIdx, :));
                            subjs_thisRC_nF_Imag = squeeze(subjsAmp_imag(nf, rcIdx, :));
                            
                            subjs_amp = sqrt(subjs_thisRC_nF_Real.^2 + subjs_thisRC_nF_Imag.^2);
                            subjs_phase = angle(complex(subjs_thisRC_nF_Real, subjs_thisRC_nF_Imag));
                            
                            subjs_X = subjs_amp.*cos(subjs_phase);
                            subjs_Y = subjs_amp.*sin(subjs_phase);
                            ax_scatter = scatter(subjs_X, subjs_Y); hold on;
                            ax_scatter.Marker = 'x';
                            ax_scatter.LineWidth = 1;
                            ax_scatter.MarkerFaceColor = cndColor;
                            ax_scatter.MarkerEdgeColor = cndColor;
                                                 
                        end
                   
                    catch err
                        rcaExtra_displayError(err)
                        % 
                    end
                end
                % legends and axes appearance
                cellfun(@(x) setAxisAtTheOrigin(x), ax, 'uni', false);
                
                setArgs = {'FontSize', 30, 'fontname', 'helvetica', 'FontAngle', 'italic'};
                cellfun(@(x) set(x, setArgs{:}), ax, 'uni', false);
                %cellfun(@(x) pbaspect(x, [1 1 1]), ax, 'uni', false);
                
                legendArgs = { 'Interpreter', 'none', 'FontSize', 30, ...
                                    'EdgeColor', 'none', 'Color', 'none'};
                
                % add legend to first axes only
                
                legend([legendHandles{:}], legendLabels{:}, legendArgs{:});
                figureHandles(rc, nc).Name = sprintf('Lolliplot Values RC %d', rc);
            end 
        end
    catch err
        rcaExtra_displayError(err)       
    end
end