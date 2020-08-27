function rcaExtra_plotCompareGroups_freq(plotSettings, varargin)

% function plots results of rc analysis in frequency domain.
% all conditions will be displayed together per harmonic multiple for each RC
% INPUT ARGUMENTS:
% varargin: arbitrary number of rcaResult structures
% fields in use:
% rcaResult.rcaSettings.nComp --number of RC comps
% rcaResult.projAvg -- average project-lvl data
% rcaResult.rcaSettings.useFrequenciesHz for latency estimate calculation, plot labels;
% rcaResult.rcaSettings.useFrequencies labels for latency fitting, labels;
% rcaResult.rcaSettings.
% plotSettings can be empty

    nGroups = nargin - 1;
    groupRCAData = varargin;
    
    % re-arrange data between groups into new rcResult structures
    % each new structure would be storing rcResult for each condition
    % combined across groups.
    
    % create template structure from first rcRresult input
    
    rcaResultCondition_template = varargin{1};
    
    % number of conditions per group
    nCndsPerGroup = cellfun(@(x) size(x.projAvj.amp, 1), 'uni', true);
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
        groupsAmp = cellfun(@(x) x.projAvj.amp(:, :, nc), 'uni', false);
        groupsPhase = cellfun(@(x) x.projAvj.phase(:, :, nc), 'uni', false);
        groupsErrA = cellfun(@(x) x.projAvj.errA(:, :, nc, :), 'uni', false);
        groupsErrP = cellfun(@(x) x.projAvj.errP(:, :, nc, :), 'uni', false);
        groupsErrEllipse = cellfun(@(x) x.projAvj.ellipseErr{nc}, 'uni', false);
        rcaResultCondition_template.projAvj.amp = groupsAmp;
        rcaResultCondition_template.projAvj.phase = groupsPhase;
        rcaResultCondition_template.projAvj.ellipseErr(1, 1) = groupsErrEllipse;
        
        rcaResultCondition_template.projAvj.errA = groupsErrA;
        rcaResultCondition_template.projAvj.errP = groupsErrP;
        
        % create group labels for legends
        plotSettings_cnd = plotSettings;
        
        % call condition plotting
        rcaExtra_plotCompareConditions_freq(plotSettings, rcaResultCondition_template)
    end
end

