function phasePlot(amp, error_amp, ph, error_phase, labels)

    for nf = 1:nFreq
    linearInd = sub2ind([nFreq nComp], nf, cp);
    ax = subplot(nComp, nFreq, linearInd, 'Parent', projFig);

    for cnd = 1:nCnd
                L is the length
                angle is alpha
                L = squeeze(amp(nf, cp, cnd));
                alpha = squeeze(phase(nf, cp, cnd));
                x = L.*cos(alpha);
                y = L.*sin(alpha);
                calcedEllipse = ellipseCalc{cnd}{nf, cp};
                eA = diff(squeeze(ampError(nf, cp, cnd, :)));
                eP = diff(squeeze(phaseError(nf, cp, cnd, :)));
                props = { 'linewidth', 2, 'color', rgb10(cnd,:)};
                plot(ax, [0, x], [0, y], props{:}); hold on;
                e = ellipse(eA, eP, alpha,x, y, rgb10(cnd,:)); hold on;
                plot the output ellipse?
                patch(calcedEllipse(:, 1), calcedEllipse(:, 2), 'r');
                plot(ax, [0, x], [0, y], props{:}); hold on;
                
                legendRef{cnd} = e.patch;
               
            end
            x0 = max(amp(nf, cp, :));

            set(ax,'XLim', 1.2*[-abs(x0) abs(x0)]);
            set(ax,'YLim', 1.2*[-abs(x0) abs(x0)]);
            setAxisAtTheOrigin(ax);
            
            descr = [labels{cp} '_' freqLabels{nf}];
            legend(ax, [legendRef{:}], cndLabels(:)');
            title(descr, 'Interpreter', 'none');
        end
end
