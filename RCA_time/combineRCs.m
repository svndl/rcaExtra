function combineRCs(A, rcData, plotName)
% function will plot heatmaps of all possible rc combinations (to figure out sign/polarity)

    close all;
    combSigns = [-1, 1];
    nRcs = size(A, 2);
    
    argin = cell(1, nRcs);
    for c = 1:nRcs
        argin{c} = combSigns; 
    end
    
    signMat = allcomb(argin{:});
    nComb = size(signMat, 1);
    
    catData = cat(3, rcData{:});
    muData = nanmean(catData, 3);
    
    figure('Position', [0 0 1 1/8])    
    for nc = 1:nComb
        comb = sum(signMat(nc, :).*A, 2);
        subplot(1, 2*nComb, 1, 2*nc - 1);
        plotOnEgi(comb);       
        subplot(2, 2*nComb, 2*nc);
        plot(sum(signMat(nc, :).*muData, 2));
        % fix the scaling
        title(sprintf('RC1 RC2 RC3 \n %s', int2str(signMat(nc, :))));
        axis off;
    end
    saveas(gcf, [plotName '.fig']);
end

%% Plot RC1 vs RC2
% 
function plot Rc1_vs_Rc2(A, rcData, plotName)
    catData = cat(3, rcData{:});
    muData = nanmean(catData, 3);
    figure;
    
    subplot(1, 2*nComb, 1, 2*nc - 1);
   


end