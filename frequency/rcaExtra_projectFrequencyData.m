function out = rcaExtra_projectFrequencyData(rcResultIn, cellSourceData, cellNoiseData1, cellNoiseData2)
% Function will project source and noise data into new rcaResut structure
% Alexandra Yakovleva, Stanford University 2022
   
    % copy input into output 
    out = rcResultIn;
    % use weights
    W = rcResultIn.W;
    % update number of conditions
    out.rcaSettings.useCnds = size(cellSourceData, 2);
    
    % project source data 
    out.projectedData = rcaProject(cellSourceData,W);
    % project noises
    out.noiseData.lowerSideBand = rcaProject(cellNoiseData1, W); 
    out.noiseData.higherSideBand = rcaProject(cellNoiseData2, W);
    % compute averages
    out = rcaExtra_computeAverages(out);
end