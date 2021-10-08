function [legendColor, gcf] = plotMultipleComponents(varargin)
    load('colors.mat');
    gcf = figure;
    tc = varargin{1};
    legendColor = cell((nargin - 1)/2, 1);
    title(descr);
    fontSize = 25;
    
    xlabel('Time, ms') % x-axis label
    ylabel('Amplitude, V') % y-axis label
    
    h_xlabel = get(currAxisHandle,'XLabel');
    set(h_xlabel,'FontSize', fontSize);
    h_ylabel = get(currAxisHandle,'YLabel');
    set(h_ylabel,'FontSize', fontSize);
    set(gca, 'FontSize', fontSize);
    
    for n = 1:(nargin - 1)/2
        mu = varargin{1 + (2*n - 1)};
        s = varargin{1 + 2*n};
        c = rgb10(n, :);
        hs = shadedErrorBar(tc, mu(:, 1), s(:, 1), {'Color', c});hold on;
        legendColor{n} = hs.patch;
    end
end
