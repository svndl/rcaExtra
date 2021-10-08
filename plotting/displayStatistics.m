function displayStatistics(axisPtr, pval, t_orig, timeScaleMs)
    
    %% plots corrected t-values and p-value on top of given plot
    
    % sigPos is the lower and upper bound of the part of the plot        
    yLims = ylim;
    sigPos = min(yLims) + diff(yLims).*[0 .1];

    % coloring in the uncorrected t-values
    tHotColMap = jmaColors('pval'); 
    tHotColMap(end, :) = [1 1 1]; 
    
    pixWidth = 30;
    curP = repmat( pval', pixWidth, 1);
    hImg = image([min(timeScaleMs), max(timeScaleMs)],[sigPos(1), sigPos(2)], curP, 'CDataMapping', 'scaled', 'Parent', axisPtr);
    
    colormap(axisPtr, tHotColMap);
    cMapMax = .05 + 2*.05/(size(tHotColMap, 1));
    set(axisPtr, 'CLim', [ 0 cMapMax ] ); % set range for color scale
    uistack(hImg,'bottom'); hold on;
end



