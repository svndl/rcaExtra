function plotStats(W, data_Inc, data_Dec)

    load('colorbrewer.mat');
    
    PaletteN = 4;
    blues = colorbrewer.seq.YlGnBu{PaletteN}/255;
    reds = colorbrewer.seq.YlOrRd{PaletteN}/255;
    
    NS_DAR = 420;
    freqHz = 2.73;
    cycleDurationSamples = round(NS_DAR./freqHz);
    
    timeCourseLen = round(1000./freqHz);    
    tc = linspace(0, timeCourseLen, size(data_Inc{1, 1}, 1));
    
    [mu_gInc, s_gInc] = rcaProjectData(data_Inc, W);
    [mu_gDec, s_gDec] = rcaProjectData(data_Dec, W);
       
    % baseline
    averagingWindowMs = 50;
    [~, b] = find(tc > averagingWindowMs);
   
    mu_inc = baselineDataTime(mu_gInc, b(1));
    mu_dec = baselineDataTime(mu_gDec, b(1));

    figure;
    
    hs_inc = shadedErrorBar(tc, mu_inc, s_gInc, {'Color', blues(end, :)}); hold on
    hs_dec = shadedErrorBar(tc, mu_dec, s_gDec, {'Color', reds(end, :)}); hold on

    h = {hs_inc.patch, hs_dec.patch};
    legend([h{:}],{'Increment', 'Decrement'});
    
    nEyes = size(data_Inc, 1);
    rc1_inc = zeros(nEyes, cycleDurationSamples);
    rc1_dec = zeros(nEyes, cycleDurationSamples);
    for ne = 1:nEyes
        % project + average
        inc = nanmean(squeeze(rcaProject(cell2mat(data_Inc(ne)), W)), 2);
        dec = nanmean(squeeze(rcaProject(cell2mat(data_Dec(ne)), W)), 2);
        %baseline  
        rc1_inc(ne, :) = inc - inc(1, 1);
        rc1_dec(ne, :) = dec - dec(1, 1);
    end
    
        
    % sigPos is the lower and upper bound of the part of the plot        
    yLims = ylim;
    xLims = xlim;
    sigPos = min(yLims) + diff(yLims).*[0 .1];
    
    %% do the permutation test
    delta = rc1_inc - rc1_dec;
    n_perm = 50000;
    
    [pval, t_orig, crit_t, est_alpha, seed_state] = ...
        mult_comp_perm_t1(delta, n_perm);    
    gcf;
    gcaOpts = {'box', 'off', 'fontsize', 30, 'fontname', 'arial', 'linewidth', 4, 'ticklength',[.025,.025]};    
    
    % coloring in the uncorrected t-values
    tHotColMap = jmaColors('pval'); 
    tHotColMap(end,:) = [1 1 1];    
    curP = repmat( pval, 10, 1);
    hImg = image([min(tc), max(tc)],[sigPos(1),sigPos(2)], curP, 'CDataMapping', 'scaled','Parent', gca);
    colormap(gca, tHotColMap);
    set(gca, gcaOpts{:});
    uistack(hImg,'bottom')
    
    % replot the lines for x and y axes
    xlim(xLims)
    ylim(yLims)
    plot(ones(10, 1)*xLims(1),linspace(yLims(1), yLims(2),10),'-k','linewidth', 2);
    plot(linspace(xLims(1), xLims(2), 10), ones(10,1)*yLims(1), '-k', 'linewidth', 2);
    set(gca,'XTick',0:300:800);
    legend([h{:}],{'Increment', 'Decrement'});

end