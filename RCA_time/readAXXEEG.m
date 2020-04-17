function rcaDataOut = readAXXEEG(rca_path)


    eegSrc = fullfile(rca_path.srcEEG);

    %% take powerdiva export and convert it to cell array format
    list_subj = list_folder([eegSrc filesep 'nl*']);
       
    nsubj = numel(list_subj);
    % check if there is a matfile
    axxData = {};
    s = 1;
    while s <= nsubj
        if (list_subj(s).isdir)
            subjDir = fullfile(eegSrc,  list_subj(s).name);
            try
                display(['Loading   ' list_subj(s).name]);
                % nCnd x nElectodes x nTrials
                subjEEG = loadSubjAXX(subjDir);
                % flatten the data out, each subj is a row, each col is
                % CND
                axxData(s, :) = (subjEEG(:))';
            catch err
                display(['Warning, could not load   ' list_subj(s).name]);
                display(err.message);
            end
            
        end
        s = s + 1;
    end
    rcaDataOut = reshape(axxData(~cellfun('isempty', axxData)), size(axxData));    
end
function dataOut = loadSubjAXX(subjDir)

    axxTrials = dir2(fullfile(subjDir, 'Axx_*_trials.mat'));
    
    nCnd = numel(axxTrials);
    dataOut = cell(nCnd, 1);
    
    for c = 1:nCnd
        
       dataFile = fullfile(subjDir, axxTrials(c).name);
       
       try
           load(dataFile);
            dataOut{c} = Wave;
       catch
           sprintf('Error loading %s', dataFile);
       end
        
    end
end
