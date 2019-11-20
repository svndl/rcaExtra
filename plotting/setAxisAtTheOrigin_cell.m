function setAxisAtTheOrigin_cell(axisCell)
% Alexandra Yakovleva, Stanford University 2012-2020

% Center axis for a cell array of handles 

    for nax = 1:numel(axisCell)
        setAxisAtTheOrigin(axisCell{nax});
    end
end
