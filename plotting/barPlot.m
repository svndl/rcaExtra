function barPlot(amp, error_amp, ph, error_phase, labels, settings)
    nFreq = size(amp, 1);
    nComp = size(amp, 2);
    load('colorbrewer.mat');
    PaletteN = 7;
    blues = colorbrewer.seq.YlGnBu{PaletteN}/255;
    reds = colorbrewer.seq.YlOrRd{PaletteN}/255;
    c_rg = cat(1, blues(end, :), reds(end, :));
    %freqLabels = cellfun( @(x) strcat('F', num2str(x)), num2cell(1:1:nFreq), 'uni', false);

    cndLabels = settings.cndLabels;
    f = settings.frequency;
    delay = settings.delay;
    % amplitude and frequency
    nSubplots_Col = 2;
    nSubplots_Row = nComp;    
    projFig = figure('units','normalized','outerposition',[0 0 1 1]);
    for cp = 1:nComp
        %projFig = figure;
        %% amplitude
        sh_amp = subplot(nSubplots_Row, nSubplots_Col, 2*(cp - 1) + 1, 'Parent', projFig);
        title_a = ['Amplitude ' labels(cp)];
        yLabel_a = 'Amplitude, \muV';
        
        ampData = squeeze(amp(:, cp, :));
        amp_errData = squeeze(error_amp(:, cp, :, :));
        barPlotNBars(sh_amp, ampData, amp_errData, title_a, cndLabels, yLabel_a, c_rg)
        
        %% phase
        %% TODO add regression line
        sh_phs = subplot(nSubplots_Row, nSubplots_Col, 2*cp, 'Parent', projFig);
        title_p  = ['Phase ' labels(cp)];
        yLabel_p = 'Phase, \phi, radians';
        
        phiData = unwrap(squeeze(ph(:, cp, :, :)));
        
        
        phi_errData = squeeze(error_phase(:, cp, :, :));
        scatterPlotPhase(sh_phs, phiData, phi_errData, title_p, cndLabels, yLabel_p, c_rg, f, delay);
    end
end
