function statData = rcaExtra_runStatsAnalysis(rcaResult1, rcaResult2, varargin)

% Function runs statistical analysis and displays results
% Input arguments:

% rcaResult1 rcaResult structure, time/frequency domain), tyo be tested
% against zero
% 
% rcaResult2 optional second rcaResult strucfture. If not empty, for each 
% conditions will be tested against rcaResult1 for significance 
    
    % if there is a second data structure
    hasSecondResultStruct = ~isempty(rcaResult2);
    
    if (hasSecondResultStruct)
        % make sure both results were computed in same domain        
        if (~strcmp(rcaResult2.rcaSettings.domain, ...
                rcaResult1.rcaSettings.domain))
            fprintf('Both results have to be computed in same domain \n');
            return;
        end
        
        % numer of components should match
        if (rcaResult2.rcaSettings.nComp ~= rcaResult1.rcaSettings.nComp)
            fprintf('Both results need to have same number of RC components\n');
            return;
        end
        % numer of conditions should match
        if (size(rcaResult2.projectedData, 2) ~= ...
                size(rcaResult1.projectedData, 2))
            fprintf('Both results need to have same number of condition\n');
            return;
        end
        
        % for frequency domain, match harmonic multiples
        if (strcmp(rcaResult2.rcaSettings.domain, 'freq'))
            freqIdx1 = cellfun(@(x) str2double(x(1)), rcaResult1.rcaSettings.useFrequencies, 'uni', true);
            freqVals1 = rcaResult1.rcaSettings.useFrequenciesHz*freqIdx1';
            
            freqIdx2 = cellfun(@(x) str2double(x(1)), rcaResult2.rcaSettings.useFrequencies, 'uni', true);
            freqVals2 = rcaResult2.rcaSettings.useFrequenciesHz*freqIdx2';
            if (~isequal(freqVals2, freqVals1))
                fprintf('Both results need to have same harmonic multiples \n');
                return;
            end
        end       
    end
    statSettings = rcaExtra_getStatsSettings(rcaResult1.rcaSettings);
    
    if (~isempty(varargin))
        statSettings.testWithin = 1;
    end
        
    % compute mean for rc1
    subjRCMean1 = rcaExtra_prepareDataArrayForStats(rcaResult1.projectedData, statSettings);
    % init mean for optional second rc result structure
    subjRCMean2 = [];
    % if not empty, compute across subj mean 
    if (hasSecondResultStruct)
        statSettings2 = rcaExtra_getStatsSettings(rcaResult2.rcaSettings);
        subjRCMean2 = rcaExtra_prepareDataArrayForStats(rcaResult2.projectedData, statSettings2);
    end
    
    % compute stats   
    
%   settings.ttestType (string): type of ttest, values: {'paired',
%   'unpaired'}
    
    try
        statData = rcaExtra_testSignificance(subjRCMean1, subjRCMean2, statSettings);
    catch err
        rcaExtra_displayError(err)
    end
end