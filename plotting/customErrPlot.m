function legend_handle = customErrPlot(currAxisHandle, timecourse, muVar, ...
    errVar, clr, descr, lineSpec)
% calls shadedErrorBar plotting (timde domain) for provided axes handle
% Alexandra Yakovleva, Stanford University 2012-2020 
    axes(currAxisHandle);
    
    title(descr, 'FontSize', 30);
    muVar = muVar*1e06;
    errVar = errVar*1e06;
    h = shadedErrorBar(timecourse, muVar, errVar, ...
        {'Color', clr, 'LineWidth', 4, 'linestyle', lineSpec}); hold on;
    legend_handle = h.mainLine;    
end
