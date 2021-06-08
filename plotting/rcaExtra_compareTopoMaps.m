function f = rcaExtra_compareTopoMaps(varargin)

    nTopoMaps = nargin;
     
    nComp = size(varargin{1}, 2);
    % averaging RC data
    
    % set colorbar limits across all topomaps
    combinedTopo = cat(3, varargin{:});
    
    colorbarLimits = [min(combinedTopo(:)), max(combinedTopo(:))];

    nRows = nTopoMaps;
    f = figure;
    % plotting topos
    try
        for c = 1:nComp
            for ntopos = 1:nTopoMaps
                subplot(nRows, nComp, (ntopos - 1)*nComp + c);
                plotOnEgi(combinedTopo(:, c, ntopos), colorbarLimits);
                title(['RC' num2str(c)], 'FontSize', 25, 'fontname', 'helvetica', 'FontAngle', 'italic'); 
            end
        end
    catch err
        fprintf('call to plotOnEgi() failed \n');
        rcaExtra_displayError(err);
    end
end