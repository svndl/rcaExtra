function subj = projectSubjDataSweep(amp, phase, eAP)
% Alexandra Yakovleva, Stanford University 2012-2020.
% modified by LLV

    nCnd = size(amp, 1);    
    for c = 1:nCnd
        % LLV fixing dimensions
        subj.amp(:, :, c, :, :) = cat(4, amp{c, :});
        subj.phase(:, :, c, :, :) = cat(4, phase{c, :});
        % subj Err is transposed
        subj.err(:, :, c, :) = (cat(4, eAP{:, c}));
    end
end