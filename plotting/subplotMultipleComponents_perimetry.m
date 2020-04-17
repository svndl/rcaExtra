function [regGCF, grGCF] = subplotMultipleComponents_perimetry(tc, varargin)
%% Function will plot multiple first components against each other   
%% INPUT:
    % tc -- timecourse (samplePoints x 1)
    % varargin -- groups + labels: {group1, group2,..., groupN, groupLabels}
    % groupX -- cell array with two elements: groupX{1} = eegData Mu, groupX{2} = eegData Std
    % groupX = {eegGroupMu(samplePoints x 3) eegGroupStd(samplePoints x 3)}
    % EEG data (mu, std) is samplePoints x 3 regions (f, p1, p2):
    % eegGroupMu = [eegGroupMu( RC1, f1) eegGroupMu ( RC1, p1) eegGroupMu ( RC1, p2)] 
%% OUTPUT
    % regGCF -- Figure handle of by region plots 
    % grGCF -- Figure handle of by group pliots 
      
    load('colors.mat');
    
    groupTitles = varargin{end};
    regionsStr = {'f', 'p1', 'p2'};
    nRegions = numel(regionsStr); 
    nGroups = numel(groupTitles);
    
    % close all figures
    close all;
    
    % figure 1: subplot groups g1 ...gn of f/p1/p2
    regGCF = figure(1);
    
    % figure 2: subplots 1) f, p1, p2 of groups g1...gn
    grGCF = figure(2);
    ax_f1 = subplot(nRegions, 1,  1, 'Parent', grGCF);
    ax_p1 = subplot(nRegions, 1,  2, 'Parent', grGCF);
    ax_p2 = subplot(nRegions, 1,  3, 'Parent', grGCF);
    ax_rg = {ax_f1, ax_p1, ax_p2};
    c_rg = rgb10;
    
    legendRG_patch = cell(nRegions, 1);
    legendGR_patch = cell(nGroups, nRegions);
    ax_gr = cell(nGroups, 1);
    fontSize = 20;
    
    for n = 1:nGroups
        %subplot by groups
        ax_gr{n} = subplot(nGroups, 1, n,  'Parent', regGCF);
        currGroup = varargin{n};
        groupMu = currGroup{1};
        groupS = currGroup{2};
        
        for r = 1:nRegions
            idx = r + nRegions*(n - 1);
            clr =  c_rg(idx, :);
            currMu = groupMu(:, r);
            currS = groupS(:, r);
            % by group subplot
            
            legendGR_patch{n, r} = customErrPlot(ax_gr{n}, tc, currMu, currS, ...
                clr, fontSize, ['Group ' groupTitles{n}]);
            % by region subplot
            
            legendRG_patch{r} = customErrPlot(ax_rg{r}, tc, currMu, currS, ...
                clr, fontSize, ['Region ' regionsStr{r}]);
            
            legend(ax_rg{r}, [legendGR_patch{:, r}], groupTitles(1:n));
           
        end
        %put legend by region(s)  
        legend(ax_gr{n}, [legendRG_patch{:}], regionsStr(:));
        
    end
end

function patch_handle = customErrPlot(currAxisHandle, timecourse, muVar, ...
    errVar, clr, fontSize, descr)

% 
    axes(currAxisHandle);
    title(descr);
    xlabel('Time, ms') % x-axis label
    ylabel('Amplitude, V') % y-axis label
    
    h_xlabel = get(currAxisHandle,'XLabel');
    set(h_xlabel,'FontSize', fontSize);
    h_ylabel = get(currAxisHandle,'YLabel');
    set(h_ylabel,'FontSize', fontSize);
    set(gca, 'FontSize', fontSize);
    h = shadedErrorBar(timecourse, muVar, errVar, ...
        {'Color', clr}); hold on;
    patch_handle = h.patch;
end