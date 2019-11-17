function groups = plotMultipleComponentsFrequencyCloud(varargin)
%% Function will lolliplot multiple components
%% INPUT:
    % varargin -- groups + labels: {group1, group2,..., groupN, groupLabels}
    % groupX -- cell array with 3 elements: 
    % groupX{1} = values amp, 
    % groupX{2} = values phase, 
    % groupX{3} = error ellipses
    
    % groupX = {Values(nCnd x nComp x nFreq) Errors (nCnd x nComp x nFreq)}
%% OUTPUT
    % groups -- Figure handle of by group pliots 
          
    groupTitles = varargin{end};
    componentTitles =  varargin{end - 2};
    conditionTitles =  varargin{end - 1};
    
    
    nGroups = numel(groupTitles);
    
    %linestyles = {'-', '--', '-.', ':', '-*', '-o', '-+', '.'};
    
    % open-closed for groups  
    markerstyles = {'*', 'o', '+', 'd'};

    % close all figures
    %close all;

    projFig = figure;

    nFreq = size(varargin{1}.amp, 1);
    nComp = size(varargin{1}.amp, 2);
    nCnd = size(varargin{1}.amp, 4);
    
    load('colorbrewer.mat'); 
    PaletteN = 5;
    
    blues = colorbrewer.seq.YlGnBu{PaletteN}/255;
    reds = colorbrewer.seq.YlOrRd{PaletteN}/255;
    
    freqLabels = cellfun( @(x) strcat('F', num2str(x)), num2cell(1:1:nFreq), 'uni', false);
    
    for cp = 1:nComp
        projFig = figure;
        for nf = 1:1
            for cnd = 1:nCnd
                linearInd = sub2ind([1 nCnd], nf, cnd);
                ax = subplot(1, nCnd, linearInd, 'Parent', projFig);
                for g = 1:nGroups
                    if (nCnd <= 2*g)
                        colorGroup = cat(1, blues(end - g, :), reds(end - g, :));
                    else
                        colorGroup = cat(1, blues(end:-1:1, :), reds(end:-1:1, :));
                    end
                    currGroupProj = varargin{g};
                
                    amp = currGroupProj.amp;
                    phase = currGroupProj.phase;
                    ellipseCalc = currGroupProj.err;
           
                    %L is the length
                    %angle is alpha
                    L = squeeze(amp(nf, cp, :, cnd));
                    alpha = squeeze(phase(nf, cp, :, cnd));
                    x = L.*cos(alpha);
                    y = L.*sin(alpha);
                    e_x = 0;
                    e_y = 0;
                    e0 = squeeze(ellipseCalc(nf, cp, :, cnd));
                    patchSaturation = 0.15;
                    patchColor =  colorGroup(cnd,:) + (1 - colorGroup(cnd,:))*(1-patchSaturation);

                    props = {'color', colorGroup(cnd, :), 'LineStyle', 'none', 'LineWidth', 2, 'MarkerSize', 14 ...
                        'MarkerEdgeColor',colorGroup(cnd, :), 'MarkerFaceColor',patchColor};                    
                    
                    p = plot(ax, x, y, markerstyles{g}, props{:}); hold on;                    
                    legendRef{g} = p;
                    cndLabel{g} = sprintf('%s %s', groupTitles{g}, conditionTitles{cnd});
                end
                descr = [componentTitles{cp} '_' freqLabels{nf}];
                title(descr, 'Interpreter', 'none');
                % font size
                fontSize = 25;
                xl = get(ax, 'XLim');
                yl = get(ax, 'YLim');
                maxX = max(abs(xl));
                maxY = max(abs(yl));
                maxV = max(maxX, maxY);
                set(ax, 'XLim', [-maxV maxV]);
                set(ax, 'YLim', [-maxV maxV]);            
                setAxisAtTheOrigin(ax);
            
                descr = [componentTitles{cp} ' ' freqLabels{nf}];
                legend(ax, [legendRef{:}], cndLabel(:));
                title(descr, 'Interpreter', 'none');
                set(gca, 'FontSize', fontSize);
                set(gca,'DefaultTextFontSize',18);
            end
         end
    end
end