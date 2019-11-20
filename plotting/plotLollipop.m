function p = plotLollipop(ax, amp, ph, ellipse, color, style)
% Alexandra Yakovleva, Stanford University 2012-2020

% Function for plotting lolliplot style analysis amplitude and phase data
    axes(ax)
    x = amp.*cos(ph);
    y = amp.*sin(ph);
    e_x = 0;
    e_y = 0;

    if (~isempty(ellipse))
        e_x = ellipse(:, 1) + x;
        e_y = ellipse(:, 2) + y;
    end


    patchSaturation = 0.5;
    patchColor =  color + (1 - color)*(1 - patchSaturation);
    errLine = line(e_x, e_y, 'LineWidth', 2); hold on;
    set(errLine,'color', patchColor);
    p = plot(ax, [0, x], [0, y], 'linewidth', 3, 'color', color, 'linestyle', style); hold on;
    
    maxV = max(abs(x), abs(y));

    set(ax,'XLim', 1.2*[-maxV maxV]);
    set(ax,'YLim', 1.2*[-maxV maxV]);
    setAxisAtTheOrigin(ax);
end

