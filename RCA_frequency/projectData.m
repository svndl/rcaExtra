function [data_Out] = projectData(data_In, W)
% Projects frequency data data_In using weights W
% Alexandra Yakovleva, Stanford University 2012-2020.

    %% project using W
    data_Out = cell(size(data_In));
    
    nCnd = size(data_Out, 1);
    nSubj = size(data_Out, 2);
    % becasue it is a pain the ass to install mtimesx/BLAS
    for c = 1:nCnd
        for s = 1:nSubj 
            data_Out{c, s} = projectSubject(data_In{c, s}, W);
        end
    end
end
function out = projectSubject(in, w)
    nTrials = size(in, 3); 
    nSamples = size(in, 1);
    nComp = size(w, 2);
    out = zeros(size(in, 1), size(w, 2), size(in, 3));
    
    for nt = 1:nTrials
        for ns = 1:nSamples
            in_s = repmat(squeeze(in(ns, :, nt))', [1 nComp]);
            out(ns, :, nt) =  nansum(in_s.*w);
        end
    end
end