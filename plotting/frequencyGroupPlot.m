function group = plotGroups_freq(groupLabels, varargin)

%% INPUT:
    % varargin -- proj groups + labels: {group1, group2, groupLabels, conditionLabels, componentLabels}
    % Each group is a structure with following elements: 
    % groupX.amp = values amp, 
    % groupX.phase = values phase, 
    % groupX.EllipseError = error ellipses
    % groupX.stats -- values for statistical info (computed between conditions and between groups)  
    
    % groupX = {Values(nCnd x nComp x nFreq) Errors (nCnd x nComp x nFreq)}

            

    barplotGroups(group1, group2, labels, settings);
    %% 
end

