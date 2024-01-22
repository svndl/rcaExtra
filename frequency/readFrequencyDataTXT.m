function [colHdr, freqsAnalyzed, binIndices, trialIndices, dataMatrix] = readFrequencyDataTXT(datafile)
    %% Imports frequency data from a Text File
    %
    % [colHdr, freqsAnalyzed, sweepVals, dataMatrix] = readFrequencyDataTXT(datafile)
    %
    %% Inputs:
    % datafile     string containing the data file 
    %
    %% Outputs:
    % colHdr          is a string with column fields
    % freqsAnalyzed   are the individual frequencies of the VEPs ('1F1' etc.)
    % sweepVals       are the contrasts or stimulus values used
    % dataMatrix      matrix containing the desired data

    fname = datafile;
    %  SetUp import columns and data formats, from JA
    %  Asterisk (*) after % exclude selected columns
    %

    hdrFields = {
        'iSess'         '%s\t'      0 %1
        'iCond'         '%f\t'      1 %2
        'iTrial'        '%f\t'      1 %3
        'iCh'           '%s\t'      1 %4 This becomes %f later in the function
        'iFr'           '%f\t'      1 %5
        'AF'            '%f\t'      1 %6
        'xF1'           '%f\t'      1 %7
        'xF2'           '%f\t'      1 %8
        'Harm'          '%s\t'      2 %9 
        'FK_Cond'       '%f\t'      1 %10
        'iBin'          '%f\t'      1 %11
        'SweepVal'      '%f\t'      1 %12
        'Sr'            '%f\t'      1 %13
        'Si'            '%f\t'      1 %14
        'N1r'           '%f\t'      1 %15
        'N1i'           '%f\t'      1 %16
        'N2r'           '%f\t'      1 %17
        'N2i'           '%f\t'      1 %18
        'Signal'        '%f\t'      1 %19
        'Phase'         '%f\t'      1 %20
        'Noise'         '%f\t'      1 %21
        'StdErr'        '%f\t'      1 %22
        'PVal'          '%f\t'      1 %23
        'SNR'           '%f\t'     2 %24
        'LSB'           '%f\t'     2 %25
        'RSB'           '%f\t'     2 %26
        'UserSc'        '%s\t'     2 %27
        'Thresh'        '%f\t'     2 %28
        'ThrBin'        '%f\t'     2 %29
        'Slope'         '%f\t'     2 %30
        'ThrInRange'    '%s\t'     2 %31
        'MaxSNR'        '%f\t'     2 };%32


    channelIx = 4;
    freqIx = 5;
    harmIx = 9;
    binIdx = 11;
    xF1Idx = 7;
    xF2Idx = 8;
    stdErrIdx = 22;

    fid = fopen(fname);
    if fid == -1
        error('File %s could not be opened.',fname);
    end

    tline = fgetl(fid);
    dati = textscan(fid, [hdrFields{:, 2}], 'delimiter', '\t', 'EmptyValue', nan);
    fclose(fid);
    % Convert the channel identifier string into digit only
    for i = 1:size(dati{1, channelIx})
        chan{1, i} = sscanf(dati{1, channelIx}{i}, 'hc%d');
    end

    dati{1, channelIx} = chan';
    usCols = [3 4 5 11 13 14 15 16 17 18 22];

    % Fill in essential matrix
    for s = 1:length(usCols)
        o = usCols(s);
        if o ~= channelIx
            dataMatrix(:, s) = (dati{1, o}(:));
        else
            if isempty(cell2mat((dati{1, o}(:))))
                colHdr = {};
                freqsAnalyzed = {};
                dataMatrix = nan;
                fprintf('ERROR! rawdata is empty..\n')
                return;
            else
                dataMatrix(:, s) = cell2mat((dati{1, o}(:)));
            end
        end

    end

    binIndices = unique(dataMatrix(:, 4)); % this will always include 0
    
    %dataMatrix = dataMatrix(dataMatrix(:, 1) >0, :); % Selects all trials but the 0th one (i.e. the average trial)
    trialIndices = unique(dataMatrix(:, 1));
    
    [freqsAnalyzed, tmpIx] = unique(dati{1, harmIx}(:));
    freqNum = nan(1, length(freqsAnalyzed));
    for f = 1:length(freqsAnalyzed)
        freqNum(f) = dati{1, freqIx}(tmpIx(f));
    end
    [~, tmpIx] = sort(freqNum);
    freqsAnalyzed = freqsAnalyzed(tmpIx);
    

    for m = 1:length(usCols)
        colHdr{m} = hdrFields{usCols(m), 1};
    end
    dataMatrix(:, end + 1) = sqrt(dataMatrix(:, end - 1).^2 + dataMatrix(:, end).^2); % Computes amplitudes in final column
    % replace samples with zero amplitudes with NaN because 0 is PowerDiva's
    % indicator of a rejected epoch
    zeroAmpRows = dataMatrix(:, end) == 0;
    dataMatrix(zeroAmpRows, 5:end) = nan;
    colHdr{end + 1} = 'ampl';
end



