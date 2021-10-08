function plotIndividualSubjectFrequency(varargin)
% plot individual subject's amplitude/phase and error bar
% subj's data is a structure with subfields subj.amp, subj.phase, subj.err
% Dimensions are nFreqs x nComponents x nSubjects xnConditions
    groupTitles = varargin{end};
    componentTitles =  varargin{end - 2};
    conditionTitles =  varargin{end - 1};
    subjData = varargin{1};

    nFreq = size(subjData.amp, 1);
    nComp = size(subjData.amp, 2);
    nCnd = size(subjData.amp, 3);
    
    %% Figure, Cond A vs Cond B by frequency
    projFig = figure;

    
    load('colorbrewer.mat'); 
    PaletteN = 7;
    
    blues = colorbrewer.seq.YlGnBu{PaletteN}/255;
    reds = colorbrewer.seq.YlOrRd{PaletteN}/255;
    
    freqLabels = cellfun( @(x) strcat('F', num2str(x)), num2cell(1:1:nFreq), 'uni', false);
    
    for cp = 1:nComp
        for nf = 1:nFreq
            linearInd = sub2ind([nFreq nComp], nf, cp);
            ax = subplot(nComp, nFreq, linearInd, 'Parent', projFig);
            cl = cat(1, blues(end:-1:1, :), reds(end:-1:1, :));
                
                for cnd = 1:nCnd
                    %% plotting project's error
                    
                    e0 = [];
                    
                    % individual error
                    eR = squeeze(subjData.err(nf, cp, cnd));
                    th = 0:pi/50:2*pi;
                    e0(:, 1) = eR * cos(th);
                    
                    %L is the length
                    %angle is alpha
                    L = squeeze(subjData.amp(nf, cp, cnd));
                    alpha = squeeze(subjData.phase(nf, cp, cnd));
                    x = L.*cos(alpha);
                    y = L.*sin(alpha);
                    e_x = 0;
                    e_y = 0;

                    if (~isempty(e0))
                        e_x = e0(:, 1) + x;
                        e_y = e0(:, 2) + y;
                    end
                
                    props = { 'linewidth', 3, 'color', cl(cnd, :), 'linestyle', '-'};
                    patchSaturation = 0.5;
                    patchColor =  cl(cnd,:) + (1 - cl(cnd,:))*(1-patchSaturation);
                    errLine = line(e_x, e_y, 'LineWidth', 2); hold on;
                    set(errLine,'color', patchColor);
                    p = plot(ax, [0, x], [0, y], props{:}); hold on;
                    
                    legendRef{cnd, g} = p;
                    cndLabel{cnd, g} = sprintf('%s %s', groupTitles{g}, conditionTitles{cnd});
                end

        end
        setAxisAtTheOrigin(ax);
        
        descr = [componentTitles{cp} ' ' freqLabels{nf}];
        legend(ax, [legendRef{:}], cndLabel(:));
        title(descr, 'Interpreter', 'none');
        set(gca, 'FontSize', fontSize);
        set(gca,'DefaultTextFontSize',18);
    end    
end