%% General bar amplitude/frequency plots for all components
function makeProjectPlots(amp, error_amp, ph, error_phase, labels)
    %plotBarsFreqs(amp, error_amp, ph, error_phase, labels);
    %lollipopPlot(amp, error_amp, ph, error_phase, labels);
    plotSubjScatter(amp, error_amp, ph, error_phase, labels)
end

%% subject scatter

function plotSubjScatter(amp, error_amp, ph, error_phase, labels)

    load('colors.mat');
    
    nFreq = size(amp.Proj, 2);
    nComp = size(amp.Proj, 3);
    load ('colors.mat');
    yl = 'Amplitude, \muV';
    freqLabels = cellfun( @(x) strcat('F', num2str(x)), num2cell(1:1:nFreq), 'uni', false);
    cndLabels = cellfun( @(x) strcat('C', num2str(x)), num2cell(1:1:nFreq), 'uni', false);
    
    projFig = figure;
    for cp = 1:nComp
        for nf = 1:nFreq
            descr = [labels{cp} '_' freqLabels{nf}];
            linearInd = sub2ind([nComp, nFreq], cp, nf);
            ax = subplot(nComp, nFreq, linearInd, 'Parent', projFig);
            values = squeeze(amp.Subj(:, :, nf, cp));
            errors = squeeze(error_amp.Subj(:, :, nf, cp, :));
            scatterPlot(ax, values, errors, descr, freqLabels, yl, rgb10)
        end
        descr = [labels{cp} '_' freqLabels{nf}];
        legend(cndLabels)
        title(descr, 'Interpreter', 'none');
        
    end
end

%% bar plots for c1 and c2
function barPlot(h, values, errors, descr, xlabels, yl, colors)
    
    axes(h);
    
    nCnd = size(values, 1);
    nF = size(values, 2);
    
    x = repmat(1:nF, [nCnd, 1]);
    colormap(colors(1:nCnd, :)); 
    bar(x', values'); hold on;
    errorbar(x', values', squeeze(errors(:,:, 1)'), squeeze(errors(:,:, 2)'), ...
        'LineStyle', 'none', 'LineWidth', 2);
    
    title(descr);
    
    xticklabels(xlabels);
    ylabel(yl);    
end

%% scatter plots
function scatterPlot(h, values, errors, descr, xlabels, yl, colors)
    
    axes(h);
    
    nCnd = size(values, 1);
    nF = size(values, 2);
    
    x = repmat(1:nF, [nCnd, 1]);
    colormap(colors(1:nCnd, :)); 
    %scatter(x, values); hold on;
    errorbar(x', values', squeeze(errors(:,:, 1)'), squeeze(errors(:,:, 2)'), ...
         '*', 'LineStyle', 'none', 'LineWidth', 2, 'MarkerSize', 5);
    
    title(descr, 'Interpreter', 'none');    
    
    xticklabels(xlabels);
    ylabel(yl);    
end
