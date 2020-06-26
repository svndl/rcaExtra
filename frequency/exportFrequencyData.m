function [cellData, noiseCell1, noiseCell2, freqLabels, binLabels] = ...
    exportFrequencyData(datapath, dataType, freqsToUse, binsToUse)

% Alexandra Yakovleva, Stanford University 2012-2020.

    if nargin < 2 || isempty(dataType), dataType='RLS'; fprintf('Using RLS.\n'); end
    if nargin < 1, error('Path to datafiles is required'); end
    if nargin < 4 || isempty(binsToUse), binsToUse = []; end
    if nargin < 3 || isempty(freqsToUse), freqsToUse = []; end

    if ~strcmp(datapath(end), '/'), pathname = cat(2, datapath, '/'); end

    switch dataType % check for correct data type
        case {'DFT','RLS'}
            filenames=dir([pathname sprintf('%s*.txt', dataType)]);
        otherwise
            error('dataType must be ''RLS'' or ''DFT''');
    end
    
    nFilenames = numel(filenames);
    if nFilenames < 1
        error('No %s files were found in %s', dataType, pathname);
        
    end

    cellData = cell(nFilenames,1);
    noiseCell1 = cell(nFilenames,1);
    noiseCell2 = cell(nFilenames,1);
    binLabels = cell(nFilenames,1);
    freqLabels = cell(nFilenames,1);
    indB = cell(nFilenames,1);
    indF = cell(nFilenames,1);

    for f = 1:length(filenames)
        % check filename
        if ~strcmp(filenames(f).name(1:3),dataType)
            error('inputfile %s is not datatype %s',filenames(f).name,dataType);
        else
        end

        [~, freqCrnt, binLabelsCrnt, data] = readFrequencyData(fullfile(pathname,filenames(f).name));
        
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
        
        
        % set values
        
        
        tempName = filenames(f).name;
        condIdx = str2num(tempName(end-6:end-4)); % grab condition number
        channelsToUse = unique(data(:,2));
        
        if (isempty(freqsToUse))
            freqsToUse = 1:numel(freqCrnt);
        end
        
        if (isempty(binsToUse))
            binsToUse = 1:(numel(binLabelsCrnt) - 1);
        end
        
        nFreqs=numel(freqsToUse);
        nChannels=numel(channelsToUse);
        nBins=numel(binsToUse);
        
        % assign frequency and bin labels
        binLabels{condIdx} = binLabelsCrnt(1:nBins)';
        freqLabels{condIdx} = freqCrnt(freqsToUse);

        if isempty(data)
            warning('No data found in %s',filenames(f).name)
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

        %% organize in data
        eeg = nan(nFreqs*nBins*2, nChannels, nTrialsToKeep);
        noise1 = nan(nFreqs*nBins*2, nChannels, nTrialsToKeep);
        noise2 = nan(nFreqs*nBins*2, nChannels, nTrialsToKeep);
        for tr = 1:nTrialsToKeep

            thisTrialInd = trialIndsToKeep(tr);
            trialData = data(trials == thisTrialInd, :);
            trialChannels = trialData(:,2);
            trialFreqs = trialData(:, 3);
            trialBins = trialData(:, 4);

            % freqs x bins
            for ch =  1:nChannels
                theseReals = trialData(trialChannels == channelsToUse(ch) & ismember(trialFreqs, freqsToUse) & ismember(trialBins,binsToUse), 5);
                theseImags = trialData(trialChannels == channelsToUse(ch) & ismember(trialFreqs, freqsToUse) & ismember(trialBins,binsToUse), 6);

                % noise 1
                theseNoiseReals1 = trialData(trialChannels == channelsToUse(ch) & ismember(trialFreqs,freqsToUse) & ismember(trialBins, binsToUse), 7);
                theseNoiseImags1 = trialData(trialChannels == channelsToUse(ch) & ismember(trialFreqs,freqsToUse) & ismember(trialBins, binsToUse), 8);

                % noise 2
                theseNoiseReals2 = trialData(trialChannels == channelsToUse(ch) & ismember(trialFreqs,freqsToUse) & ismember(trialBins, binsToUse), 9);
                theseNoiseImags2 = trialData(trialChannels == channelsToUse(ch) & ismember(trialFreqs,freqsToUse) & ismember(trialBins, binsToUse), 10);

                eeg(:, ch, tr) = [theseReals; theseImags];
                noise1(:, ch, tr) = [theseNoiseReals1; theseNoiseImags1];
                noise2(:, ch, tr) = [theseNoiseReals2; theseNoiseImags2];
            end
        end
        cellData{condIdx} = eeg;
        noiseCell1{condIdx} =  noise1;
        noiseCell2{condIdx} = noise2;
        indF{condIdx} = trialFreqs(trialChannels == channelsToUse(1) & ismember(trialFreqs, freqsToUse) & ismember(trialBins, binsToUse));
        indB{condIdx} = trialBins(trialChannels == channelsToUse(1) & ismember(trialFreqs, freqsToUse) & ismember(trialBins, binsToUse));
    end
    chanIncluded = channelsToUse;   
end