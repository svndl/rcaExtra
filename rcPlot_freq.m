function rcPlot_freq(rcaDataIn, freq, A, statData, Rxx, Ryy, dGen)
% Function would display results of RC data
% Alexandra Yakovleva, 2020 Stanford University

    % number of components to plot
    nComp = size(A, 2);
    
    % averaging RC data
    
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
            title(['RC' num2str(c)], 'FontSize', 25, 'fontname', 'helvetica', 'FontAngle', 'italic');
        end
    catch
        fprintf('call to plotOnEgi() failed. Plotting electrode values in a 1D style instead.\n');
        for c = 1:nComp, subplot(nSubplotsRow, nComp, c); plot(A(:, c), '*k-'); end
        title(['RC' num2str(c)]);
    end
    
    % plotting amplitude
    % use black colors
    default_color = [0 0 0];
    
    AxesHandle = cell(nComp, 1);
    try
        for c = 1:nComp
            AxesHandle{c} = subplot(nSubplotsRow, nComp, c + nComp);

            % concat bars for amplitude plot
            groupAmp = squeeze(rcaDataIn.amp(:, c));
            groupAmpErrs = rcaDataIn.errA(:, c, :);
            % plot all bars first
            %bar_label = {strcat('RC #', num2str(c))};
            freqplotBar(AxesHandle{c}, groupAmp, groupAmpErrs, default_color, {});
    
            % add significance
            asterisk = repmat('*', size(groupAmp, 1), 1);
            asterick_plotSettings = {'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
                'FontSize', 50, 'fontname', 'helvetica', 'Color', 'r'};
            
            if (~isempty(statData))
                currRC_sig = statData.sig(:, c);
                currPValue = statData.pValues(:, c);
                % pValues text Y position
                text_maxY = 0.5*groupAmp ;
                text_sigAsterick = asterisk(currRC_sig > 0);
    
                text(AxesHandle{c}, 1:length(currPValue), ...
                    text_maxY, num2str(currPValue, '%0.2f'), 'FontSize', 10);
   
                % preset settings for stats
                text(AxesHandle{c}, find(currRC_sig > 0), ...
                groupAmp(currRC_sig > 0), text_sigAsterick, asterick_plotSettings{:});
            end
            pbaspect(AxesHandle{c}, [1 1 1]);
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