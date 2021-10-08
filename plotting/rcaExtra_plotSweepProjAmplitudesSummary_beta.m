function rcaExtra_plotSweepProjAmplitudesSummary_beta(rcaResult, nRcs_in, nFs_in, lockAxes, phaseAspRatio)
% as of now, it will plot all frequencies for all RCs from the supplied
% rcaResult struct. At the moment, the high noise estimates are used to
% plot the noise ceiling.
% // TODO: abscissa should reflect actual quantities (needs to fetch info)
% // TODO: tiledlayout() might not be flexible enough, might have to
% rewrite the plot panel layout part
% LLV

if nargin < 5 || isempty(phaseAspRatio)
    phaseAspRatio = 5;
end
if nargin < 4 || isempty(lockAxes)
    lockAxes = true;
end
if nargin < 3 || isempty(nFs_in)
    nFs_in = -1;
end
if nargin < 2 || isempty(nRcs_in)
    nRcs_in = -1;
end

xx = rcaResult.rcaSettings.useBins;
yy = rcaResult.projAvg.amp;
warning('*** temporarily recomputing std of projected amplitudes to plot SEM estimates! ***');
% yyErr = rcaResult.projAvg.errA;
% yyErr = nan(size(yy));
subjProjAmpls = squeeze(rcaResult.subjProj.amp);
yyErr = std(subjProjAmpls, [], 4) ./ sqrt(size(subjProjAmpls, 4));
ampl_limits = [min(yy, [], 'all'), max(yy, [], 'all')];
yyPh = rad2deg(rcaResult.projAvg.phase);
topo = rcaResult.A;
if not(isfield(rcaResult, 'noiseHighAvg'))
    error('TODO: run "rcaExtra_computeSweepAverages()" on rcaResult');
end
yNoiseHigh = rcaResult.noiseHighAvg.amp;
if nRcs_in == -1
    nRcs = rcaResult.rcaSettings.nComp;
else
    assert(nRcs_in <= rcaResult.rcaSettings.nComp, 'requested more RCs than available in data.');
    nRcs = nRcs_in;
end
if nFs_in == -1
    nF = numel(rcaResult.rcaSettings.useFrequencies);
else
    assert(nFs_in <= numel(rcaResult.rcaSettings.useFrequencies), 'requested more harmonics than available in data.');
    nF = nFs_in;
end

freqLabels = rcaResult.rcaSettings.useFrequencies(1:nF);
cndNmb = rcaResult.rcaSettings.useCnds;
cndString = rcaResult.rcaSettings.label;

tl = tiledlayout(nRcs * 2, nF + 1, 'TileSpacing', 'compact', 'Padding', 'compact');

for rc_idx = 1:nRcs
    tmp = nexttile([2 1]);
    colorbarLimits = [min(topo(:, rc_idx)), max(topo(:, rc_idx))];
    plotOnEgi(topo(:, rc_idx), colorbarLimits);
    daspect(tmp, [1 1 1]); % axis equal
    title(sprintf('RC%i', rc_idx), 'FontName', 'Helvetica', 'FontSize', 16);
    
    for f_idx = 1:nF
        nexttile;
        hold on;
        plot(xx, yy(:, f_idx, rc_idx), '.-k', 'LineWidth', 1.5, ...
            'MarkerSize', 20);
        %         errorbar(xx, yy(:, f_idx, rc_idx), yyErr(:, f_idx, rc_idx, 1), ...
        %             yyErr(:, f_idx, rc_idx, 2), '.-k', 'LineWidth', 1.5, ...
        %             'MarkerSize', 20); % asymmetric for future use with projected amplitudes
        errorbar(xx, yy(:, f_idx, rc_idx), yyErr(:, f_idx, rc_idx), '.-k', 'LineWidth', 1.5, ...
            'MarkerSize', 20, 'CapSize', 0); % asymmetric for future use with projected amplitudes
        area(xx, yNoiseHigh(:, f_idx, rc_idx), 0, 'FaceColor', [0.5, 0.5, 0.5], ...
            'FaceAlpha', 0.5, 'EdgeAlpha', 0);
        if rc_idx == 1
            title(sprintf('%s', freqLabels{f_idx}), 'FontName', 'Helvetica', ...
                'FontSize', 16);
        end
        if lockAxes
            ylim(ampl_limits);
        end
        % pbaspect([1.5 1 1]);
        xticks(xx);
        xticklabels([]);
        if lockAxes && f_idx > 1
            currYTicks = yticks;
            yticklabels([]);
            yticks(currYTicks);
        end
        set(gca, 'FontSize', 14, 'FontName', 'Helvetica');
        hold off;
    end
    % phases
    for f_idx = 1:nF
        nexttile;
        hold on;
        plot(xx, yyPh(:, f_idx, rc_idx), '-k', 'LineWidth', 1, ...
            'MarkerSize', 20);
        pbaspect([phaseAspRatio 1 1]);
        ylim([-180, 180]);
        yticklabels([-180, 0, 180]);
        if f_idx > 1
            yticklabels([]);
        end
        if rc_idx < nRcs
            xticklabels([]);
            xticks(xx);
        end
        set(gca, 'FontSize', 14, 'FontName', 'Helvetica');
        hold off;
    end
end
title(tl, sprintf('Cnd n. %i, "%s"', cndNmb, cndString), ...
    'FontName', 'Helvetica', 'FontSize', 18);
end