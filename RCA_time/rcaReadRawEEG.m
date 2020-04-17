function rcaData = rcaReadRawEEG(dataPath, loadSettings)
% Processes subjects rawEEG. Generates and rca-ready matfile   
    
    loadedDir = fullfile(dataPath.loadedEEG);
    eegSrc = fullfile(dataPath.srcEEG);

%    proj_dir = uigetdir(eegSrc, 'Select the EEG raw data folder');
%    if (~(proj_dir))
%        error('No directory selected, quitting...');
%    end

    %% take powerdiva export and convert it to cell array format
    list_subj = list_folder(eegSrc, loadSettings.subjTag);
    nsubj = numel(list_subj);
    % check if there is a matfile
    
    removeEyes = 0;
    display(['Eye Artifacts Status = ' num2str(removeEyes)]);
    for nge = 1:nsubj
        if (list_subj(nge).isdir)
            subjDir = fullfile(eegSrc, list_subj(nge).name, loadSettings.subDirMat);
            subjDataFile = fullfile(loadedDir, [list_subj(nge).name '.mat']);
            try                
                if (exist(subjDataFile, 'file'))
                    display(['Loading   ' subjDataFile]);
                    load(subjDataFile);
                else
                    display(['Loading   ' subjDir]);                   
                    subjEEG = readRawData(subjDir, removeEyes);
                    save(subjDataFile, 'subjEEG');
                end
                rcaData(nge, :) = subjEEG(:)';
            catch err
                fprintf("Could not load  %s\n", list_subj(nge).name);
                fprintf("Error: %s \n", err.message);
                %subj_names(nge) = [];
                %do nothing
            end    
        end
    end
end
