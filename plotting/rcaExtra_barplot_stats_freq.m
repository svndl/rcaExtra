function f = rcaExtra_barplot_stats_freq(frequencies, vals, errs, colors, labels, significance, pValues)
        
    % number of harmonics/conditions to display
    [nF, nCnd] = size(vals);    
    
    % labels for x-axis
    xlabels = arrayfun( @(x) strcat(num2str(x), 'Hz'), frequencies, 'uni', false);
       
    %% adjusting bar width according to number of harmonics/conditions
    nGroups = nF;
    nBars = nCnd;
    groupWidth = min(0.8, nBars/(nBars + 1.5));
    xE = zeros(nGroups, nBars);
    
    for b = 1:nBars
        xE(:, b) = (1:nGroups) - groupWidth/2 + (2*b -1 )*groupWidth / (2*nBars);
    end
    f = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    set(gcf, 'renderer', 'openGL');
    
    %% splitting into significant/non-significant
        
    nsigVals = vals(~significance, :);    
    nsigxE = xE(~significance, :);
    nsigValErrs = errs(~significance, :, :);
    
    %% plotting bar errors
    % display all (significant, non-significant) for legend purposes
    % then draw non-significant on top
    
    if (nCnd > 1)
        beh_sig = errorbar(xE, vals, squeeze(errs(:, :, 1)), squeeze(errs(:, :, 2)), ...
            'LineStyle', 'none', 'LineWidth', 2); hold on;
        
        beh_nsig = errorbar(nsigxE, nsigVals, squeeze(nsigValErrs(:, :, 1)), squeeze(nsigValErrs(:, :, 2)), ...
            'LineStyle', 'none', 'LineWidth', 2); hold on;
        %select the one with 2 conditions
    else
        beh_sig = errorbar(xE, vals, squeeze(errs(:, 1)), squeeze(errs(:, 2)), ...
            'LineStyle', 'none', 'LineWidth', 2); hold on;
        
        beh_nsig = errorbar(nsigxE, nsigVals, squeeze(nsigValErrs(:, 1)), squeeze(nsigValErrs(:, 2)), ...
            'LineStyle', 'none', 'LineWidth', 2); hold on;
    end
    legendHandle = beh_sig;
    
    %% plot bars and errors for each condition in a loop
    % workaround, since bar(x, y) cannot have duplicate x
    % 
    patchSaturation = 0.15;
    sigSaturation = 0.5;
    for nc = 1:nCnd
        % define significant/ non significant colors
        color1 = colors(:, nc);
        color0 = color1 + (1 - color1)*(1 - sigSaturation);                
        patchColor0 = color0 + (1 - color0)*(1 - patchSaturation);        
        patchColor1 = color1 + (1 - color1)*(1 - patchSaturation);
        
        nsigBarProps = {'LineWidth', 2, 'EdgeColor', color0, 'FaceColor', patchColor0, 'FaceAlpha', 0.5};
        sigBarProps = {'LineWidth', 2, 'EdgeColor', color1, 'FaceColor', patchColor1, 'FaceAlpha', 0.5};
        
        bar(xE(:, nc), vals(:, nc), 0.8*groupWidth/nCnd, sigBarProps{:}); hold on; 
        bar(nsigxE(:, nc), nsigVals(:, nc), 0.8*groupWidth/nCnd,  nsigBarProps{:}); hold on;        
        
        if (~isempty(beh_nsig(nc)))
            set(beh_nsig(nc), 'color', color0); 
        end
        if (~isempty(beh_sig(nc)))
            set(beh_sig(nc), 'color', color1);
            % missing condition
        end
    end    
    % add pValues and pValue legends
    
    % axis consmetics
    try
        set(gca, 'XTick', 1:numel(frequencies))
        set(gca, 'XTickLabel', xlabels);
    catch
        xlabel(xlabels);
    end
    if (~isempty(labels))
        legend(legendHandle, labels{:}, 'Interpreter', 'none',  'FontSize', 30, 'EdgeColor', 'none', 'Color', 'none');
    end
    currYLimit = ylim(gca);
    ylim([0, 1.2*currYLimit(2)]);
    title('Amplitude Values');
    set(gca,'FontSize', 30, 'fontname', 'helvetica', 'FontAngle', 'italic');
    ylabel('Amplitude (\muV)');
    pbaspect(gca, [1 1 1]);
    
    %% add significance
    asterisk_1 = repmat({'*'}, size(vals, 1), 1);
    asterisk_2 = repmat({'**'}, size(vals, 1), 1);
    asterisk_3 = repmat({'***'}, size(vals, 1), 1);
    
    asterick_plotSettings = {'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
        'FontSize', 50, 'fontname', 'helvetica', 'Color', 'r'};
    
    %currRC_sig = statData.sig(:, c);
    currRC_sig_1 = (pValues < 0.05).* (pValues > 0.01);
    currRC_sig_2 = (pValues < 0.01).*(pValues > 0.001);
    currRC_sig_3 = pValues < 0.001;
    
    % pValues text Y position
    text_maxY = 0.35*vals(:, 1) ;
    
    text_sigAsterick_1 = asterisk_1(currRC_sig_1 > 0);
    text_sigAsterick_2 = asterisk_2(currRC_sig_2 > 0);
    text_sigAsterick_3 = asterisk_3(currRC_sig_3 > 0);
    
    % display pValue (should be optional)
    text(gca, 1:length(pValues), ...
        text_maxY(:, 1), num2str(pValues, '%0.4f'), 'FontSize', 20);
    
    % display significance
    text(gca, find(currRC_sig_1 > 0), ...
        vals(currRC_sig_1 > 0, 1), text_sigAsterick_1, asterick_plotSettings{:});
    
    text(gca, find(currRC_sig_2 > 0), ...
        vals(currRC_sig_2 > 0, 1), text_sigAsterick_2, asterick_plotSettings{:});
    
    text(gca, find(currRC_sig_3 > 0), ...
        vals(currRC_sig_3 > 0, 1), text_sigAsterick_3, asterick_plotSettings{:});
    
    % add pValue legends
    text(gca, nF, 1.1*vals(1, 1), '* : 0.01 < p < 0.05', ...
        'FontSize', 20, 'fontname', 'helvetica', 'Color', 'k');
    text(gca,  nF, vals(1, 1), '** : 0.001 < p < 0.01', ...
        'FontSize', 20, 'fontname', 'helvetica', 'Color', 'k');
    text(gca,  nF, 0.9*vals(1, 1), '*** : p < 0.001', ...
        'FontSize', 20, 'fontname', 'helvetica', 'Color', 'k');
end
