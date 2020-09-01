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
        
        % create groups+condition labels for legends
        if (~isempty(plotSettings) && ~isempty(plotSettings.legendLabels))
            %plotSettings_cnd.legendLabels = cellfun(@(x) strcat(x, ' ', num2str(nc)))
        end
                
        % call condition plotting
        rcaExtra_plotCompareConditions_freq(plotSettings_cnd, rcaResultCondition_template);
        
        % comment plot settings
    end
end

