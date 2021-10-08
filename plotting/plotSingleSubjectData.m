function plotSingleSubjectData(subjName, ch)
%% set path
    %% data dirs 
    [rootFolder, ~, ~] = fileparts(mfilename('fullpath'));
    switch subjName(1)
        case 'p'
            SubjDir = 'Patients';
        case 'c'
            SubjDir = 'Controls';
        otherwise
            SubjDir = 'Students';
    end
    
    srcEEGDir = fullfile(rootFolder, 'EEG_DATA', 'FullField', SubjDir);
    
    %% load data  
    listDir = fullfile(srcEEGDir, ['*' subjName '*']);
    listSessions = list_folder(listDir);        
    nSessions = numel(listSessions);
    names = {listSessions(:).name};
    subjData = {};
    for ns = 1:nSessions
        if (listSessions(ns).isdir)
            subjDir = fullfile(srcEEGDir,  listSessions(ns).name);
            subjDataFile = fullfile(subjDir, [listSessions(ns).name '.mat']);
            try
                display(['Loading   ' listSessions(ns).name]);
                
                if exist(subjDataFile, 'file')
                    load(subjDataFile);
                else
                    subjEEG = readRawData(subjDir);
                    save(subjDataFile, 'subjEEG');
                end
                subjData(ns, :) = subjEEG(:)';
            catch
                display(['Warning, could not load   ' listSessions(ns).name]);
                names(ns) = [];
                %do nothing
            end
            
        end
    end
    %% split and resample data
    
    lEye = [1, 2];
    rEye = [3, 4];
    
    NS_DAR = 420;
    freqHz = 2.73;
    cycleDurationSamples = round(NS_DAR./freqHz);
        
    incIdx = 1;
    decIdx = 2;
    
    data_OS = resampleData(subjData(:, lEye), cycleDurationSamples);
    data_OD = resampleData(subjData(:, rEye), cycleDurationSamples);
   
    timeCourseLen = round(1000./freqHz);    
    tc = linspace(0, timeCourseLen, size(data_OS{1, 1}, 1));
    
    %% split and average data
    
    OS_Inc = data_OS(:, incIdx);
    OD_Inc = data_OD(:, incIdx);
    OS_Dec = data_OS(:, decIdx);
    OD_Dec = data_OD(:, decIdx);
    
    %% OS Inc
    catData_inc_os = cat(3, OS_Inc{:});
    muData_inc_os = nanmean(catData_inc_os, 3);
    mu_inc_os = muData_inc_os - repmat(muData_inc_os(1, :), [size(muData_inc_os, 1) 1]);
    s_inc_os = nanstd(catData_inc_os, [], 3)/(sqrt(size(catData_inc_os, 3)));
    
    %% OD inc 
    catData_inc_od = cat(3, OD_Inc{:});
    muData_inc_od = nanmean(catData_inc_od, 3);
    mu_inc_od = muData_inc_od - repmat(muData_inc_od(1, :), [size(muData_inc_od, 1) 1]);
    s_inc_od = nanstd(catData_inc_od, [], 3)/(sqrt(size(catData_inc_od, 3)));
    
    %% OS dec
    catData_dec_os = cat(3, OS_Dec{:});
    muData_dec_os = nanmean(catData_dec_os, 3);
    mu_dec_os = muData_dec_os - repmat(muData_dec_os(1, :), [size(muData_dec_os, 1) 1]);
    s_dec_os = nanstd(catData_dec_os, [], 3)/(sqrt(size(catData_dec_os, 3)));
    
    %% OD dec
    catData_dec_od = cat(3, OD_Dec{:});
    muData_dec_od = nanmean(catData_dec_od, 3);
    mu_dec_od = muData_dec_od - repmat(muData_dec_od(1, :), [size(muData_dec_od, 1) 1]);
    s_dec_od = nanstd(catData_dec_od, [], 3)/(sqrt(size(catData_dec_od, 3)));
    
    %% plot data 
    group_inc_mu = [mu_inc_os(:, ch), mu_inc_od(:, ch)];
    group_inc_s = [s_inc_os(:, ch), s_inc_od(:, ch)];
    group_dec_mu = [mu_dec_os(:, ch), mu_dec_od(:, ch)];
    group_dec_s = [s_dec_os(:, ch), s_dec_od(:, ch)];
    
    [h1, h2] = subplotMultipleConditions( ...
         {tc, tc}, ...
         {'Increment', 'Decrement'},...
         {'OS', 'OD'}, ...
         {group_inc_mu, group_inc_s}, ...
         {group_dec_mu, group_dec_s});
end