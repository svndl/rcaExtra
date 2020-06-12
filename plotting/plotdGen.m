function plotdGen(handles, covData, nComp, nSubplotsRow)

    % plotting covariance and dGen
    hasAdditionalData = ~isempty(covData.Rxx) && ~isempty(covData.Ryy) && ~isempty(covData.dGen);
    if(hasAdditionalData)
        xLabelStr = arrayfun(@(x) strcat('RC ', num2str(x)), nComp:-1:1, 'uni', false);
        try
            gca(handles)
            [~, eg] = eig(covData.Rxx + covData.Ryy);
            e = sort(diag(eg), 'ascend');
            subplot(nSubplotsRow, 2, 5);
            % plot last nComp
            plot(e(end - nComp + 1:end), '*', 'MarkerSize', 20);
            title('Within-trial covariance spectrum', 'FontSize', 20, ...
                'fontname', 'helvetica', 'FontAngle', 'italic');
            set(gca, 'FontSize', 20);
            set(gca, 'xticklabel', xLabelStr);
        
            subplot(nSubplotsRow, 2, 6); 
            plot(covData.dGen(end - nComp + 1:end), '^', 'MarkerSize', 20);
            title('dGen', 'FontSize', 20, ...
                'fontname', 'helvetica', 'FontAngle', 'italic'); 
            set(gca, 'FontSize', 20);
            set(gca, 'xticklabel', xLabelStr);

        catch err
            fprintf('unable to plot within-trial covariance spectrum. \n');
        end
    end
end