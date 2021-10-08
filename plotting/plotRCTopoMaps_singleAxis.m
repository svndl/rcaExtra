function plotRCTopoMaps_singleAxis(axHandle, topoMaps, nRows)
nComp = size(topoMaps, 2); % LLV THIS GOES AWAY
assert(size(topoMaps, 2) == 1, 'this function plots a topo map for a single RC and condition at a time.');
% averaging RC data

% set colorbar limits across all components
colorbarLimits = [min(topoMaps(:)), max(topoMaps(:))];
extremeVals = [min(topoMaps); max(topoMaps)];

%% flip signs
s = ones(1, nComp);
%    f = ones(1, nComp);

% comment to match the components signs
%     for rc = 1:nComp
%         [~, f(rc)] = max(abs(extremeVals(:, rc)));
%     end
%     if f(1) == 1 % largest extreme value of RC1 is negative
%         s(1) = -1; % flip the sign of RC1 so its largest extreme value is positive (yellow in parula)
%         f(1) = 2;
%     end
%     for rc = 2:nComp
%         if f(rc)~=f(1) % if the poles containing the maximum corr coef are different
%             s(rc) = -1; % we will flip the sign of that RC's time course & thus its corr coef values (in A) too
%         end
%     end

% plotting topos
try
    %     gca(axHandle)
    axes(axHandle);
    %     ax = subplot(nRows, nComp, c);
    %     outerpos = ax.OuterPosition;
    %     ti = ax.TightInset;
    %     left = outerpos(1) + ti(1);
    %     bottom = outerpos(2) + ti(2);
    %     ax_width = outerpos(3) - ti(1) - ti(3);
    %     ax_height = outerpos(4) - ti(2) - ti(4);
    %     ax.Position = [left bottom ax_width ax_height];
    plotOnEgi(s.*topoMaps, colorbarLimits);
    
catch err
    fprintf('call to plotOnEgi() failed. Plotting electrode values in a 1D style instead.\n');
    disp(err);
    err.stack.name
    err.stack.line
    err.stack
end
end