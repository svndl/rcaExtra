function [corr_list, flip_list] = rcaExtra_adjustRCSigns(rcResult)
% Function computes signs of RC components in a way that mimimizes the difference between
% source data and reconstructed RC signal

% Alexandra Yakovleva, Stanford University 2020

    % combine source data across trials and conditions
    switch rcResult.rcaSettings.domain
        case 'time'
            sensor_data = cat(3, rcResult.sourceData{:});
            rca_data = cat(3, rcResult.projectedData{:});            
            sensor_data_avg = nanmean(sensor_data, 3);
            rca_data_avg = nanmean(rca_data, 3);
            % take mean across subjects, then root mean squared
           
            %sensor_rms = rms(nanmean(sensor_data, 3), 1);
            %[~, sort_idx] = sort(sum(sensor_rms, 1), 'descend');

        case 'freq'
            %if (~isfield(rcResult));
            rca_data_avg = mean(rcResult.projAvg.amp, 3);
            [sensorAvg, ~]  = averageFrequencyData(rcResult.sourceData, ...
                numel(rcResult.rcaSettings.binsToUse),...
                numel(rcResult.rcaSettings.freqsToUse));
            sensor_data_avg = mean(sensorAvg.amp, 3);
%             [~, sort_idx] = sort(sum(vector_mu, 1), 'descend');      
%         otherwise
    end
    sensor_sum = sum(sensor_data_avg, 2); 
    
    n_comp = rcResult.rcaSettings.nComp;
    outcomes_all = logical(dec2bin(0:2^n_comp - 1) - '0');
    nComb = size(outcomes_all, 1);

    % cut in half due to symmetry 
    outcomes = outcomes_all(round(1:0.5*nComb), :);
    
    temp_corr = zeros(nComb, 1);
    for c = 1:size(outcomes, 1)
        temp_rca = rca_data_avg;
        temp_rca(:, outcomes(c,:)) = rca_data_avg(:, outcomes(c,:))*-1;
        temp_sum = nansum(temp_rca, 2);
        temp_corr(c) = corr(temp_sum(:), sensor_sum(:));
    end
    [corr_list, corr_idx] = sort(temp_corr, 'descend');
    flip_list = outcomes(corr_idx, :);
end