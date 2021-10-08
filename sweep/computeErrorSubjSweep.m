function dE = computeErrorSubjSweep(dataRe, dataIm)
% Alexandra Yakovleva, Stanford University 2012-1020

nSubj = size(dataRe, 1);
nCnd = size(dataRe, 2);
dE = cell(nSubj, nCnd);
for c = 1:nCnd
    allSubj_re = squeeze(dataRe(:, c));
    allSubj_im = squeeze(dataIm(:, c));
    dE(:, c) = ...
        cellfun(@(x, y) computeErrTCirc(x, y), ...
        allSubj_re, allSubj_im, 'uni', false);
end
end

function errDiff = computeErrTCirc(reVec, imVec)
nB = size(reVec, 1);
% number of components
nF = size(reVec, 2);
nC = size(reVec, 3);
errDiff = zeros(nF, nC);
for b = 1:nB
    for f = 1:nF
        for c = 1:nC
            reData = squeeze(reVec(b, f, c, :));
            imData = squeeze(imVec(b, f, c, :));
            validIdx = (~isnan(reData)) & squeeze(~isnan(imData));
            data = complex(reData(validIdx), imData(validIdx));
            try
                [~, errDiff(b, c), ~, ~] = tcirc(data);
            catch err
                disp('Failed to calc tcirc');
            end
        end
    end
end
end