function binData = rcaExtra_reshapeBinsToTrials(trialData, nFreqs)

% based on Blair's reshaping code
% modified to operate on arbitraty number of bins and same number of
% harminics
% binData = reshapeTrialToBinForRCA(trialData, nFreqs)
% ---------------------------------------------------------------
% Blair - August 2020
%
% This function reshapes a single feature x electrode x trial matrix to a 
%   feature x electrode x bin matrix before input to RCA.
%
% REQUIRED INPUT
% - trialData: A feature x electrode x trial matrix. Here, trials are 
%   assumed to represent the concatenation of some number of bins, while
%   the feature dimension comprises real and imaginary fourier coefficients
%   for nBins frequencies and some number of bins. The arrangement of
%   features along the trial dimension is assumed to be (1) real then
%   imaginary; (2) within that, frequency 1:nFreqs; (3) and then bins
%   1:nBins within frequency. The size of dimension 1 (the feature 
%   dimension) is thus nFreqs * 2 * nBins.
%
% OPTIONAL INPUT
% - nFreqs: How many frequencies are included in the input data matrix
%   must be defined
% 
% NOTE that nFreqs is never entered by the user, but is rather computed 
%   based on nBins and the size of the input data matrix. 
%
% OUTPUTS
% - binData: A feature x electrode x bin matrix. Once the third dimension
%   of the matrix represents single bins (not bins concatenated into
%   trials), the size of the first (feature) dimension is nFreqs * 2.
%
% This function can be called in a cellfun call to rearrange all elements 
%   of a cell array of 3D input-to-RCA matrices.

% clear all; close all; clc
% 
% nFreqs = 3; nb = 10; ntr = 10; nch = 128;
% trialData = rand([nFreqs * 2 * nb, nch, ntr]); % 60 x 128 x 10
%%
% if nargin < 2 || isempty(nBins)
%    warning('Input nBins not specified. Setting nBins to 10');
%    nBins = 10;
% end

    [nFeature, nElectrode, nTrial] = size(trialData);

    nBins = (nFeature / 2) / nFreqs;
    %%

    % Initialize the output data matrix
    binData = nan([nFreqs * 2, nElectrode, nTrial * nBins]);
    assert(numel(trialData) == numel(binData), 'Mismatched input and output data sizes.')

    % tic
    % Outer loop: Iterate through the trials
    for t = 1:nTrial
   
        % Inner loop: Iterate through the bins
        for b = 1:nBins
        
            % Dim 3 idx of current single-bin output
            outIdx = (t - 1) * nBins + b;
        
            % Move the current nFreq*2 x channel matrix to the output
            binData(:, :, outIdx) = squeeze(trialData(b:nBins:end, :, t));
        end
    end
% toc

