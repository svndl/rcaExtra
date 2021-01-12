function plot_addStatsBar_freq(currAxisHandle, pValues, xVals)    
% function adds significance values to bars

    %% add significance
    asterisk_1 = repmat({'*'}, size(xVals, 1), 1);
    asterisk_2 = repmat({'**'}, size(xVals, 1), 1);
    asterisk_3 = repmat({'***'}, size(xVals, 1), 1);
    
    asterick_plotSettings = {'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
        'FontSize', 50, 'fontname', 'helvetica', 'Color', 'r'};
    
    %currRC_sig = statData.sig(:, c);
    currRC_sig_1 = (pValues < 0.05).* (pValues > 0.01);
    currRC_sig_2 = (pValues < 0.01).*(pValues > 0.001);
    currRC_sig_3 = pValues < 0.001;
    
    % pValues text Y position
    text_maxY = 0.35*xVals(:, 1) ;
    
    text_sigAsterick_1 = asterisk_1(currRC_sig_1 > 0);
    text_sigAsterick_2 = asterisk_2(currRC_sig_2 > 0);
    text_sigAsterick_3 = asterisk_3(currRC_sig_3 > 0);
    
%     % display pValue (should be optional)
%     text(currAxisHandle, 1:length(pValues), ...
%         text_maxY(:, 1), num2str(pValues, '%0.4f'), 'FontSize', 20);
    
    % display significance
    text(currAxisHandle, find(currRC_sig_1 > 0), ...
        xVals(currRC_sig_1 > 0, 1), text_sigAsterick_1, asterick_plotSettings{:});
    
    text(currAxisHandle, find(currRC_sig_2 > 0), ...
        xVals(currRC_sig_2 > 0, 1), text_sigAsterick_2, asterick_plotSettings{:});
    
    text(currAxisHandle, find(currRC_sig_3 > 0), ...
        xVals(currRC_sig_3 > 0, 1), text_sigAsterick_3, asterick_plotSettings{:});
    
    nF = size(xVals, 1);
    % add pValue legends
    text(currAxisHandle, nF, 1.1*xVals(1, 1), '* : 0.01 < p < 0.05', ...
        'FontSize', 20, 'fontname', 'helvetica', 'Color', 'k');
    text(currAxisHandle,  nF, xVals(1, 1), '** : 0.001 < p < 0.01', ...
        'FontSize', 20, 'fontname', 'helvetica', 'Color', 'k');
    text(currAxisHandle,  nF, 0.9*xVals(1, 1), '*** : p < 0.001', ...
        'FontSize', 20, 'fontname', 'helvetica', 'Color', 'k');
end