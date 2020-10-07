function projectedSubj = projectSubjectAmplitudes(proj)
% vector projection of subject data onto project's average data

    % concatenate subjects's real/imaginary data
    
    [nSubj, nCnd] = size(proj.subjsRe);    
    subjAvgReal = cat(4, proj.subjsRe{:});
    subjAvgImag = cat(4, proj.subjsIm{:});
    [nF, nRcs, ~, ~] = size(subjAvgReal);
    
    subjAvgReal = reshape(subjAvgReal, [nF nRcs nCnd nSubj]);
    subjAvgImag = reshape(subjAvgImag, [nF nRcs nCnd nSubj]);
    
    % subjMean has two fields, each nF x nComponents n nConditions x nSubjects
    
    projectedRe = zeros(size(subjAvgReal));
    projectedIm = zeros(size(subjAvgImag));
    projectedAmp = zeros(size(subjAvgImag));
    projectedPhase = zeros(size(subjAvgImag));
    
    % for each harmonic multiple 
    for f = 1:nF
        % for each rc
        for rc = 1:nRcs
            % for each condition
            for c = 1:nCnd
                % select real and imaginary data from each subset
                real_in = squeeze(subjAvgReal(f, rc, c, :));
                imag_in = squeeze(subjAvgImag(f, rc, c, :));
                % concatenate and remove NaNs
                
                xyData = cat(2, real_in, imag_in);
                not_nan = ~any(isnan(xyData), 2);
                xyData = xyData(not_nan, :);
                
                % extract project-level average and replicate for the
                % number of subjects
                avgReIm = cat(2, proj.avgRe(f, rc, c), proj.avgIm(f, rc, c));
                xyMean = repmat(avgReIm, [nSubj 1]);
                
                % compute projection 
                lenC = dot(xyData, xyMean, 2) ./ sum(xyMean .* xyMean, 2);
                % apply projection
                xyOut = bsxfun(@times, lenC, xyMean);
                
                % recompute real and imaginary data 
                projectedRe(f, rc, c, :) = xyOut(:, 1);
                projectedIm(f, rc, c, :) = xyOut(:, 2);
                % compute amp and phase
                projectedAmp(f, rc, c, :) = sign(lenC).*sqrt(xyOut(:, 1).^2 + xyOut(:, 2).^2);
                projectedPhase(f, rc, c, :) =  angle(complex(xyOut(:, 1), xyOut(:, 2)));
            end
        end
    end
    % reshape to match subj dims
    
    projectedSubj.amp = projectedAmp;
    projectedSubj.phase = projectedPhase;
    projectedSubj.subjRe = projectedRe;
    projectedSubj.subjIm = projectedIm;
    
end

