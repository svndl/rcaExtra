function plotFrequencyData(proj, subj, labels, cndLabels)

    %close all;
    barPlot(proj.amp, proj.errA, proj.phase, proj.errP, labels, cndLabels);
    %barPlot(proj.amp, proj.errA, proj.phase, proj.errP, labels, cndLabels);
    
    lollipopPlot(proj.amp, proj.phase, proj.ellipseErr, labels);
    plotSubjScatter(subj.amp, subj.err, labels);
end