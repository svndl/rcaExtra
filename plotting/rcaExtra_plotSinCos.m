function dataOut = rcaExtra_plotSinCos(plotHandle, rcaResult)

    for cp = 1:nComp
        
        groupAmps = squeeze(projAvg.amp(:, cp, :));
        groupAmpErrs = squeeze(projAvg.errA(:, cp, :, :));
        freqplotBar(amplitudes, groupAmps, groupAmpErrs, plotInfo.colors, plotInfo.legendLabels);
        title(amplitudes, strcat(plotInfo.Title, ' RC', num2str(cp)), 'FontSize', 35);
        set(amplitudes, plotInfo.axesprops{:});
        
        pbaspect(amplitudes, [1 1 1]);
        

    end
end