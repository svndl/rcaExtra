function statResults = rcaExtra_testSignificance(dataSet1, dataSet2, testSettings)
% Function will perform significance testing
% Alexandra Yakovleva, Stanford University 2020
    
    
    switch testSettings.domain
        case 'time'
            % dataSet1, dataSet2 for time domain should have 
            % nSamples x nRcs x nCnd x nSubjs dims
            
            [nSamples, nRc, nCnd, ~] = size(dataSet1);
            
            if (~isempty(dataSet2))
                [nSamples2, nRc2, nCnd2, ~] = size(dataSet2);
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
            [nF, nRc, nCnd, ~] = size(dataSet1.subjAvgImag);
            
            h0 = zeros(nF, nRc, nCnd);
            pVals = ones(nF, nRc, nCnd);
             
            for r = 1:nRc
                for c = 1:nCnd
                    for f = 1:nF
                        d1 = dataSet1.subjAvgReal(f, r, c, :);
                        d2 = dataSet1.subjAvgImag(f, r, c, :);
                        data1Slice = cat(2, squeeze(d1), squeeze(d2));
                        data2Slice = [];
                        if (~isempty(dataSet2))
                            d3 = dataSet2.subjAvgReal(f, r, c, :);
                            d4 = dataSet2.subjAvgImag(f, r, c, :);       
                            data2Slice = cat(2, squeeze(d3), squeeze(d4));                        
                        end
                        if (isempty(data2Slice))
                            % dependent TSquared Tcirc or Hotelling, depeding
                            % on eig1/eig2 ratio
                        
                            out = rcaExtra_HTSquared_d(data1Slice, data2Slice);                        
                        elseif (isfield(testSettings, 'testWithin'))
                            dataSlice = cat(3, data1Slice, data2Slice); 
                            out = rcaExtra_HTSquared_d(dataSlice);                                                    
                        else
                            % independent TSquared Hotelling  
                            out = rcaExtra_HTSquared_i(data1Slice, data2Slice);
                        end
                        h0(f, r, c) = out.H;
                        pVals(f, r, c) = out.pVal;
                    end
                end
            end
        otherwise
    end
    statResults.sig = h0;
    statResults.pValues = pVals;
end
