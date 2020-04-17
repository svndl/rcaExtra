function projectRC(eegCND, W, A, nComp, titles, timeCourseLen, dirResFigures)
% Alexandra Yakovleva, Stanford University 2012-2020.
 
    %project on conditions   
    % number of projected conditions
    
    load('colors.mat');
    cl = rgb10;

    
    timeCourse = linspace(0, timeCourseLen, size(eegCND{1, 1}, 1));
    how.splitBy = titles;
    close all;
    nCnd = size(eegCND, 2);
    h = cell(nCnd, 1);
    FontSize = 25;
    
    %% run the projections, plot the topography
    
    c1 = nComp;
      for c = c1:nComp
         
         subplot(nComp, 2, 2*c - 1);
         xlabel('Time, ms') % x-axis label
         ylabel('Amplitude, V') % y-axis label
         h_xlabel = get(gca,'XLabel');
         set(h_xlabel,'FontSize', FontSize); 
         h_ylabel = get(gca,'YLabel');
         set(h_ylabel,'FontSize', FontSize);
         
         color_idx = 1;        
         for cn = 1:nCnd  
             [muData_C, semData_C] = rcaProjectmyData(eegCND(:, cn), W);
             hs = shadedErrorBar(timeCourse, muData_C(:, c), semData_C(:, c), {'Color', cl(color_idx, :)}); hold on
             h{cn} = hs.patch;
             color_idx = color_idx + 1;
         end
         legend([h{1:end}], [how.splitBy]'); hold on;
         title(['RC' num2str(c) ' time course']);
         subplot(nComp, 2, 2*c);         
         
         plotOnEgi(A(:,c)); hold on;
      end
     
     if (~exist(dirResFigures, 'dir'))
         mkdir(dirResFigures)
     end
     set(findobj(gcf,'Type','text'), 'FontSize', FontSize);
     saveas(gcf, fullfile(dirResFigures, strcat('rcaProject_', how.splitBy{:})), 'fig');
     close(gcf);     
end 