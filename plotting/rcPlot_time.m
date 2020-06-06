function rcPlot_time(rcaDataIn, tc, A, statData, Rxx, Ryy, dGen)
% Function would display results of RC data
% Alexandra Yakovleva, 2020 Stanford University

    % number of components to plot
    nComp = size(A, 2);
    
    % calculating mean and standard deviation for each component
    rcaDataMean = cellfun(@(x) nanmean(x, 3), rcaDataIn, 'uni', false);
    catData = cat(3, rcaDataMean{:});
    muData = nanmean(catData, 3);
    muData = muData - repmat(muData(1, :), [size(muData, 1) 1]);
    semData = nanstd(catData, [], 3)/(sqrt(size(catData, 3)));

    % set colorbar limits across all components
    colorbarLimits = [min(A(:)), max(A(:))];
    extremeVals = [min(A); max(A)];

    %% flip signs
    s = ones(1, nComp);
    f = ones(1, nComp);
    
    for rc = 1:nComp
        [~, f(rc)] = max(abs(extremeVals(:, rc)));
    end
    if f(1) == 1 % largest extreme value of RC1 is negative
        s(1) = -1; % flip the sign of RC1 so its largest extreme value is positive (yellow in parula)
        f(1) = 2;
    end
    for rc = 2:nComp
        if f(rc)~=f(1) % if the poles containing the maximum corr coef are different
            s(rc) = -1; % we will flip the sign of that RC's time course & thus its corr coef values (in A) too
        end
    end

    
    %% plotting routine
    nSubplotsRow = 3;
    
    % plotting topos
    try
        for c = 1:nComp
            subplot(nSubplotsRow, nComp, c);
            ax = gca;
            outerpos = ax.OuterPosition;
            ti = ax.TightInset;
            left = outerpos(1) + ti(1);
            bottom = outerpos(2) + ti(2);
            ax_width = outerpos(3) - ti(1) - ti(3);
            ax_height = outerpos(4) - ti(2) - ti(4);
            ax.Position = [left bottom ax_width ax_height];           
            plotOnEgi(s(c).*A(:, c), colorbarLimits);
            title(['RC' num2str(c)], 'FontSize', 25);
        end
    catch
        fprintf('call to plotOnEgi() failed. Plotting electrode values in a 1D style instead.\n');
        for c = 1:nComp, subplot(nSubplotsRow, nComp, c); plot(A(:, c), '*k-'); end
        title(['RC' num2str(c)]);
    end
    
    % plotting waveforms
    AxesHandle = cell(nComp, 1);
    lineProps = {'k', 'LineWidth', 1};
    yMax = 1.2*max(muData(:));
    try
        for c = 1:nComp
            AxesHandle{c} = subplot(nSubplotsRow, nComp, c + nComp);
            shadedErrorBar(tc, s(c).*muData(:, c), semData(:, c), lineProps); hold on;
            AxesHandle{c}.YLim = [-yMax, yMax];
            %axis square;
            set(gca, 'FontSize', 20);
            if (c == 1)            
                xlabel('\sl Time (msec)');
                ylabel('\sl Amplitude (\muV)');
            end
            % add stats
            if (~isempty(statData))
                plot_addStatsBar_time(AxesHandle{c}, statData.pValues(:, c), ...
                    statData.sig(:, c), tc);
            end
            
        end
        linkaxes([AxesHandle{:}], 'y');
    catch err
        fprintf('unable to plot rc means and sems. \n');
    end
    
    % plotting covariance and dGen
    hasAdditionalData = ~isempty(Rxx) && ~isempty(Ryy) && ~isempty(dGen);
    if(hasAdditionalData)
        try
            [~, eg] = eig(Rxx + Ryy);
            e = sort(diag(eg), 'ascend');
            subplot(nSubplotsRow, 2, 5);
            % plot last nComp
            plot(e(end - nComp + 1:end), '*r', 'MarkerSize', 10);
            title('Within-trial covariance spectrum', 'FontSize', 20);
            set(gca, 'FontSize', 20);
        
            subplot(nSubplotsRow, 2, 6); 
            plot(dGen(end - nComp + 1:end), '^b', 'MarkerSize', 10);
            title('Across-trial covariance spectrum', 'FontSize', 20); 
            set(gca, 'FontSize', 20);
       
        catch err
            fprintf('unable to plot within-trial covariance spectrum. \n');
        end
    end
end