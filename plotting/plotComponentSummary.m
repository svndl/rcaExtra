function figHandle = plotComponentSummary(compID, f, groupData, plotSettings)
    figHandle = figure;
    set(figHandle, 'units', 'normalized', 'outerposition', [0 0 1 1]);
    
    nSubplots_Row = 1;
    plotLabel = groupData.compLabels{compID};
    compLabel = plotLabel(1:2);
    switch compLabel
        case 'RC'
            nSubplots_Col = 3;
            topographies = subplot(nSubplots_Row, nSubplots_Col, 1, 'Parent', figHandle);
            colorbarLimits = [min(groupData.A(:)), max(groupData.A(:))];
            axes(topographies);
            
            if ~isempty(which('mrC.plotOnEgi')) % check for mrC version of plotOnEgi
                mrC.plotOnEgi(groupData.A(:, compID), colorbarLimits);
            else
                plotOnEgi(groupData.A(:, compID),colorbarLimits);
            end
            title(plotLabel, 'FontSize', 30);
            
        otherwise
            nSubplots_Col = 2;
    end
    amplitudes = subplot(nSubplots_Row, nSubplots_Col, nSubplots_Col - 1, 'Parent', figHandle);
    latencies = subplot(nSubplots_Row, nSubplots_Col, nSubplots_Col, 'Parent', figHandle);

    % topo plot

    % concat bars for amplitude plot
    groupAmp = squeeze(groupData.amp(:, compID, :));
    groupAmpErrs = groupData.errA(:, compID, :, :);

    % plot all bars first
    freqplotBar(amplitudes, groupAmp, groupAmpErrs, plotSettings.colors, {plotLabel});
    
    % add significance
    asterisk = repmat('*', size(groupAmp, 1), 1);
    
    asterick_plotSettings = {'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
                'FontSize', 50, 'fontname', 'helvetica'};
            
    if (isfield(groupData, 'stats'))
        currRC_sig = groupData.stats.sig(:, compID);
        currPValue = groupData.stats.pValues(:, compID);
        % pValues text Y position
        text_maxY = 0.5*groupAmp ;
        text_sigAsterick = asterisk(currRC_sig > 0);
    
        text(amplitudes, 1:length(currPValue), ...
            text_maxY, num2str(currPValue, '%0.2f'), plotSettings.statssettings{:});
   
        % preset settings for stats
        text(amplitudes, find(currRC_sig > 0), ...
            groupAmp(currRC_sig > 0), text_sigAsterick, asterick_plotSettings{:});
    end
    set(amplitudes, plotSettings.axesprops{:});
    pbaspect(amplitudes, [1 1 1]);

    %% concat frequency for latency plot
    groupAngles_raw = groupData.phase(:, compID, :);
    groupAngles = unwrap(groupAngles_raw);
    groupAnglesErrs = groupData.errP(:, compID, :, :);

    freqPlotLatency(latencies, groupAngles, groupAnglesErrs, plotSettings.colors, {plotLabel}, f);
    set(latencies, plotSettings.axesprops{:});
    pbaspect(latencies, [1 1 1]);
end