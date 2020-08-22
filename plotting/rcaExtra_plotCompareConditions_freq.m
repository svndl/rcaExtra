function rcaExtra_plotCompareConditions_freq(rcaResult, plotSettings)
% function plots results of rc analysis in frequency domain.
% all conditions will be displayed together per harmonic multiple for each RC
% INPUT ARGUMENTS:
% rcaResult structure, fields in use:
% rcaResult.rcaSettings.nComp --number of RC comps
% rcaResult.projAvg -- average project-lvl data
% rcaResult.rcaSettings.useFrequenciesHz for latency estimate calculation, plot labels;
% rcaResult.rcaSettings.useFrequencies labels for latency fitting, labels;
% rcaResult.rcaSettings.
% plotSettings can be empty

    % lolliplots, copy global plot settings and modify if needed;
    plotSettings_loli = plotSettings;
    fh_Lolli = rcaExtra_plotLollipops(rcaResult, plotSettings_loli);
    % Latency plots, copy global plot settings and modify if needed;
    
    plotSettings_lat = plotSettings;
    fh_Lat = rcaExtra_plotLatencies(rcaResult, plotSettings_lat);
    
    % aplitude plots, copy global plot settings and modify if needed;
    plotSettings_amp = plotSettings;    
    fh_Amp = rcaExtra_plotAmplitudes(rcaResult, plotSettings_amp);
end

