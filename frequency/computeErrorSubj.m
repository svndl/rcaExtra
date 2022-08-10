function [pVal, dE] = computeErrorSubj(dataRe, dataIm)
% Alexandra Yakovleva, Stanford University 2012-1020

    nSubj = size(dataRe, 1);
    nCnd = size(dataRe, 2);
    dE = cell(nSubj, nCnd);
    pVal = cell(nSubj, nCnd);
    
    for cn = 1:nCnd
        allSubj_re = squeeze(dataRe(:, cn));
        allSubj_im = squeeze(dataIm(:, cn));
        [pVal(:, cn), dE(:, cn)] = ...
            cellfun(@(x, y) computeErrTCirc(x, y), ...
            allSubj_re, allSubj_im, 'uni', false);
    end
end

function [pVal, errDiff] = computeErrTCirc(reVec, imVec)
    nFreq = size(reVec, 1);
    % number of components
    nComp = size(reVec, 2);
    errDiff = zeros(nFreq, nComp);
    pVal = zeros(nFreq, nComp);
    
    for nf = 1:nFreq
        for cp = 1:nComp
            reData = squeeze(reVec(nf, cp, :));
            imData = squeeze(imVec(nf, cp, :));
            %% using nanstd instead of the tcirc here?
              
            validIdx = (~isnan(reData)) & squeeze(~isnan(imData));
            data = complex(reData(validIdx), imData(validIdx));
            try
                [pVal(nf, cp), errDiff(nf, cp), ~, ~] = tcirc(data);
            catch err
                disp('Failed to calc tcirc');
                rcaExtra_displayError(err);
            end    
        end
    end
end