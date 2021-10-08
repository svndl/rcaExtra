function plotSummary_Waveforms(figHandle, rcResult, statData, nSubplotsRow)
    AxesHandle = cell(rcResult.rcaSettings.nComp, 1);
    lineProps = {'k', 'LineWidth', 1};
    
    yMax = 1e+06*1.2*max(rcResult.mu(:));
    gca(figHandle);
    try
        for c = 1:rcResult.rcaSettings.nComp
            AxesHandle{c} = subplot(nSubplotsRow, rcResult.rcaSettings.nComp, c + rcResult.rcaSettings.nComp);
            shadedErrorBar(rcResult.timecourse, 1e+06*rcResult.mu(:, c), 1e+06*rcResult.s(:, c), lineProps); hold on;
            AxesHandle{c}.YLim = [-yMax, yMax];
            %axis square;
            set(gca, 'FontSize', 20, 'fontname', 'helvetica');
            if (c == 1)            
                xlabel('\sl Time (msec)');
                ylabel('\sl Amplitude (\muV)');
            end
            % add stats
            if (~isempty(statData))
                plot_addStatsBar_time(AxesHandle{c}, statData.pValues(:, c), ...
                    statData.sig(:, c), rcResult.timecourse);
            end
            
        end
        linkaxes([AxesHandle{:}], 'y');
    catch err
        rcaExtra_displayError(err);
        fprintf('unable to plot rc means and sems. \n');
    end
end
