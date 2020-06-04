function rcResult = rcaExtra_runAnalysis(dataIn, rcSettings)
% runs time or frequency RCA
% Alexandra Yakovleva, Stanford University 2020.


    switch rcSettings.domain
        case 'time'
            rcResult = runRCA_time(dataIn, rcSettings);
        case 'freq'
            rcResult = runRCA_frequency(dataIn, rcSettings);
        otherwise
            rcResult = runRCA_time(dataIn, rcSettings);
    end
    % flip component signs (should be migrated to runRCA_*)
    
    %dataOut = rcaExtra_adjustRCSigns(rcResult, rcSettings);  
end