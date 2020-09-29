function [amp, phase] = computeAmpPhase(dataRe, dataIm)
% Alexandra Yakovleva, Stanford University 2012-1020
    nCnd = size(dataRe, 2);
    nSubj = size(dataRe, 1);
    amp = cell(nCnd, nSubj);
    phase = amp;
    for c = 1:nCnd
        amp(c, :) = cellfun(@(x, y) sqrt(x.^2 + y.^2), dataRe(:, c), dataIm(:, c), 'uni', false);
        phase(c, :) = cellfun(@(x, y) angle(complex(x, y)), dataRe(:, c), dataIm(:, c), 'uni', false);
    end
end