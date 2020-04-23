function [rcaData, W, A, runSettings] = rcaRunOnly(eegSrc, settings)

    % baseline all electrodes
    %baselinedEEG = cellfun(@(x) x - repmat(x(1, :, :), [size(x, 1) 1 1]), eegSrc, 'uni', false);
    
    baselinedEEG = eegSrc;
    
    dirResData = settings.resultsDir;
    if (iscell(dirResData))
        dirResData = [dirResData{:}];
    end
    dirResFigures = settings.figureDir;
    if (iscell(dirResFigures))
        dirResFigures = [dirResFigures{:}];
    end
    
    fileRCA = fullfile(dirResData, ['rcaResults_Time_' settings.label '.mat']);
    
    % run RCA
    delete(gcp('nocreate'));
    
    if(~exist(fileRCA, 'file'))
        [rcaData, W, A, ~, ~, ~, ~] = rcaRun(baselinedEEG', settings.nReg, settings.nComp);
        runSettings = settings;
        save(fileRCA, 'rcaData', 'W', 'A', 'runSettings');
        saveas(gcf, fullfile(dirResFigures, ['RCA_' settings.label '.fig']));
        saveas(gcf, fullfile(dirResFigures, ['RCA_' settings.label '.png']));        
    else
        disp(['Loading weights from ' fileRCA]);
        load(fileRCA);
        if (~cmpRCARunSettings(settings, runSettings))
            disp('New settings don''t match previous instance, re-running RCA ...'); 
            fileRCA_old = fullfile(dirResData, ['previous_rcaResults_Time_' settings.label '.mat']);

            movefile(fileRCA ,fileRCA_old, 'f')
            [rcaData, W, A, runSettings] = rcaRunOnly(eegSrc, settings);       
        end
            
        % add projected data
        if (~exist('rcaData', 'var'))
            try
                rcaData = rcaProject(baselinedEEG, W);
                save(fileRCA, 'rcaData', 'W', 'A');
            catch err
                disp('could not project Subjects, results not modified');
                rcaData = baselinedEEG;
            end
        end
        % add settings
        if (~exist('runSettings', 'var'))
            % implement proper storage/loading: if there are no settings,
            % re-run and store
            runSettings = settings;
            try
                save(fileRCA, 'rcaData', 'W', 'A', 'runSettings');
            catch err
                disp('could not add settings, results not modified');
                rcaData = baselinedEEG;
            end
        end
    end
end

