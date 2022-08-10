function subj = projectSubjData(amp, phase, eAP, pVal)
% Alexandra Yakovleva, Stanford University 2012-2020.

    nCnd = size(amp, 1);    
    for c = 1:nCnd
        subj.amp(:, :, c, :) = (cat(3, amp{c, :}));
        subj.phase(:, :, c, :) = (cat(3, phase{c, :}));
        % subj Err is transposed
        subj.err(:, :, c, :) = (cat(3, eAP{:, c}));
        subj.pVal(:, :, c, :) = (cat(3, pVal{:, c}));
    end
end