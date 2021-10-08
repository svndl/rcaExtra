function plotConditions(EEGMat, timeCourseLen, dirResFigures, titles, channel)
    %project on conditions
    load('colors.mat')
    how.splitBy = titles;
    close all;
    nCnd = size(EEGMat, 2);
    h = cell(nCnd, 1);
    %% run the projections, plot the topography
    for c = 1:nCnd
        
        subplot(nCnd, 1, c);
        cndData = EEGMat{:, c};
        catData = cat(3, cndData{:});
        muData = nanmean(catData, 3);
        muData = muData - repmat(muData(1, :), [size(muData, 1) 1]);
        semData = nanstd(catData, [], 3)/(sqrt(size(catData, 3)));
        timeCourse = linspace(0, timeCourseLen(c), size(muData, 1));

        hs = shadedErrorBar(timeCourse, muData(:, channel), semData(:, channel), {'Color', rgb10(c, :, :)}); hold on
        h{c} = hs.patch;
        legend(how.splitBy(c));
        set(gca,'fontsize',20)
    end
    
    if (~exist(dirResFigures, 'dir'))
        mkdir(dirResFigures)
    end
    
    saveas(gcf, fullfile(dirResFigures, strcat('rcaProject_', how.splitBy{:})), 'fig');
    close(gcf);
end