function [dA, dF, ellipse] = fitErrorEllipse_3DSweep(dataRe, dataIm)
% will fit error ellipse for multidimentional data
% dataRe, dataIm are nFx nComp xnSamples
% LLV: modified for sweeps
% Alexandra Yakovleva, Stanford University 2012-1020
nBins = size(dataRe, 1);
nFreqs = size(dataRe, 2);
nComps = size(dataRe, 3);


dA = zeros(nBins, nFreqs, nComps, 2);
dF = zeros(nBins, nFreqs, nComps, 2);

ellipse = cell(nBins, nFreqs, nComps);
for b = 1:nBins
    for f = 1:nFreqs
        for c = 1:nComps
            % grab samples
            currData_Re = squeeze(dataRe(b, f, c, :));
            currData_Im = squeeze(dataIm(b, f, c, :));
            
            % drop NaN values
            % data dims: nSamples x 2
            xyData = [currData_Re, currData_Im];
            nanVals = sum(isnan(xyData), 2) > 0;
            validData = xyData(~nanVals, :);
            try
                [dA(b, f, c, :), dF(b, f, c, :), ~ , ellipse{b, f, c}] = ...
                    fitErrorEllipse(validData, [], [], 1);
            catch err
                rcaExtra_displayError(err);
                ellipse{b, f, c} = [];
            end
        end
    end
end
end