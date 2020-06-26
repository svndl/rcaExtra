function [corr_list, flip_list] = testWeightFlipping(eegSRCDir)

    %eegSRCDir = '/Volumes/Extreme SSD/EEG_DATA';
    corr_list = [];
    flip_list = [];
    % select rc result file
    [filename, pathname, ~] = uigetfile('*.mat', 'Select RC result file', eegSRCDir);
    % supports new file format for now
    try
        load(fullfile(pathname, filename), 'rcaResult');
        [corr_list, flip_list] = rcaExtra_adjustRCSigns(rcaResult);
    catch err
        rcaExtra_displayError(err)
    end
end


