function [signalDataSel, noise1Sel, noise2Sel, infoSel] = extractDataSubset(sourceDataFileName, settings)
    % Return subset of data contained in sourceDataFileName
    % containing binsToUse, freqsToUse, condsToUse
    
    %Copyright 2019 Alexandra Yakovleva Stanford University SVNDL
    
    signalDataSel = [];
    noise1Sel = [];
    noise2Sel = [];
    infoSel = [];
    
    try
        load(sourceDataFileName); 
        if (isempty(signalData))
            return 
        end
    catch err
        rcaExtra_displayError(err);
        return
    end
    
    if (~isfield(settings, 'useConditions'))
        condsToUse = [];
    else
        condsToUse = settings.useConditions;        
    end
    
    if (~isfield(settings, 'useBins'))
        binsToUse = [];
    else
        binsToUse = settings.useBins;
    end
    
    if (~isfield(settings, 'useFrequencies'))
        freqsToUseStr = [];
    else
        freqsToUseStr = settings.useFrequencies;        
    end
    
    if (~isfield(settings, 'useTrials'))
        trialsToUse = [];
    else
        trialsToUse = settings.useTrials;        
    end

    if (isempty(condsToUse))
        condsToUse = 1:size(signalData, 1);
    end
        
    nConds = length(condsToUse);  
    
    % pre-allocate
    signalDataSel = cell(nConds, 1);
    noise1Sel = cell(nConds, 1);
    noise2Sel = cell(nConds, 1);
    freqLabelsSel = cell(nConds, 1);
    binLabelsSel = cell(nConds, 1);
    
    for c = 1:nConds
        % if outside of data range or condition has no data, add empty cell
        if condsToUse(c) > size(signalData, 1) || isempty(signalData{condsToUse(c)})
            signalDataSel{c} = [];
            noise1Sel{c} = [];
            noise2Sel{c} = [];
        else
            if isempty(freqsToUseStr)
                % use all available frequencies
                freqsToUseStr = unique(info.freqLabels{condsToUse(c)});
                infoSel.freqLabels = freqsToUseStr;
            else
                [~, hasFrequencies] = ismember(settings.useFrequencies, info.freqLabels{condsToUse(c)});
                freqsToUseStr = info.freqLabels{condsToUse(c)}(hasFrequencies); 
            end           
            if isempty(binsToUse)
                % use all available bins
                % (note: canmot differ across conditions)
                infoSel.binLabels = unique(info.binLabels{condsToUse(c)});
                binsToUse = info.binLabels;
            else
            end
            if isempty(trialsToUse)
                % use all available trials 
                % (note: can differ across conditions)
                curTrials = 1:size(signalData{condsToUse(c)},3); % use all trials
            else
                curTrials = trialsToUse;
            end
            % raw data structured first by harmonics as listed in useFrequencies
            % following the exact order, then by bins ie 1F1 bins 0-10, 2
            allFreqs = numel(info.freqLabels{condsToUse(c)});
            
            allBins = info.binLabels{condsToUse(c)};
            cellIdx = arrayfun(@(x) (x + binsToUse' + 1), ((hasFrequencies') - 1).*numel(allBins), 'uni', false);
            indReal = cat(1, cellIdx{:});
            selRowIx = [indReal; indReal + allFreqs*numel(allBins)];            
 
            missingIdx = find(~ismember(curTrials, 1:size(signalData{condsToUse(c)}, 3)));
            if ~isempty(missingIdx)
                error('Input trial indices "%s" is not among set of trials',num2str(curTrials(missingIdx),'%d,'));
            else
            end
            % repmat because the first half is real, second half is imag with same ordering
            try
                signalDataSel{c} = signalData{condsToUse(c)}(selRowIx, :, curTrials); 
                noise1Sel{c}     = noise1{condsToUse(c)}(selRowIx, :, curTrials);
                noise2Sel{c}     = noise2{condsToUse(c)}(selRowIx, :, curTrials);
            catch err
                rcaExtra_displayError(err);
                signalDataSel{c} = [];
                noise1Sel{c} = [];
                noise2Sel{c} = [];
            end
            
%             % find non-empty frequency indices
%             nonEmpty = find(cell2mat(cellfun(@(x) ~isempty(x), info.indF, 'uni', false)));
%             % find first among conditions to use
%             nonEmpty = min(nonEmpty(ismember(nonEmpty,condsToUse)));
%             % check if indices are unequal
%             if any ( info.indF{nonEmpty} ~= info.indF{condsToUse(c)} )
%                 disp('frequency indices are not matched across conditions');
%             elseif any ( info.indB{nonEmpty} ~= info.indB{condsToUse(c)} )
%                 disp('bin indices are not matched across conditions');
%             else
%             end

%             % assign indices and labels of selected data features
%             % grab bin indices
%             indBSel{c} = indB{condsToUse(c)}(selRowIx);
%             % grab frequency indices
%             indFSel{c}  = indF{condsToUse(c)}(selRowIx);
%             % grab bin labels
%             try
%                 binLabelsSel{c}  = binLabels{condsToUse(c)}(binsToUse+1); % add one, because bin level 0 = average
%             catch
%                 binLabelsSel{c}  = binLabels{condsToUse(c)}(binsToUse); % add one, because bin level 0 = average
%             end  
%             % grap frequency labels
%              
             freqLabelsSel{c}  = info.freqLabels{condsToUse(c)}(hasFrequencies);
             try
                binLabelsSel{c}  = info.binLabels{condsToUse(c)}(binsToUse + 1); % add one, because bin level 0 = average
             catch
                binLabelsSel{c}  = info.binLabels{condsToUse(c)}(binsToUse);
             end
%                  
%             % grap frequency labels
%             trialsSel{c}  = curTrials;
        end
    end

    % now replace missing conditions with NaNs
    
    signalDataSel = replaceEmpty(signalDataSel);
    noise1Sel = replaceEmpty(noise1Sel);
    noise2Sel = replaceEmpty(noise2Sel);
    infoSel.freqLabels = freqLabelsSel;
    infoSel.binLabels = binLabelsSel;
    
%     indFSel = replaceEmpty(indFSel);
%     indBSel = replaceEmpty(indBSel);
%     freqLabelsSel = replaceEmpty(freqLabelsSel);
%     binLabelsSel = replaceEmpty(binLabelsSel);
%     trialsSel = replaceEmpty(trialsSel);
end

function cellOut = replaceEmpty(cellIn)
    nonEmpty = cell2mat(cellfun(@(x) ~isempty(x),cellIn,'uni',false));
    repIdx = find(nonEmpty, 1, 'first');
    cellOut = cellIn;
    cellOut(~nonEmpty) = {nan(size(cellIn{repIdx}))};
end