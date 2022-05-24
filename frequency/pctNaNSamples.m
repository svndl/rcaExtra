function out = pctNaNSamples(sourceData3D)

    vectorizedData = sourceData3D(:);
    out = 100*sum(isnan(vectorizedData))/numel(vectorizedData);
end