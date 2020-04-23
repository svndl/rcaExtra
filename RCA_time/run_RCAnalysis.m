function [mu, s] = run_RCAnalysis(dataIn, rcaSettings)
    % resample data
    NS_DAR = 420;
    
    sampling_rate = round(NS_DAR/rcaSettings.freq);
    resampled_data = dataIn;
    if (size(dataIn{1, 1}, 1) ~= sampling_rate)
        resampled_data = resampleData(dataIn, sampling_rate);
    end
    
    timeCourseLen = round(1000./rcaSettings.freq);
    disp(['Running RC on ' rcaSettings.label ' dataset']);
    [rc, W, A, ~]  = rcaRunOnly(resampled_data, rcaSettings);
    
    tc = linspace(0, timeCourseLen - 1, sampling_rate);
    rcPlot(rc, tc, A);
    % rc
    [mu_pol, s_pol] = prepData(rcaProject(resampled_data, W));
    
    %[mu_inc, s_inc] = prepData(rcaProject(resampled_data(:, 1), W));
    %[mu_dec, s_dec] = prepData(rcaProject(resampled_data(:, 2), W));

    % channels
    
    W_ch = zeros(128, numel(rcaSettings.chanToCompare));
    W_ch(rcaSettings.chanToCompare, :) = 1;
    
    %[ch_mu_inc, ch_s_inc] = prepData(rcaProject(resampled_data(:, 1), W_ch));
    %[ch_mu_dec, ch_s_dec] = prepData(rcaProject(resampled_data(:, 2), W_ch));
    [ch_mu_pol, ch_s_pol] = prepData(rcaProject(resampled_data, W_ch));
    
%     mu.inc.rc = mu_inc;
%     mu.inc.ch = ch_mu_inc;
%     mu.dec.rc = mu_dec;
%     mu.dec.ch = ch_mu_dec;
    mu.pol.rc = mu_pol;
    mu.pol.ch = ch_mu_pol;
    mu.source = rcaProject(resampled_data, W);
%     s.inc.rc = s_inc;
%     s.inc.ch = ch_s_inc;
%     s.dec.rc = s_dec;
%     s.dec.ch = ch_s_dec;
    s.pol.rc = s_pol;
    s.pol.ch = ch_s_pol;
end