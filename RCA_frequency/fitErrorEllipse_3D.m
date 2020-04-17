function [dA, dF, ellipse] = fitErrorEllipse_3D(dataRe, dataIm)
% will fit error ellipse for multidimentional data
% dataRe, dataIm are nFx nComp xnSamples
% Alexandra Yakovleva, Stanford University 2012-1020
    nF = size(dataRe, 1);
    nC = size(dataRe, 2);
    
    dA = zeros(nF, nC, 2);
    dF = zeros(nF, nC, 2);
    
    ellipse = cell(nF, nC);
    for f = 1:nF
        for c = 1:nC
            % grab samples
            currData_Re = squeeze(dataRe(f, c, :));
            currData_Im = squeeze(dataIm(f, c, :));
            
            % drop NaN values
            % data dims: nSamples x 2 
            xyData = [currData_Re, currData_Im];
            nanVals = sum(isnan(xyData), 2) > 0;
            validData = xyData(~nanVals, :);
            try
                [dA(f, c, :), dF(f, c, :), ~ , ellipse{f, c}] = ...
                    fitErrorEllipse(validData, [], [], 1);
            catch
               ellipse{f, c} = [];
            end
        end
    end
end