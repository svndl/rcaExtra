function main_Standard_Oddball_analysis_time

    %% define experimentInfo
    
    experimentName = 'Exports_6Hz';
    
    % load up expriment info specified in loadExperimentInfo_experimentName
    % matlab file
    
    try
        info = feval(['loadExperimentInfo_' experimentName]);
    catch err
        % in case unable to load the designated file, load default file
        % (not implemented atm)
        disp('Unable to load specific expriment settings, loading default');
        info = loadExperimentInfo_Default;
    end
    
    % specified for general data loader and plotting, currently not used
    domain = 'time';
    
    % read raw data 
    [subj_names, DataOut] = rcaReadRawEEG_Custom(info);
    
    % specify RCA settings
    rcaSettings.subjList = subj_names;
    rcaSettings.nReg = 8; 
    rcaSettings.nComp = 8;    
    runDate = datestr(clock,26); 
    runDate(strfind(runDate,'/')) ='';
    rcaSettings.runDate = runDate; % runtime info
    
    % allocating space for rcAnalysis
    nConditions = numel(info.conditionLabels);
    
    % store each condition's mu/s for plotting and stats
    mu_cnd = cell(nConditions, 1);
    s_cnd = cell(nConditions, 1);
    rcaSettings_cnd = cell(nConditions, 1);
    close all;
    
    % run RC on each condition
    for nc = 1:2
        rcaSettings_cnd{nc} = rcaSettings;
        rcaSettings_cnd{nc}.label = info.conditionLabels{nc};
        rcaSettings_cnd{nc}.resultsDir = info.destDataDir_RCA;
        rcaSettings_cnd{nc}.figureDir = info.destDataDir_FIG;
        rcaSettings_cnd{nc}.chanToCompare = 75;
        rcaSettings_cnd{nc}.freq = info.frequencies(1);
        % run RC
        [mu_cnd{nc}, s_cnd{nc}] = run_RCAnalysis(DataOut(:, nc), rcaSettings_cnd{nc});
    end
    
    
    ns_f1 = round(1000./info.frequencies(1));
    tc1 = linspace(0, ns_f1, size(mu_cnd{1}.pol.rc, 1));
        
    % compare two conditions
    cndToCompare = 1;
    for nc = 2:2
        % plot two conditions
        for ncomp = 1:rcaSettings_cnd{nc}.nComp
            % projected averages
            data_1 = mu_cnd{cndToCompare}.pol.rc(:, ncomp);
            data_2 = mu_cnd{nc}.pol.rc(:, ncomp);
            
            mu = cat(2, data_1, data_2);
            s = cat(2, s_cnd{cndToCompare}.pol.rc(:, ncomp), s_cnd{nc}.pol.rc(:, ncomp));
            labels = info.conditionLabels([cndToCompare, nc]);
            gcf_cmp = plotConditions_time(tc1, labels, mu, s);
            
            % run paired test
            data1_raw = mu_cnd{cndToCompare}.source;
            data2_raw = mu_cnd{nc}.source;
            
            [pValue, h0] = ttest_paired(data1_raw, data2_raw, ncomp);
            % add colorbar
            
            allaxes = findall(gcf_cmp, 'type', 'axes'); 
            plot_addStatsBar_time(pValue, h0, allaxes(1), tc1)    
            
            % save
            saveFigsStr = strcat(domain, '_rca_ComparingConditions_', ...
                info.conditionLabels{cndToCompare}, '_', info.conditionLabels{nc}, '_Comp_', num2str(ncomp), '.fig');
            saveas(gcf_cmp, fullfile(info.destDataDir_FIG, saveFigsStr));
             
        end
    end    
end
