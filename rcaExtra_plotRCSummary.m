function rcaExtra_plotRCSummary(rcResult, rcSettings, rcStats)
% Function displays summary results of RCA
% Alexandra Yakovleva, 2020 Stanford University

    f = figure;
    nRows = 3;
    %% Row 1: plot Topography
    plotRCTopoMaps(f, rcResult.A, nRows);    
    %% Row 2: plot waveforms with significance for time domain data 
    %% or amplitude bars/significance for frequency domain data
    
    switch rcSettings.domain
        case 'time'
            plotRCWaveforms(f, nSubplotsRow);
        case 'freq'
            plotAmplitudeBars(f, rcResult, rcStats);
        otherwise
    end
    %% Row 3: plot Cov spectrum and dGen 
    plotdGen(f, rcResult.Rxx, rcResult.Ryy, rcResult.dGen, nRow);
    %% save figure
    filename = strcat('rca_', rcSettings.domain, rcaSettings.label, '_', rcaSettings.runDate, '.fig');
    save(gcf, fullfile(rcSettings.destDataDir_FIG, filename));
end

