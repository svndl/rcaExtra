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
       plotSettings = rcaExtra_getPlotSettings(rcaResult.rcaSettings);
       plotSettings.legendLabels = arrayfun(@(x) strcat('Condition ', num2str(x)), ...
           1:size(rcaResult.projAvg.ellipseErr, 1), 'uni', false);
       % default settings for all plotting: 
       % font type, font size
       
       plotSettings.Title = 'Waveforms';
       % plotSettings.RCsToPlot = 3;
       % legend background (transparent)
       % xTicks labels
       % xAxis, yAxis labels
       % hatching (yes/no) 
       % plot title 
    end
    % handles for each rc component
    
    fh = cell(rcaResult.rcaSettings.nComp);
    
    for nrc = 1:rcaResult.rcaSettings.nComp
    
        fh{nrc} = shadedErrorBar(rcaResult.timecourse, rcaResult.mu(:, c), rcaResult.s(:, c), lineProps); hold on;
    end
end

