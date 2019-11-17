function out = unwrapPhases(values)
    out = values;
    for c = 1:size(values, 2)
        %2f
        while (values(2, c)<values(1, c))
            values(2, c) = values(2, c) + 2*pi;
        end
        % 3f
        while (values(3, c)<values(2, c))
            values(3, c) = values(3, c) + 2*pi;
        end
        %4f    
        while (values(4, c) < values(3, c))
            values(4, c) = values(4, c) + 2*pi;
        end

        if(values(4, c) - values(3, c) < pi/2)
            values(4, c) = values(4, c) + 2*pi;
        end
    end
end

