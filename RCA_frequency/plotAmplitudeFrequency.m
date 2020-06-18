function plotAmplitudeFrequency(plotType, f, varargin)
%% INPUT:
    % groupData is a structure with following elements: 
    % groupData.amp = values amp, 
    % groupData.phase = values phase, 
    % groupData.EllipseError = error ellipses
    % groupData.stats -- values for statistical info (computed between conditions and between groups)
    % groupData.A -- topography
    % groupData.label -- group label

    % frequency 
    groupData = varargin;
    nGroups = numel(groupData);
    
    plotSettings = getOnOffPlotSettings('groups', 'Frequency');    
            
    close all;
    
    [nF, nComp, nCnd] = size(groupData{1}.projAvg.amp);
    
    fh_ampfreq = cell(nComp, 1);
    fh_lolli = cell(nComp, 1);
    % amplitude and frequency
    nSubplots_Row = 1;    
    nSubplots_Col = 2;
    
    
    switch plotType
        case 'between'
            % pick corresponding conditions from each grooup  
            cellAmps = cellfun(@(x) squeeze(x.amp(:, cp, :)), groupData, 'uni', false);
            cellAmpsErrs = cellfun(@(x) squeeze(x.errA(:, cp, :, :)), groupData, 'uni', false);
        
            amps = cat(2, cellAmps{:});
            ampsErrs = cat(3, cellAmpsErrs{:}); 
            cellLats = cellfun(@(x) squeeze(x.phase(:, cp, :)), groupData, 'uni', false);
            cellLatsErrs = cellfun(@(x) squeeze(x.errP(:, cp, :, :)), groupData, 'uni', false);
            anglesRaw = cat(2, cellLats{:});
            angs = unwrap(anglesRaw);     
            angleErrs = cat(3, cellLatsErrs{:});  
            
            % pick data for stats, if applicable (2 groups)
            
            % 
        case 'within'
            % plotting conditions 
    end
    for cp = 1:nComp
        fh_ampfreq{cp} = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
        fh_lolli = cell(nComp, 1);
        
        g1_Label = [groupData{1}.label ' ' groupData{1}.compLabels{cp}];
        g2_label = [groupData{2}.label ' ' groupData{2}.compLabels{cp}];
        groupLabels = {g1_Label, g2_label};
        amplitudes = subplot(nSubplots_Row, nSubplots_Col, 1, 'Parent', fHandles{cp});
        latencies = subplot(nSubplots_Row, nSubplots_Col, 2, 'Parent', fHandles{cp});
    
        %% concat bars for amplitude plot
        % plot all bars first
        freqplotBar(amplitudes, amps, permute(groupAmpErrs, [1 3 2]), plotSettings.colors, groupLabels);
        set(amplitudes, plotSettings.axesprops{:});
        pbaspect(amplitudes, [1 1 1]);
        
        %% add stats
        
        % pValues text Y position
        currRC_sig = groupStats.sig(:, cp);
        currRC_pV = groupStats.pValues(:, cp);
        text_maxY = 0.5*max(amps, [], 2);
        text_sigAsterick = asterisk(currRC_sig > 0);
        
        text(amplitudes, 1:length(currRC_pV), ...
            text_maxY, num2str(currRC_pV,'%0.2f'), plotSettings.statssettings{:});
        
        text(amplitudes, find(currRC_sig>0), ...
            amps(currRC_sig > 0), text_sigAsterick, asterick_plotSettings{:});
               
        
        %% concat frequency for latency plot
        
        freqPlotLatency(latencies, groupAngles, permute(groupAnglesErrs, [1 3 2]), plotSettings.colors, groupLabels, f);
        set(latencies, plotSettings.axesprops{:});
        pbaspect(latencies, [1 1 1]);
    
    end
end



