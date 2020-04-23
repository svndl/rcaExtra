function fHandles = plotConditionComparitionTwoGroups_freq(f, groupData, groupStats)

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
    fHandles = cell(nComp, 1);
    % amplitude and frequency
    nSubplots_Row = 1;    
    nSubplots_Col = 2;
    
    asterisk = repmat('*', size(groupData{1}.amp, 1), 1) ;
    asterick_plotSettings = {'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
                'FontSize', 50, 'fontname', 'helvetica'};
    
    for cp = 1:nComp
        fHandles{cp} = figure;
        set(fHandles{cp}, 'units', 'normalized', 'outerposition', [0 0 1 1]);
        g1_Label = [groupData{1}.label ' ' groupData{1}.compLabels{cp}];
        g2_label = [groupData{2}.label ' ' groupData{2}.compLabels{cp}];
        groupLabels = {g1_Label, g2_label};
        amplitudes = subplot(nSubplots_Row, nSubplots_Col, 1, 'Parent', fHandles{cp});
        latencies = subplot(nSubplots_Row, nSubplots_Col, 2, 'Parent', fHandles{cp});
    
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
        text_maxY = 0.5*max(groupAmp, [], 2);
        text_sigAsterick = asterisk(currRC_sig > 0);
        
        text(amplitudes, 1:length(currRC_pV), ...
            text_maxY, num2str(currRC_pV,'%0.2f'), plotSettings.statssettings{:});
        
        text(amplitudes, find(currRC_sig>0), ...
            groupAmp(currRC_sig > 0), text_sigAsterick, asterick_plotSettings{:});
               
        
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

