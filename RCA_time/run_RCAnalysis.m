function [mu, s] = run_RCAnalysis(dataIn, freq, resultsDir, datasetName, channel)
    % resample data
    NS_DAR = 420;
    sampling_rate = round(NS_DAR/freq);    
    resampled_data = resampleData(dataIn, sampling_rate);
    settings.resultsDir = resultsDir;
    settings.dataset = datasetName;
    
    timeCourseLen = round(1000./freq);
    disp(['Running RC on ' datasetName ' dataset']);
    [rc, W, A]  = rcaRunOnly(resampled_data, settings, timeCourseLen);
    
    tc = linspace(0, timeCourseLen - 1, sampling_rate);
    rcPlot(rc, tc, A);
    % rc
    [mu_pol, s_pol] = prepData(rcaProject(resampled_data, W));
    
    [mu_inc, s_inc] = prepData(rcaProject(resampled_data(:, 1), W));
    [mu_dec, s_dec] = prepData(rcaProject(resampled_data(:, 2), W));

    % oz
    W_oz = zeros(128, 1);
    W_oz(channel) = 1;
    
    [oz_mu_inc, oz_s_inc] = prepData(rcaProject(resampled_data(:, 1), W_oz));
    [oz_mu_dec, oz_s_dec] = prepData(rcaProject(resampled_data(:, 2), W_oz));
    [oz_mu_pol, oz_s_pol] = prepData(rcaProject(resampled_data, W_oz));
    
    
    mu.inc.rc = mu_inc;
    mu.inc.oz = oz_mu_inc;
    mu.dec.rc = mu_dec;
    mu.dec.oz = oz_mu_dec;
    mu.pol.rc = mu_pol;
    mu.pol.oz = oz_mu_pol;
    mu.source = rcaProject(resampled_data, W);
    s.inc.rc = s_inc;
    s.inc.oz = oz_s_inc;
    s.dec.rc = s_dec;
    s.dec.oz = oz_s_dec;
    s.pol.rc = s_pol;
    s.pol.oz = oz_s_pol;   
end