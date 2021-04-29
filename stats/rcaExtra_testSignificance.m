function statResults = rcaExtra_testSignificance(dataSet1, dataSet2, testSettings)
% Function will perform significance testing
% Alexandra Yakovleva, Stanford University 2020
    
    
    switch testSettings.domain
        case 'time'
            % dataSet1, dataSet2 for time domain should have 
            % nSamples x nRcs x nCnd x nSubjs dims
            
            [nSamples, nRc, nCnd, ~] = size(dataSet1);
            
            if (~isempty(dataSet2))
                [nSamples2, nRc2, nCnd2, ~] = size(dataSet1);
                % must have same number of timesamples
                if (nSamples ~= nSamples2)
                    statResults = NaN;
                    return;
                end
                nRc = min(nRc, nRc2);
                nCnd = min(nCnd, nCnd2);              
            end
            h0 = zeros(nSamples, nRc, nCnd);
            pVal = ones(nSamples, nRc, nCnd);
            
            % todo define settings here 
            for r = 1:nRc
                for c = 1:nCnd
                    data1Slice = squeeze(dataSet1(:, r, c, :));
                    data2Slice = [];
                    if (~isempty(dataSet2))
                        data2Slice = squeeze(dataSet2(:, r, c, :));
                    end
                        
                    [h0(:, r, c), pVal(:, r, c), ~, ~, ~] =  ...
                        rcaExtra_ttestPermute(data1Slice, data2Slice, testSettings);            
                end
            end

            
            % frequency domain testing:
        case 'freq'
            [nF, nRc, nCnd, nSubj] = size(dataSet1.subjAvgImag);
            
            h0 = zeros(nF, nRc, nCnd);
            pVal = ones(nF, nRc, nCnd);
             
            for r = 1:nRc
                for c = 1:nCnd
                    d1 = dataSet1.subjAvgReal(:, r, c, :);
                    d2 = dataSet1.subjAvgImag(:, r, c, :);
                    % reshape conditions
                    data1Slice.subjAvgReal = reshape(d1, [nF 1 nSubj]);
                    data1Slice.subjAvgImag = reshape(d2, [nF 1 nSubj]);
                    
                    data2Slice = [];
                    if (~isempty(dataSet2))
                        d3 = dataSet2.subjAvgReal(:, r, c, :);
                        d4 = dataSet2.subjAvgImag(:, r, c, :);
                        nSubj2 = size(dataSet2.subjAvgImag, 4);
                        
                        data2Slice.subjAvgReal = reshape(d3, [nF 1 nSubj2]);
                        data2Slice.subjAvgImag = reshape(d4, [nF 1 nSubj2]);
                    end
                    if (isfield(testSettings, 'testWithin'))
                        [h0(:, r, c), pVal(:, r, c), ~] = rcaExtra_tSquaredWithin(data1Slice, data2Slice);                        
                    else
                        [h0(:, r, c), pVal(:, r, c), ~] = rcaExtra_tSquared(data1Slice, data2Slice);
                    end
                    
                end
            end
        otherwise
    end
    statResults.sig = h0;
    statResults.pValues = pVal;
end