function rcaExtra_plotCompareConditions_freq(plotSettings, rcaResult)
% function plots results of rc analysis in frequency domain.
% all conditions will be displayed together per harmonic multiple for each RC
% INPUT ARGUMENTS:
% plotSettings structure with plotting settings, 
% such as labels, legends (currently being implemented) 

% rcaResult structure, fields in use:
% rcaResult.rcaSettings.nComp --number of RC comps
% rcaResult.projAvg -- average project-lvl data
% rcaResult.rcaSettings.useFrequenciesHz for latency estimate calculation, plot labels;
% rcaResult.rcaSettings.useFrequencies labels for latency fitting, labels;
% rcaResult.rcaSettings.

    % lolliplots, copy global plot settings and modify if needed;
    plotSettings_loli = plotSettings;
    
    fh_Lolli = rcaExtra_plotLollipops(rcaResult, plotSettings_loli);
    % Latency plots, copy global plot settings and modify if needed;
    
    plotSettings_lat = plotSettings;
    fh_Lat = rcaExtra_plotLatencies(rcaResult, plotSettings_lat);
    
    % aplitude plots, copy global plot settings and modify if needed;
    plotSettings_amp = plotSettings;
    fh_Amp = rcaExtra_plotAmplitudes(rcaResult, plotSettings_amp);
    
    % plot avg Sin Cos as dots for each harmonic multiple
    plotSettings_reim = plotSettings;    
    fh_SinCos = rcaExtra_plotSinCos_freq(rcaResult, plotSettings_reim);
    
    % semilogy for log bar charts only
    % 
end

