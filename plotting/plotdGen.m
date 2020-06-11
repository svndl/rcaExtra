function plotdGen(handles, Rxx, Ryy, dGen, nSubplotsRow)

    % plotting covariance and dGen
    hasAdditionalData = ~isempty(Rxx) && ~isempty(Ryy) && ~isempty(dGen);
    if(hasAdditionalData)
        try
            gca(handles)
            [~, eg] = eig(Rxx + Ryy);
            e = sort(diag(eg), 'ascend');
            subplot(nSubplotsRow, 2, 5);
            % plot last nComp
            plot(e(end - nComp + 1:end), '*', 'MarkerSize', 20);
            title('Within-trial covariance spectrum', 'FontSize', 20, ...
                'fontname', 'helvetica', 'FontAngle', 'italic');
            set(gca, 'FontSize', 20);
        
            subplot(nSubplotsRow, 2, 6); 
            plot(dGen(end - nComp + 1:end), '^', 'MarkerSize', 20);
            title('Across-trial covariance spectrum', 'FontSize', 20, ...
                'fontname', 'helvetica', 'FontAngle', 'italic'); 
            set(gca, 'FontSize', 20);
       
        catch err
            fprintf('unable to plot within-trial covariance spectrum. \n');
        end
    end
end