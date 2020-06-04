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

            
            % time domain testing:
        case 'freq'
            [h0, pVal, stat] = rcaExtra_tSquared(dataSet1, dataSet2);            
            
    end
end