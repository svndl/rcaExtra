function [realT,realP,corrT,critVal,clustDistrib] = tTest_between(dataIn1, dataIn2, maxPerms, timeMask, permMatrix, deletePool, tParams )

    numSubjs1 = size(dataIn1, 2);
    numSubjs2 = size(dataIn2, 2);

    nSubjs = min(numSubjs1, numSubjs2);
    numPerms = 2 ^ nSubjs;
    if nargin <7 || isempty(tParams)
        tParams = {'alpha', 0.05, 'dim', 2};
    else
    end
    if nargin < 6 || isempty(deletePool)
        deletePool = false;
    else
    end
    if nargin < 5 || isempty(permMatrix)
        permMatrix = [];
    end
    if nargin < 4 || isempty(timeMask)
        timeMask = 1:size(dataIn1, 1);
    else
    end
    if nargin < 3 || isempty(maxPerms)
        maxPerms = numPerms;
        iPerms = 1:maxPerms;
    else
        % choose a random set of the possible perms/combs
        rand('state', sum(100*clock));
        iPerms = round( numPerms * rand( maxPerms, 1 ) );
    end
    
    
    if isempty(permMatrix)
        permMatrix = num2bits(iPerms , nSubjs);
    else
    end

    
    %ground truth 
    [realT, realP, CI, stats] = ttest2(dataIn1, dataIn2, tParams{:});
    
    clustDistrib = zeros(maxPerms, 1);
    poolobj = gcp;
    
    jointData = cat(2, dataIn1, dataIn2);
    
    parfor p = 1:maxPerms % all possible permutations       
        shuffled = jointData(:, randperm(numSubjs1 + numSubjs2));
        [fakeT, P, CI, stats] =  ttest2(shuffled(:, 1:numSubjs1), shuffled(:, numSubjs1+1:end), tParams{:});
        clustDistrib(p) = max(clustLength(fakeT));
    end
    critVal = prctile(clustDistrib, 95); % 95 % of values are below this
    
    realLocs = bwlabel(realT);   %identify contiguous ones
    realLength = regionprops(realLocs, 'area');  %length of each span
    realLength = [ realLength.Area];
    corrIdx = find(realLength > critVal);
    corrT = ismember(realLocs, corrIdx);
    if deletePool
        delete(poolobj)
    else
        delete(poolobj)
    end
end
