function out = rcaExtra_normalizeByErr_post(rcaResult)
%% Function will normalize the RCA-projected sensor-space data.
% Function takes rcaResult as input argument and returns a copy of input
% structure with each subj/condition's RCA-projected data normalized by
% error (check tcirc.m for SE/SD computation).
% Data modified (changed) is rcaResult.projectedData and all computed averages.
% Noise bands data is not normalized (as of 8.10.23). 
% Alexandra Yakovleva, Stanford University 2023.

    [nSubj, nCnds] = size(rcaResult.projectedData);
    normalized_rcProjData = cell(nSubj, nCnds);
    
    for ns = 1:nSubj
        for nc = 1:nCnds
            % sensor projected data
            subjData = rcaResult.projectedData{ns, nc};
            % noise data
            subjErr = squeeze(rcaResult.subjAvg.err(:, :, nc, ns));       
            normalized_rcProjData{ns, nc} = subjData./(1.96*repmat(subjErr, [2 1 size(subjData, 3)]));
        end
    end
    out = rcaResult;
    out.projectedData = normalized_rcProjData;
    out = rcaExtra_computeAverages(out);
end