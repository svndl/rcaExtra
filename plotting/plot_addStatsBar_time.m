function plot_addStatsBar_time(currAxisHandle, pValue, h0, tc)

   %% ADD STATS
    % sigPos is the lower and upper bound of the part of the plot        
    yLims_curr = ylim(currAxisHandle);
    ylim(currAxisHandle, [1.1*yLims_curr(1) yLims_curr(2)]); 
    yLims = ylim(currAxisHandle);
    sigPos = min(yLims) + diff(yLims).*[0 .1];
    %sigPos = yLims;

    % coloring in the uncorrected t-values
    tHotColMap = jmaColors('pval'); 
    tHotColMap(end, :) = [1 1 1]; 
    
    pixWidth = 20;
    pBar = repmat( pValue', pixWidth, 1);
    hImg = image([min(tc)+ 1, max(tc)],[sigPos(1), sigPos(2)], pBar, ...
        'CDataMapping', 'scaled', 'Parent', currAxisHandle, 'AlphaData', 0.5);
    
    colormap(currAxisHandle, tHotColMap);
    cMapMax = .05 + 2*.05/(size(tHotColMap, 1));
    set(currAxisHandle, 'CLim', [ 0 cMapMax ] ); % set range for color scale
    uistack(hImg, 'bottom'); hold on;
    pos = get(currAxisHandle, 'position');
    cb = colorbar(currAxisHandle);
    set(cb, 'position',[pos(1) + pos(3) 2*pos(2) .02 .1])
        
    %identify contiguous ones
    regionIdx = bwlabel(h0);
    for m = 1:max(regionIdx)
        tmp = regionprops(regionIdx == m, 'centroid');
        idx = round(tmp.Centroid(2));
        text(currAxisHandle, tc(idx), sigPos(2), '*', 'fontsize', 50, 'fontname', 'helvetica', 'horizontalalignment','center','verticalalignment','top');
    end
 end