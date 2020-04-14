function fHandle = plotConditionComparitionTwoGroups_freq(f, groupData, groupStats)

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
    
    nComp = size(groupData{1}.amp, 2);
    
    nSubplots_Row = nComp;
    
    % topo, amplitude and frequency
    nSubplots_Col = 2;
    
    fHandle = figure;
    set(fHandle, 'units', 'normalized', 'outerposition', [0 0 1 1]);
    asterisk = repmat('*', size(groupData{1}.amp, 1), 1) ;  
    for cp = 1:nComp
        compID = nSubplots_Col*(cp - 1) + 1 ;
        groupLabels = {groupData{1}.label, groupData{2}.label};
        amplitudes = subplot(nSubplots_Row, nSubplots_Col, compID, 'Parent', fHandle);
        latencies = subplot(nSubplots_Row, nSubplots_Col, compID + 1, 'Parent', fHandle);
    
        %% concat bars for amplitude plot
        groupAmp_cell = cellfun(@(x) squeeze(x.amp(:, cp, :)), groupData, 'uni', false);
        groupAmpErrs_cell = cellfun(@(x) squeeze(x.errA(:, cp, :, :)), groupData, 'uni', false);
        
        groupAmp = cat(2, groupAmp_cell{:});
        groupAmpErrs = cat(3, groupAmpErrs_cell{:});
        % plot all bars first
        freqplotBar(amplitudes, groupAmp, permute(groupAmpErrs, [1 3 2]), plotSettings.colors, groupLabels);
        set(amplitudes, plotSettings.axesprops{:});
        pbaspect(amplitudes, [1 1 1]);
        
        %% add stats
        
        % pValues text Y position
        currRC_sig = groupStats.sig(:, cp);
        currRC_pV = groupStats.pValues(:, cp);
        text_maxY = 1.2*max((groupAmp + squeeze(groupAmpErrs(:, :, 2))), [], 2);
        text_sigAsterick = asterisk(currRC_sig > 0);
        
        text(amplitudes, 1:length(currRC_pV), ...
            text_maxY, num2str(currRC_pV,'%0.2f'), plotSettings.statssettings{:});
        
        text(amplitudes, 1:sum(currRC_sig), ...
            groupAmp(currRC_sig > 0), text_sigAsterick, plotSettings.statssettings{:});
               
        
        %% concat frequency for latency plot
        groupLat_cell = cellfun(@(x) squeeze(x.phase(:, cp, :)), groupData, 'uni', false);
        groupLatErrs_cell = cellfun(@(x) squeeze(x.errP(:, cp, :, :)), groupData, 'uni', false);
        
        
        groupAngles_raw = cat(2, groupLat_cell{:});
        groupAngles = unwrap(groupAngles_raw);
        
        groupAnglesErrs = cat(3, groupLatErrs_cell{:});
        
        freqPlotLatency(latencies, groupAngles, permute(groupAnglesErrs, [1 3 2]), plotSettings.colors, groupLabels, f);
        set(latencies, plotSettings.axesprops{:});
        pbaspect(latencies, [1 1 1]);
    
    end
end

