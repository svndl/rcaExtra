function [mu, s] = run_OZAnalysis(dataIn, freq, path, tag, channel)
    % resample data
    NS_DAR = 420;
    sampling_rate = round(NS_DAR/freq);    
    resampled_data = resampleData(dataIn, sampling_rate);
    path.results_Data = fullfile(path.srcEEG, 'results', tag);
    
    % oz
    W_oz = zeros(128, 1);
    W_oz(channel) = 1;
    
    [oz_mu_inc, oz_s_inc] = prepData(rcaProject(resampled_data(:, 1), W_oz));
    [oz_mu_dec, oz_s_dec] = prepData(rcaProject(resampled_data(:, 2), W_oz));
    
    mu.inc.oz = oz_mu_inc;
    mu.dec.oz = oz_mu_dec;

    s.inc.oz = oz_s_inc;
    s.dec.oz = oz_s_dec;
end