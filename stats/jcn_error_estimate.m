function null_hyp = jcn_error_estimate(sampleVector_1D)
% input: double sampleVector_1D is a vector with N elements
% output: boolean null_hyp accept(1, true) or reject (0, false)

        N = numel(sampleVector_1D);
        alpha = 0.05;
        tail = 'two';
        % two-tailed critical t-value for dF - 1 (function CritT compiled from finv table) 
        tCrit = CritT(alpha, N - 1, tail);
        
        % following Miller et al (1998), Norcia and Tyler (1984) jackknife
        % error estimate method
        
        D_i = jackknife(@mean, sampleVector_1D);
        D = mean(sampleVector_1D);
        J_ = mean(D_i);
        % compute sem of a difference
        sD = sqrt(((N - 1)/N)*sum((D_i - J_).^2));

        t_J = D/sD;
        
        % reject null hypothesis (null_hyp = 1) if tCrit < observed t_J
        % accept null hypothesis (null_hyp = 0) if tCrit >= observed t_J
        
        null_hyp = boolean(tCrit < t_J);       
end