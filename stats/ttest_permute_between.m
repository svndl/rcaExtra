function [realT, realP, corrT, critVal, clustDistrib] = ttest_permute_between(inData1, inData2, maxPerms, timeMask, permMatrix, deletePool, tParams )
        % [realT,realP,corrT,critVal,clustDistrib]= ttest_permute( inData,maxPerms,timeMask,permMatrix,deletePool,tParams )
        % 
        % input:
        %   inData1: waveform 1 to test against zero, as a t x s matrix, where t is time and s is subjects.
        %   inData2: waveform 2 to test against zero, as a t x s matrix, where t is time and s is subjects.
        
        % 
        % optional:
        %   maxPerms (scalar): number of permutations to run, if not given every possible permutation will be run
        %   timeMask (1xt logical): true indicates timepoints that should be included in the test, 
        %                           default is to include everything.
        %   permMatrix: matrix of permutations to run, 
        %               useful if multiple tests will be run on the same set of subjects.
        %   deletePool (logical true/[false]): if true, the parallel pool object used to run the tests will be deleted afterwards. Useful if you know you are running the last instance of the function.
        %   tParams (cell): t-test parameters, default is {'dim',2,'alpha',0.05}.
        % 
        % output:
        %   realT (1xt logical): significance of ordinary t-test
        %   realP (1xt double): p-values of ordinary t-test
        %   corrt (1xt logical): significance of corrected t-test
        %   critVal (scalar): critical number of significant time-points
        %                     required for surviving correction
        %   clustDistrib: distribution of significance run lengths for
        %                 permuted data.
        
        % take out NaN data and count subjects
        notNaN = sum(isnan(inData1), 1)==0;
        inData1_clear = inData1(:, notNaN);
        numSubjs1 = size(inData1_clear, 2);
        
        notNaN = sum(isnan(inData2), 1)==0;
        inData2_clear = inData2(:, notNaN);
        numSubjs2 = size(inData2_clear, 2);

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
            timeMask = 1:size(inData1, 1);
        else
        end
        if nargin < 3 || isempty(maxPerms)
            maxPerms = numPerms;
            iPerms = 1:maxPerms;
        else
            % choose a random set of the possible perms/combs
            rand('state',sum(100*clock));
            iPerms = round( numPerms * rand( maxPerms, 1 ) );
        end
        
        if isempty(permMatrix)
            permMatrix = num2bits(iPerms , nSubjs);
        else
        end
        
        [realT(timeMask), realP(timeMask), CI, stats] = ttest2(inData1, inData2, tParams{:});
        clustDistrib = zeros(maxPerms,1);
        poolobj = gcp;
        parfor p = 1:maxPerms % all possible permutations
           shuffled1 = inData1(:, randperm(numSubjs1));
           shuffled2 = inData2(:, randperm(numSubjs2));
            
           [fakeT, P, CI, stats] =  ttest2(shuffled1, shuffled2, tParams{:});
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

function rB = num2bits( aV, aN )
    tV = aV(:); % Make sure v is a row vector.
    tNV = length( tV ); % number of numbers to convert
    rB = zeros( tNV, aN );
    tP = aN - 1;
    rB( :, 1 ) = mod( tV, ( 2 ^ aN ) );
    for iP = 1:( aN - 1 )
        rB( :, iP+1 ) = mod( rB( :, iP ), ( 2 ^ tP ) );
        rB( :, iP ) = floor( rB( :, iP ) / ( 2 ^ tP ) );
        tP = tP - 1;
    end
    rB( :, end ) = floor( rB( :, end ) / ( 2 ^ tP ) );
    rB ( rB == 0 ) = -1;
end
