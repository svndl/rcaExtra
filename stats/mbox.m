function [sig_diff, pVal] = mbox(data1, data2, alphaVal)
    n1 = size(data1, 1);
    n2 = size(data2, 1);
    
    S1 = cov(data1);
    S2 = cov(data2);
    
    p = size(data1, 2); % number of columns
    g = 2; % number of groups
    
    S12 = ((n1 - 1)*S1 + (n2 - 1)*S2)/(n1 - 1 + n2 - 1);
    Fstat = (n1 - 1)*log(det(S1)) + (n2 - 1)*log(det(S2));
    MB = (n1 - 1 + n2 - 1)*log(det(S12)) - Fstat;
    
    sum1 = 1/(n1 - 1) + 1/(n2 - 1);
    sum2 = 1/((n1 - 1)^2) + 1/((n2 - 1)^2);
    
    % F-test or Chi-test approx depending on sample size
    bw_cutoff = 20;
    useApprox = 'Chi2';
    if (n1 > bw_cutoff) || (n2 > bw_cutoff)
        useApprox = 'F';
    end
    
    % correction factor.
    cFactor = (( (2*p^2)+ 3*p - 1)/(6*(p + 1)*(g - 1)))*(sum1 - 1/(n1 - 1 + n2 - 1));
     
    switch useApprox
        case 'Chi2'
            % Chi-square approximation
            X2 = MB*(1 - cFactor);
            v = (p*(p + 1)*(g - 1))/2; % degrees of freedom
            pVal = 1 - chi2cdf(X2, v);
        case 'F'
            C0 = (sum2 - 1/(n1 - 1 + n2 - 1)^2)*(p - 1)*(p + 2)/(6*(g - 1));
            cDiff = C0 - cFactor^2;
            v1 = p*(p + 1)*(g - 1)/2;%Numerator degrees of freedom.
            if ( cDiff >= 0)
                  
                v21 = fix((v1 + 2)/cDiff);  %Denominator degrees of freedom.
                Fstat = MB*(1 - cFactor - (v1/v21))/v1;  %F approximation.
                pVal = 1 - fcdf(Fstat, v1, v21);  %Significance value associated to the observed F statistic.
            else
                v22 = fix(-(v1 + 2)/cDiff);  %Denominator degrees of freedom.
                b = v22/(1 - cFactor - 2/v22);
                Fstat = (v22* MB)/(v1 * (b - MB));  %F approximation.
                pVal = 1 - fcdf(Fstat, v1, v22);  %Significance value associated to the observed F statistic.
            end
    end
    
    sig_diff = 0;
    if pVal < alphaVal
        sig_diff = 1;
    end
end