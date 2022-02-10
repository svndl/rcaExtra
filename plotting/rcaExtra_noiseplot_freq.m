function rcaExtra_noiseplot_freq(fig_h, noiseLow, noiseHigh, colors, labels)
    
    [nF, nCnd] = size(noiseLow);    
    
        % add noise floor
    ax = get(fig_h, 'CurrentAxes'); 
    for nc = 1:nCnd
        ampLo = squeeze(noiseLow(:, nc));
        ampHi = squeeze(noiseHigh(:, nc));
        ampNoiseAvg = (ampLo + ampHi)/2;
        x = xlim;
  
        area(ax, [x(1) 1:nF x(2)]', [ampNoiseAvg(1); ampNoiseAvg; ampNoiseAvg(end)],...
            'EdgeColor','none','FaceColor', colors(nc, :), 'FaceAlpha', 0.1, ...
            'DisplayName', strcat('Noise',' ', labels{nc}));
    end
end