function f = rcaExtra_compareTopoMaps(topoMaps1, topoMaps2)

    nComp = size(topoMaps1, 2);
    % averaging RC data
    
    % set colorbar limits across all components
    colorbarLimits = [min([topoMaps1(:); topoMaps2(:)]), ...
        max([topoMaps1(:); topoMaps2(:)])];

    nRows = 2;
    f = figure;
    % plotting topos
    try
        for c = 1:nComp
            subplot(nRows, nComp, c);
            plotOnEgi(topoMaps1(:, c), colorbarLimits);
            title(['Old RC' num2str(c)], 'FontSize', 25, 'fontname', 'helvetica', 'FontAngle', 'italic');            
            
            subplot(nRows, nComp, c + nComp);
            plotOnEgi(topoMaps2(:, c), colorbarLimits);
            title(['New RC' num2str(c)], 'FontSize', 25, 'fontname', 'helvetica', 'FontAngle', 'italic');            
        end
    catch err
        fprintf('call to plotOnEgi() failed \n');
        rcaExtra_displayError(err);
    end
end