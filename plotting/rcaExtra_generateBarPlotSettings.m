function out = rcaExtra_generateBarPlotSettings

    out.patchSaturation = 0.15;
    
    % error bar props
    out.errorBarProps.LineStyle = 'none';
    out.errorBarProps.LineWidth =  2;
    out.errorBarProps.CapSize = 6;
    out.errorBarProps.Marker = 'none';
    out.errorBarProps.MarkerSize = 6;
    out.errorBarProps.MarkerEdgeColor = 'auto';
    out.errorBarProps.MarkerFaceColor = 'none';
    % bar props
    out.barProps.LineWidth =  2;
    out.barProps.LineStyle = '';
    out.barProps.EdgeColor = [0 0 0];
    out.barProps.FaceColor = [0 0 0];
    
    out.Legend.String = '';
end