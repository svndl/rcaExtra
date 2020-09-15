function [latencyVals, latencyErrs] = rcaExtra_computeLatencies(rcaResult)
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
    nF = numel(freqIdx);
    [~, nComp, nCnd] = size(rcaResult.projAvg.phase);
    latencyVals = zeros(nComp, nCnd);
    latencyErrs = zeros(nComp, nCnd);
    for rc = 1:nComp
        
        rcaAngles = squeeze(rcaResult.projAvg.phase(:, rc, :));
        values_unwrapped = unwrapPhases(rcaAngles);
        for c = 1:nCnd

            [Pc, ~] = polyfit(freqVals, values_unwrapped(:, c), 1);
       
            yfit = Pc(1)*freqVals + Pc(2);
    
            latencyVals(rc, c) = 1000*Pc(1)/(2*pi);    
            d = (yfit - values_unwrapped(:, c)).^2;
            dMs = 1000*d/(2*pi);
        
            %dd = sqrt(sum(d)/(nF - 2)); 
            latencyErrs(rc, c) = sqrt(sum(dMs)/(nF - 2));
        end
    end
end