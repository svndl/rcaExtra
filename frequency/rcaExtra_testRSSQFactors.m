function [t, pValue] = rcaExtra_testRSSQFactors(rssq1, w1, rssq2, w2)
    % function will compute pairwise  RSS Statistics between two datasets
    % representing two distinct factors

    % INPUT 
    % rssq1, rssq2 calculated RSSQ matrices nSubjects x nConditions in a factor) x nRCs
    % w1, w2 assossiated weights nSubjects x nConditions (# of valid entries for each factor)  
    
    % for each subject, compute weighted mean across conditions for the same
    % factor
    
    [nSubjs, nCnds, nComps] = size(rssq1);
    wmean_factor_diff = zeros(nSubjs, 1);
    weights_factor = zeros(nSubjs, 1);
    max_weight = max([w1(:); w2(:)]);
    population_wmean = zeros(nComps, 1);
    population_wstd = zeros(nComps, 1);
    rc = {};
    factor_diff = [];
    figure;
    for ncp = 1:nComps
        %for each component, compute weighted mean distribution
        for ns = 1:nSubjs
            weights_factor(ns) = sum(w1(ns, :) +  w2(ns, :));
            
                wmean_factor_diff(ns) = ...
                wmean(rssq1(ns, :, ncp), w1(ns, :)) - ...
                wmean(rssq2(ns, :, ncp), w2(ns, :)); 
        end
        rc = cat(1, rc, repmat({strcat('RC ', num2str(ncp))}, [nSubjs 1]));
        factor_diff = cat(1, factor_diff, wmean_factor_diff);
        % weighted mean and standard deviation
        population_wmean(ncp) = wmean(wmean_factor_diff, weights_factor/(max_weight*nCnds*2));
        population_wstd(ncp) = std(wmean_factor_diff, weights_factor/(max_weight*nCnds*2));
        
    end
    violinplot(factor_diff, rc); hold on;
    t = population_wmean./(population_wstd./sqrt(nSubjs));
    
    df = nSubjs;
    pValue = betainc(df./(df + t.^2), df/2, 0.5);     
    % acquire weighted    
end