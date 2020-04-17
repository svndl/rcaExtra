%% plot individual components

function plotRCAResults_tc(rcaDataIn, tc, A)

    nComp = size(A, 2);

    catData = cat(3, rcaDataIn{:});
    muData = nanmean(catData, 3);
    muData = muData - repmat(muData(1, :), [size(muData, 1) 1]);
    semData = nanstd(catData, [], 3)/(sqrt(size(catData, 3)));

    colorbarLimits = [min(A(:)),max(A(:))];

    extremeVals = [min(A); max(A)];

    %% flip signs
    s = ones(1, nComp);
    f = ones(1, nComp);
    
    for rc = 1:nComp
        [~, f(rc)] = max(abs(extremeVals(:, rc)));
    end
    if f(1) == 1 % largest extreme value of RC1 is negative
        s(1) = -1; % flip the sign of RC1 so its largest extreme value is positive (yellow in parula)
        f(1) = 2;
    end
    for rc = 2:nComp
        if f(rc)~=f(1) % if the poles containing the maximum corr coef are different
            s(rc) = -1; % we will flip the sign of that RC's time course & thus its corr coef values (in A) too
        end
    end

    try
        for c=1:nComp
            subplot(3,nComp,c);
            plotOnEgi(s(c).*A(:,c),colorbarLimits);
            title(['RC' num2str(c)]);
            axis off;
        end
    catch
        fprintf('call to plotOnEgi() failed. Plotting electrode values in a 1D style instead.\n');
        for c=1:nComp, subplot(3,nComp,c); plot(A(:,c),'*k-'); end
        title(['RC' num2str(c)]);
    end

    try
        for c=1:nComp
            subplot(3,nComp,c+nComp);
            shadedErrorBar(tc,s(c).*muData(:,c),semData(:,c),'k');
            title(['RC' num2str(c) ' time course']);
            axis tight;
        end
    catch
        fprintf('unable to plot rc means and sems. \n');
    end
    % no access to these values outside of RCA run code
%     try
%         [~,eigs]=eig(Rxx+Ryy);
%         eigs=sort(diag(eigs),'ascend');
%         subplot(325); hold on
%         plot(eigs,'*k:');
%         nEigs=length(eigs);
%         plot(nEigs-Kout,eigs(nEigs-Kout),'*g');
%         title('Within-trial covariance spectrum');
%     catch
%         fprintf('unable to plot within-trial covariance spectrum. \n');
%     end
end
