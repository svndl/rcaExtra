function setAxisAtTheOrigin_cell(axisCell)
    for nax = 1:numel(axisCell)
        setAxisAtTheOrigin(axisCell{nax});
    end
end
