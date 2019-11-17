function setAxisAtTheOrigin(gc)
    axes(gc);
    xl = get(gc, 'XLim');
    yl = get(gc, 'YLim');
    maxV = max(max(abs(xl)), max(abs(yl)));
    set(gc, 'XLim', [-maxV maxV]);
    set(gc, 'YLim', [-maxV maxV]);
    % GET TICKS
    X = get(gc, 'Xtick');
    Y = get(gc, 'Ytick');

    % GET LABELS
    XL = get(gc, 'XtickLabel');
    YL = get(gc, 'YtickLabel');

    % GET OFFSETS
    Xoff = diff(get(gc, 'XLim'))./40;
    Yoff = diff(get(gc, 'YLim'))./40;

    % DRAW AXIS LINEs
    plot(get(gc, 'XLim'), [0 0], 'k', 'LineWidth', 2);
    plot([0 0], get(gc,'YLim'), 'k', 'LineWidth', 2);

    % Plot new ticks  
    for i = 1:length(X)
        plot([X(i) X(i)], [0 Yoff], '-k', 'LineWidth', 3);
    end
    for i = 1:length(Y)
        plot([Xoff, 0], [Y(i) Y(i)], '-k', 'LineWidth', 3);
    end

    % ADD LABELS
    text(X, zeros(size(X))-2.*Yoff, XL, 'FontSize', 30, 'fontname', 'helvetica', 'fontangle', 'italic');
    text(zeros(size(Y))-3.*Xoff, Y, YL, 'FontSize', 30, 'fontname', 'helvetica', 'fontangle', 'italic');

    box off;
    axis square;
    axis off;
    set(gcf,'color','w');    
end
