function plotAmplitudeBars(fighandle, rcaDataIn, statData, nSubplotsRow)
    % plotting amplitude
    % use black colors
    
    nComp = size(rcaDataIn.amp, 2);
    default_color = [0 0 0];
    
    AxesHandle = cell(nComp, 1);
    try
        for c = 1:nComp
            gca(fighandle);
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
        fprintf('unable to plot Amplitude \n');        
        rcaExtra_displayError(err);
    end
end