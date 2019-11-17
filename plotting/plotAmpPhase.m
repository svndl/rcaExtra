function [bh, ebh] = plotAmpPhase(ax1, ax2, amp, ph, errA, errP, color)
    %% amplitude
    yLabel_a = 'Amplitude, \muV';
    axes(ax1);
    
    nCnd = 1;
    nF = size(amp, 1);
    xlabels = cellfun( @(x) strcat(num2str(x), 'F'), num2cell(1:1:nF), 'uni', false);
    
    x = (1:nF)';
   
    nGroups = nF;
    nBars = nCnd;
    groupWidth = min(0.8, nBars/(nBars + 1.5));
    xE = zeros(nGroups, nBars);
    for b = 1:nBars
        xE(:, b) = (1:nGroups) - groupWidth/2 + (2*b -1 )*groupWidth / (2*nBars);
    end
    
    bh = bar(x, amp); hold on;
    beh = errorbar(xE, amp, errA(:, 1), errA(:, 2), ...
        'LineStyle', 'none', 'LineWidth', 2);hold on;
    
    patchSaturation = 0.15;

    patchColor = color + (1 - color)*(1 - patchSaturation);
    set(bh, 'EdgeColor', color);
    set(bh, 'FaceColor', patchColor);
    set(beh, 'color', color);
    title('Amplitude', 'Interpreter', 'none');    

    try
        xticklabels(xlabels(:));
    catch
        xlabel(xlabels);
    end
    ylabel(yLabel_a);
    
    %% phase
    %% TODO add regression line
    yLabel_p = 'Phase, \phi, radians';

    phiData = unwrap(ph);
    axes(ax2);
    
    ebh = errorbar(x, phiData, errP(:, 1), errP(:, 2), ...
         '*', 'LineStyle', 'none', 'LineWidth', 2, 'MarkerSize', 7); hold on;
    title('Phase', 'Interpreter', 'none');    
    set(ebh, 'color', color);
    
    try
        xticklabels(xlabels);
    catch
        xlabel(xlabels);
    end
    ylabel(yLabel_p);    
end