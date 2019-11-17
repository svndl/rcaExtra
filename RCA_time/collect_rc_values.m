function [out_rc, out_oz]= collect_rc_values(cellGroup, rcIndex)
    
    nStructs = numel(cellGroup);
    out_rc.inc = zeros(size(cellGroup{1}.inc.rc, 1), nStructs);
    out_rc.dec = out_rc.inc;
    out_rc.pol = out_rc.inc;
    
    out_oz.inc = out_rc.inc;
    out_oz.dec = out_rc.inc;
    out_oz.pol = out_rc.inc;
    for ns = 1:nStructs
        try
            out_rc.inc(:, ns) = sign(rcIndex(ns))*cellGroup{ns}.inc.rc(:, abs(rcIndex(ns)));
            out_rc.dec(:, ns) = sign(rcIndex(ns))*cellGroup{ns}.dec.rc(:, abs(rcIndex(ns)));
            out_rc.pol(:, ns) = sign(rcIndex(ns))*cellGroup{ns}.pol.rc(:, abs(rcIndex(ns)));
            
        catch err
            out_rc.inc(:, ns) = cellGroup{ns}.inc.rc(:, 1);
            out_rc.dec(:, ns) = cellGroup{ns}.dec.rc(:, 1);
            out_rc.pol(:, ns) = cellGroup{ns}.pol.rc(:, 1);
            
            
        end
        out_oz.inc(:, ns) = cellGroup{ns}.inc.oz;
        out_oz.dec(:, ns) = cellGroup{ns}.dec.oz;
        out_oz.pol(:, ns) = cellGroup{ns}.pol.oz;
        
    end
end