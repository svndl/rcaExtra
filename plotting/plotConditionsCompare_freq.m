function [fHandles_bars, fHandles_lolli] = plotConditionsCompare_freq(f, cndData)

%% INPUT:
    % cndDataX is a structure with following elements: 
    % cndDataX.amp = values amp, 
    % cndDataX.phase = values phase, 
    % cndData{x}.EllipseError = error ellipses
    % cndDataX.stats -- values for statistical info (computed between conditions and between groups)
    % cndDataX.A -- topography
    % cndDataX.label -- group label
        
    plotSettings = getOnOffPlotSettings('conditions', 'Frequency');    
            
    close all;
    
    nComp = size(cndData.amp, 2);
    fHandles_bars = cell(nComp, 1);
    fHandles_lolli = cell(nComp, 1);
    
    % amplitude and frequency
    asterisk = repmat('*', size(cndData.amp, 1), 1) ;
    asterick_plotSettings = {'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
                'FontSize', 50, 'fontname', 'helvetica'};
    
    for cp = 1:nComp
        
        [fHandles_bars{cp}, fHandles_lolli{cp}] = plotConditions_freq(f, cndData.labels, cndData, [], cp);
                
        %% add stats
        allaxes_amp = findall(fHandles_bars{cp}, 'type', 'axes');
        % pValues text Y position
        currRC_sig = cndData.stats.sig(:, cp);
        currRC_pV = cndData.stats.pValues(:, cp);
        cndAmp = squeeze(cndData.amp(:, cp, :));
        avgAmp = mean(cndAmp, 2);
        text_maxY = 0.5*max(cndAmp, [], 2);
        text_sigAsterick = asterisk(currRC_sig > 0);
        
        text(allaxes_amp(2), 1:length(currRC_pV), ...
            text_maxY, num2str(currRC_pV,'%0.2f'), plotSettings.statssettings{:});
        
        text(allaxes_amp(2), find(currRC_sig>0), ...
            avgAmp(currRC_sig > 0), text_sigAsterick, asterick_plotSettings{:});
    end
end
