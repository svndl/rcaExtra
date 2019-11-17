function [muData, semData] = projectAvgData(data, weights)
    nSensors = size(weights, 1);
    nRcs = size(weights, 2);
    avgData = cellfun(@(x) nanmean(x, 3), data, 'uni', false);
    % workaround to accomodate the 'all' channels case
    if (nRcs < nSensors)
        dataOut = rcaProject(avgData, weights);
    else
        dataOut = avgData;
    end
    catData = cat(3, dataOut{:});
    muData = nanmean(catData, 3);
    semData = nanstd(catData, [], 3)/(sqrt(size(catData, 3)));   
    
    %baselining
    muData = muData - repmat(muData(1, :), [size(muData, 1) 1]);
end
