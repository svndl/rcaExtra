function res = rcaExtra_compareRCASettings_time(settingsLoaded, settingsCurrent)
    
    % compare subject list
    diff_subjects = isequal(settingsLoaded.subjList, settingsCurrent.subjList);
    
    % compare number of components
    diff_ncomp = (settingsLoaded.nComp == settingsCurrent.nComp);
    
    % compare number of regs
    diff_nreg = (settingsLoaded.nReg == settingsCurrent.nReg);
    
    % compare frequencies
    diff_freq = (settingsLoaded.samplingRate == settingsCurrent.samplingRate);
    
    
    res = diff_subjects && diff_ncomp && diff_nreg && diff_freq;
end