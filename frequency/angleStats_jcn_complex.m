function angleStats_jcn_complex(rcaResult)
    % average real and imaginary components
    statSettings = rcaExtra_getStatsSettings(rcaResult.rcaSettings);
    subjRCMean_complex = rcaExtra_prepareDataArrayForStats(rcaResult.projectedData, ...
        statSettings);
        
    % compute on-off differences for real, imaginary 
    diff_Real = subjRCMean_complex.subjAvgReal(:, :, 1, :) - subjRCMean_complex.subjAvgReal(:, :, 2, :);
    diff_Imag = subjRCMean_complex.subjAvgImag(:, :, 1, :) - subjRCMean_complex.subjAvgImag(:, :, 2, :);
    
    % select RC1 and 1F-4F for the frequencies
    diff_Real_RC1 = squeeze(diff_Real(:, 1, :));
    diff_Imag_RC1 = squeeze(diff_Imag(:, 1, :));
    
    % compute averages for 
    angle =  rad2deg(angle(complex(diff_Real_RC1, diff_Imag_RC1)));
    avg_real_rc1 = mean(diff_Real_RC1, 2);
    avg_imag_rc1 = mean(diff_Imag_RC1, 2);
    
    % jackknife averages for 1F-4F

    Di_real = jackknife(@mean, diff_Real_RC1');
    Di_imag = jackknife(@mean, diff_Imag_RC1');
    
    % compute angle
    DJ_phase_angle = rad2deg(angle(complex(Di_real, Di_imag)));
    Avg_all_population = rad2deg(angle(complex(avg_real_rc1, avg_imag_rc1)));
    [~, N] = size(diff_Real_RC1);
    alpha = 0.05;
    tail = 'two';
    % two-tailed critical t-value for dF - 1 (function CritT compiled from finv table)
    tCrit = CritT(alpha, N - 1, tail);
    
    J_r = mean(Di_real, 1);
    J_i = mean(Di_imag, 1);
    
    sD_r = sqrt(((N - 1)/N)*sum((D_i - J_).^2));
    
    t_J = D/sD;

    
end