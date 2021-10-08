function cndFigure = plotConditions_time(tc, conditionLabels, cndMu, cndS)
%% Function will plot multiple first components against each other   
%% INPUT:
    % tc -- timecourse (samplePoints x 1)
    % conditionLabels -- legends
    % cndMu -- conditions avg
    % cndS -- conditions error
%% OUTPUT
    % cndFigure -- Figure handle  
      
        
    nConditions = size(cndMu, 2);
    legendALL_patch = cell(nConditions, 1);
    
    plotSettings = getOnOffPlotSettings('conditions', 'Time');    
    
    % close all figures
    close all;  
       
    cndFigure = figure;
    set(cndFigure, 'units','normalized','outerposition',[0 0 1 1]);

     
    for nc = 1:nConditions
        clr = plotSettings.colors(nc, :);
        legendALL_patch{nc} = customErrPlot(gca, tc, cndMu(:, nc), cndS(:, nc), ...
            clr, 'RC', plotSettings.linestyles{nc});        
    end
    if (plotSettings.showlegends)
        
        allLabels = conditionLabels;
        legend(gca, [legendALL_patch{:}], allLabels(:));
    end
    
    xlabel('Time, msec') % x-axis label
    ylabel('Amplitude, \muV') % y-axis label
    
    set(gca, plotSettings.axesprops{:});
    pbaspect(gca, [1 1 1]);    
end