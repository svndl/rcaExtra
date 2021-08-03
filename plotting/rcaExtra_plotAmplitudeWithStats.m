function rcaExtra_plotAmplitudeWithStats(plotContainer1, plotContainer2, rcResultContainer1, rcResultContainer2)

    statsBetween_rcaData = rcaExtra_runStatsAnalysis(rcResultContainer1, rcResultContainer2);
    figureHandles = rcaExtra_plotAmplitudes(plotContainer1, plotContainer2);
    xLocations = 1:size(statsBetween_rcaData.pValues, 1);
    [nRcs, nCnds] = size(figureHandles);
    
    for rc = 1:nRcs
        for cn = 1:nCnds
            figureHandles(rc, cn).Name = char(strcat(plotContainer1.conditionLabels(cn), ...
                'SA',plotContainer1.dataLabel, plotContainer2.dataLabel));
            currAxisHandle = get(figureHandles(rc, cn), 'CurrentAxes');
            plot_addStatsBar_freq(currAxisHandle, statsBetween_rcaData.pValues(:, rc, cn), ...
                xLocations');
        end
    end
end