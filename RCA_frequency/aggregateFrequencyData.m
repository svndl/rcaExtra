function [amp, amp_err, phase, phase_err] = aggregateFrequencyData(inputData, proj_data_avg, nB, nF, W, channels)         
    %% Project average
    %aggregate weights:
    
    channelW = zeros(128, numel(channels));
    channelW(channels) = 1;
    
    allW = [W channelW];
    [ampP, error_ampP, phaseP, error_phaseP] = computeProjAverage(inputData, nB, nF, allW);
    nComp = size(allW, 2);
    %% RESHAPING and ordering the dims:
    
    %nCnd x nF x nComponents
    amp.Proj = reshape(cell2mat(ampP), [size(ampP, 1) nF nComp]);
    phase.Proj = reshape(cell2mat(phaseP), [size(phaseP, 1) nF nComp]);
    amp_err.Proj = error_ampP;    
    phase_err.Proj = error_phaseP;       
    
    [ampS, error_ampS, phaseS, error_phaseS] = computeAvgBySubjects(inputData, nB, nF, allW);

    %nCnd x nSubj x nF nComponents
       
    %nCnd x nSubj x nF nComponents x 2
    amp_err.Subj =  error_ampS;
    phase_err.Subj = error_phaseS;

    amp.Subj = reshape(cell2mat(ampS), [size(ampS, 1) size(ampS, 2) nF nComp]);
    phase.Subj = reshape(cell2mat(phaseS), [size(phaseS, 1) size(phaseS, 2) nF nComp]);
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
    
    error_amp = zeros(nCnd, nFreqs, nComp, 2);
    error_phase = zeros(nCnd, nFreqs, nComp, 2);
    [amp, phase] = computeAmpPhase(projected_avg_Re, projected_avg_Im);
    %[error_amp, error_phase] = computeErrorProj(projected_Re, projected_Im, nFreqs, nComp);
end
function [amp, error_amp, phase, error_phase] = computeAvgBySubjects(inputData, nB, nF, W)
    
    nCh = size(W, 1);
    nCmp = size(W, 2);
    [avg_Re, avg_Im] = computeSubjAvg(inputData, nB, nF, nCh);    
    proj_Re = cellfun(@(x) x*W, avg_Re, 'uni', false);
    proj_Im = cellfun(@(x) x*W, avg_Im, 'uni', false);
    
    % avg per subject!
    [amp, phase] = computeAmpPhase(proj_Re, proj_Im);
    [data_Re, data_Im] = getRealImag(inputData);
    
    nCnd = size(data_Re, 1);
    nSubj = size(data_Re, 2);
    error_amp = zeros(nCnd, nSubj, nF, nCmp, 2);
    error_phase = error_amp;
    for c = 1:nCnd
        for s = 1:nSubj
            currentCnd_re = data_Re{c, s};
            currentCnd_im = data_Im{c, s};
            % project 
            for f = 1:nF
                proj_re = W'*squeeze(currentCnd_re(f, :, :));
                proj_im = W'*squeeze(currentCnd_im(f, :, :));
                for cmp = 1:nCmp
                   try
                       xyData = [proj_re(cmp, :); proj_im(cmp, :)];
                       nanVals = sum(isnan(xyData), 1) > 0;
                        [error_amp(c, s, f, cmp, :), error_phase(c, s, f, cmp, :), ~ ,~] = ...
                            fitErrorEllipse(xyData(:, ~nanVals)');
                   catch
                   end
                end
            end
        end
    end   
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
    meanBySubj = cellfun(@(x) squeeze(nanmean(x, 4)), reshapedData, 'uni',false);
    weights = cellfun(@(x) sum(~isnan(x), 4), reshapedData, 'uni',false);
    nCnd = size(meanBySubj, 1);
    nSubj = size(meanBySubj, 2);
    wa = cell(nCnd, nSubj);
    for c = 1:nCnd
        for s = 1:nSubj
            cW = weights{c, s};
            cS = meanBySubj{c, s};
            try
                wa{c, s} = squeeze(wmean(cS, cW, 1));
            catch
                wa{c, s} = nan(nFreq, nComp);
            end
        end
        proj{c} = cat(3, wa{:});
    end
end
function wa = computeAvg(dataIn)
    wa = cellfun(@(x) nanmean(x, 3), dataIn, 'uni',false);
end

% each subject is a trial
function [proj, avgProj] = averageProject(dataIn, nBins, nFreq, nComp)
    if (nBins > 1)
        reshapedData = cellfun(@(x) reshape(x, [nBins nFreq nComp size(x, 3)]), dataIn, 'uni',false);  
        meanBySubj = cellfun(@(x) squeeze(nanmean(x, 4)), reshapedData, 'uni',false);
        weights = cellfun(@(x) sum(~isnan(x), 4), reshapedData, 'uni',false);
    else
        meanBySubj = dataIn;
    end

    nCnd = size(meanBySubj, 1);
    proj = cell(nCnd, 1);
    nSubj = size(meanBySubj, 2);
    weighted = cell(nSubj, 1);
    for c = 1:nCnd
        for s = 1:nSubj
            cW = weights{c, s};
            cS = meanBySubj{c, s};
            try
                weighted{s} = squeeze(wmean(cS, cW, 1));
            catch
                weighted{s} = nan(nFreq, nComp);
            end
        end
        proj{c} = cat(3, weighted{:});
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
    
    ampDiff = zeros(nCnd, nF, nComp, 2);
    phaseDiff = ampDiff;
    for c = 1:nCnd
        
        for cmp = 1:nComp
            currentCnd_re = dataRe(c, :);
            currentCnd_im = dataIm(c, :);
            for f = 1:nF
                subjData_re = cell2mat(cellfun(@(x) x(f, :, cmp), currentCnd_re, 'uni', false));
                subjData_im = cell2mat(cellfun(@(x) x(f, :, cmp), currentCnd_im, 'uni', false));
                xyData = [subjData_re; subjData_im];
                [ampDiff(c, f, cmp, :), phaseDiff(c, f, cmp, :), ~ ,~] = ...
                    fitErrorEllipse(xyData');
            end
        end
    end
end
