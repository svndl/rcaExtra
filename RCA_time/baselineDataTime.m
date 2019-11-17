function out = baselineDataTime(data, idIdx)

    m1 = nanmean(data(1:idIdx));   
    out = data - m1;
end