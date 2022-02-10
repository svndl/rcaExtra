function plotSummary_AmplitudeBars(fighandle, xLabel, rcaDataIn, statData, nSubplotsRow)
    % plotting amplitude
    % use black colors
    
    nComp = size(rcaDataIn.amp, 2);
    default_color = [0; 0 ; 0];
    
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
            
            xLabel_num = cellfun(@(x) str2double(x(1)), xLabel, 'uni', true);
            
            rcaExtra_barplot_freq(AxesHandle{c}, xLabel_num, groupAmp, groupAmpErrs, ...
            default_color, {});
    
            % add significance
            asterisk_1 = repmat({'*'}, size(groupAmp, 1), 1);
            asterisk_2 = repmat({'**'}, size(groupAmp, 1), 1);
            asterisk_3 = repmat({'***'}, size(groupAmp, 1), 1);
           
            asterick_plotSettings = {'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
                'FontSize', 30, 'fontname', 'helvetica', 'Color', 'r'};
            
            if (~isempty(statData))
                currPValue = statData.pValues(:, c);
                %currRC_sig = statData.sig(:, c);
                currRC_sig_1 = (currPValue < 0.05).* (currPValue > 0.01);
                currRC_sig_2 = (currPValue < 0.01).* (currPValue > 0.001);
                currRC_sig_3 = currPValue < 0.001;
                
                
                % pValues text Y position
                text_maxY = 0.5*groupAmp ;
                
                text_sigAsterick_1 = asterisk_1(currRC_sig_1 > 0);
                text_sigAsterick_2 = asterisk_2(currRC_sig_2 > 0);
                text_sigAsterick_3 = asterisk_3(currRC_sig_3 > 0);
    
%                 text(AxesHandle{c}, 1:length(currPValue), ...
%                     text_maxY, num2str(currPValue, '%0.4f'), 'FontSize', 30);
   
                % preset settings for stats
                text(AxesHandle{c}, find(currRC_sig_1 > 0), ...
                    groupAmp(currRC_sig_1 > 0), text_sigAsterick_1, asterick_plotSettings{:});
                
                text(AxesHandle{c}, find(currRC_sig_2 > 0), ...
                    groupAmp(currRC_sig_2 > 0), text_sigAsterick_2, asterick_plotSettings{:});

                text(AxesHandle{c}, find(currRC_sig_3 > 0), ...
                    groupAmp(currRC_sig_3 > 0), text_sigAsterick_3, asterick_plotSettings{:});
                
            end
            pbaspect(AxesHandle{c}, [1 2 1]);
        end
        linkaxes([AxesHandle{:}], 'y');
    catch err
        fprintf('unable to plot Amplitude \n');        
        rcaExtra_displayError(err);
    end
end