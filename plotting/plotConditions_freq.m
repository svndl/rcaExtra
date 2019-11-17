function [cnd_Bars, cnd_Lolliplots] = plotConditions_freq(f, cndLabels, cndData, colorOrder)

%% INPUT:
    % varargin -- proj groups + labels: {group1, group2, groupLabels, conditionLabels, componentLabels}
    % Each group is a structure with following elements: 
    % groupX.amp = values amp, 
    % groupX.phase = values phase, 
    % groupX.EllipseError = error ellipses
    % groupX.stats -- values for statistical info (computed between conditions and between groups)  
    
    % groupX = {Values(nCnd x nComp x nFreq) Errors (nCnd x nComp x nFreq)}
    
    nConditions = numel(cndLabels);
    
    if(isempty(colorOrder))
        plotSettings = getOnOffPlotSettings('conditions', 'Frequency');
        plotColors = plotSettings.colors;     
    else 
        plotSettings = getOnOffPlotSettings('groupsconditions', 'Frequency');
        plotColors = squeeze(plotSettings.colors(colorOrder, :, :))';
    end
            
    close all;
    
    nComp = 1; % drop the OZ component

    % amplitude and frequency
    nSubplots_Col = 2;
    nSubplots_Row = nComp;
    
    cnd_Bars = figure;
    set(cnd_Bars, 'units', 'normalized', 'outerposition', [0 0 1 1]);
    
    amplitudes = subplot(nSubplots_Row, nSubplots_Col, 1, 'Parent', cnd_Bars);
    latencies = subplot(nSubplots_Row, nSubplots_Col, 2, 'Parent', cnd_Bars);
    
    cnd_Lolliplots = figure;
    set(cnd_Lolliplots, 'units', 'normalized', 'outerposition', [0 0 1 1]);

    cp = 1; %RC's
 
    cndAmps = squeeze(cndData.amp(:, cp, :)); 
    cndAmpsErrs = squeeze(cndData.errA(:, cp, :, :));
    % plot all bars first
    freqplotBar(amplitudes, cndAmps, cndAmpsErrs, plotColors, cndLabels);
    set(amplitudes, plotSettings.axesprops{:});
    pbaspect(amplitudes, [1 1 1]);    

    
    %% concat frequency for latency plot    
    cndAngles_raw = squeeze(cndData.phase(:, cp, :));
    cndAnglesErrs = squeeze(cndData.errP(:, cp, :, :));

    %% phase wrapping
    cndAngles = unwrap(cndAngles_raw); 
    
    freqPlotLatency(latencies, cndAngles, cndAnglesErrs, plotColors, cndLabels, f);    
    set(latencies, plotSettings.axesprops{:});
    pbaspect(latencies, [1 1 1]);
    
    % lolliplots
    nFreq = size(cndAngles, 1);
    ax = cell(1, nFreq);
    legendRef = cell(1, nConditions);
    freqLabels = cellfun( @(x) strcat('F', num2str(x)), num2cell(1:1:nFreq), 'uni', false);
    
    
    for nf = 1:nFreq        
        ax{nf} = subplot(nSubplots_Row, nFreq, nf, 'Parent', cnd_Lolliplots);
        axes(ax{nf}); 
        
        for nc = 1:nConditions
            colorGroup = plotColors(nc, :);            
            groupstyle = plotSettings.linestyles{nc};

                alpha = cndAngles(nf, nc);
                L = cndAmps(nf, nc);
                try
                    ellipseCalc = cndData.ellipseErr{nc};
                catch
                    ellipseCalc = cndData{nc}.err;
                end
                x = L.*cos(alpha);
                y = L.*sin(alpha);
                e_x = 0;
                e_y = 0;
                try
                    e0 = ellipseCalc{nf, cp};
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
                legendRef{nc} = plot(ax{nf}, [0, x], [0, y], props{:}); hold on;
        end
        % font size
        %linkaxes([ax{1}, ax{nf}],'xy');
        setAxisAtTheOrigin(ax{nf});
        set(ax{nf}, plotSettings.axesprops{:});
        
        descr = ['Conditions ' freqLabels{nf}];
        legend([legendRef{:}], cndLabels(:));
        title(descr, 'Interpreter', 'none');
    end
end

