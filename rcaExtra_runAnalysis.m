function rcResult = rcaExtra_runAnalysis(rcSettings, dataIn, varargin)
% runs time or frequency RCA
% Alexandra Yakovleva, Stanford University 2020.

    switch rcSettings.domain
        case 'time'
            rcResult = runRCA_time(rcSettings, dataIn);
        case 'freq'
            noise1 = varargin{1};
            noise2 = varargin{2};

            rcResult = runRCA_frequency(rcSettings, dataIn, noise1, noise2);
        otherwise
            rcResult = runRCA_time(rcSettings, dataIn);
    end
    % TODO here:
    % flip component signs (should be migrated to runRCA_*)
    
    %dataOut = rcaExtra_adjustRCSigns(rcResult, rcSettings);  
end