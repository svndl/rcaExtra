function rcaExtra_plotCompareConditions_time(plotSettings, rcaResult)
% function plots results of rc analysis in frequency domain.
% all conditions will be displayed together per harmonic multiple for each RC
% INPUT ARGUMENTS:
% plotSettings structure with plotting settings, 
% such as labels, legends (currently being implemented) 

% rcaResult structure, fields in use:
% rcaResult.rcaSettings.nComp --number of RC comps
% rcaResult.rcaSettings.useFrequenciesHz for latency estimate calculation, plot labels;
% rcaResult.mu -- mean signal average
% rcaResult.std -- standard deviation 
    
    if (isempty(plotSettings))
       % fill settings template
       plotSettings = rcaExtra_getPlotSettings(rcaResult);
       plotSettings.Title = 'Waveforms';
       plotSettings.RCsToPlot = 1:3;
    end
    % handles for each rc component
    
    
    for cp = 1:numel(plotSettings.RCsToPlot)
        
        rc = plotSettings.RCsToPlot(cp);
        f = rcaExtra_plotWaveforms_time(rcaResult.timecourse, ...
            squeeze(rcaResult.mu_cnd(:, rc, :)),...
            squeeze(rcaResult.s_cnd(:, rc, :)), plotSettings.useColors, plotSettings.legendLabels);
        
        fhWaveforms.Name = strcat('RC ', num2str(rc), plotSettings.Title);
        
        %% save figure in rcaResult.rcaSettings
        try
            saveas(f, ...
                fullfile(rcaResult.rcaSettings.destDataDir_FIG, [fhWaveforms.Name '.fig']));
        catch err
            rcaExtra_displayError(err);
        end
    end
end

