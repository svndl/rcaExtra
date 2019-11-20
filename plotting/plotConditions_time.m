function cndFigure = plotConditions_time(tc, conditionLabels, cndMu, cndS)
% Alexandra Yakovleva, Stanford University 2012-2020
%% Function will plot multiple first components against each other   
%% INPUT:
    % tc -- timecourse (samplePoints x 1)
    % varargin -- groups + labels: {group1, group2,..., groupN, groupLabels, ConditionLabels}
    % groupX -- cell array with two elements: groupX{1} = eegData Mu, groupX{2} = eegData Std
    % groupX = {eegGroupMu(samplePoints x nParts) eegGroupStd(samplePoints x nParts)}
    % EEG data (mu, std) is samplePoints x nParts regions (f, p1, p2):
    % eegGroupMu = [eegGroupMu( RC1, f1) eegGroupMu ( RC1, p1) eegGroupMu ( RC1, p2)] 
%% OUTPUT
    % regGCF -- Figure handle of by region plots 
    % grGCF -- Figure handle of by group pliots 
      
        
    nConditions = numel(conditionLabels);
    legendALL_patch = cell(nConditions, 1);
    
    plotSettings = getOnOffPlotSettings('conditions', 'Time');    
    
    % close all figures
    close all;  
       
    cndFigure = figure;
    set(cndFigure, 'units','normalized','outerposition',[0 0 1 1]);

     
    for nc = 1:nConditions
        clr = plotSettings.colors(nc, :);
        legendALL_patch{nc} = customErrPlot(gca, tc, cndMu(:, nc), cndS(:, nc), ...
            clr, 'RC1 pooled over groups', plotSettings.linestyles{nc});        
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
