function out = rcaExtra_computeSweepAverages(rcaResult)
% function will compute supplemental mean and error values used for plotting and stats
% Alexandra Yakovleva, Stanford University 2020
% LLV temporary high-level averaging function for sweeps data, treated in
% frequency domain for now. Will allow to average sweep data both in time-
% and frequency-domain in the future

    % copy structure
    out = rcaResult;
    
    switch(rcaResult.rcaSettings.domain)
        case 'sweep'
            % compute average data
            [projAvg, subjAvg, subjProjected] = averageSweepData(rcaResult.projectedData, ...
                numel(rcaResult.rcaSettings.useBins), numel(rcaResult.rcaSettings.useFrequencies));
            out.projAvg = projAvg;
            out.subjAvg = subjAvg;
            out.subjProj = subjProjected;

            % add noise averaging, old structures might not have the field
            if (isfield(rcaResult, 'noiseData'))
                try
                    [noiseLowAvg, ~, ~] = averageSweepData(rcaResult.noiseData.lowerSideBand, ...
                        numel(rcaResult.rcaSettings.useBins), numel(rcaResult.rcaSettings.useFrequencies));
            
                    [noiseHighAvg, ~, ~] = averageSweepData(rcaResult.noiseData.higherSideBand, ...
                        numel(rcaResult.rcaSettings.useBins), numel(rcaResult.rcaSettings.useFrequencies));
                catch err
                    rcaExtra_displayError(err);
                    noiseLowAvg = projAvg;
                    noiseHighAvg = projAvg;                    
                end
                out.noiseLowAvg = noiseLowAvg;
                out.noiseHighAvg = noiseHighAvg;
            end
        otherwise
            error('not implemented. check your rcaRes.rcaSettings.domain flag.');
    end
end