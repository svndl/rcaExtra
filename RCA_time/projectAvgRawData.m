 function out = projectAvgRawData(dataIn, rcWeights)
    
    nGroups = size(dataIn.rawData, 1);
    nConditions = size(dataIn.rawData{1}, 2);
    nSamples =  size(dataIn.eegGrouped{1}, 4);
    noProjEEG = 0;
    
    if (~isstruct(rcWeights))
        W_all.W_g = repmat({rcWeights}, [nGroups, 1]);
        W_all.W_c = repmat({rcWeights}, [nConditions, 1]);
        W_all.W_gc = repmat({rcWeights}, [nGroups nConditions]);
        noProjEEG = 1;
    else
        W_all = rcWeights;
    end
    nRCs = size(W_all.W_g{1}, 2);
    
    groupsProjected = cell(nGroups, 1);
    
    group_mu = zeros(nGroups, nRCs, nSamples);
    group_s = zeros(nGroups, nRCs, nSamples);
    
    condition_mu = zeros(nConditions, nRCs, nSamples);
    condition_s = zeros(nConditions, nRCs, nSamples);
    
    all_mu = zeros(nGroups, nConditions, nRCs, nSamples);
    all_s = zeros(nGroups, nConditions, nRCs, nSamples);
        
    for g = 1:nGroups
        currGroup = dataIn.rawData{g};
        groupCell = cat(1, currGroup(:));
        nUniqueSubjs = size(currGroup, 1);
        projectedRC = zeros(nUniqueSubjs, nConditions, nRCs, nSamples);
        
        % project group for plotting
        
        [mG, sG] = projectAvgData(groupCell, W_all.W_g{g});        
        group_mu(g, :, :) = mG';
        group_s(g, :, :) = sG';
        
        for c = 1:nConditions
            gcData = dataIn.rawData{g}(:, c);
            [mGC, sGC] = projectAvgData(gcData, W_all.W_gc{g, c});
            
            all_mu(g, c, :, :) = mGC';
            all_s(g, c, :, :) = sGC';
                        
            dataToProject = squeeze(dataIn.eegGrouped{g}(:, c, :, :));
            if (~noProjEEG)
                projResult = rcaProject(dataToProject, W_all.W_gc{g, c});
            else
                projResult = dataToProject;
            end
            projectedRC(:, c, :, :)  = baseline3DData(projResult);
        end
        groupsProjected{g} = projectedRC;
    end
    conditionsData = cat(1, dataIn.rawData{:});
    for c = 1:nConditions
        [mC, sC] = projectAvgData(conditionsData(:, c), W_all.W_c{c});
        condition_mu(c, :, :) = mC';
        condition_s(c, :, :) = sC';
    end  
    % actual projected data
    out.eeg = groupsProjected;
    % plotting
    out.group_mu = group_mu;
    out.group_s = group_s;
    out.condition_mu = condition_mu;
    out.condition_s = condition_s;
    out.all_mu = all_mu;
    out.all_s = all_s;
 end
