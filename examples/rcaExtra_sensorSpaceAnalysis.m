function rcaExtra_sensorSpaceAnalysis

%% Example using RCA, sensor-space data 


    [subjList_cnt, sensorData_Controls, N1_cnt, N2_cnt, ~]...
        = getRawData(info_controls);

    %merge and re-bin the data
    nFreqs = length(info_controls.useFrequencies);

    sensorData_Controls1 = cellfun(@(x) rcaExtra_reshapeBinsToTrials(x, nFreqs),...
        sensorData_Controls, 'UniformOutput', false);
    noise_LO_Controls1 = cellfun(@(x) rcaExtra_reshapeBinsToTrials(x, nFreqs),...
        N1_cnt, 'UniformOutput', false);
    noise_HI_Controls1 = cellfun(@(x) rcaExtra_reshapeBinsToTrials(x, nFreqs),...
        N2_cnt, 'UniformOutput', false);

    % rca analysis
    info_rca_controls = info_controls;
    info_rca_controls.useBins = 1;
    info_rca_controls.subjTag = 'nl-*';
    info_rca_controls.useFrequenciesHz = 2.73;
    info_rca_controls.dataType = 'RLS';
    info_rca_controls.subjList = subjList_cnt;
    info_rca_controls.nReg = 7; % number of regularizarion params
    info_rca_controls.nComp = 6; % number of RC components
    info_rca_controls.label = 'Younger_1bin';
    info_rca_controls.useCnds = 1:2;
    info_rca_controls.destDataDir_RCA = '/Volumes/Extreme SSD/FullField/Students/RCA';

    rcResult_cnt = runRCA_frequency(info_rca_controls, sensorData_Controls1, noise_LO_Controls1, noise_HI_Controls1);
    
    % create copy of rcResult structure to store sensor data
    sensorResult_cnt = rcResult_cnt;
    sensorResult_cnt.projectedData = sensorData_Controls1;
    sensorResult_cnt.noiseData.lowerSideBand = noise_LO_Controls1;
    sensorResult_cnt.noiseData.higherSideBand = noise_HI_Controls1;
    sensorResult_cnt.W = diag(ones(1, 128));    
    sensorResult_cnt.rcaSettings.nComp = 128;
    sensorResult_cnt.rcaSettings.label = 'Younger_1bin_source';
    sensorResult_cnt = rcaExtra_computeAverages(sensorResult_cnt);
    
    % plotting 
    
    plotContainerStruct_Controls = rcaExtra_addPlotOptionsToData(rcResult_cnt.projAvg);
    plotContainerStruct_Controls.statData = rcaExtra_runStatsAnalysis(rcResult_cnt, []);
    freqIdx = cellfun(@(x) str2double(x(1)), rcResult_cnt.rcaSettings.useFrequencies, 'uni', true);
    freqVals = rcResult_cnt.rcaSettings.useFrequenciesHz*freqIdx;
    %xLabel = arrayfun( @(x) strcat(num2str(x), 'Hz'), freqVals, 'uni', false);
    yLabel = 'Amplitude, \muV';
    
    % specify plotting styles data for each container    
    xlabel_idx = rcResult_cnt.rcaSettings.useFrequencies;
    
    plotContainerStruct_Controls.xDataLabel = xlabel_idx;
    plotContainerStruct_Controls.yDataLabel = yLabel;
    rcsToPlot = 1;
    cndsToPlot = [1 2];
    % colors
    
    cnt_off_red = [193, 18, 31];
    cnt_on_pink = [231, 161, 156];

    % specify plotting styles data for RC container
    plotContainerStruct_Controls.rcsToPlot = rcsToPlot;
    plotContainerStruct_Controls.cndsToPlot = cndsToPlot;
    plotContainerStruct_Controls.conditionLabels = {'Inc ON', 'Dec OFF'};
    plotContainerStruct_Controls.dataLabel = {'Controls'};
    plotContainerStruct_Controls.conditionColors = cat(1, cnt_off_red/255, cnt_off_red/255);
    plotContainerStruct_Controls.conditionMarkers = {'^', 'v'};
    plotContainerStruct_Controls.markerStyles = {'filled', 'filled'};
    plotContainerStruct_Controls.markerSize = 12;
    plotContainerStruct_Controls.lineStytles = {'-', '-'};
    plotContainerStruct_Controls.LineWidths = 2;
    plotContainerStruct_Controls.significanceSaturation = 0.15;
    plotContainerStruct_Controls.patchSaturation = 0.15;

    % copy sensor-space data to RC plotting container
    plotContainerStruct_Cnt_sensor = plotContainerStruct_Controls;
    
    plotContainerStruct_Cnt_sensor.dataToPlot = sensorResult_cnt.projAvg;
    plotContainerStruct_Cnt_sensor.statData = rcaExtra_runStatsAnalysis(sensorResult_cnt, []);

    plotContainerStruct_Cnt_sensor.conditionColors = cat(1, cnt_on_pink/255, cnt_on_pink/255);
    plotContainerStruct_Cnt_sensor.rcsToPlot = 76;
    plotContainerStruct_Cnt_sensor.dataLabel = {'Controls Channel 76'};

    % comparing data
    sensor_rc = rcaExtra_plotAmplitudes(plotContainerStruct_Controls, plotContainerStruct_Cnt_sensor);
end