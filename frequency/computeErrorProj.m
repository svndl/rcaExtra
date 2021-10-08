function [ampDiff, phaseDiff, ellipse] = computeErrorProj(dataRe, dataIm)
% Alexandra Yakovleva, Stanford University 2012-1020
    nCnd = size(dataRe, 2);
    ampDiff = cell(nCnd, 1);
    phaseDiff = cell(nCnd, 1);
    ellipse = cell(nCnd, 1);
    for c = 1:nCnd
        cndRe = (cat(3, dataRe{:, c}));
        cndIm = (cat(3, dataIm{:, c}));

        [ampDiff{c}, phaseDiff{c}, ellipse{c}] = fitErrorEllipse_3D(cndRe, cndIm);
        % store ellipse
    end
end