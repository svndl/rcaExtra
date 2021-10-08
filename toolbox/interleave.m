function B = interleave(dim, varargin)
% Interleave arrays along specified dimension.
% 
% Syntax
%   B = interleave(dim, A1, A2)
%   B = interleave(dim, A1, A2, A3,... An)
% 
% Description
%   B = interleave(dim, A1, A2) interleaves the arrays A1 and A2 along the
%   dimension specified by dim. The input arrays must be of the same class
%   and size, and, the dim argument must be a real, positive, integer value.  
% 
%   B = interleave(dim, A1, A2, A3,... An) interleaves all the input arrays
%   A1, A2, A3,... An, along the dimension dim.
% 
% Input arguments
%   dim - Dimension along which to interleave arrays.
%         Data type: scalar integer
%   An  - Arrays to combine.
%         Data type: numeric | char | cell | logical | categorical | table
%                    struct | datetime | timeseries
%         Size     : (any size and same for all arrays)
%   
% Output arguments
%   B   - Array of the interleaved arrays. 
%         Data type: (same as An)
%         Size     : (same as An, but the dimension dim is expanded n times)
% 
% Notes
%   This function inherits similar behaviors from the cat function, see
%   https://www.mathworks.com/help/matlab/ref/cat.html.
% 
%   If the argument dim is greater than the number of dimension of the 
%   input arrays, the output, B, is expanded to match this dimension.
%
%   If the input arrays are struct arrays, they must have the same fields.
% 
%   If the input arrays are table arrays (or timetable since R2016b), they
%   must have the same variables, and, the argument dim must always be set
%   to 1 (not 2), because it is not possible to duplicate variables.
%
%   If the input arrays are ordinal categorical arrays, they must have the
%   same sets of categories including their order.
% 
% Examples  
%   Example 1: interleave three numeric arrays with two dimensions each one
%              along the first, second and third dimensions.
%   A1 = ones(2,3)*4;
%   A2 = ones(2,3)*5;
%   A3 = ones(2,3)*6;
%   B = interleave(1, A1, A2, A3);
%   B = interleave(2, A1, A2, A3);
%   B = interleave(3, A1, A2, A3); % Notice the expansive behavior.
% 
%   Example 2: interleave three numeric arrays with three dimensions each
%              one  along the first, second and third dimensions.
%   A1 = ones(2,3,2)*4;
%   A2 = ones(2,3,2)*5;
%   A3 = ones(2,3,2)*6;
%   B = interleave(1, A1, A2, A3);
%   B = interleave(2, A1, A2, A3);
%   B = interleave(3, A1, A2, A3);
% 
%   Example 3: interleave three char arrays along the first and second
%              dimensions.
%   A1 = ['abc'; 'def'];
%   A2 = ['hij'; 'klm'];
%   A3 = ['nop'; 'qrs'];
%   B = interleave(1, A1, A2, A3);
%   B = interleave(2, A1, A2, A3);
% 
%   Example 4: interleave three cell arrays along the first and second
%              dimensions.
%   A1 = {'a', 'b'; 'c', 'd'};
%   A2 = {'h', 'i'; 'j', 'k'};
%   A3 = {'x', 'y'; 'z', 'w'};
%   B = interleave(1, A1, A2, A3);
%   B = interleave(2, A1, A2, A3);
% 
%   Example 5: interleave two categorical arrays long the first dimension.
%   A1 = categorical({'dog'; 'cat'; 'bird'});
%   A2 = categorical({'hamster'; 'fish'; 'parrot'});
%   B = interleave(1, A1, A2);
% 
%   Example 6: interleave two table arrays long the first dimension.
%   load patients
%   T = table(Gender, Smoker, Height, Weight);
%   T = sortrows(T, 'Gender', 'descend'); % Sort variable gender.
%   A1 = T(1:50,:); % Male.
%   A2 = T(51:100,:); % Female.
%   B = interleave(1, A1, A2); % Interleave genders while it is possible. 
% 
%   Example 7: interleave two struct arrays along the first and second
%              dimension.
%   load patients
%   T = table(Gender, Smoker, Height, Weight);
%   T = sortrows(T, 'Gender', 'descend'); % Sort variable gender.
%   A1 = table2struct(T(1:50,:)); % Male.
%   A2 = table2struct(T(51:100,:)); % Female.
%   B = interleave(1, A1, A2); % Interleave genders similar to the previous
%                              % example.
%   B = interleave(2, A1, A2); % Notice the similar behavior of the cat
%                              % function cat(2,A1,A2).
%
% Copyright 2017 Brayan Torres Zagastizabal 
% brayantz_13@hotmail.com
% Check classes and sizes.
narginchk(2, Inf)
if nargin > 2
    classes = cellfun(@(x) class(x), varargin, 'UniformOutput', false);
    if ~isequal(classes{:})
        error([mfilename ':classMismatch'],...
              'Input arrays must be of the same class.')
    end
end
sizeArray = cellfun(@(x) size(x), varargin, 'UniformOutput', false);
if nargin > 2
    if ~isequal(sizeArray{:})
        error([mfilename ':sizeMismatch'],...
              'All of the input arrays must be of the same size.')
    end
end
% interleave arrays.
indexArray = arrayfun(@(x) 1:x, sizeArray{1}, 'UniformOutput', false);
C = cat(dim, varargin{:});
dimLength = size(C, dim);
nArrays = length(varargin);
dimIndex = reshape(1:dimLength, [], nArrays)';
indexArray{dim} = dimIndex(:);
B = C(indexArray{:});
end