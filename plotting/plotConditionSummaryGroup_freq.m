function fHandles = plotConditionSummaryGroup_freq(f, groupData)

%% INPUT:
    % groupData is a structure with following elements: 
    % groupData.amp = values amp, 
    % groupData.phase = values phase, 
    % groupData.EllipseError = error ellipses
    % groupData.stats -- values for statistical info (computed between conditions and between groups)
    % groupData.A -- topography
    % groupData.label -- group label
    
      
    plotSettings = getOnOffPlotSettings('groups', 'Frequency');    
            
    close all;
    
    nCompTotal = size(groupData.amp, 2);
    fHandles = cell(nCompTotal, 1);
    
    % plotting RCs
    for comp = 1:nCompTotal
        fHandles{comp} = plotComponentSummary(comp, f, groupData, plotSettings);        
    end    
end
