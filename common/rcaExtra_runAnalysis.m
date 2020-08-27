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
    
    % test weight flipping
    sprintf('Running weight-flipping analysis now \n');
    outcomes = rcaExtra_adjustRCSigns(rcResult, dataIn);
    
    % print out the results
    fprintf('Weight flipping for %s \n', rcSettings.domain);
    fprintf('Max Correlation for 2D (all subjs) %f \n', max(outcomes.corrVars_2d));
    fprintf('Sign flips for 2D (1 = multiply by -1, 0 = keep) : ');
    fprintf(' %d ', outcomes.flipIdx_2d);
    fprintf('\n');
    fprintf('Max Correlation for average (avg subject) %f \n', max(outcomes.corrVars_avg))
    fprintf('Sign flips for avg (1 = multiply by -1, 0 = keep): ');
    fprintf(' %d ', outcomes.flipIdx_avg);   
    fprintf('\n');
    %% Option 1: store the flipping outcomes separately
    % save(fullfile(rcSettings.destDataDir_RCA, 'rc_signs.mat'), 'outcomes');
    
    % %Option 2: add outcomes to existing rcaResult structure
    % capitalize the time/freq domain label:
    % domainLabel = [upper(rcSettings.domain(1)) rcSettings.domain(2:end)];
   
    % recreate save path for rcaResult.mat structure
    % rcMatfile = fullfile(rcSettings.destDataDir_RCA, strcat('rcaResults_', domainLabel, rcaSettings.label, '.mat'));
    
    % copy loaded results to structure with required name (we'll be relying on loading and using the 'rcaResult', not rcResult)
    % rcaResult = rcResult;
    
    % add outcomes field to structure
    
    % rcaResult.outcomes = outcomes;
    % append data to the existing structure
    % save(rcMatfile, 'rcaResult', -append');
end