function dataOut = rcaExtra_project3DMatrix(dataIn, w)
% function will re-project 3D data array using inverse of 2D w matrix
% Alexandra Yakovleva, Stanford University 2021.

    
    [nSamples, nW0, nTrials] = size(dataIn);
    
    [nCh, nW] = size(w);
    
    % initiate output:
    dataOut = nan(nSamples, nCh, nTrials);
    
    % compare number of weights in original data and input w  
    if (nW0 == nW)
    
        for nt = 1:nTrials
            for ns = 1:nSamples
                in_s = repmat(squeeze(dataIn(ns, :, nt))', [1 nW]);
                dataOut(ns, :, nt) =  nansum(in_s.*w);
            end
        end
    end
end