function out = unwrapPhases(values)
    out = unwrap(values);
    
    [nF, nCnd] = size(values);
    if (out(1)) < 0
        out = out +2*pi;
    end
    for c = 1:nCnd
        for f = 2:nF
            while (out(f, c) < out(f - 1, c))
                out(f, c) = out(f, c) + 2*pi;
            end
        end

        if(out(end, c) - out(end - 1, c) < pi/2)
            out(end, c) = out(end, c) + 2*pi;
        end
    end
end

