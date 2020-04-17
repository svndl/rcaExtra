function lollipopPlot(amp, phase, ellipseCalc, labels)    
    nFreq = size(amp, 1);
    nComp = size(amp, 2);
    nCnd = size(amp, 3);
    legendRef = cell(nCnd, 1);

    load('colorbrewer.mat');
    PaletteN = 7;
    blues = colorbrewer.seq.YlGnBu{PaletteN}/255;
    reds = colorbrewer.seq.YlOrRd{PaletteN}/255;
    c_rg = cat(1, blues(end, :), reds(end, :));

    freqLabels = cellfun( @(x) strcat('F', num2str(x)), num2cell(1:1:nFreq), 'uni', false);
    cndLabels = cellfun( @(x) strcat('Cnd ', num2str(x)), num2cell(1:1:nCnd), 'uni', false);
    projFig = figure('units','normalized','outerposition',[0 0 1 1]);
    for cp = 1:nComp
        for nf = 1:nFreq
            linearInd = sub2ind([nFreq nComp], nf, cp);
            ax = subplot(nComp, nFreq, linearInd, 'Parent', projFig);

            for cnd = 1:nCnd
                %L is the length
                %angle is alpha
                L = squeeze(amp(nf, cp, cnd));
                alpha = squeeze(phase(nf, cp, cnd));
                x = L.*cos(alpha);
                y = L.*sin(alpha);
                e0 = ellipseCalc{cnd}{nf, cp};
                %eA = 0.5*sum(squeeze(ampError(nf, cp, cnd, :)));
                %eP = 0.5*sum(squeeze(phaseError(nf, cp, cnd, :)));
                %maxAmpDiff = eA*cos(alpha);
                %maxAngleDiff = L*sin(alpha + eP) - y;
                e_x = e0(:, 1) + x;
                e_y = e0(:, 2) + y;
                props = { 'linewidth', 2, 'color', c_rg(cnd,:)};
                %plot(ax, [0, x], [0, y], props{:}); hold on;
                %e = ellipse(maxAmpDiff, maxAngleDiff, alpha, x, y, c_rg(cnd,:)); hold on;
                % plot the output ellipse?
                patchSaturation = 0.15;
                patchColor =  c_rg(cnd,:) + (1 -  c_rg(cnd,:))*(1-patchSaturation);
                p.patch = patch(e_x, e_y, patchColor); hold on;
                p.mainLine = line(e_x, e_y, 'LineWidth', 2); hold on;
                edgeColor = c_rg(cnd,:);
                set(p.mainLine,'color', edgeColor);

                plot(ax, [0, x], [0, y], props{:}); hold on;
                legendRef{cnd} = p.patch;
            end
            maxV = max(amp(nf, cp, :));

            set(ax,'XLim', 1.2*[-abs(maxV) abs(maxV)]);
            set(ax,'YLim', 1.2*[-abs(maxV) abs(maxV)]);
            setAxisAtTheOrigin(ax);
            
            descr = [labels{cp} '_' freqLabels{nf}];
            legend(ax, [legendRef{:}], cndLabels(:)');
            title(descr, 'Interpreter', 'none');
        end
    end
end