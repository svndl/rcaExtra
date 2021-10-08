function [regGCF, grGCF] = plotGroupsConditions_time(tcg, conditionLabels, groupLabels, varargin)
%% Function will plot multiple first components against each other   
%% INPUT:
    % tc -- timecourse (samplePoints x 1)
    % varargin -- groups + labels: {group1, group2,..., groupN, groupLabels, ConditionLabels}
    % groupX -- cell array with two elements: groupX{1} = eegData Mu, groupX{2} = eegData Std
    % groupX = {eegGroupMu(samplePoints x nParts) eegGroupStd(samplePoints x nParts)}
    % EEG data (mu, std) is samplePoints x nParts regions (f, p1, p2):
    % eegGroupMu = [eegGroupMu( RC1, f1) eegGroupMu ( RC1, p1) eegGroupMu ( RC1, p2)] 
%% OUTPUT
    % regGCF -- Figure handle of by region plots 
    % grGCF -- Figure handle of by group pliots 
      
        
    nRegions = numel(groupLabels); 
    nGroups = numel(conditionLabels);
    
    groups = varargin(1 : nGroups);
    plotSettings = getOnOffPlotSettings('groupsconditions', 'Time');    

    % close all figures
    close all;
    
    % figure 1: subplot groups g1 ...gn of f/p1/p2
    regGCF = figure(1);
    set(regGCF, 'units','normalized','outerposition',[0 0 1 1]);
    
    % figure 2: subplots of conditions for groups g1...gn
    grGCF = figure(2);
    
    set(grGCF, 'units','normalized','outerposition', [0 0 1 1]);
    ax_rg = cell(nRegions,1);
    for r = 1:nRegions
        ax_rg{r} = subplot(1, nRegions, r, 'Parent', grGCF);
    end
    
    
    legendRG_patch = cell(nRegions, 1);
    legendGR_patch = cell(nGroups, nRegions);

    ax_gr = cell(nGroups, 1);
    
    for n = 1:nGroups
        %subplot by groups
        ax_gr{n} = subplot(1, nGroups, n, 'Parent', regGCF);

        currGroup = groups{n};
        groupMu = currGroup{1};
        groupS = currGroup{2};
        tc = tcg{n};
        for r = 1:nRegions
            %idx = r + nRegions*(n - 1);
            
            clr = plotSettings.colors(r, :, n);
           
            currMu = groupMu(:, r);
            currS = groupS(:, r);
            % by group subplot
            
            groupLineSpec = plotSettings.linestyles{r};

            legendGR_patch{n, r} = customErrPlot(ax_gr{n}, tc, currMu, currS, ...
                clr, [conditionLabels{n}], groupLineSpec);
            % by region subplot
            
            legendRG_patch{r} = customErrPlot(ax_rg{r}, tc, currMu, currS, ...
                clr, [groupLabels{r}], groupLineSpec);
            
            
            if ( plotSettings.showlegends)            
                legend(ax_rg{r}, [legendGR_patch{:, r}], conditionLabels(1:n));
            end
            % all subplot
            set(get(ax_rg{r}, 'xlabel'), 'string', plotSettings.xl) % x-axis label
            set(get(ax_rg{r}, 'ylabel'), 'string', plotSettings.yl) % x-axis label
            set(ax_rg{r},  plotSettings.axesprops{:});                       
        end
        
        %put legend by region(s)
        if ( plotSettings.showlegends)
            legend(ax_gr{n}, [legendRG_patch{:}], groupLabels(:));
        end
        set(get(ax_gr{n}, 'xlabel'), 'string', plotSettings.xl) % x-axis label
        set(get(ax_gr{n}, 'ylabel'), 'string', plotSettings.yl) % x-axis label
        set(ax_gr{n},  plotSettings.axesprops{:});
    end
    
    % same scale! 
    linkaxes([ax_gr{:}],'xy');
    linkaxes([ax_rg{:}],'xy');
    
    axesHandles_g = findobj(get(regGCF, 'Children'), 'flat', 'Type', 'axes');
    for a1 = 1:numel(axesHandles_g)
        pbaspect(axesHandles_g(a1), [1 1 1]);    
    end
    axesHandles_c = findobj(get(grGCF, 'Children'), 'flat', 'Type', 'axes');
    for a2 = 1:numel(axesHandles_c)
        pbaspect(axesHandles_c(a2), [1 1 1]);    
    end
    % unlink for stats plotting later
    linkaxes([ax_gr{:}],'off');
    linkaxes([ax_rg{:}],'off');
end