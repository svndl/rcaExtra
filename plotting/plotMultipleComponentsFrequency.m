function groups = plotGroupsConditions_freq(conditionLabels, groupLabels, varargin)
%% Function will lolliplot multiple components pairwise
%% INPUT:
    % varargin -- groups + labels: {group1, group2,..., groupN, groupLabels}
    % groupX -- cell array with 3 elements: 
    % groupX{1} = values amp, 
    % groupX{2} = values phase, 
    % groupX{3} = error ellipses
    
    % groupX = {Values(nCnd x nComp x nFreq) Errors (nCnd x nComp x nFreq)}
%% OUTPUT
    % groups -- Figure handle of by group pliots
   
    componentTitles =  {'RC1', 'OZ'};    
    nGroups = numel(groupLabels);
    
    groupData = varargin;
    
    nFreq = size(groupData{1}.amp, 1);
    nCnd = size(groupData{1}.amp, 3);
    nComp = size(groupData{1}.amp, 2);
    
    plotSettings = getOnOffPlotSettings('groupsconditions', 'Freq');    

    ax = cell(1, nFreq);
    
    freqLabels = cellfun( @(x) strcat('F', num2str(x)), num2cell(1:1:nFreq), 'uni', false);
    
    nComp = 1;
    for cp = 1:nComp
        for nf = 1:nFreq
            figure('units','normalized','outerposition',[0 0 1 1]);
            ax{nf} = gca;
            for g = 1:nGroups
                currGroupProj = groupData{g};
                colorGroup = plotSettings.colors(r, :, :);
                
                groupstyle = plotSettings.linestyles{r};

                amp = currGroupProj.amp;
                phase = currGroupProj.phase;
                try
                    ellipseCalc = currGroupProj.ellipseErr;
                catch
                    ellipseCalc = currGroupProj.err;
                end
                
                for cnd = 1:nCnd
                    
                    %L is the length
                    %angle is alpha
                    L = squeeze(amp(nf, cp, cnd));
                    alpha = squeeze(phase(nf, cp, cnd));
                    x = L.*cos(alpha);
                    y = L.*sin(alpha);
                    e_x = 0;
                    e_y = 0;
                    try
                        e0 = ellipseCalc{cnd}{nf, cp};
                    catch
                        
                        e0 = ellipseCalc(nf);
                    end
                    if (~isempty(e0))
                        e_x = e0(:, 1) + x;
                        e_y = e0(:, 2) + y;
                    end
                
                    props = { 'linewidth', 8, 'color', colorGroup(cnd, :), 'linestyle', groupstyle};
                    %plot(ax, [0, x], [0, y], props{:}); hold on;
                    %e = ellipse(maxAmpDiff, maxAngleDiff, alpha, x, y, c_rg(cnd,:)); hold on;
                    % plot the output ellipse?
                    patchSaturation = 0.5;
                    patchColor =  colorGroup(cnd,:) + (1 - colorGroup(cnd, :))*(1-patchSaturation);
                    %p.patch = patch(e_x, e_y, patchColor); hold on;
                    errLine = line(e_x, e_y, 'LineWidth', 5); hold on;
                    %edgeColor = colorGroup(cnd,:);
                    set(errLine,'color', patchColor);
                    p = plot(ax{nf}, [0, x], [0, y], props{:}); hold on;
                    
                    legendRef{cnd, g} = p;
                    cndLabel{cnd, g} = sprintf('%s %s', groupLabels{g}, conditionLabels{cnd});
                end
                %descr = [componentTitles{cp} '_' freqLabels{nf}];
                %title(descr, 'Interpreter', 'none');
            end
            % font size      
            linkaxes([ax{1}, ax{nf}],'xy');
            setAxisAtTheOrigin(ax{nf});
            descr = [componentTitles{cp} ' ' freqLabels{nf}];
            legend(ax{nf}, [legendRef{:}], cndLabel(:), 'FontSize', 25);
            title(descr, 'Interpreter', 'none');
            saveas(gcf, fullfile(saveDir, [groupLabels{:} '_' freqLabels{nf} '.fig']))
            saveas(gcf, fullfile(saveDir, [groupLabels{:} '_' freqLabels{nf} '.png']))        
        end
    end
end