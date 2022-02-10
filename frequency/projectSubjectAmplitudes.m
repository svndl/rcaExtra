function projectedSubj = projectSubjectAmplitudes(proj)
% vector projection of subject data onto project's average data

    % concatenate subjects's real/imaginary data
    
    [nSubj, nCnd] = size(proj.subjsRe);    
    subjAvgReal = cat(4, proj.subjsRe{:});
    subjAvgImag = cat(4, proj.subjsIm{:});
    [nF, nRcs, ~, ~] = size(subjAvgReal);
    
    subjAvgReal = reshape(subjAvgReal, [nF nRcs nSubj nCnd]);
    subjAvgImag = reshape(subjAvgImag, [nF nRcs nSubj nCnd]);
    
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
                real_in = squeeze(subjAvgReal(f, rc, :, c));
                imag_in = squeeze(subjAvgImag(f, rc, :, c));
                % concatenate and remove NaNs
                
                xyData = cat(2, real_in, imag_in);
                not_nan = ~any(isnan(xyData), 2);
                xyDataValid = xyData(not_nan, :);
                
                nSubjValid = size(xyDataValid, 1);
                
                lenC = zeros(nSubj, 1);
                % extract project-level average and replicate for the
                % number of subjects
                avgReIm = cat(2, proj.avgRe(f, rc, c), proj.avgIm(f, rc, c));
                xyMean = repmat(avgReIm, [nSubj 1]);           
                % workaround  for bad subjects
                % compute projection

                if (nSubjValid < nSubj)
                    xyMeanValid = repmat(avgReIm, [nSubjValid 1]);           
                    lenC(not_nan) = dot(xyDataValid, xyMeanValid, 2) ./ sum(xyMeanValid .* xyMeanValid, 2);
                else
                    lenC = dot(xyDataValid, xyMean, 2) ./ sum(xyMean .* xyMean, 2);
                end    
                xyOut = bsxfun(@times, lenC, xyMean);     

                % apply projection
                % recompute real and imaginary data 
                projectedRe(f, rc, :, c) = xyOut(:, 1);
                projectedIm(f, rc, :, c) = xyOut(:, 2);
                % compute amp and phase
                projectedAmp(f, rc, :, c) = sign(lenC).*sqrt(xyOut(:, 1).^2 + xyOut(:, 2).^2);
                projectedPhase(f, rc, :, c) =  angle(complex(xyOut(:, 1), xyOut(:, 2)));
            end
        end
    end
    % permute to move subj dims in last place
    projectedSubj.amp = permute(projectedAmp, [1 2 4 3]);
    projectedSubj.phase = permute(projectedPhase, [1 2 4 3]);
    projectedSubj.subjRe = permute(projectedRe, [1 2 4 3]);
    projectedSubj.subjIm = permute(projectedIm, [1 2 4 3]);  
end

