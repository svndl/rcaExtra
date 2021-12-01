function [subjEEG, subjNoise1, subjNoise2, info] = ...
    exportFrequencyData_beta(datapath, dataType)

% Alexandra Yakovleva, Stanford University 2012-2020.

    if nargin < 2 || isempty(dataType), dataType='RLS'; fprintf('Using RLS.\n'); end
    if nargin < 1, error('Path to datafiles is required'); end

    if ~strcmp(datapath(end), '/'), pathname = cat(2, datapath, '/'); end

    switch dataType % check for correct data type
        case {'DFT','RLS'}
            filenames = dir([pathname sprintf('%s*.txt', dataType)]);
        otherwise
            error('dataType must be ''RLS'' or ''DFT''');
    end
    % pre-allocate output
    nConditions = length(filenames);
    subjEEG = cell(nConditions, 1);
    subjNoise1 = cell(nConditions, 1);
    subjNoise2 = cell(nConditions, 1);
    info.freqLabels = cell(nConditions, 1);
    info.binLabels = cell(nConditions, 1);
    headerTable = rcaExtra_getXDivaTextHeaderTable;
    
    for nf = 1:nConditions
        % check filename
        if ~strcmp(filenames(nf).name(1:3),dataType)
            error('inputfile %s is not datatype %s',filenames(nf).name, dataType);
        else
        end

        cndDataStruct = importdata(fullfile(pathname, filenames(nf).name)); 
        floatData = cndDataStruct.data;
        % textData has all 32 columns exported as text, remove headers:
        strData = cndDataStruct.textdata(2:end, :);
        
        % data columns we'll be storing for each condition
        allBins = floatData(:, 2);
        allChannels = strData(:, headerTable('iCh', "Var1").Variables);
        allConditions = str2double(strData(:, headerTable('iCond', "Var1").Variables));
        allFreqVals = str2double(strData(:, headerTable('AF', "Var1").Variables));
        allFreqLabels = (strData(:, headerTable('Harm', "Var1").Variables));
        allTrials = str2double(strData(:, headerTable('iTrial', "Var1").Variables));        
        allxF1 = str2double(strData(:, headerTable('xF1', "Var1").Variables));
        allxF2 = str2double(strData(:, headerTable('xF2', "Var1").Variables));
        
        binsUnique = unique(allBins, 'rows','stable');
        cndUnique = unique(allConditions, 'rows','stable');
        trialsUnique = unique(allTrials, 'rows','stable');
        uniqueFreqVals = unique(allFreqVals, 'rows','stable');
        uniqueFreqLabels = unique(allFreqLabels, 'rows','stable');
        uniqueChanLabels = unique(allChannels, 'rows','stable');
        uniqueF1 = unique(allxF1, 'rows','stable');
        uniqueF2 = unique(allxF2, 'rows','stable');
        
        
        % load text data
        %[~, freqCrnt, binLabelsCrnt, data] = readFrequencyDataTXT(fullfile(pathname, filenames(nf).name));
        
        % Data Fields
        % 1 'iTrial'        
        % 2 'iCh'          
        % 3 'iFr'      
        % 4 'iBin'      
        % 5 'SweepVal' 
        % 6 'Sr'      
        % 7 'Si'     
        % 8 'N1r'   
        % 9 'N1i'  
        % 10 'N2r'   
        % 11 'N2i'   
        
        %% arrange data
        
        % filename is {DFT, RLS}_c0xx.txt 
        % grab condition number
        tempName = filenames(nf).name;
        condIdx = str2num(tempName(end - 6:end - 4)); 
        
        info.channelsToUse = unique(data(:,  2));
        info.freqLabels{condIdx} = uniqueFreqLabels;
        info.binLabels{condIdx} = binsUnique;
       
        % numerical values for current processing 
        nFreqs = numel(freqCrnt);
        nBins = numel(binLabelsCrnt);
        nChannels = numel(info.channelsToUse);

        if isempty(data)
            warning('No data found in %s',filenames(nf).name)
            continue
        end
 
        %% check congruency of trials
        trials = data(:, 1);
        trialInds =  unique(trials(:));
        nTrials = numel(trialInds);
        nEntriesPerTrialInd = zeros(nTrials, 1);
        for tr = 1:length(trialInds)
            trialData = data(trials == trialInds(tr), :);
            nEntriesPerTrialInd(tr) = numel(trialData(:));
        end

        % only keep trials in which the number of entries is congruent
        trialIndsToKeep = trialInds(nEntriesPerTrialInd == mode(nEntriesPerTrialInd));
        nTrialsToKeep = numel(trialIndsToKeep);

        % allocate data per condition
        eeg = nan(nFreqs*nBins*2, nChannels, nTrialsToKeep);
        noise1 = nan(nFreqs*nBins*2, nChannels, nTrialsToKeep);
        noise2 = nan(nFreqs*nBins*2, nChannels, nTrialsToKeep);
        
        for tr = 1:nTrialsToKeep

            thisTrialInd = trialIndsToKeep(tr);
            trialData = data(trials == thisTrialInd, :);
            trialChannels = trialData(:,2);
            trialBins = trialData(:, 4);

            % freqs x bins
            for ch =  1:nChannels
                
                thisTrialChannels = (trialChannels == ch);
                thisTrialBins = ismember(trialBins, binLabelsCrnt);
                thisTrialDataIncluded = thisTrialChannels&thisTrialBins;
                
                theseReals = trialData(thisTrialDataIncluded, 5);
                theseImags = trialData(thisTrialDataIncluded, 6);

                % noise 1
                theseNoiseReals1 = trialData(thisTrialDataIncluded, 7);
                theseNoiseImags1 = trialData(thisTrialDataIncluded, 8);

                % noise 2
                theseNoiseReals2 = trialData(thisTrialDataIncluded, 9);
                theseNoiseImags2 = trialData(thisTrialDataIncluded, 10);

                eeg(:, ch, tr) = [theseReals; theseImags];
                noise1(:, ch, tr) = [theseNoiseReals1; theseNoiseImags1];
                noise2(:, ch, tr) = [theseNoiseReals2; theseNoiseImags2];
            end
        end
        subjEEG{nf} = eeg;
        subjNoise1{nf} = noise1;
        subjNoise2{nf} = noise2;
    end
end