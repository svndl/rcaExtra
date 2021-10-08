function rcaExtra_plotCompareGroups_freq(plotSettings, varargin)

% function plots results of rc analysis in frequency domain.
% all groups will be displayed together per harmonic multiple for each RC
% INPUT ARGUMENTS:
% varargin: arbitrary number of rcaResult structures, must be > 1
% fields in use:
% rcaResult.rcaSettings.nComp --number of RC comps
% rcaResult.projAvg -- average project-lvl data
% rcaResult.rcaSettings.useFrequenciesHz for latency estimate calculation, plot labels;
% rcaResult.rcaSettings.useFrequencies labels for latency fitting, labels;
% rcaResult.rcaSettings.
% plotSettings can be empty
    
    % check number of groups
    if (nargin == 1)
        fprintf('Use rcaExtra_plotCompareConditions_freq for condition comparison within a group \n');
        return;
    end
    % re-arrange data between groups into new rcResult structures
    % each new structure would be storing rcResult for each condition
    % combined across groups.
    
    % create template structure from first rcRresult input 
    rcaResultCondition_template = varargin{1};
    if (isempty(plotSettings))
       % fill settings template
       plotSettings = rcaExtra_getPlotSettings(rcaResultCondition_template);
       plotSettings.Title = '';
       plotSettings.RCsToPlot = 1:3;
       plotSettings.groupLegends = cellfun(@(x) strcat('Group ', num2str(x)), 1:nargin, 'uni', false);
       % legend background (transparent)
       % xTicks labels
       % xAxis, yAxis labels
       % hatching (yes/no) 
       % plot title       
    end        

    rcaResultGroups = varargin;
    
    % number of conditions per group
    nCndsPerGroup = cellfun(@(x) size(x.projAvg.ellipseErr, 1), rcaResultGroups, 'uni', true);
    nCnd = unique(nCndsPerGroup);
    % if number of conditions varies, loop over minimum
    if (nCnd > 1)
        nCnd = min(nCnd);
    end
    
    % fields that will be merged together by condition:
    % rcaResultCondition_template.projAvj.amp
    % rcaResultCondition_template.projAvj.phase
    % rcaResultCondition_template.projAvj.errA
    % rcaResultCondition_template.projAvj.errP
    % rcaResultCondition_template.projAvj.ellipseErr
    for nc = 1:nCnd
        %merge group data by condition
        groupsAmp = cellfun(@(x) x.projAvg.amp(:, :, nc), rcaResultGroups, 'uni', false);
        groupsPhase = cellfun(@(x) x.projAvg.phase(:, :, nc), rcaResultGroups, 'uni', false);
        groupsErrA = cellfun(@(x) x.projAvg.errA(:, :, nc, :), rcaResultGroups, 'uni', false);
        groupsErrP = cellfun(@(x) x.projAvg.errP(:, :, nc, :), rcaResultGroups, 'uni', false);
        groupsErrEllipse = cellfun(@(x) x.projAvg.ellipseErr{nc}, rcaResultGroups, 'uni', false);
        
        % combine all 
        rcaResultCondition_template.projAvg.amp = cat(3, groupsAmp{:});
        rcaResultCondition_template.projAvg.phase = cat(3, groupsPhase{:});
        rcaResultCondition_template.projAvg.ellipseErr = groupsErrEllipse';
        
        % error dimentions are nF x nComp x nCnd x 2 
        rcaResultCondition_template.projAvg.errA = cat(3, groupsErrA{:});
        rcaResultCondition_template.projAvg.errP = cat(3, groupsErrP{:});
        
        plotSettings_cnd = plotSettings;
        
        % won't work for more than 2 groups, need to fix
        plotSettings_cnd.useColors = squeeze(plotSettings.useColors(ng, :, :));
        
        % group 1 Condition A, B
        % group 2 Condition A, B
        % group 3 Condition A, B
        
        % creating a joint group where we merge together datafrom same conditions 
        
        % Group A: Group 1 condition A, Group 2 Condition A, Group 3 Condition A
        
        % Group B: Group 1 Condition B, Group 2 Condition B, Group 3 Condition B
        
        % create groups+condition labels for legends
        if (~isempty(plotSettings) && ~isempty(plotSettings.legendLabels))
            
            plotSettings_cnd.legendLabels = cellfun(@(x, y) strcat(x, y), ...
                plotSettings.groupLegends, ...
                repmat(plotSettings.legendLabels(nc), [1 numel(rcaResultGroups)]), ...
                'uni', false);
        end
        % call condition plotting
        rcaExtra_plotCompareConditions_freq(plotSettings_cnd, rcaResultCondition_template);
        
        % comment plot settings
    end
end

