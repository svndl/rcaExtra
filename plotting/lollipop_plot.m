%% Lollipop
function lollipop_plot(amp, error_amp, ph, error_phase, labels)
    load('colors.mat');
    
    nCnd = size(amp.Proj, 2);
    nFreq = size(amp.Proj, 1);
    nComp = size(amp.Proj, 3);
    load ('colors.mat');
    freqLabels = cellfun( @(x) strcat('F', num2str(x)), num2cell(1:1:nFreq), 'uni', false);
    projFig = figure;
    for cp = 1:nComp
        for nf = 1:nFreq
            linearInd = sub2ind([nComp, nFreq], cp, nf);
            ax = subplot(nComp, nFreq, linearInd, polaraxes,  'Parent', projFig);
            for cnd = 1:nCnd
                %amp_errData = error_amp.Proj(:, :, cp, :);
                %phi_errData = error_phase.Proj(:, :, cp, :);
               
                props = { 'linewidth', 2, 'color', rgb10(cnd,:)};
                p = polarplot(ax, [ 0 ph.Proj(nf, cnd, cp)], [0 amp.Proj(nf, cnd, cp)], props{:}); hold on;
            end
            descr = [labels{cp} '_' freqLabels{nf}];
            legend({'Condition 1', 'Condition 2'})
            title(descr, 'Interpreter', 'none');
        end
    end
    
end