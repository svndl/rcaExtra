function [rcaData, W, A] = rcaRunOnly(eegSrc, settings, varargin)

% Alexandra Yakovleva, Stanford University 2012-2020

% Runs RC analysis and saves weights/projected data into settings.datset matfile  

    % RC parameters
    nReg = 7;
    % number of components to extract/plot
    nComp = 3;
    
    dirResData = settings.resultsDir;
    if (iscell(dirResData))
        dirResData = [dirResData{:}];
    end
    fileRCA = fullfile(dirResData, ['RCA_' settings.dataset '.mat']);
    % run RCA
    if(~exist(fileRCA, 'file'))
        [rcaData, W, A, ~, ~, ~, ~] = rcaRun(eegSrc', nReg, nComp);
        save(fileRCA, 'rcaData', 'W', 'A');
        saveas(gcf, fullfile(dirResData, ['RCA_' settings.dataset '.fig']));
        saveas(gcf, fullfile(dirResData, ['RCA_' settings.dataset '.png']));        
    else
        disp(['Loading weights from ' fileRCA]);
        load(fileRCA);
        if (~exist('rcaData', 'var'))
            try
                rcaData = rcaProject(eegSrc, W);
                save(fileRCA, 'rcaData', 'W', 'A');
            catch err
                disp('could not project Subjects, results not modified');
                rcaData = eegSrc;
        end
    end
end

