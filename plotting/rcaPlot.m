function rcaPlot(A, muData, semData, tc)
    figure;
    colorbarLimits = [min(A(:, 1)),max(A(:, 1))];

    if ~isempty(which('mrC.plotOnEgi')) % check for mrC version of plotOnEgi
        mrC.plotOnEgi(A(:,1), colorbarLimits);
    else
        plotOnEgi(A(:,1),colorbarLimits);
    end
        title(['RC' num2str(1)], 'FontSize', 30);
        axis off;
    
    figure
    shadedErrorBar(tc', -muData(:, 1), semData(:, 1), 'k');
    title(['RC' num2str(1) ' time course']);
    axis tight;
end
