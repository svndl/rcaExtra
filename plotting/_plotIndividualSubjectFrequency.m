function rcaExtra_plotIndividualSubjectFrequency(rcaResult, plotSettings)
% plot individual subject's amplitude/phase and error bar
% subj's data is a structure with subfields subj.amp, subj.phase, subj.err
% Dimensions are nFreqs x nComponents x nSubjects xnConditions
    
    if (isempty(plotSettings))
       % fill settings template
       plotSettings = rcaExtra_getPlotSettings(rcaResult.rcaSettings);
       plotSettings.legendLabels = arrayfun(@(x) strcat('Condition ', num2str(x)), ...
           1:size(rcaResult.projAvg.ellipseErr, 1), 'uni', false);
       % default settings for all plotting: 
       % font type, font size
       
       plotSettings.Title = 'Amplitude Plot';
       plotSettings.RCsToPlot = 1:3;
       % legend background (transparent)
       % xTicks labels
       % xAxis, yAxis labels
       % hatching (yes/no) 
       % plot title 
        
    end
    subjData = rcaResult.subjAvg;
    
    [nFreq, ~, ~, nCnd]  = size(subjData);
    projFig = figure;
   
    freqIdx = cellfun(@(x) str2double(x(1)), rcaResult.rcaSettings.useFrequencies, 'uni', true);
    freqVals = rcaResult.rcaSettings.useFrequenciesHz*freqIdx;
    
    cl = plotSettings.useColors;
    for cp = 1:numel(plotSettings.RCsToPlot)
        rc = plotSettings.RCsToPlot(cp);
        
        for nf = 1:nFreq
            linearInd = sub2ind([nFreq numel(plotSettings.RCsToPlot)], nf, cp);
            ax = subplot(numel(plotSettings.RCsToPlot), nFreq, linearInd, 'Parent', projFig);
                for cnd = 1:nCnd
                    %% plotting project's error
                    
                    e0 = [];
                    
                    % individual error
                    eR = squeeze(subjData.err(nf, rc, :, cnd));
                    th = 0:pi/50:2*pi;
                    e0(:, 1) = eR * cos(th);
                    e0(:, 2) = eR * sin(th);
                    
                    %L is the length
                    %angle is alpha
                    L = squeeze(subjData.amp(nf, rc, :, cnd));
                    alpha = squeeze(subjData.phase(nf, rc, :, cnd));
                    x = L.*cos(alpha);
                    y = L.*sin(alpha);
                    e_x = 0;
                    e_y = 0;

                    if (~isempty(e0))
                        e_x = e0(:, 1) + x;
                        e_y = e0(:, 2) + y;
                    end
                
                    props = { 'linewidth', 3, 'color', cl(:, cnd), 'linestyle', '-'};
                    patchSaturation = 0.5;
                    patchColor =  cl(cnd,:) + (1 - cl(cnd,:))*(1-patchSaturation);
                    errLine = line(e_x, e_y, 'LineWidth', 2); hold on;
                    set(errLine,'color', patchColor);
                    p = plot(ax, [0, x], [0, y], props{:}); hold on;
                    
                    legendRef{cnd, g} = p;
                    cndLabel{cnd, g} = sprintf('%s %s', groupTitles{g}, conditionTitles{cnd});
                end
        end
        setAxisAtTheOrigin(ax);
        
        descr = [componentTitles{cp} ' ' freqLabels{nf}];
        legend(ax, [legendRef{:}], cndLabel(:));
        title(descr, 'Interpreter', 'none');
        set(gca, 'FontSize', fontSize);
        set(gca,'DefaultTextFontSize',18);
    end    
end