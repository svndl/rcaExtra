function results = rcaExtra_HTSquared_d(xyData, varargin)
    % Syntax: [results] = tSquaredFourierCoefs(xyData,testMu,alphaVal)
    %
    % Returns the results of running Hotelling's t-squared test that the mean
    % of the 2D data in xyData is the same as the mean specified in testMu at
    % the specified alphaVal (0-1).
    %
    % Based on Anderson (1984) An Introduction to Multivariate Statistical 
    % Analysis, Wiley
    %
    % In:
    %   xyData - n x 2 x q matrix containing n data samples
    %            if q = 1, data will be tested against zero    
    %            if q = 2, a paired t-test will be performed,
    %            testing xyData(:,:,1) against xyData(:,:,2). 
    %            2 is the maximum length of the third dimension. 
    %            Function assumes that the 2D data in xyData(:,:,1)
    %            and the optional xyData(:,:,2) are Fourier 
    %            coefficients organized with  the real coefficients 
    %            in the 1st column and the imaginary
    %            coefficients in the 2nd column. Rows = samples.
    % 
    % <options>:
    %   testMu - 2-element vector specifying the mean to test against ([0,0]) 
    % 
    %   alphaVal - scalar indicating the alpha value for testing ([0.05])
    %
    %   pdStyle - do PowerDiva style testing (true/[false])
    %
    % Out:
    %
    %   results - struct containing the following fields:
    %             alpha, tSqrdCritical, tSqrd, pVal, H (0 if can't reject null; 1 if
    %             rejected the null hypothesis)

    opt	= ParseArgs(varargin,...
        'testMu'		, [0,0], ...
        'alphaVal'		, 0.05	, ...
        'pdStyle',        false ...
        );

    dims = size(xyData);
    if dims(1) < 2
        error('input data must contain at least 2 samples');
    end
    if dims(2) ~= 2
        error('input data must be a matrix of 2D row samples');
    end
    if length(dims) < 3 % if no third dimension
        xyData(:,:,2) = zeros(size(xyData));
    elseif dims(3) > 2
         error('length of third dimension of input data may not exceed two')
    else
    end

    if length(opt.testMu) ~= 2
        error('testMu should be a 2D vector');
    end

    xyData = xyData(:,:,1) - xyData(:,:,2);
    
    % remove NaNs
    xyData = xyData(~any(isnan(xyData),2),:);
    
    N = size(xyData,1);
    
    try
        [sampMu, sampCovMat, ~, smaller_eigenval, ~, larger_eigenval, ~] ...
            = eigFourierCoefs(xyData);
    catch
        fprintf('The covariance matrix of xyData could not be calculated, probably your data do not contain >1 sample.');
    end
    

    results.alpha = opt.alphaVal;
    
    %decide on tSquared or tCirc (Baker 2021)
    CI = sqrt(max(larger_eigenval)/min(smaller_eigenval));
    CI_list = 1:0.001:100;

    pdffunction = ((N - 2).*(2.^(N - 2))) .* ((CI_list.^2 - 1)./((CI_list.^2 + 1).^(N - 1))) .* (CI_list.^(N - 3));
    cdfinverse = 1 - (cumsum(pdffunction)./sum(pdffunction));
    %CI_crit = min(CI_list(find(cdfinverse<alpha)));

    pval = 0;
    CI_sig = 0;
    indices = find(CI_list >= CI);
    if (~isempty(indices))
        pval = cdfinverse(indices(1));
        CI_sig = pval < results.alpha;            
    end
    useTCirc = 1;
    if (CI_sig > 0)
        useTCirc = 0;
    end
    
    if opt.pdStyle
        sampCovMat = eye(2);
    else
    end
    
    if (~useTCirc)
        fprintf('Dependent T2Hotelling using T2 with CI %f \n', CI);
        % Eqn. 2 in Sec. 5.3 of Anderson (1984):
        t0Sqrd = ((N - 1)*2)/(N - 2) * finv(1 - opt.alphaVal, 2, N - 2); 
        results.tSqrdCritical = t0Sqrd;
    
        p = 2; % number of variables
        df1 = p;  %Numerator degrees of freedom.
        df2 = N - p;  %Denominator degrees of freedom.
        try
            % Eqn. 2 of Sec. 5.1 of Anderson (1984):
            tSqrd = N * (sampMu - opt.testMu) * (sampCovMat \ (sampMu - opt.testMu)'); 

            tSqrdF = (N-p)/(p*(N-1)) * tSqrd; % F approximation 
            pVal = 1 - fcdf(tSqrdF, df1, df2);  % compute p-value

            results.tSqrd = tSqrd;
            results.Fratio = tSqrdF;
            results.pVal = pVal;
            results.H = tSqrd >= results.tSqrdCritical;
            results.df1 = df1;
            results.df2 = df2;
            results.testAmp = abs(complex(sampMu(1),sampMu(2)));
        catch
            fprintf('inverse of the sample covariance matrix could not be computed.')
        end
    else
        fprintf('Dependent T2Hotelling using T2 using TCirc with CI %f \n', CI);        
        [pVal, stdDev, pT2, pChi] = tcirc(complex(xyData(:, 1), xyData(:, 2)));
        results.Fratio = pChi;
        results.pVal = pVal;
        results.H = (pVal <= results.alpha);        
    end    
end

