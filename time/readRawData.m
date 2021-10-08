function dataOut = readRawData(dataPath, removeEyes, nanArtifacts)

%This function reorganizes the data for 1 subject. By default, we analyze by
%subjects. CellData will be 1Xncondition cell array, within each cell, you
%will have timesample X channels X ntrials. If analyzing by scenes,
%cellData will be a nScenes X nconditions cell array for each subject. The
%cellData will be concatenated later for every subject. 

 
    if nargin < 3, nanArtifacts = 1; end
    %if nargin < 2, removeEyes = 1; end

    list_rawFiles = list_folder(fullfile(dataPath, '*Raw*.mat'));      
    nFiles = numel(list_rawFiles);
    for z = 1:nFiles
        try
            dataFile = fullfile(dataPath, list_rawFiles(z).name);
            load(dataFile);
            
            % remove prelude/postlude
            nSamples = size(RawTrial, 1)/NmbEpochs;
            RawTrial_core = RawTrial(nSamples*NmbPreludeEpochs+1:end - nSamples*NmbPreludeEpochs, :);
            IsEpochOK_core = IsEpochOK(NmbPreludeEpochs+1:end - NmbPreludeEpochs, :);      
            rawtrial = double(RawTrial_core).*repmat(Ampl.', size(RawTrial_core, 1), 1) + repmat(Shift.',size(RawTrial_core, 1), 1);
        
            if nanArtifacts %make epochs with Artifacts to nan
                [rowE, colE] = find(IsEpochOK_core == 0);
                for idx = 1:length(rowE)
                    rowIdx = ((rowE(idx) - 1)*round(nSamples) + 1):((rowE(idx) - 1)*round(nSamples) + round(nSamples));
                    rawtrial(rowIdx, colE(idx)) = NaN;
                end
            end
            % Format is 'Raw_cxxN_tyyM.mat';
        
            cndN = str2num(list_rawFiles(z).name(6:8));
            trlN = str2num(list_rawFiles(z).name(11:13));
            try
                numNaNs(cndN, trlN) = length(find(IsEpochOK == 0));
                rawdata{1, cndN}(:, :, trlN) = rawtrial;
            catch err
                display(['oops, something went wrong loading ' list_rawFiles(z).name]);
                fprintf('At %d %d \n', cndN, trlN);
            end
        catch err
            sprintf("Error loading %s", dataFile);
        end
    end

    nCnd = size(rawdata, 2);
    cellData = cell(1, nCnd); 
    for c = 1:nCnd
        if removeEyes
            nTrialsThisCond = size(rawdata{1, c}, 3);
            for tr = 1:nTrialsThisCond
                dataIn = rawdata{1, c}(:, :, tr);
                X = dataIn(:, 1:end - 2); % data channels
                V = dataIn(:, end - 1:end);  % HEOG/VEOG
                if ~isempty(find(isnan(V), 1))
                    disp('ERROR: Eye channels contain NaNs')
                    return;
                end
                dataOut = (eye(size(X, 1)) - V*pinv(V))*X; %A=pinv(V)*X; % transfer function from eyes to data electrodes
                % If a channel has NaN in any epoch, this step will
                % assign NaNs to every epoch in that block for that channel.
                cellData{1, c}(:, :, tr) = dataOut;
            end
        else
            cellData{1, c} = rawdata{1, c}(:, 1:end - 2, :);  % just take out EOG reference electrodes from electrode
        end
    end
    %% take out prelude/postlude
    %% won't work for conditions with diff frequencies
    %     binLength = size(RawTrial, 1)/NmbEpochs;
    %     dataOut = cellfun( @(x) x(binLength + 1:end - binLength, :, :), cellData, 'uni', false);
    
    dataOut = cellData;
end
