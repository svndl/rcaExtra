function pa = plotPhase(ax, ph, err, color, style)

    freqLabels = 
    %% phase
    %% TODO add regression line
    title_p  = ['Phase XX' ];
    yLabel_p = 'Phase, \phi, radians';

    scatterPlotPhase(ax, ph, err, title_p, freqLabels, yLabel_p, color); hold on;
end