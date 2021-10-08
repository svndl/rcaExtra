function proj = projectProjDataSweep(amp, phase, errA, errP)
% frequencies x channels (components) x conditions
% Alexandra Yakovleva, Stanford University 2012-1020
% LLV modified for sweeps

proj.amp = cat(4, amp{:});
proj.phase = cat(4, phase{:});

proj.errA = permute(cat(5, errA{:}), [1 2 3 5 4]);
proj.errP = permute(cat(5, errP{:}), [1 2 3 5 4]);
end

% from: projectSubjectAmplitudesSweep
% LOOKS LIKE I FORGOT TO ADAPT THIS FOR SWEEPS
% % [nBin nF nRcs nSubj nCnd]
% permute to move subj dims in last place
% projectedSubj.amp = permute(projectedAmp, [1 2 3 5 4]);