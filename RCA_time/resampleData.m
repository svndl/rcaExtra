function dataOut = resampleData(dataIn, cycleDurtaionSamples)
    dataOut = cell(size(dataIn));
    nRows = size(dataIn, 1);
    nCols = size(dataIn, 2);
    
    for r = 1:nRows
        for c = 1:nCols
            cellData = dataIn{r,c};
            nSamples = size(cellData, 1);
            sampleLength = cycleDurtaionSamples;
            nSplits = nSamples/cycleDurtaionSamples;
            nEEG = size(cellData, 2);
            nTrials = size(cellData, 3);
            X = mat2cell(cellData, sampleLength*ones(nSplits, 1), nEEG, nTrials);
            dataOut{r, c} = cat(3, X{:});
        end
    end
end