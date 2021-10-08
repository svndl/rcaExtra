function groupFigure = plotGroups_time(tc, groupLabels, groupMu, groupS)
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
      
        
    nGroups = numel(groupLabels);
    legendALL_patch = cell(nGroups, 1);
    
    plotSettings = getOnOffPlotSettings('groups', 'Time');    
    
    % close all figures
    close all;  
       
    groupFigure = figure;
    set(groupFigure, 'units','normalized','outerposition',[0 0 1 1]);

     
    for ng = 1:nGroups
        clr = plotSettings.colors(ng, :);
        legendALL_patch{ng} = customErrPlot(gca, tc, groupMu(:, ng), groupS(:, ng), ...
            clr, 'RC1 pooled over polarity', plotSettings.linestyles{ng});        
    end
    if (plotSettings.showlegends)
        
        allLabels = groupLabels;
        legend(gca, [legendALL_patch{:}], allLabels(:), 'Interpreter', 'none');
    end
    
    xlabel('Time (msec)') % x-axis label
    ylabel('Amplitude (\muV)') % y-axis label
    
    set(gca, plotSettings.axesprops{:});
    pbaspect(gca, [1 1 1]);    
end