function OnOff_Students = loadExperimentInfo_OnOff_Students

%% info is a structure describing experiment parameters
OnOff_Students = rcaExtra_genStructureTemplate;
[curr_path, ~, ~] = fileparts(mfilename('fullpath'));
OnOff_Students.path.rootFolder = curr_path;

% source EEG data
srcDirPath = uigetdir(curr_path, 'Select EEG SOURCE directory');
if (~isempty(srcDirPath))
    OnOff_Students.path.sourceEEGDir = srcDirPath;
end

% destination EEG directory
OnOff_Students.path.destDataDir = uigetdir(curr_path, 'Select analysis results directory');


%% create subdirectories
dirNames = {'MAT', 'FIG', 'RCA'};
dirPaths = rcaExtra_setupDestDir(OnOff_Students.path.destDataDir, dirNames);

OnOff_Students.path.destDataDir_MAT = dirPaths{1};
OnOff_Students.path.destDataDir_FIG = dirPaths{2};
OnOff_Students.path.destDataDir_RCA = dirPaths{3};

% replace default values here
% fullfiled_Students.info.subjTag = 'll_sawtooth_nl*';
OnOff_Students.info.subjTag = 'nl*LR*'; % make it match any participant starting with "nl" and having "LR" in the name (both eyes tested I think)
% fullfiled_Students.info.subDirTxt = 'Exp_TEXT_HCN_128_Avg';
% fullfiled_Students.info.subDirMat = 'Exp_MATL_HCN_128_Avg';
OnOff_Students.info.subDirTxt = ''; % MATLAB and TEXT exports are kept all together for this project
OnOff_Students.info.subDirMat = '';
OnOff_Students.info.groupLabels = {'SVNDL Luminance'};
OnOff_Students.info.conditionLabels = {'OS ON', 'OS OFF', 'OD ON', 'OD OFF'};
OnOff_Students.info.frequenciesHz = 2.73;
OnOff_Students.info.useSpecialDataLoader = false;
OnOff_Students.info.frequencyLabels = {{'1F1', '2F1', '3F1', '4F1'}};
OnOff_Students.info.binsNmb = 8;
end