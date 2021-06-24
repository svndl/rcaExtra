function setAxisAtTheOrigin(gc)
% sets axis at the origin 
    if (iscell(gc))
        % cell array of axis handles
        cellfun(@(x) setSingleAxesAtThe0(x), gc, 'uni', false);
    else
        %single handle
        setSingleAxesAtThe0(gc)
    end  
end
    
function setSingleAxesAtThe0(gc)
    axes(gc);
    xl = get(gc, 'XLim');
    yl = get(gc, 'YLim');
    maxV = max(max(abs(xl)), max(abs(yl)));
    set(gc, 'XLim', [-maxV maxV]);
    set(gc, 'YLim', [-maxV maxV]);
    
    % GET TICKS
%     X = get(gc, 'Xtick');
%     Y = get(gc, 'Ytick');
    
    % GET LABELS
%     XL = get(gc, 'XtickLabel');
%     YL = get(gc, 'YtickLabel');

    % SET NEW TICKS
%     nXTicks = numel(X);
%     nYTicks = numel(Y);
    
    % old code
    %nNewTicks = min(nXTicks, nYTicks);
    
    nNewTicks = 3;
    newTicks = linspace(-maxV, maxV, nNewTicks)';
    
    % GET OFFSETS
    Xoff = diff(get(gc, 'XLim'))./30;
    Yoff = diff(get(gc, 'YLim'))./30;

    % DRAW AXIS LINEs
    plot(get(gc, 'XLim'), [0 0], 'k', 'LineWidth', 2);
    plot([0 0], get(gc,'YLim'), 'k', 'LineWidth', 2);

    % Plot new ticks  
    for i = 1:nNewTicks
        plot([newTicks(i) newTicks(i)], [0 Yoff], '-k', 'LineWidth', 3);
    end
    for i = 1:nNewTicks
        plot([Xoff, 0], [newTicks(i) newTicks(i)], '-k', 'LineWidth', 3);
    end

    % ADD LABELS
    textProperties = {'FontSize', 30, 'fontname', 'helvetica', 'fontangle', 'italic'};
    newTickLabels = num2str(round(newTicks, 2));
    text(newTicks, zeros(nNewTicks, 1)-2.*Yoff, newTickLabels, textProperties{:});
    text(zeros(nNewTicks, 1)-3.*Xoff, newTicks, newTickLabels, textProperties{:});

    box off;
    axis square;
    axis off;
    set(gcf,'color','w');    
end
        
