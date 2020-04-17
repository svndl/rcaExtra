function [rcaData, W, A] = rcaRunOnly(eegSrc, settings, varargin)

    % RC parameters
    nReg = 8;
    % number of components to extract/plot
    nComp = 8;
    
    % baseline all electrodes
    
    %baselinedEEG = cellfun(@(x) x - repmat(x(1, :, :), [size(x, 1) 1 1]), eegSrc, 'uni', false);
    baselinedEEG = eegSrc;
    
    dirResData = settings.resultsDir;
    if (iscell(dirResData))
        dirResData = [dirResData{:}];
    end
    fileRCA = fullfile(dirResData, ['RCA_' settings.dataset '.mat']);
    % run RCA
    if(~exist(fileRCA, 'file'))
        [rcaData, W, A, ~, ~, ~, ~] = rcaRun(baselinedEEG', nReg, nComp);
        save(fileRCA, 'rcaData', 'W', 'A');
        saveas(gcf, fullfile(dirResData, ['RCA_' settings.dataset '.fig']));
        saveas(gcf, fullfile(dirResData, ['RCA_' settings.dataset '.png']));        
    else
        disp(['Loading weights from ' fileRCA]);
        load(fileRCA);
        if (~exist('rcaData', 'var'))
            try
                rcaData = rcaProject(baselinedEEG, W);
                save(fileRCA, 'rcaData', 'W', 'A');
            catch err
                disp('could not project Subjects, results not modified');
                rcaData = baselinedEEG;
        end
    end
end

