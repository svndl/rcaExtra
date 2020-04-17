function subj = projectSubjData(amp, phase, eAP)
% Alexandra Yakovleva, Stanford University 2012-2020.

    nCnd = size(amp, 1);    
    for c = 1:nCnd
        subj.amp(:, :, :, c) = (cat(3, amp{c, :}));
        subj.phase(:, :, :, c) = (cat(3, phase{c, :}));
        subj.err(:, :, :, c) = (cat(3, eAP{c, :}));
    end
end