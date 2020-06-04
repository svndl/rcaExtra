function res = rcaExtra_compareRCASettings_freq(settingsLoaded, settingsCurrent)
    
    % compare subject list
    diff_subjects = isequal(settingsLoaded.subjList, settingsCurrent.subjList);
    
    % compare number of components
    diff_ncomp = (settingsLoaded.nComp == settingsCurrent.nComp);
    
    % compare number of regs
    diff_nreg = (settingsLoaded.nReg == settingsCurrent.nReg);
    
    % compare frequencies
    diff_bins = isequal(settingsLoaded.binsToUse, settingsCurrent.binsToUse);

    % load frequency labels
    diff_freq = isequal(settingsLoaded.freqLabels, settingsCurrent.freqLabels);
    
    res = diff_subjects && diff_ncomp && diff_nreg && diff_freq && diff_bins;
end