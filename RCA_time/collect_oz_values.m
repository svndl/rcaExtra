function out_oz = collect_oz_values(cellGroup)
% Alexandra Yakovleva, Stanford University 2012-2020

% store OZ waveforms in a structure, on-off specific

    nStructs = numel(cellGroup);
    
    for ns = 1:nStructs
        out_oz.inc(:, ns) = cellGroup{ns}.inc.oz;
        out_oz.dec(:, ns) = cellGroup{ns}.dec.oz;
    end
end
