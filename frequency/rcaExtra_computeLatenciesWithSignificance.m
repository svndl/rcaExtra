function [latencyVals, latencyErrs] = rcaExtra_computeLatenciesWithSignificance(rcaResult, statData)
% Function will compute latencies based on frequency info, 
% stimulation frequency F and harmonic multiples, and angle values.

% Input args: rcaResult structure
% Fields used for computation:

% rcaResult.rcaSettings.useFrequencies  -- cell array of harmonic multiples
% rcaResult.rcaSettings.useFrequenciesHz -- double value of stimulus frequency
% rcaResult.projAvg.phase -- angle values, 3D matrix of nF x nRc x nCnd


% Output args:

% latencyVals 2D array, computed latencies (msec), nRCs x nCnd
% latencyErrs 2D array, computed latency error estimates (msec), symmetric,  nRCs x nCnd

    freqIdx = cellfun(@(x) str2double(x(1)), rcaResult.rcaSettings.useFrequencies, 'uni', true);
    freqVals = rcaResult.rcaSettings.useFrequenciesHz*freqIdx';
    rcaResult_avg = rcaResult;
    if (~isfield(rcaResult, 'projAvg'))
        rcaResult_avg = rcaExtra_computeAverages(rcaResult);
    end    
    [~, nComp, nCnd] = size(rcaResult_avg.projAvg.phase);
    latencyVals = NaN*ones(nComp, nCnd);
    latencyErrs = Inf*ones(nComp, nCnd);
    for rc = 1:nComp
        
        rcaAngles = squeeze(rcaResult_avg.projAvg.phase(:, rc, :));
        values_unwrapped = unwrapPhases(rcaAngles);
        for c = 1:nCnd
            significance_RC = statData.sig(:, rc, c);            
            significantIdx = (significance_RC > 0)';
            significantFreqs = freqVals(significantIdx);
            nF = sum(significantIdx);
            if (nF >= 2)
                try
                    [Pc, ~] = polyfit(significantFreqs, values_unwrapped(significantIdx, c), 1);
       
                    yfit = Pc(1)*significantFreqs + Pc(2);
    
                    latencyVals(rc, c) = 1000*Pc(1)/(2*pi);    
                    d = (yfit - values_unwrapped(significantIdx, c)).^2;
                    dMs = 1000*d/(2*pi);
        
                    %dd = sqrt(sum(d)/(nF - 2)); 
                    latencyErrs(rc, c) = sqrt(sum(dMs)/(nF - 2));
                catch err
                    rcaExtra_displayError(err);
                end
            end
        end
    end
end