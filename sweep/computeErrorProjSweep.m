function [ampDiff, phaseDiff, ellipse] = computeErrorProjSweep(dataRe, dataIm)
% Alexandra Yakovleva, Stanford University 2012-1020
% modified by LLV for sweeps
    nCnd = size(dataRe, 2);
    ampDiff = cell(nCnd, 1);
    phaseDiff = cell(nCnd, 1);
    ellipse = cell(nCnd, 1);
    for c = 1:nCnd
        cndRe = (cat(4, dataRe{:, c}));
        cndIm = (cat(4, dataIm{:, c}));

        [ampDiff{c}, phaseDiff{c}, ellipse{c}] = fitErrorEllipse_3DSweep(cndRe, cndIm);
        % store ellipse
    end
end