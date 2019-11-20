function out = baselineDataTime(data, idIdx)

% Alexandra Yakovleva, Stanford University 2012-2020
% baselining time data

    m1 = nanmean(data(1:idIdx));   
    out = data - m1;
end
