function out = rcaExtra_generateLatPlotSettings

    out.patchSaturation = 0.15;
    
    % error bar props
    out.errorBarProps.LineStyle = 'none';
    out.errorBarProps.LineWidth =  2;
    out.errorBarProps.CapSize = 6;
    out.errorBarProps.Marker = 'none';
    out.errorBarProps.MarkerSize = 6;
    out.errorBarProps.MarkerEdgeColor = 'auto';
    out.errorBarProps.MarkerFaceColor = 'none';
    % line props
    out.latProps.LineWidth =  2;
    out.latProps.LineStyle = '';
    out.latProps.Color = [0 0 0];
    
    out.Legend.String = '';
end