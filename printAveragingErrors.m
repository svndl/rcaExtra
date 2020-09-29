function printAveragingErrors(projAveargeErr, type)

    [nF, nRCs, nC, ~]= size(projAveargeErr);
    switch type
        case 'a'
            typeErr = 'Amplitude, mV';
        case 'p'
            typeErr = 'Phase, rad';
    end
    for c = 1:nC
        fprintf('%s errors for Condition  %d \n', typeErr, c);        
        for r = 1:nRCs
            fprintf('%s errors for RC %d \n', typeErr, r);
            
            fprintf('Frequency  \tLow  \t \tHigh \n');
            
            for f = 1:nF
                
                fprintf('%dF \t \t%f \t %f \n', f, projAveargeErr(f, r, c, 1), projAveargeErr(f, r, c, 2));
            end
            fprintf('\n');
        end
    end
end