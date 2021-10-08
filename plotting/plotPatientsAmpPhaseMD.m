function plotPatientsAmpPhaseMD

    %% load all data
    
    [proj, subj, list, md] = analyze_Patients_Frequency('data')
    
    %% plot 3d data
    plotMultipleComponentsFrequencyCloud(subj1, compLabels, cndLabels, groupLabels(1));
    plotMultipleComponentsFrequencyCloud(subj2, compLabels, cndLabels, groupLabels(2));
    

end