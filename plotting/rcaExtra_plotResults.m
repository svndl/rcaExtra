function gcfHandles = rcaExtra_plotResults(varargin)
% plotting results of RC analysis
% Alexandra Yakovleva, Stanford University 2020
% varargin: cell array of dataStructures: rcaExtra_plotResults(data1,
% data2, ..., dataN, plotSettings);

% dataStructure has different fields depending on the time/frequency domain
% analysis.

% For time domain the required fields are:
    % dataStructure.mean (timepoints x nRCs x conditions/groups)
    % dataStructure.std (timepoints x nRCs x conditions/groups)
    % dataStructure.labels

% for Frequency domain the required fields are 

% both time and frequency domain: 
    % dataStructure.stats


% plotSettings describes HOW to plot and what exactly to plot
% plotSettings.domain = freq plots lolliplots, amplitude and latency 
% plotSettings.domain = time plots waveforms
% plotSettings.conditionsToPlot = [] vector of conditions to plot, empty plots everything
% plotSettings.rcToPlot = [] vector of RCs to plot, empty plots everything

    switch plotSettings.domain
        
        case 'time'
            
        case 'freq'
            
            
        otherwise
    end
end