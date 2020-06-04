function dataOut = rcaExtra_adjustRCSigns(rcResults, rcSettings)
% Function computes signs of RC components in a way that mimimizes the difference between
% source data and reconstructed RC signal

% Alexandra Yakovleva, Stanford University 2020

    % combine source data across trials and conditions
    nConditions = size(rcResults.sourceData, 2);
    sensor_data = [];
    rca_data = [];
    switch rcSettings.domain
        case 'time'
            sensor_data = cat(3, rcResults.sourceData{:});
            rca_data = cat(3, rcResults.rcDataProjected{:});
            
    
            % take mean across subjects, then root mean squared
            sensor_rms = rms(nanmean(sensor_data, 3), 1);
            [~, sort_idx] = sort(sum(sensor_rms, 1), 'descend');

        case 'freq'
%             bin_idx = repmat(bin_idx == input(1).settings.binIndices, 2, 1);
%             comp_idx = contains(input(1).settings.compLabels, 'rc');
%             for h = 1:length(harm_idx)
%                 % average over trials 
%                 input(harm_idx(h)).input_data = cellfun(@(x) nanmean(x,3), input(harm_idx(h)).input_data, 'uni', false);
%                 input(harm_idx(h)).rca_data = cellfun(@(x) nanmean(x,3), input(harm_idx(h)).rca_data, 'uni', false);
%                 for c = 1:length(cond_idx)
%                     cur_sensor = cell2mat(permute(input(harm_idx(h)).input_data(cond_idx(c),:), [1,3,2]));
%                     cur_sensor = cur_sensor(bin_idx, :, :);
%                     sensor_data = cat(1, sensor_data, cur_sensor);
%                     cur_rca = cell2mat(permute(input(harm_idx(h)).rca_data(cond_idx(c),:), [1,3,2]));
%                     cur_rca = cur_rca(bin_idx, :, :);
%                     rca_data = cat(1, rca_data,  cur_rca);
%                 end
%             end
%             % don't include comparison channel 
%             % in rca_data to use for correlation
%             rca_data = rca_data(:,comp_idx,:);
%         
%             % select most responsive electrodes
%             n_idx = length(harm_idx)*length(cond_idx);
%             real_mu = nanmean(sensor_data(1:n_idx,:, :),3);
%             imag_mu = nanmean(sensor_data(n_idx+1:end,:, :),3);
%             vector_mu = sqrt(real_mu.^2+imag_mu.^2);
%             [~, sort_idx] = sort(sum(vector_mu,1), 'descend');      
%         otherwise
    end
    sensor_data_avg = nanmean(sensor_data, 3);
    rca_data_avg = nanmean(rca_data, 3);
    
    sensor_sum = sum(sensor_data_avg, 2);
    
    flip_idx = zeros(1, size(rca_data, 2));
    
    n_comp = size(rca_data, 2);
    outcomes = logical(dec2bin(0:2^n_comp - 1) - '0');
    
    for c = 1:size(outcomes, 1)
        temp_rca = rca_data_avg;
        temp_rca(:, outcomes(c,:)) = rca_data_avg(:, outcomes(c,:))*-1;
        temp_sum = nansum(temp_rca, 2);
        temp_corr(c) = corr(temp_sum(:), sensor_sum(:));
    end
    [corr_list, corr_idx] = sort(temp_corr, 'descend');
    flip_list = outcomes(corr_idx, :);
    
end