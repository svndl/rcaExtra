function plotSubjScatter(amp, errAmp, labels)
    % frequencies x components  x subjects x conditions
    load('colors.mat');
    nFreq = size(amp, 1);
    nComp = size(amp, 2);
    
    load('colorbrewer.mat');
    PaletteN = 7;
    blues = colorbrewer.seq.YlGnBu{PaletteN}/255;
    reds = colorbrewer.seq.YlOrRd{PaletteN}/255;
    c_rg = cat(1, blues(end, :), reds(end, :));
    
    
    
    yl = 'Amplitude, \muV';
    freqLabels = cellfun( @(x) strcat('F', num2str(x)), num2cell(1:1:nFreq), 'uni', false);
    projFig = figure;
    for cp = 1:nComp
        for nf = 1:nFreq            
            descr = [labels{cp} '_' freqLabels{nf}];
            linearInd = sub2ind([nFreq nComp], nf, cp);
            ax = subplot(nComp, nFreq, linearInd, 'Parent', projFig);
            
            % nSubj x nCnd
            values = squeeze(amp(nf, cp, :, :));
            %2 x nSubj x nCnd
            errors = squeeze(errAmp(nf, cp, :, :));                        
            scatterPlotAmplitude(ax, values, errors, descr, yl, c_rg);
        end
    end
end

function scatterPlotAmplitude(h, values, errors, descr, yl, colors)
    axes(h);
    
    nSubj = size(values, 1);
    nCnd = size(values, 2);
    
    x = repmat((1:nSubj), [nCnd 1])';    
    
    ebh = errorbar(x, values, errors, errors, ...
         '*', 'LineStyle', 'none', 'LineWidth', 2, 'MarkerSize', 7);
    title(descr, 'Interpreter', 'none');
    
    cndLabels = cellfun( @(x) strcat('CND', num2str(x)), num2cell(1:1:nCnd), 'uni', false);  
    legend(cndLabels{:});

    for c = 1:nCnd
        set(ebh(c), 'color', colors(c, :));
    end
    ylabel(yl);    
end