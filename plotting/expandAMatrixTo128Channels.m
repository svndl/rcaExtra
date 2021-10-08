function A128 = expandAMatrixTo128Channels(A, montage, initOut)
% A128 = expandAMatrixTo128Channels(A, montage, initOut)
% ------------------------------------------------------------------
% Creator: Blair Kaneshiro (May 2021)
% Maintainer: Blair Kaneshiro
%
% This function takes in the RCA weight forward-model projection matrix A,
% computed from a reduced montage, and adds NaNs or zeros so that the
% output matrix with 128 spatial entries so that the result can be plotted
% using the plotOnEgi function.
%
% INPUTS (required)
% - A: Matrix of size space x component.
%
% INPUTS (optional)
% - montage: String specifying the montage of the input matrix A. If not
%   entered or empty, the function will print a warning and assign a best
%   guess based on the size of the space dimension of input A.
% - initOut [0, NaN]: What to initiate the output matrix with. If not
%   entered or empty, the function will print a warning and set to 0.
%
% OUTPUT
% - A128: Expanded A matrix of size 128 x component. Entries of the
%   input A matrix have been assigned to the proper rows of the output, and
%   the remaining rows are NaN. This matrix can be passed into the
%   plotOnEGI matrix.
%
% IMPROVEMENTS
% - Instead of string label of montage, allow user to specify vector of
%   values?

%% Preloaded input montages

%%% Wearables DSI-VR300
% https://wearablesensing.com/wp-content/uploads/2018/07/Wearable-Sensing-DSI-VR300-Specifications_2018.pdf
% Fz, Pz, P3, P4, PO7, PO8, Oz
montage_wearablesDSIVR300 = [11 62 52 92 65 90 75];

%% Input data checks

% Make sure A matrix was input
assert(nargin >= 1, ['The function requires at least one input ' ...
    '(forward-model projection matrix A).'])

% If second input is missing, assign default and print warning.
if nargin < 2 || isempty(montage)
    % LATER: Switch based on number of rows of A
    warning(['Input ''montage'' not specified. Setting to ''dsivr300'' ' ...
        '(' mat2str(montage_wearablesDSIVR300) ').'])
    montage = montage_wearablesDSIVR300;
end

% If second input is missing, assign default and print warning.
if nargin < 3 || isempty(initOut)
    initOut = 0;
    warning('Input ''initOut'' not specified. Setting values of unused electrodes in output matrix to 0.')
end

% Make sure the initOut input is NaN or 0
assert(isnan(initOut) || isequal(initOut, 0), ...
    'Input ''initOut'' must be NaN or 0.');

%% Get correct montage and fill in output variable

% Get correct montage
if isnumeric(montage)
    %     disp(['Read montage array ' mat2str(montage) '.'])
    outChan = montage;
else
    switch montage
        case 'dsivr300'
            disp(['Read montage string ''dsivr300''.'])
            outChan = montage_wearablesDSIVR300;
        otherwise
            error('Montage not recognized!')
    end
end

% Initiate output variable
nComp = size(A, 2);
if isnan(initOut) A128 = nan(128, nComp);
else A128 = zeros(128, nComp); end

% Fill in output variable with input data at specified electrode locations
A128(outChan,:) = A;