function [group_Bars, group_Lolliplots] = plotGroups_freq(f, groupLabels, varargin)

%% INPUT:
    % varargin -- proj groups + labels: {group1, group2, groupLabels, conditionLabels, componentLabels}
    % Each group is a structure with following elements: 
    % groupX.amp = values amp, 
    % groupX.phase = values phase, 
    % groupX.EllipseError = error ellipses
    % groupX.stats -- values for statistical info (computed between conditions and between groups)  
    
    % groupX = {Values(nCnd x nComp x nFreq) Errors (nCnd x nComp x nFreq)}
    
    nGroups = numel(groupLabels);
    
    groups = varargin(1 : nGroups);
    plotSettings = getOnOffPlotSettings('groups', 'Frequency');    
            
    %close all;
    
    nComp = 1; % drop the OZ component
    if (nargin > nGroups + 2)
        nComp = varargin{end};
    end

    % amplitude and frequency
    nSubplots_Col = 2;
    nSubplots_Row = 1;
    
    group_Bars = figure;
    set(group_Bars, 'units', 'normalized', 'outerposition', [0 0 1 1]);
    
    amplitudes = subplot(nSubplots_Row, nSubplots_Col, 1, 'Parent', group_Bars);
    latencies = subplot(nSubplots_Row, nSubplots_Col, 2, 'Parent', group_Bars);
    
    group_Lolliplots = figure;
    set(group_Lolliplots, 'units', 'normalized', 'outerposition', [0 0 1 1]);

    cp = nComp; %RC's
 
    %% concat bars for amplitude plot   
    groupAmp_cell = cellfun(@(x) squeeze(x.amp(:, cp, :)), groups, 'uni', false);
    groupAmpErrs_cell = cellfun(@(x) squeeze(x.errA(:, cp, :, :)), groups, 'uni', false);
    
    groupAmp = cat(2, groupAmp_cell{:});
    groupAmpErrs = cat(3, groupAmpErrs_cell{:});
    % plot all bars first
    freqplotBar(amplitudes, groupAmp, permute(groupAmpErrs, [1 3 2]), plotSettings.colors, groupLabels);
    set(amplitudes, plotSettings.axesprops{:});
    pbaspect(amplitudes, [1 1 1]);    
    
%     asterisk = repmat('*', size(groupAmp, 1), 1);   
%     if (isfield(groupData, 'stats'))
%         currRC_sig = groupData.stats.sig(:, comp);
%         currPValue = groupData.stats.pValues(:, comp);
%         % pValues text Y position
%         text_maxY = 0.5*groupAmp ;
%         text_sigAsterick = asterisk(currRC_sig > 0);
%         
%         text(amplitudes, 1:length(currPValue), ...
%             text_maxY, num2str(currPValue, '%0.2f'), plotSettings.statssettings{:});
%         
%         text(amplitudes, find(currRC_sig > 0), ...
%             groupAmp(currRC_sig > 0), text_sigAsterick, plotSettings.statssettings{:});
%         
%     end
    
    %% concat frequency for latency plot
    groupLat_cell = cellfun(@(x) squeeze(x.phase(:, cp, :)), groups, 'uni', false);
    groupLatErrs_cell = cellfun(@(x) squeeze(x.errP(:, cp, :, :)), groups, 'uni', false);

        
    groupAngles_raw = cat(2, groupLat_cell{:});
    groupAngles = unwrap(groupAngles_raw); 
    
    groupAnglesErrs = cat(3, groupLatErrs_cell{:});
    
    freqPlotLatency(latencies, groupAngles, permute(groupAnglesErrs, [1 3 2]), plotSettings.colors, groupLabels, f);    
    set(latencies, plotSettings.axesprops{:});
    pbaspect(latencies, [1 1 1]);
    
    % lolliplots
    nFreq = size(groupAngles, 1);
    ax = cell(1, nFreq);
    legendRef = cell(1, nGroups);
    freqLabels = cellfun( @(x) strcat('F', num2str(x)), num2cell(1:1:nFreq), 'uni', false);
    
    
    for nf = 1:nFreq        
        ax{nf} = subplot(nSubplots_Row, nFreq, nf, 'Parent', group_Lolliplots);
        axes(ax{nf}); 
        
        for ng = 1:nGroups
            colorGroup = plotSettings.colors(ng, :);            
            groupstyle = plotSettings.linestyles{ng};

                alpha = groupAngles(nf, ng);
                L = groupAmp(nf, ng);
                try
                    ellipseCalc = groups{ng}.ellipseErr;
                catch
                    ellipseCalc = currGroupProj.err;
                end
                x = L.*cos(alpha);
                y = L.*sin(alpha);
                e_x = 0;
                e_y = 0;
                try
                    e0 = ellipseCalc{1}{nf, cp};
                catch
                    
                    e0 = ellipseCalc(nf);
                end
                if (~isempty(e0))
                    e_x = e0(:, 1) + x;
                    e_y = e0(:, 2) + y;
                end
                props = { 'linewidth', 8, 'color', colorGroup, 'linestyle', groupstyle};             
                patchSaturation = 0.5;
                patchColor =  colorGroup + (1 - colorGroup)*(1 - patchSaturation);
                errLine = line(e_x, e_y, 'LineWidth', 5); hold on;
                set(errLine,'color', patchColor);
                legendRef{ng} = plot(ax{nf}, [0, x], [0, y], props{:}); hold on;
        end
        % font size
        %linkaxes([ax{1}, ax{nf}],'xy');
        setAxisAtTheOrigin(ax{nf});
        set(ax{nf}, plotSettings.axesprops{:});
        
        descr = ['Groups ' freqLabels{nf}];
        legend([legendRef{:}], groupLabels(:));
        title(descr, 'Interpreter', 'none');
    end
end

