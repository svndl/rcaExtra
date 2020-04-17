function barplotGroups(g1, g2, groupLabels, settings)
    cndLabels = settings.cndLabels;
    colors1 = settings.colors1;
    colors2 = settings.colors2; 
    saveDir = settings.saveDir;
    f = settings.frequency;
    if(isfield(settings, 'delay'))
        delay = settings.delay;
    else
        delay = 0;
    end
        
    %close all;
    nFreq = size(g1.amp, 1);
    %nComp = size(g1.amp, 2);
    nComp = 1;

    % amplitude and frequency
    nSubplots_Col = 2;
    nSubplots_Row = nComp;
    
    nFigs = get(gcf, 'Number');
    group1_Fig = figure(nFigs + 1);
    set(group1_Fig, 'units', 'normalized', 'outerposition', [0 0 1 1]);
    
    group2_Fig = figure(nFigs + 2);
    set(group2_Fig, 'units', 'normalized', 'outerposition', [0 0 1 1]);

    between_groups_Fig1 = figure(nFigs + 3);
    set(between_groups_Fig1, 'units', 'normalized', 'outerposition', [0 0 1 1]);
    between_groups_Fig2 = figure(nFigs + 4);
    set(between_groups_Fig2, 'units', 'normalized', 'outerposition', [0 0 1 1]);
    
    %%
    for cp = 1:1
        %projFig = figure;
        %% amplitude
        sh_amp_1 = subplot(nSubplots_Row, nSubplots_Col, 2*(cp - 1) + 1, 'Parent', group1_Fig);
        sh_amp_2 = subplot(nSubplots_Row, nSubplots_Col, 2*(cp - 1) + 1, 'Parent', group2_Fig);
        sh_amp_3 = subplot(nSubplots_Row, nSubplots_Col, 2*(cp - 1) + 1, 'Parent', between_groups_Fig1);
        sh_amp_4 = subplot(nSubplots_Row, nSubplots_Col, 2*(cp - 1) + 1, 'Parent', between_groups_Fig2);
        
        title_1 = ['Amplitude ' groupLabels(1)];
        title_2 = ['Amplitude ' groupLabels(2)];
        title_3 = ['Amplitude ' cndLabels(1)];
        title_4 = ['Amplitude ' cndLabels(2)];

        yLabel_a = 'Amplitude, \muV';
        
        ampData_g1 = squeeze(g1.amp(:, cp, :));
        amp_errData_g1 = squeeze(g1.errA(:, cp, :, :));
        
        ampData_g2 = squeeze(g2.amp(:, cp, :));
        amp_errData_g2 = squeeze(g2.errA(:, cp, :, :));
        
        btwn_Amp_C1 = cat(2, ampData_g1(:, 1), ampData_g2(:, 1));
        btwn_Amp_C2 = cat(2, ampData_g1(:, 2), ampData_g2(:, 2));
        colors3 = cat(1, colors1(1, :), colors2(1, :));
        colors4 = cat(1, colors1(2, :), colors2(2, :));
        
        btwn_AmpE_C1 = cat(3, cat(2, amp_errData_g1(:, 1, 1), amp_errData_g2(:, 1, 1)), ...
            cat(2, amp_errData_g1(:, 1, 2), amp_errData_g2(:, 1, 2)));
        btwn_AmpE_C2 = cat(3, cat(2, amp_errData_g1(:, 2, 1), amp_errData_g2(:, 2, 1)), ...
            cat(2, amp_errData_g1(:, 2, 2), amp_errData_g2(:, 2, 2)));
         
        barPlotNBars(sh_amp_1, ampData_g1, amp_errData_g1, title_1, cndLabels, yLabel_a, colors1);
        barPlotNBars(sh_amp_2, ampData_g2, amp_errData_g2, title_2, cndLabels, yLabel_a, colors2);
        barPlotNBars(sh_amp_3, btwn_Amp_C1, btwn_AmpE_C1, title_3, groupLabels, yLabel_a, colors3);
        barPlotNBars(sh_amp_4, btwn_Amp_C2, btwn_AmpE_C2, title_4, groupLabels, yLabel_a, colors4);
        
        linkaxes([sh_amp_1, sh_amp_2, sh_amp_3, sh_amp_4], 'xy');
        %% phase
        sh_phs_1 = subplot(nSubplots_Row, nSubplots_Col, 2*cp, 'Parent', group1_Fig);
        sh_phs_2 = subplot(nSubplots_Row, nSubplots_Col, 2*cp, 'Parent', group2_Fig);
        sh_phs_3 = subplot(nSubplots_Row, nSubplots_Col, 2*cp, 'Parent', between_groups_Fig1);
        sh_phs_4 = subplot(nSubplots_Row, nSubplots_Col, 2*cp, 'Parent', between_groups_Fig2);
        
        title_1 = ['Phase ' groupLabels(1)];
        title_2 = ['Phase ' groupLabels(2)];
        title_3 = ['Phase ' cndLabels(1)];
        title_4 = ['Phase ' cndLabels(2)];
        yLabel_p = 'Phase, \phi, radians';
        
        phiData_g1 = unwrap(squeeze(g1.phase(:, cp, :, :)));
        phi_errData_g1 = squeeze(g1.errP(:, cp, :, :));
        phiData_g2 = unwrap(squeeze(g2.phase(:, cp, :, :)));
        phi_errData_g2 = squeeze(g2.errP(:, cp, :, :));
        
        btwn_Ph_C1 = cat(2, phiData_g1(:, 1), phiData_g2(:, 1));
        btwn_Ph_C2 = cat(2, phiData_g1(:, 2), phiData_g2(:, 2));
        btwn_PhE_C1 = cat(3, cat(2, phi_errData_g1(:, 1, 1), phi_errData_g2(:, 1, 1)), ...
            cat(2, phi_errData_g1(:, 1, 2), phi_errData_g2(:, 1, 2)));
        btwn_PhE_C2 = cat(3, cat(2, phi_errData_g1(:, 2, 1), phi_errData_g2(:, 2, 1)), ...
            cat(2, phi_errData_g1(:, 2, 2), phi_errData_g2(:, 2, 2)));

        scatterPlotPhase(sh_phs_1, phiData_g1, phi_errData_g1, title_1, cndLabels, yLabel_p, colors1, f, delay);
        scatterPlotPhase(sh_phs_2, phiData_g2, phi_errData_g2, title_2, cndLabels, yLabel_p, colors2, f, delay);
        scatterPlotPhase(sh_phs_3, btwn_Ph_C1, btwn_PhE_C1, title_3, groupLabels, yLabel_p, colors3, f, delay);
        scatterPlotPhase(sh_phs_4, btwn_Ph_C2, btwn_PhE_C2, title_4, groupLabels, yLabel_p, colors4, f, delay);
        linkaxes([sh_phs_1, sh_phs_2, sh_phs_3, sh_phs_4], 'xy');
        
    end
    
    sep = '_';
    name_1 = strcat('amp-phase', sep, groupLabels(1), sep, cndLabels(1), sep, cndLabels(2));
    name_2 = strcat('amp-phase', sep, groupLabels(2), sep, cndLabels(1), sep, cndLabels(2));
    name_3 = strcat('amp-phase', groupLabels(1), sep, groupLabels(2), sep, cndLabels(1));
    name_4 = strcat('amp-phase', groupLabels(1), sep, groupLabels(2), sep, cndLabels(2));
    
    saveas(group1_Fig, fullfile(saveDir, cell2mat([name_1 '.fig'])));
    saveas(group2_Fig, fullfile(saveDir, cell2mat([name_2 '.fig'])));

    saveas(between_groups_Fig1, fullfile(saveDir, cell2mat([name_3 '.fig'])));
    saveas(between_groups_Fig2, fullfile(saveDir, cell2mat([name_4 '.fig'])));

    saveas(group1_Fig, fullfile(saveDir, cell2mat([name_1 '.png'])));
    saveas(group2_Fig, fullfile(saveDir, cell2mat([name_2 '.png'])));

    saveas(between_groups_Fig1, fullfile(saveDir, cell2mat([name_3 '.png'])));
    saveas(between_groups_Fig2, fullfile(saveDir, cell2mat([name_4 '.png'])));
    
end
