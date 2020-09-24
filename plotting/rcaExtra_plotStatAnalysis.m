function rcaExtra_plotStatAnalysis(rcaResult1, rcaResult2, statData, plotSettings)
% function will do usual plotting routine (time or frequency domain),
% with the addition of statistical significance testing. 

% Input args: 

    % plotSettings -- optional
    % rcaResult1 -- results structure for dataset 1
    % rcaResult2 -- results structure for second dataset, optional

    % plot results with significance for time domain
    
    % creat default plot settings template 
    if (isempty(plotSettings))
       % fill settings template
%        plotSettings = rcaExtra_getPlotSettings(rcaResult1.rcaSettings);
%        plotSettings.legendLabels = arrayfun(@(x) strcat('Condition ', num2str(x)), ...
%            1:size(rcaResult1.projAvg.ellipseErr, 1), 'uni', false);
%        % default settings for all plotting: 
%        % font type, font size
%        
%        plotSettings.Title = 'Lollipop Plot';
%        plotSettings.RCsToPlot = 1:3;
%        % legend background (transparent)
%        % xTicks labels
%        % xAxis, yAxis labels
%        % hatching (yes/no) 
%        % plot title 
        
        
        
    end
    switch rcaResult1.rcaSettings.domain
        case 'time'
            % if two datasets, do group comparision plot
            if (hasSecondResultStruct)
                % concatenate mean and std for each RC/Condition
                % display and add stats bar
                % 
            end
        case 'freq'
            % remove all non-significant harmonics multples from
            % projected data and then compute averages
            %% todo

            % for multiple conditions, remove pairwise
            avgStruct1 = rcaExtra_computeAverages(rcaResult1);
            if (hasSecondResultStruct)
                avgStruct2 = rcaExtra_computeAverages(rcaResult2);    
            end
            
            % concatenate amp, phase, error ellipses
            % remove non-significant frequencies
            
    end


end