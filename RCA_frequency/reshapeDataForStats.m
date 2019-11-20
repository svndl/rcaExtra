function dataOut = reshapeDataForStats(dataIn)
% Alexandra Yakovleva, Stanford University 2012-2020
% Reshapes projected frequency data for stats

    nCnd = size(dataIn, 2);
    nSubj = size(dataIn, 1);
    
    nF = size(dataIn{1, 1}, 1);
    nComp = size(dataIn{1, 1}, 2);
    
    dataOut = zeros(nComp, nF, nCnd, nSubj);
    
    for cn = 1:nCnd
        for ns = 1:nSubj
            data = dataIn{ns, cn};
            for f = 1:nF
                for cp =1:nComp
                    dataOut(cp, f, cn, ns) = data(f, cp);
                end
            end
        end
    end
end
