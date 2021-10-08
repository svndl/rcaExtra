function rcaExtra_plotRCSummary(rcResult, rcStats)
% Function displays summary results of RCA
% Alexandra Yakovleva, 2020 Stanford University
    f = figure;
    f.Name = rcResult.rcaSettings.label;
    nRows = 3;
    %% Row 1: plot Topography
    plotSummary_TopoMaps(f, rcResult.A, nRows);
    
    %% Row 2: plot waveforms with significance for time domain data 
    %% or amplitude bars/significance for frequency domain data
    
    switch rcResult.rcaSettings.domain
        case 'time'
            % supply timeline
            plotSummary_Waveforms(f, rcResult, rcStats, nRows);
        case 'freq'
            plotSummary_AmplitudeBars(f, rcResult.rcaSettings.useFrequencies, ...
                rcResult.projAvg, rcStats, nRows);
        otherwise
    end
    
    %% Row 3: plot Cov spectrum and dGen
    try
        plotdGen(f, rcResult.covData, rcResult.rcaSettings.nComp, nRows);
    catch err
        rcaExtra_displayError(err);
    end
    
    %% save figure
    filename = strcat('rca_', rcResult.rcaSettings.domain, rcResult.rcaSettings.label, '_', rcResult.rcaSettings.runDate, '.fig');
    filename_png = strcat('rca_', rcResult.rcaSettings.domain, rcResult.rcaSettings.label, '_', rcResult.rcaSettings.runDate, '.eps');

    saveas(gcf, fullfile(rcResult.rcaSettings.destDataDir_FIG, filename));
    saveas(gcf, fullfile(rcResult.rcaSettings.destDataDir_FIG, filename_png));
end

