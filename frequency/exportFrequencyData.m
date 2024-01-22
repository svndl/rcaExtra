function [subjEEG, subjNoise1, subjNoise2, info] = ...
    exportFrequencyData(datapath, dataType)

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
    % change to account for # RLS_Cxx of conditions
    fnames = {filenames.name};
    numbers = str2double(extract(fnames, digitsPattern));
    nConditions = numel(numbers);

    
    if (~nConditions)        
        fprintf('Source exports not present at %s', datapath)
    end
    subjEEG = cell(nConditions, 1);
    subjNoise1 = cell(nConditions, 1);
    subjNoise2 = cell(nConditions, 1);
    subjStdErr = cell(nConditions, 1);
    info.freqLabels = cell(nConditions, 1);
    info.binLabels = cell(nConditions, 1);
    info.trialLabels = cell(nConditions, 1);
    
    for n = 1:nConditions
        % check filename
        if ~strcmp(filenames(n).name(1:3),dataType)
            error('inputfile %s is not datatype %s',filenames(n).name, dataType);
        else
        end

        % load text data
        [~, freqCrnt, binLabelsCrnt, trialCrnt, data] = readFrequencyDataTXT(fullfile(pathname, filenames(n).name));
        % save matching condition #
        nc = numbers(n);
        
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
        % 12 StdErr
        
        %% arrange data
        
        % filename is {DFT, RLS}_c0xx.txt 
        % grab condition number
        info.channelsToUse = unique(data(:,  2));
        info.freqLabels{nc} = freqCrnt;
        info.binLabels{nc} = binLabelsCrnt;
        info.trialLabels{nc} = trialCrnt;
       
        % numerical values for current processing 
        nFreqs = numel(freqCrnt);
        nBins = numel(binLabelsCrnt);
        nChannels = numel(info.channelsToUse);

        if isempty(data)
            warning('No data found in %s',filenames(nc).name)
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
        stderr = zeros(nFreqs*nBins, nChannels, nTrialsToKeep);
        
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
                
                % StdErr               
                stderr(:, ch, tr) = trialData(thisTrialDataIncluded, 11);

                eeg(:, ch, tr) = [theseReals; theseImags];
                noise1(:, ch, tr) = [theseNoiseReals1; theseNoiseImags1];
                noise2(:, ch, tr) = [theseNoiseReals2; theseNoiseImags2];
            end
        end
        subjEEG{nc} = eeg;
        subjNoise1{nc} = noise1;
        subjNoise2{nc} = noise2;
        subjStdErr{nc} = stderr;
    end
end