function dE = computeErrorSubj(dataRe, dataIm)
% Alexandra Yakovleva, Stanford University 2012-1020

    nSubj = size(dataRe, 2);
    nCnd = size(dataRe, 1);
    dE = cell(nCnd, nSubj);
    for c = 1:nCnd
        allSubj_re = squeeze(dataRe(c, :));
        allSubj_im = squeeze(dataIm(c, :));
        dE(c, :) = ...
            cellfun(@(x, y) computeErrTCirc(x, y), ...
            allSubj_re, allSubj_im, 'uni', false);
    end
end

function errDiff = computeErrTCirc(reVec, imVec)
    nF = size(reVec, 1);
    % number of components
    nC = size(reVec, 2);
    errDiff = zeros(nF, nC);
    for f = 1:nF
        for c = 1:nC
            reData = squeeze(reVec(f, c, :));
            imData = squeeze(imVec(f, c, :));
            validIdx = (~isnan(reData)) & squeeze(~isnan(imData));
            data = complex(reData(validIdx), imData(validIdx));
            try
                [~, errDiff(f, c), ~, ~] = tcirc(data);
            catch err
                disp('Failed to calc tcirc');
            end    
        end
    end
end