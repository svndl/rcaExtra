function plotRCWaveforms(plotHandle, nSubplotsRow)


    AxesHandle = cell(nComp, 1);
    lineProps = {'k', 'LineWidth', 1};
    yMax = 1.2*max(muData(:));
    gca(figHandle);
    try
        for c = 1:nComp
            AxesHandle{c} = subplot(nSubplotsRow, nComp, c + nComp);
            shadedErrorBar(tc, s(c).*muData(:, c), semData(:, c), lineProps); hold on;
            AxesHandle{c}.YLim = [-yMax, yMax];
            %axis square;
            set(gca, 'FontSize', 20);
            if (c == 1)            
                xlabel('\sl Time (msec)');
                ylabel('\sl Amplitude (\muV)');
            end
            % add stats
            if (~isempty(statData))
                plot_addStatsBar_time(AxesHandle{c}, statData.pValues(:, c), ...
                    statData.sig(:, c), tc);
            end
            
        end
        linkaxes([AxesHandle{:}], 'y');
    catch err
        fprintf('unable to plot rc means and sems. \n');
    end
end
