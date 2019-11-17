function plot_addStatsBar_time(pValue, currAxisHandle, tc)

    %nIters = 5000;
    %[sig_cnd, p_cond, crit_cnd, alpha_cnd, s_cnd] = ttest_permute(conditionDiff', nIters);

   %% ADD STATS
    % sigPos is the lower and upper bound of the part of the plot        
    yLims_curr = ylim;
    ylim([1.1*yLims_curr(1) yLims_curr(2)]); 
    yLims = ylim;
    sigPos = min(yLims) + diff(yLims).*[0 .1];

    % coloring in the uncorrected t-values
    tHotColMap = jmaColors('pval'); 
    tHotColMap(end, :) = [1 1 1]; 
    
    pixWidth = 20;
    pBar = repmat( pValue', pixWidth, 1);
    hImg = image([min(tc), max(tc)],[sigPos(1), sigPos(2)], pBar, ...
        'CDataMapping', 'scaled', 'Parent', currAxisHandle, 'AlphaData', 0.7);
    
    colormap(currAxisHandle, tHotColMap);
    cMapMax = .05 + 2*.05/(size(tHotColMap, 1));
    set(currAxisHandle, 'CLim', [ 0 cMapMax ] ); % set range for color scale
    uistack(hImg, 'bottom'); hold on;
    pos = get(currAxisHandle, 'position');
    cb = colorbar;
    set(cb,'position',[pos(1) + pos(3) 2*pos(2) .02 .1]) 
 end