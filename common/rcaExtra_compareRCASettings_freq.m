function res = rcaExtra_compareRCASettings_freq(settingsLoaded, settingsCurrent)
    
    % compare subject list
    diff_subjects = isequal(settingsLoaded.subjList, settingsCurrent.subjList);
    
    % compare number of components
    diff_ncomp = (settingsLoaded.nComp == settingsCurrent.nComp);
    
    % compare number of regs
    diff_nreg = (settingsLoaded.nReg == settingsCurrent.nReg);
    
    % compare frequencies
    try
        diff_bins = isequal(settingsLoaded.useBins, settingsCurrent.useBins);
    catch err 
        fprintf('failed comparing bins: \n');
        rcaExtra_displayError(err);
        % request input
        x = input( 'Enter 1 if you want to re-run RCA, 0 to proceed at your own discretion: ');
        if isempty(x)
          x = 1;
        end
        diff_bins = ~x;
    end
    
    % load frequency labels
    try
        diff_freq = isequal(settingsLoaded.useFrequencies, settingsCurrent.useFrequencies);
    catch err 
        fprintf('Failed comparing frequencies: \n');
        rcaExtra_displayError(err);
        % request input
        x = input( 'Enter 1 if you want to re-run RCA, 0 to proceed at your own discretion: ');
        if isempty(x)
          x = 1;
        end
        diff_freq = ~x;
    end
    
    try
        diff_cnd = isequal(settingsLoaded.useCnds, settingsCurrent.useCnds);
    catch err
        disp('No info on conditions used for analysis, loading data at your own risk');
        diff_cnd = 1; 
        rcaExtra_displayError(err);
    end
    res = diff_subjects && diff_ncomp && diff_nreg && diff_freq && diff_bins && diff_cnd;
end