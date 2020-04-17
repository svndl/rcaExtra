function out = unwrapPhases(values)
    out = values;
    for c = 1:size(values, 2)
        %2f
        while (out(2, c)<out(1, c))
            out(2, c) = out(2, c) + 2*pi;
        end
        % 3f
        while (out(3, c)<out(2, c))
            out(3, c) = out(3, c) + 2*pi;
        end
        %4f    
        while (out(4, c) < out(3, c))
            out(4, c) = out(4, c) + 2*pi;
        end

        if(out(4, c) - out(3, c) < pi/2)
            out(4, c) = out(4, c) + 2*pi;
        end
    end
    
end

