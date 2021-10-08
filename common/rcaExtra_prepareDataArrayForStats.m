function subjMean = rcaExtra_prepareDataArrayForStats(dataMat, dataSettings)
% Alexandra Yakovleva 2020, Stanford University
    switch dataSettings.domain
        case 'time'
            % mean RCs by subject, 
            % dims are nTimesamples x nRCs x nConditions x nSubjs
            subjMeanCell = cellfun(@(x) nanmean(x, 3), dataMat, 'uni', false);
            subjMean = cat(4, subjMeanCell{:});
            [nSubj, nCnd] = size(subjMeanCell);
            [nSamples, nRcs, ~, ~] = size(subjMean);
            % reshape and permute to preserve number of conditions
            if (nCnd >1)
                subjMean = reshape(subjMean, [nSamples nRcs nSubj nCnd]);
                subjMean = permute(subjMean, [1 2 4 3]);
            end
        case 'freq'
            [nSubj, nCnd] = size(dataMat);                        
            % for frequency, need to know nB, nF and nRCs
            % subjSensorMean: nF x nRCs x nCnd x nSubj  
            [data_Re, data_Im] = getRealImag_byBin(dataMat, ...
                dataSettings.nBins, dataSettings.nFreqs, dataSettings.nComp);
            [~, AvgReal, ~] = averageProject(data_Re, dataSettings.nBins);
            [~, AvgImag, ~] = averageProject(data_Im, dataSettings.nBins);    
            subjMean.subjAvgReal = cat(4, AvgReal{:});
            subjMean.subjAvgImag = cat(4, AvgImag{:});
            [nSamples, nRcs, ~, ~] = size(subjMean.subjAvgReal);
             if (nCnd > 1)
                subjMean.subjAvgReal = reshape(subjMean.subjAvgReal, [nSamples nRcs nSubj nCnd]);
                subjMean.subjAvgReal = permute(subjMean.subjAvgReal, [1 2 4 3]);
                subjMean.subjAvgImag = reshape(subjMean.subjAvgImag, [nSamples nRcs nSubj nCnd]);
                subjMean.subjAvgImag = permute(subjMean.subjAvgImag, [1 2 4 3]);                
            end
           
    end
end