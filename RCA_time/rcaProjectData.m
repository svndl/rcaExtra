function [muData, semData] = rcaProjectData(data, weights)
% Alexandra Yakovleva, Stanford University 2012-2020

% project and baseline data thru RC weights

    dataOut = rcaProject(data, weights);
    catData = cat(3, dataOut{:});
    muData = nanmean(catData, 3);
    semData = nanstd(catData, [], 3)/(sqrt(size(catData, 3)));   
    
    %baselining
    muData = muData - repmat(muData(1, :), [size(muData, 1) 1]);
end
