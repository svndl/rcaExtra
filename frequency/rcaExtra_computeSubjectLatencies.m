function [latencyVals, latencyErrs] = rcaExtra_computeSubjectLatencies(rcaResult)
% Function will compute latencies based on frequency info, 
% stimulation frequency F and harmonic multiples, and angle values.

% Input args: rcaResult structure
% Fields used for computation:

% rcaResult.rcaSettings.useFrequencies  -- cell array of harmonic multiples
% rcaResult.rcaSettings.useFrequenciesHz -- double value of stimulus frequency
% rcaResult.subjAvg.phase -- angle values, 4D matrix of nF x nRc x nSubj nCnd


% Output args:

% latencyVals 3D array, computed latencies (msec), nSubj x nRCs x nCnd
% latencyErrs 3D array, computed latency error estimates (msec), symmetric,  nSubj x nRCs x nCnd

    %
    freqIdx = cellfun(@(x) str2double(x(1)), rcaResult.rcaSettings.useFrequencies, 'uni', true);
    freqVals = rcaResult.rcaSettings.useFrequenciesHz*freqIdx';
    
    nF = numel(freqIdx);
    [~, nComp, nSubj, nCnd] = size(rcaResult.subjAvg.phase);
    latencyVals = zeros(nSubj, rcaResult.rcaSettings.nComp, nCnd);
    latencyErrs = zeros(nSubj, rcaResult.rcaSettings.nComp, nCnd);
    for s = 1:nSubj
        for rc = 1:nComp
            for c = 1:nCnd
                rcaAngles = squeeze(rcaResult.subjAvg.phase(:, rc, s, c));
                values_unwrapped = unwrapPhases(rcaAngles);

                [Pc, ~] = polyfit(freqVals, values_unwrapped, 1);
       
                yfit = Pc(1)*freqVals + Pc(2);
    
                latencyVals(s, rc, c) = 1000*Pc(1)/(2*pi);    
                d = (yfit - values_unwrapped).^2;
                dMs = 1000*d/(2*pi);
        
                %dd = sqrt(sum(d)/(nF - 2)); 
                latencyErrs(s, rc, c) = sqrt(sum(dMs)/(nF - 2));
            end
        end
    end
end