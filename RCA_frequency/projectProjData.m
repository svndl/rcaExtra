function proj = projectProjData(amp, phase, errA, errP)
    % frequencies x channels (components) x conditions
% Alexandra Yakovleva, Stanford University 2012-1020
    
    proj.amp = cat(3, amp{:});    
    proj.phase = cat(3, phase{:});
    
    proj.errA = permute(cat(4, errA{:}), [1 2 4 3]);
    proj.errP = permute(cat(4, errP{:}), [1 2 4 3]);    
end
