function out_oz = collect_oz_values(cellGroup)
    
    nStructs = numel(cellGroup);
    
    for ns = 1:nStructs
        out_oz.inc(:, ns) = cellGroup{ns}.inc.oz;
        out_oz.dec(:, ns) = cellGroup{ns}.dec.oz;
    end
end