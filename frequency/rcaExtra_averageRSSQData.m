function out = rcaExtra_averageRSSQData(inputData, nBins, nFreqs)

    [rssq_vals, rssq_weights] = calculatewRSSQ(inputData, nBins, nFreqs);
    
    [nSubjs, nCnds, nRCs] = size(rssq_vals);
    rssqProjMean_CND = zeros(nCnds, nRCs);
    rssqProjStd_CND = zeros(nCnds, nRCs);
    
    rssqProjMean = zeros(nRCs, 1);
    rssqProjStd = zeros(nRCs, 1);

    for nrc = 1:nRCs
        % project-level average:
        cndWMeanPerSubj =  wmean(rssq_vals(:,:, nrc), rssq_weights, 2);
        wSum = sum(rssq_weights, 2);
        rssqProjMean(nrc) = wmean(cndWMeanPerSubj, wSum);
        rssqProjStd(nrc) = std(cndWMeanPerSubj, wSum);
        % condition (or sub-factor) average
        for nc = 1:nCnds
            rssqProjMean_CND(nc, nrc) = wmean(rssq_vals(:, nc, nrc), rssq_weights(:, nc));
            rssqProjStd_CND(nc, nrc) = std(rssq_vals(:, nc, nrc), rssq_weights(:, nc)/100);
        end
    end
end