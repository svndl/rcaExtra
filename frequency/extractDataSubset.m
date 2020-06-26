function [signalDataSel, noise1Sel, noise2Sel, info] = extractDataSubset(sourceDataFileName, settings)
    % Return subset of data contained in sourceDataFileName
    % containing binsToUse, freqsToUse, condsToUse
    
    %Copyright 2019 Alexandra Yakovleva Stanford University SVNDL
    
    load(sourceDataFileName); 
    
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
        freqsToUse = [];
    else
        freqsToUse = settings.useFrequencies;        
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
        
    signalDataSel = cell(nConds, 1);
    noise1Sel = cell(nConds, 1);
    noise2Sel = cell(nConds, 1);
    
    
    for c = 1:nConds
        if condsToUse(c) > size(signalData, 1) || isempty(signalData{condsToUse(c)})
            signalDataSel{c} = [];
            noise1Sel{c} = [];
            noise2Sel{c} = [];
        else
            if isempty(binsToUse)
                % use all available bins
                % (note: canmot differ across conditions)
                binsToUse = unique(info.indB{condsToUse(c)});
                binsToUse = binsToUse(binsToUse>0); % use all bins except the average bin
            else
                
            end
            if isempty(freqsToUse)
                % use all available frequencies
                % (note: cannot differ across conditions)
                settings.useFrequencies = unique(info.freqLabels{condsToUse(c)});
                freqsToUse = unique(info.indF{condsToUse(c)});
            else
                [~, freqsToUse] = ismember(settings.useFrequencies, info.freqLabels{condsToUse(c)});
            end
            selRowIx = ismember(info.indB{condsToUse(c)}, binsToUse) & ismember(info.indF{condsToUse(c)}, freqsToUse);
            if isempty(trialsToUse)
                % use all available trials 
                % (note: can differ across conditions)
                curTrials = 1:size(signalData{condsToUse(c)},3); % use all trials
            else
                curTrials = trialsToUse;
            end
            missingIdx = find(~ismember(curTrials,1:size(signalData{condsToUse(c)}, 3)));
            if ~isempty(missingIdx)
                error('Input trial indices "%s" is not among set of trials',num2str(curTrials(missingIdx),'%d,'));
            else
            end
            signalDataSel{c} = signalData{condsToUse(c)}(repmat(selRowIx,[2,1]),:,curTrials); % repmat because the first half is real, second half is imag with same ordering
            noise1Sel{c}     =     noise1{condsToUse(c)}(repmat(selRowIx,[2,1]),:,curTrials);
            noise2Sel{c}     =     noise2{condsToUse(c)}(repmat(selRowIx,[2,1]),:,curTrials);
            
            % find non-empty frequency indices
            nonEmpty = find(cell2mat(cellfun(@(x) ~isempty(x), info.indF, 'uni', false)));
            % find first among conditions to use
            nonEmpty = min(nonEmpty(ismember(nonEmpty,condsToUse)));
            % check if indices are unequal
            if any ( info.indF{nonEmpty} ~= info.indF{condsToUse(c)} )
                disp('frequency indices are not matched across conditions');
            elseif any ( info.indB{nonEmpty} ~= info.indB{condsToUse(c)} )
                disp('bin indices are not matched across conditions');
            else
            end

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
              freqLabelsSel{c}  = info.freqLabels{condsToUse(c)}(freqsToUse);
              binLabelsSel{c}  = info.binLabels{condsToUse(c)}(binsToUse + 1); % add one, because bin level 0 = average              
%             % grap frequency labels
%             trialsSel{c}  = curTrials;
        end
    end

    % now replace missing conditions with NaNs
    
    signalDataSel = replaceEmpty(signalDataSel);
    noise1Sel = replaceEmpty(noise1Sel);
    noise2Sel = replaceEmpty(noise2Sel);
    info.indF = freqsToUse;
    info.indB = binsToUse;
    info.freqLabels = unique(cat(1, freqLabelsSel{:}));
    info.binLabels = unique(cat(1, binLabelsSel{:}));
    
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