function rcaExtra_plotCompareGroups_time(plotSettings, varargin)

% function plots results of rc analysis in frequency domain.
% all groups will be displayed together per harmonic multiple for each RC
% INPUT ARGUMENTS:
% varargin: arbitrary number of rcaResult structures, must be > 1
% fields in use for each rcResult structure:
% rcaResult.rcaSettings.nComp --number of RC comps
% rcaResult.mu_cnd -- average per group per condition
% rcaResult.s_cnd -- average per group per condition
% rcaResult.timecourse -- timecourse, if varies, minimum length will be
% used for plotting

% plotSettings can be empty
    
    % check number of groups
    if (nargin == 1)
        fprintf('Use rcaExtra_plotCompareConditions_time for condition comparison within a group \n');
        return;
    end
    
    % re-arrange data between groups into new rcResult structures
    % each new structure would be storing rcResult for each condition
    % combined across groups.
    
    % create template structure from first rcRresult input 
    rcaResultCondition_template = varargin{1};
    rcaResultGroups = varargin;
    
    % number of conditions per group
    nCndsPerGroup = cellfun(@(x) size(x.projectedData, 2), rcaResultGroups, 'uni', true);
    nCnd = unique(nCndsPerGroup);
    
    % if number of conditions varies, loop over minimum
    if (nCnd > 1)
        nCnd = min(nCnd);
    end
    
    % check timecourse duration for each group and use minimum (shortest)
    % in case it varies across groups
    
    nSamplesPerGroup = cellfun(@(x) size(x.timecourse, 2), rcaResultGroups, 'uni', true);
    durationPerGroup = cellfun(@(x) x.timecourse(end), rcaResultGroups, 'uni', true);
    nSamples = min(nSamplesPerGroup);
    rcaResultCondition_template.timecourse = linspace(0, min(durationPerGroup), nSamples);
    
    % fields that will be merged together by condition:
    % rcaResultCondition_template.mu_cnd
    % rcaResultCondition_template.s_cnd
    for nc = 1:nCnd
        %merge group data by condition
        groupsMu = cellfun(@(x) x.mu_cnd(:, :, nc), rcaResultGroups, 'uni', false);
        groupsStd = cellfun(@(x) x.s_cnd(:, :, nc), rcaResultGroups, 'uni', false);
        
        % combine all 
        rcaResultCondition_template.mu_cnd = cat(3, groupsMu{:});
        rcaResultCondition_template.s_cnd = cat(3, groupsStd{:});
          
        plotSettings_cnd = plotSettings;
        plotSettings_cnd.useColors = squeeze(plotSettings.colors.interleaved(nc, :, :));
        
        
        % create groups+condition labels for legends
        if (~isempty(plotSettings) && ~isempty(plotSettings.legendLabels))
            %plotSettings_cnd.legendLabels = cellfun(@(x) strcat(x, ' ', num2str(nc)))
        end
                
        % call condition plotting
        rcaExtra_plotCompareConditions_time(plotSettings_cnd, rcaResultCondition_template);
        
        % comment plot settings
    end
end

