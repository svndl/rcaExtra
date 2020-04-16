function fHandles = plotConditionSummaryGroup_freq(f, groupData)

%% INPUT:
    % groupData is a structure with following elements: 
    % groupData.amp = values amp, 
    % groupData.phase = values phase, 
    % groupData.EllipseError = error ellipses
    % groupData.stats -- values for statistical info (computed between conditions and between groups)
    % groupData.A -- topography
    % groupData.label -- group label
    
      
    plotSettings = getOnOffPlotSettings('groups', 'Frequency');    
            
    close all;
    
    nComp = size(groupData.A, 2);
    nSubplots_Row = 1;

    % topo, amplitude and frequency
    nSubplots_Col = 3;
    
    fHandles = cell(nComp, 1);
    
    colorbarLimits = [min(groupData.A(:)), max(groupData.A(:))];
    for comp = 1:nComp
        fHandles{comp} = figure;
        set(fHandles{comp}, 'units', 'normalized', 'outerposition', [0 0 1 1]);
        
        plotLabel = strcat(groupData.label, ' RC #', num2str(comp));
        topographies = subplot(nSubplots_Row, nSubplots_Col, 1, 'Parent', fHandles{comp});
        amplitudes = subplot(nSubplots_Row, nSubplots_Col, 2, 'Parent', fHandles{comp});
        latencies = subplot(nSubplots_Row, nSubplots_Col, 3, 'Parent', fHandles{comp});
    
        %% topo plot
        axes(topographies);

        if ~isempty(which('mrC.plotOnEgi')) % check for mrC version of plotOnEgi
            mrC.plotOnEgi(groupData.A(:, comp), colorbarLimits);
        else
            plotOnEgi(groupData.A(:, comp),colorbarLimits);
        end
        title(['RC' num2str(comp)], 'FontSize', 30);
 
        %% concat bars for amplitude plot   
        groupAmp = squeeze(groupData.amp(:, comp, :));
        groupAmpErrs = groupData.errA(:, comp, :, :);
    
        % plot all bars first
        freqplotBar(amplitudes, groupAmp, groupAmpErrs, plotSettings.colors, {plotLabel});
        %% add significance
        asterisk = repmat('*', size(groupAmp, 1), 1);
        
        if (isfield(groupData, 'stats'))
            currRC_sig = groupData.stats.sig(:, comp);
            currPValue = groupData.stats.pValues(:, comp);
            % pValues text Y position
            text_maxY = 0.5*groupAmp ;
            text_sigAsterick = asterisk(currRC_sig > 0);
            
            text(amplitudes, 1:length(currPValue), ...
                text_maxY, num2str(currPValue, '%0.2f'), plotSettings.statssettings{:});
            
            text(amplitudes, find(currRC_sig > 0), ...
                groupAmp(currRC_sig > 0), text_sigAsterick, plotSettings.statssettings{:});
            
        end
        set(amplitudes, plotSettings.axesprops{:});
        pbaspect(amplitudes, [1 1 1]);    

    
        %% concat frequency for latency plot
        groupAngles_raw = groupData.phase(:, comp, :);
        groupAngles = unwrap(groupAngles_raw); 
        groupAnglesErrs = groupData.errP(:, comp, :, :);
    
        freqPlotLatency(latencies, groupAngles, groupAnglesErrs, plotSettings.colors, {plotLabel}, f);    
        set(latencies, plotSettings.axesprops{:});
        pbaspect(latencies, [1 1 1]);
        
        
        %% test against zero add significance 
        
    end
end
