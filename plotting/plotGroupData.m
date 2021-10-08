function plotGroupData(groupProj, groupStyle, groupColors, btwnGroupHandles_lolliplot, btwnGroupHandles_ampphase)

    nFreq = size(groupProj.amp, 1);
    nCnd = size(groupProj.amp, 3);


    lolliplot_by_grp = figure(3*nCnd + 1); %set(lolliplot_by_grp, 'Visible', 'off');
    amp_phase_by_grp = figure(3*nCnd + 2); %set(amp_phase_by_grp, 'Visible', 'off');


%     [groupSig, groupPVal, groupStat] = computeStatsFreq(cat(3, ...
%         groupProj.subjsRe{:}), cat(3, groupProj.subjsIm{:}));
    comp =1;
    for cnd = 1:nCnd
        ax_amp_phase_group_1 = subplot(1, 2, 1, 'Parent', amp_phase_by_grp);
        ax_amp_phase_group_2 = subplot(1, 2, 2, 'Parent', amp_phase_by_grp);
        
        a = squeeze(groupProj.amp(:, comp, cnd));
        p = squeeze(groupProj.phase(:, comp, cnd));
        %pVal = squeeze(groupPVal(nf, 1, cnd));
        eA = squeeze(groupProj.errA(:, comp, :, cnd));
        eP = squeeze(groupProj.errP(:, comp, :, cnd));

        %% plot amp and phase
        [~, ~] = plotAmpPhase(ax_amp_phase_group_1, ...
            ax_amp_phase_group_2, a, p, eA, eP, groupColors(cnd, :));
        [~, ~] = plotAmpPhase(btwnGroupHandles_ampphase{1, cnd},...
            btwnGroupHandles_ampphase{1, cnd},...
            a, p, eA, eP, groupColors(cnd, :));
        
        for nf = 1:nFreq
            ax_lolliplot_group = subplot(1, nFreq, nf, 'Parent', lolliplot_by_grp);
    
                   
            ax = squeeze(groupProj.amp(nf, comp, cnd));
            px = squeeze(groupProj.phase(nf, comp, cnd));
            %pVal = squeeze(groupPVal(nf, 1, cnd));
            %% lollipop plot ellipse        
            e0 = [];
            if isfield(groupProj, 'ellipseErr')
                e0 = groupProj.ellipseErr{cnd}{nf, comp};
            else
                % individual error
                th = 0:pi/50:2*pi;
                e0(:, 1) = e * cos(th);
                e0(:, 2) = e * sin(th);
            end
        
            %% plot lolliplot
            [~] = plotLollipop(ax_lolliplot_group, ax, px, e0, groupColors(cnd, :), groupStyle);
            [~] = plotLollipop(btwnGroupHandles_lolliplot{nf, cnd}, ax, px, e0, groupColors(cnd, :), groupStyle);
            
            
            %cndLabel{cnd, g} = sprintf('%s %s', groupTitles{g}, conditionTitles{cnd});
        end
        %descr = [componentTitles{cp} '_' freqLabels{nf}];
        %title(descr, 'Interpreter', 'none');
    end

    
    %descr = [componentTitles{cp} ' ' freqLabels{nf}];
    %legend(ax, [legendRef{:}], cndLabel(:));
    %title(descr, 'Interpreter', 'none');
end