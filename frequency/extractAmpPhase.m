function [amp, amp_err, phase, phase_err] = extractAmpPhase(inputData, nB, nF, W)


    % Arguments
    % inputData -- cell-organized source data (nCnd by nSubj, each subj is 2*nBins*nFreq x nChannels x nTotalTrials)
    % nB, nF, nCh -- total number of bins, frequencies, channels (for reshaping and avg)
    % W -- projection weights (nChannels x nComp for rc or nChannelsx1 for OZ projection)  
    
    
    
    
    %% subject average
    [ampS, error_ampS, phaseS, error_phaseS] = computeAvgBySubjects(inputData, nB, nF, W);
    %% Project average (each subject is a trial)    
    [ampP, error_ampP, phaseP, error_phaseP] = computeProjAverage(inputData, nB, nF, W);
    
    nComp = size(W, 2);
    %% RESHAPING and ordering the dims:
    %nCnd x nSubj x nF nComponents
    amp.Subj = reshape(cell2mat(ampS), [size(ampS, 1) size(ampS, 2) nF nComp]);
    phase.Subj = reshape(cell2mat(phaseS), [size(phaseS, 1) size(phaseS, 2) nF nComp]);
    
    %nCnd x nF x nComponents
    amp.Proj = reshape(cell2mat(ampP), [size(ampP, 1) nF nComp]);
    phase.Proj = reshape(cell2mat(phaseP), [size(phaseP, 1) nF nComp]);
    
    % nCnd x nSubj x nF nComponents x 2
    amp_err.Subj =  error_ampS;
    phase_err.Subj = error_phaseS;
    
    
    amp_err.Proj = error_ampP;    
    phase_err.Proj = error_phaseP;    
end
function [amp, error_amp, phase, error_phase] = computeProjAverage(inputData, nBins, nFreqs, W)
    %% split into real/imag data
    [data_Re, data_Im] = getRealImag(inputData);
    nComp = size(W, 2);
    nCh =  size(W, 1);
    nCnd = size(data_Re, 1);
    [Re, avg_Re] = averageProject(data_Re, nBins, nFreqs, nCh);
    
    [Im, avg_Im] = averageProject(data_Im, nBins, nFreqs, nCh);
    
    projected_Re = cell(nCnd, 1);
    projected_Im = projected_Re;
    
    for c = 1:nCnd
        cnd_Re = Re{c, :};
        cnd_Im = Im{c, :};
        mult_Re = zeros(nFreqs, size(cnd_Re, 3), nComp);
        mult_Im = mult_Re;
        for f = 1:nFreqs
            mult_Re(f, :, :) = squeeze(cnd_Re(f, :, :))'*W;
            mult_Im(f, :, :) = squeeze(cnd_Im(f, :, :))'*W;
        end
        projected_Re{c} = mult_Re;
        projected_Im{c} = mult_Im;
    end
    
    projected_avg_Re = cellfun(@(x) x*W, avg_Re, 'uni', false);
    projected_avg_Im = cellfun(@(x) x*W, avg_Im, 'uni', false);

    [amp, phase] = computeAmpPhase(projected_avg_Re, projected_avg_Im);
    [error_amp, error_phase] = computeErrorProj(projected_Re, projected_Im, nFreqs, nComp);
end
function [amp, error_amp, phase, error_phase] = computeAvgBySubjects(inputData, nB, nF, W)
    
    nCh = size(W, 1);
    nCmp = size(W, 2);
    [data_Re, data_Im] = computeSubjAvg(inputData, nB, nF, nCh);    
    proj_Re = cellfun(@(x) x*W, data_Re, 'uni', false);
    proj_Im = cellfun(@(x) x*W, data_Im, 'uni', false);
    
    % avg per subject!
    [amp, phase] = computeAmpPhase(proj_Re, proj_Im);
    [error_amp, error_phase] = computeErrorSubj(proj_Re, proj_Im, nF, nCmp);
end
function [wa_Re, wa_Im] = computeSubjAvg(dataIn, nBins, nFreqs, nComp)
    %% split into real/imag data
    [data_Re, data_Im] = getRealImag(dataIn);
    fhandle = 'computelWAbyTrial';
    args = {nBins, nFreqs, nComp};
    if (nBins == 1)
        fhandle = 'computeAvg';
        args = {};
    end
    wa_Re = feval(fhandle, data_Re, args{:});
    wa_Im = feval(fhandle, data_Im, args{:});
end
    
function wa = computelWAbyTrial(dataIn, nBins, nFreq, nComp)  
    % compute weighted avg across bins for each subj
    reshapedData = cellfun(@(x) reshape(x, [nBins nFreq nComp size(x, 3)]), dataIn, 'uni',false);  
    meanBySubj = cellfun(@(x) squeeze(nanmean(x)), reshapedData, 'uni',false);
    %weights = cellfun(@(x) sum(~isnan(x), 4), reshapedData, 'uni',false);
    nCnd = size(meanBySubj, 1);
    nSubj = size(meanBySubj, 2);
    wa = cell(nCnd, nSubj);
    for c = 1:nCnd
        cS = meanBySubj(c, :);
        wa(c, :) = cellfun(@(x) squeeze(nanmean(x, 3)), cS, 'uni', false);
        %cW = weights(c, :);
        %wa(c, :) = cellfun(@(x, y) squeeze(wmean(x, y)), cS, cW, 'uni', false);
    end
end
function wa = computeAvg(dataIn)
    wa = cellfun(@(x) nanmean(x, 3), dataIn, 'uni',false);
%     weights = cellfun(@(x) sum(~isnan(x), 3), dataIn, 'uni',false);
%     nCnd = size(dataIn, 1);
%     nSubj = size(dataIn, 2);
%     wa = cell(nCnd, nSubj);
%     for c = 1:nCnd
%         cS = meanBySubj(c, :);
%         cW = weights(c, :);
%         wa(c, :) = cellfun(@(x, y) squeeze(wmean(x, y)), cS, cW, 'uni', false);
%     end
end

% each subject is a trial
function [proj, avgProj] = averageProject(dataIn, nBins, nFreq, nComp)
    if (nBins > 1)
        reshapedData = cellfun(@(x) reshape(x, [nBins nFreq nComp size(x, 3)]), dataIn, 'uni',false);  
        meanBySubj = cellfun(@(x) squeeze(nanmean(x)), reshapedData, 'uni',false);
    else
        meanBySubj = dataIn;
    end
    nCnd = size(meanBySubj, 1);
    proj = cell(nCnd, 1);
    for c = 1:nCnd
        proj{c} = cat(3, meanBySubj{c, :});
    end
    avgProj = cellfun(@(x) nanmean(x, 3), proj, 'uni', false); 
end

function [amp, phase] = computeAmpPhase(dataRe, dataIm)
    amp = cellfun(@(x, y) sqrt(x.^2 + y.^2), dataRe, dataIm, 'uni', false);
    phase = cellfun(@(x, y) angle(complex(x, y)), dataRe, dataIm, 'uni', false); 
end

function [ampDiff, phaseDiff] = computeErrorSubj(dataRe, dataIm, nF, nComp)
    nCnd = size(dataRe, 1);
    nSubj = size(dataRe, 2);
    ampDiff = zeros(nCnd, nSubj, nF, nComp, 2);
    phaseDiff = ampDiff;
    for c = 1:nCnd
        for s = 1:nSubj
            currentCnd_re = dataRe{c, s};
            currentCnd_im = dataIm{c, s};
            for f = 1:nF
                for cmp = 1:nComp                    
                   xyData = [currentCnd_re(f, cmp); currentCnd_im(f, cmp)];
                   [ampDiff(c, s, f, cmp, :), phaseDiff(c, s, f, cmp, :), ~ ,~] = ...
                       fitErrorEllipse(xyData);
                end
            end
        end
    end
end
function [ampDiff, phaseDiff] = computeErrorProj(dataRe, dataIm, nF, nComp)
    nCnd = size(dataRe, 1);
    
    ampDiff = zeros(nCnd, nComp, nF, 2);
    phaseDiff = ampDiff;
    for c = 1:nCnd
        
        for cmp = 1:nComp
            currentCnd_re = dataRe(c, :);
            currentCnd_im = dataIm(c, :);
            for f = 1:nF
                subjData_re = cell2mat(cellfun(@(x) x(f, :, cmp), currentCnd_re, 'uni', false));
                subjData_im = cell2mat(cellfun(@(x) x(f, :, cmp), currentCnd_im, 'uni', false));
                xyData = [subjData_re; subjData_im];
                nanVals = sum(isnan(xyData), 1) > 0;
                [ampDiff(c, cmp, f, :), phaseDiff(c, cmp, f, :), ~ ,~] = ...
                    fitErrorEllipse(xyData(:, ~nanVals)');
            end
        end
    end
end