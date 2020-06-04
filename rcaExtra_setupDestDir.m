function dirPaths = rcaExtra_setupDestDir(destDirPath, dirNames)
% generates subdirectories within destDirPath
% Alexandra Yakovleva, Stanford Unicersity, 2020

    % generate full path to subdirectories using fullfile 
    dirPaths = cellfun(@(x) fullfile(destDirPath, x), dirNames, 'uni', false);
    
    % check if subdirectories exist
    dirsExist = cellfun(@(x) ~exist(x, 'dir'), dirPaths, 'uni', false);
    
    % make a list of subdirectories we need to create
    dirsToCreate = dirPaths(cell2mat(dirsExist));
    
    % if all subdirectories exist, don't create 
    if (~isempty(dirsToCreate))
        cellfun(@(x) mkdir(x), dirsToCreate, 'uni', false);
    end
end