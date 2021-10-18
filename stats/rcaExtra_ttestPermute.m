function [h0, realP, corrT, critVal, clustDistrib] = rcaExtra_ttestPermute(inData1, inData2, ttestSettings)
%
% input:
%   inData1: the difference waveform to test against zero, as a t x s matrix, where t is time and s is subjects.
%   inData2 (optional): the difference waveform to test against zero, as a t x s matrix, where t is time and s is subjects.

% settings :
%   settings.maxPerms (scalar): number of permutations to run, if not given every possible permutation will be run
%   settings.timeMask (1xt logical): true indicates timepoints that should be included in the test,
%                           default is to include everything.
%   settings.permMatrix: matrix of permutations to run,
%               useful if multiple tests will be run on the same set of subjects.
%   settings.deletePool (logical true/[false]): if true, the parallel pool object used to run the tests will be deleted afterwards. Useful if you know you are running the last instance of the function.
%   settings.tParams (cell): t-test parameters, default is {'dim',2,'alpha',0.05}.
%   settings.ttestType (string): type of ttest (paired/unpaired)
% output:
%   realT (1xt logical): significance of ordinary t-test
%   realP (1xt double): p-values of ordinary t-test
%   corrt (1xt logical): significance of corrected t-test
%   critVal (scalar): critical number of significant time-points
%                     required for surviving correction
%   clustDistrib: distribution of significance run lengths for
%                 permuted data.
        
    
    % take out NaN data and count subjects for the first dataset   
    notNaN = sum(isnan(inData1), 1) == 0;
    inData1 = inData1(:, notNaN);
    nSubjs1 = size(inData1, 2);
    
    nTotalSubjs = nSubjs1;
    nTimeSamples = size(inData1, 1);  
    
    % if there's no dataset, test against zero 
    testAgainstZero = false;
    
    if (isempty(inData2))
        fcnCall = @ttest;
        testAgainstZero = true;
    else
        notNaN = sum(isnan(inData2), 1) == 0;
        inData2 = inData2(:, notNaN);
        nSubjs2 = size(inData2, 2);
        nTotalSubjs  = nSubjs1 + nSubjs2;
        
        if (nSubjs2 ~= nSubjs1)
            fcnCall = @ttest2;
        end
    end
    numPerms = 2^nTotalSubjs;
    %% fill missing settings
    if ~isfield(ttestSettings, 'tParams')
        ttestSettings.tParams = {'dim', 2, 'alpha', 0.05};
    end
    if ~isfield(ttestSettings, 'deletePool')
        ttestSettings.deletePool = true;
    end
    if ~isfield(ttestSettings, 'timeMask')
        ttestSettings.timeMask = 1:nTimeSamples;
    end
    
    if ~isfield(ttestSettings, 'maxPerms')
        ttestSettings.maxPerms = min(numPerms, 5000);
        ttestSettings.iPerms = 1:ttestSettings.maxPerms;
    else
        % choose a random set of the possible perms/combs
        rand('state', sum(100*clock));
        ttestSettings.iPerms = round( numPerms * rand(ttestSettings.maxPerms, 1) );
    end
        
    if ~isfield(ttestSettings, 'permMatrix')
        ttestSettings.permMatrix = num2bits(ttestSettings.iPerms, nTotalSubjs);     
    end
    if (~isfield(ttestSettings, 'ttestType'))
        fcnCall = @ttest2;
        ttestSettings.ttestType = 'unpaired';
    end
    
    % allocate space for values
    
    h0 = zeros(max(ttestSettings.timeMask), 1);
    realP = ones(max(ttestSettings.timeMask), 1);
    clustDistrib = zeros(max(ttestSettings.timeMask), 1);

    switch ttestSettings.ttestType
        case 'paired'
            fcnCall = @ttest;
        case 'unpaired'
            fcnCall = @ttest2;
    end
    dataSlice1 = inData1(ttestSettings.timeMask, :);
    poolobj = gcp;
        
    if (testAgainstZero)
        fcnCall = @ttest;
        [h0, realP, ~, ~] = fcnCall(dataSlice1, 0, ttestSettings.tParams{:});
        pooledData = dataSlice1;
        pooledIdx = ones(nSubjs1, 1);
        
        parfor p = 1:ttestSettings.maxPerms % all possible permutations   
            % shuffle indicies
            newPooledIdx = pooledIdx(randperm(nSubjs1));
            shuffledData = pooledData(:, newPooledIdx == 1);       
            [h0_shuffled, ~, ~, ~] =  fcnCall(shuffledData, 0, ttestSettings.tParams{:});
            clustDistrib(p) = max(clustLength(h0_shuffled));
        end
        
    else     
        dataSlice2 = inData2(ttestSettings.timeMask, :);
        [h0, realP, ~, ~] = fcnCall(dataSlice1, dataSlice2, ttestSettings.tParams{:});
        % create pooled list and keep true group indicies
        
        pooledData = cat(2, dataSlice1, dataSlice2);
        pooledIdx = cat(1, ones(nSubjs1, 1), 2*ones(nSubjs2, 1));
        
        parfor p = 1:ttestSettings.maxPerms
            % randomize subject indicies
            newPooledIdx = pooledIdx(randperm(nTotalSubjs));
            % create null distributions with random incicies 
            shuffledData1 = pooledData(:, newPooledIdx == 1);
            shuffledData2 = pooledData(:, newPooledIdx == 2);
            
            [h0_shuffled, ~, ~, ~] =  fcnCall(shuffledData1, shuffledData2, ttestSettings.tParams{:});
            clustDistrib(p) = max(clustLength(h0_shuffled));
        end
    end
        
    
    %% compute 
    critVal = prctile(clustDistrib,95); % 95 % of values are below this
    
    realLocs = logical(h0);   %identify contiguous ones
    realLength = regionprops(realLocs, 'area');  %length of each span
    realLength = [ realLength.Area];
    corrIdx = find(realLength > critVal);
    % old code
    % corrT = ismember(realLocs,corrIdx);
    
    %% MK update October 15 2021
    %% added by MK 
    
    % Find the separate regions - i.e. which elements are clusters of 1s:
    nonZeroElements = realLocs ~= 0;
    minSeparation = 1; % The separation required between 2 clusters is just 1 sample
    nonZeroElements = ~bwareaopen(~nonZeroElements, minSeparation);
    % Assign labels to each individual cluster (ascending numeric)
    [labeledRegions, ~] = bwlabel(nonZeroElements);
    % Use the labeled regions as indices for the corrIdx
    
    % Use the labeled regions as indices for the corrIdx
    corrT = ismember(labeledRegions, corrIdx);
    
    if ttestSettings.deletePool
        delete(poolobj);
    end
    
    
    if ttestSettings.deletePool
        delete(poolobj);
    end
end
