function rcaExtra_plotAmplitudeWithStats(plotContainer1, plotContainer2, rcResultContainer1, rcResultContainer2)

    statsBetween_rcaData = rcaExtra_runStatsAnalysis(rcResultContainer1, rcResultContainer2);
    figureHandles = rcaExtra_plotAmplitudes(plotContainer1, plotContainer2);
    xLocations = 1:size(statsBetween_rcaData.pValues, 1);
    for fh = 1:int8(numel(figureHandles))
        statsBetween_rcaData.pValues(:, 1, fh)
        figureHandles(fh).Name = char(strcat(plotContainer1.conditionLabels(fh), ...
            'SA',plotContainer1.dataLabel, plotContainer2.dataLabel));
        currAxisHandle = get(figureHandles(fh), 'CurrentAxes');
        plot_addStatsBar_freq(currAxisHandle, statsBetween_rcaData.pValues(:, 1, fh), ...
            xLocations');
    end
end