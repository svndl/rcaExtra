function A = my_repelem(A, varargin)
% Alexandra Yakovleva, Stanford University 2012-2020

% duplicates the functionality of Matlab's repelem

  index = cell(1, nargin-1);
  for iDim = 1:nargin-1
    lens = varargin{iDim};
    if isscalar(lens)
      if (lens == 1)
        index{iDim} = ':';
        continue
      else
        lens = repmat(lens, 1, size(A, iDim));
      end
    end
    vals = 1:size(A, iDim);
    clens = cumsum(lens);
    index{iDim} = zeros(1, clens(end));
    index{iDim}([1 clens(1:end-1)+1]) = diff([0 vals]);
    index{iDim} = cumsum(index{iDim});
  end
  A = A(index{:});

end
