function plot_addStatsBar_freq(currAxisHandle, pValues, xVals)    
% function adds significance values to bars

    nF = size(xVals, 1);
    % create significance levels
    
    asterisk_1 = repmat({'*'}, nF, 1);
    asterisk_2 = repmat({'**'}, nF, 1);
    asterisk_3 = repmat({'***'}, nF, 1);
    
    asterick_plotSettings = {'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
        'FontSize', 50, 'fontname', 'helvetica', 'Color', 'r'};
    
    %currRC_sig = statData.sig(:, c);
    currRC_sig_1 = (pValues < 0.05).* (pValues > 0.01);
    currRC_sig_2 = (pValues < 0.01).*(pValues > 0.001);
    currRC_sig_3 = pValues < 0.001;
    
    % pValues text Y position
    maxY = ylim;
    text_maxY = 0.5*maxY(2)*ones(nF, 1);
    
    text_sigAsterick_1 = asterisk_1(currRC_sig_1 > 0);
    text_sigAsterick_2 = asterisk_2(currRC_sig_2 > 0);
    text_sigAsterick_3 = asterisk_3(currRC_sig_3 > 0);
    
%     % display pValue (should be optional)
%     text(currAxisHandle, 1:length(pValues), ...
%         text_maxY(:, 1), num2str(pValues, '%0.4f'), 'FontSize', 20);
    
    % display significance
    text(currAxisHandle, xVals(currRC_sig_1 > 0), ...
        text_maxY(currRC_sig_1 > 0), text_sigAsterick_1, asterick_plotSettings{:});
    
    text(currAxisHandle, xVals(currRC_sig_2 > 0), ...
       text_maxY(currRC_sig_2 > 0), text_sigAsterick_2, asterick_plotSettings{:});
    
    text(currAxisHandle, xVals(currRC_sig_3 > 0), ...
        text_maxY(currRC_sig_3 > 0), text_sigAsterick_3, asterick_plotSettings{:});
    
%     % add pValue legends
%     text(currAxisHandle, nF, 1.1*text_maxY(1, 1), '* : 0.01 < p < 0.05', ...
%         'FontSize', 20, 'fontname', 'helvetica', 'Color', 'k');
%     text(currAxisHandle,  nF, text_maxY(1, 1), '** : 0.001 < p < 0.01', ...
%         'FontSize', 20, 'fontname', 'helvetica', 'Color', 'k');
%     text(currAxisHandle,  nF, 0.9*text_maxY(1, 1), '*** : p < 0.001', ...
%         'FontSize', 20, 'fontname', 'helvetica', 'Color', 'k');
end