function varargout = extractDataSubset(sourceDataFileName, settings)
    % Return subset of data contained in sourceDataFileName
    % containing binsToUse, freqsToUse, condsToUse
    
    %Copyright 2019 Alexandra Yakovleva Stanford University SVNDL
    
    signalDataSel = [];
    noise1Sel = [];
    noise2Sel = [];
    stdErrSel = [];
    infoSel = [];
    
    dataHasStdErr = 0;
    dataHasNoise = 0;
    try
        load(sourceDataFileName); 
        if (isempty(signalData))
            return 
        end
    catch err
        rcaExtra_displayError(err);
        return
    end
    
    if (exist('subjStdErr','var'))
       dataHasStdErr = 1; 
    end
        
    if (~isfield(settings, 'useCnds'))
        condsToUse = []; %empty, use all conditions
    else
        condsToUse = settings.useCnds;        
    end
    
    if (~isfield(settings, 'useBins'))
        binsToUse = []; % empty, use all bins except 0
    else
        binsToUse = settings.useBins;
    end
    
    if (~isfield(settings, 'useFrequencies'))
        freqsToUseStr = []; % empty, use all frequencies
    else
        freqsToUseStr = settings.useFrequencies;        
    end
    
    if (isempty(condsToUse))
        condsToUse = 1:size(signalData, 1);
    end
    
    if (~isfield(settings, 'useTrials'))
        trialsToUse = []; % empty, use all trials except 0
    else
        trialsToUse = settings.useTrials;        
    end
    
    if (~isfield(settings, 'useChannels'))
        channelsToUse = []; % empty, u
    else
        channelsToUse = settings.useChannels;        
    end
    nConds = length(condsToUse);  
    
    % pre-allocate
    signalDataSel = cell(nConds, 1);
    noise1Sel = cell(nConds, 1);
    noise2Sel = cell(nConds, 1);
    stdErrSel = cell(nConds, 1);
    freqLabelsSel = cell(nConds, 1);
    binLabelsSel = cell(nConds, 1);
    
    for c = 1:nConds
        % if outside of data range or condition has no data, add empty cell
        if condsToUse(c) > size(signalData, 1) || isempty(signalData{condsToUse(c)})
            signalDataSel{c} = [];
            noise1Sel{c} = [];
            noise2Sel{c} = [];
            stdErrSel{c} = [];
        else
            %% frequency selection
            if isempty(freqsToUseStr)
                % use all available frequencies
                freqsToUseStr = unique(info.freqLabels{condsToUse(c)});
                infoSel.freqLabels = freqsToUseStr;
            else
                [~, hasFrequencies] = ismember(settings.useFrequencies, info.freqLabels{condsToUse(c)});
                freqsToUseStr = info.freqLabels{condsToUse(c)}(hasFrequencies); 
            end
            
            %% bin selection
            allBins = unique(info.binLabels{condsToUse(c)});
            
            % transpose if needed
            if (size(allBins, 1) == 1)
                allBins = allBins';
            end

            if isempty(binsToUse)
                % use all available bins except bin 0
                % use find to return indicies > 0                 
                binIndex = find(allBins);
            else
                binIndex = find(ismember(allBins, settings.useBins));    
            end
            
            %% trial selection
            allTrials = 1:size(signalData{condsToUse(c)}, 3);
            
            if isempty(trialsToUse)
                % use all available trials except  0
                curTrials = allTrials(2:end);
            else
                curTrials = find(ismember(allTrials, trialsToUse + 1));
            end

            %% channel selection
            allChannels = 1:size(signalData{condsToUse(c)}, 2);
            if isempty(channelsToUse)
                % use all channels
                curChannels =  allChannels;
            else
                curChannels = channelsToUse;
            end
            
            if (~isempty(noise1{c}) && ~isempty(noise2{c}))
                dataHasNoise = 1;
            end

            infoSel.binLabels = allBins(binIndex);
            curBins = infoSel.binLabels;

            % raw data structured first by harmonics as listed in useFrequencies
            % following the exact order, then by bins ie 1F1 bins 0-10, 2F1 bins 0-10, etc..
           
            allFreqs = numel(info.freqLabels{condsToUse(c)});
            
            % start of bin0 for each freq multiple
            binStarts = ((hasFrequencies') - 1).*(numel(allBins));
            % add selected bin indicies
            cellIdx = arrayfun(@(x) (x + binIndex), binStarts, 'uni', false);
            indReal = cat(1, cellIdx{:});
            selRowIx = [indReal; indReal + allFreqs*numel(allBins)];            
 
            missingIdx = find(~ismember(curTrials, 1:size(signalData{condsToUse(c)}, 3)));
            if ~isempty(missingIdx)
                error('Input trial indices "%s" is not among set of trials',num2str(curTrials(missingIdx),'%d,'));
            else
            end
            % repmat because the first half is real, second half is imag with same ordering
            try
                % must have signal data var
                signalDataSel{c} = signalData{condsToUse(c)}(selRowIx, curChannels, curTrials);
                
                % new mfHD data doesn't have noise yet
                if (dataHasNoise)
                    noise1Sel{c} = noise1{condsToUse(c)}(selRowIx, curChannels, curTrials);
                    noise2Sel{c}  = noise2{condsToUse(c)}(selRowIx, curChannels, curTrials);
                end
                if (dataHasStdErr)
                    stdErrSel{c} = subjStdErr{condsToUse(c)}(indReal, curChannels, curTrials);
                end
            catch err
                rcaExtra_displayError(err);
                signalDataSel{c} = [];
                noise1Sel{c} = [];
                noise2Sel{c} = [];
                stdErrSel{c} = [];
            end
            
              
             freqLabelsSel{c}  = info.freqLabels{condsToUse(c)}(hasFrequencies);
             try
                binLabelsSel{c}  = info.binLabels{condsToUse(c)}(curBins + 1); % add one, because bin level 0 = average
             catch
                binLabelsSel{c}  = info.binLabels{condsToUse(c)}(curBins);
             end
        end
    end

    % now replace missing conditions with NaNs
    signalDataSel = replaceEmpty(signalDataSel);
    if (dataHasNoise)
        noise1Sel = replaceEmpty(noise1Sel);
        noise2Sel = replaceEmpty(noise2Sel);
    end
    if (dataHasStdErr)
        stdErrSel = replaceEmpty(stdErrSel);
    end
    infoSel.freqLabels = freqLabelsSel;
    infoSel.binLabels = binLabelsSel;
    
    [varargout{1:5}] = deal(signalDataSel, noise1Sel, noise2Sel, stdErrSel, infoSel);
end

function cellOut = replaceEmpty(cellIn)
    nonEmpty = cell2mat(cellfun(@(x) ~isempty(x),cellIn,'uni',false));
    repIdx = find(nonEmpty, 1, 'first');
    cellOut = cellIn;
    cellOut(~nonEmpty) = {nan(size(cellIn{repIdx}))};
end