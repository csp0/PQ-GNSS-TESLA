
% =========================================================================
% PQ-GNSS-TESLA: TTFAF Statistical Bar Chart
% =========================================================================
clc; clear; close all;
fprintf('=== Starting Scenario 2: Statistical Bar Chart Simulation ===\n');

% 1. Simulation Parameters
N_trials = 100000;          % Number of Monte Carlo trials
T_frame = 18;               % Length of one frame (seconds)
T_epoch = 90;               % Length of one epoch (5 frames, 90 seconds)

% Case 1: Standard GPS L1C (Baseline TTFF)
t_wait_1 = rand(1, N_trials) * T_frame;  
ttff_case1 = t_wait_1 + (8 * T_frame);

% Case 2: GPS Chimera (Legacy Authentication TTFAF)
t_wait_2 = rand(1, N_trials) * T_frame;
ttff_base_2 = t_wait_2 + (8 * T_frame);
sig_wait_2 = rand(1, N_trials) * 900;    % 15-minute signature broadcast cycle
ttfaf_case2 = max(ttff_base_2, sig_wait_2);

% Case 3: Proposed PQ-GNSS-TESLA (Primary Mode, OOB-assisted)
ttfaf_case3 = zeros(1, N_trials);
t_start_3 = rand(1, N_trials) * T_epoch; 

for i = 1:N_trials
    wait_f = T_frame - mod(t_start_3(i), T_frame);
    curr_f = floor(t_start_3(i) / T_frame) + 1;
    valid_frames = 0; mac_received = false; rx_time = 0;
    
    while valid_frames < 8 || ~mac_received
        if curr_f == 5
            mac_received = true; 
        else
            valid_frames = valid_frames + 1; 
        end
        rx_time = rx_time + T_frame;
        curr_f = mod(curr_f, 5) + 1; 
    end
    ttfaf_case3(i) = wait_f + rx_time;
end

% Case 4: Proposed PQ-GNSS-TESLA (Fallback Mode, SiS-only)
t_wait_4 = rand(1, N_trials) * T_frame;
ttfaf_case4 = t_wait_4 + 1800; % 30-minute self-recovery cycle

% =========================================================================
% 2. Statistical Computations (Mean, Min, Max)
% =========================================================================
data_means = [mean(ttff_case1), mean(ttfaf_case2), mean(ttfaf_case3), mean(ttfaf_case4)];
data_mins  = [min(ttff_case1), min(ttfaf_case2), min(ttfaf_case3), min(ttfaf_case4)];
data_maxs  = [max(ttff_case1), max(ttfaf_case2), max(ttfaf_case3), max(ttfaf_case4)];

err_neg = data_means - data_mins;
err_pos = data_maxs - data_means;

% =========================================================================
% 3. Plotting the Bar Chart with Error Bars and Legend
% =========================================================================
figure('Color', 'w', 'Position', [100 100 850 550]); 
hold on; grid on;

% Define distinct colors for the cases
colors = [0.2 0.2 0.2;  % Gray (Case 1)
          0.0 0.4 0.9;  % Blue (Case 2)
          0.9 0.1 0.1;  % Red  (Case 3)
          0.8 0.2 0.8]; % Magenta (Case 4)

% Plot bars individually to create separate handles for the legend
b_handles = gobjects(1, 4);
for i = 1:4
    b_handles(i) = bar(i, data_means(i), 0.6, 'FaceColor', colors(i,:), ...
                       'EdgeColor', 'k', 'LineWidth', 1.2);
end

% Add Error Bars (Min & Max bounds)
errorbar(1:4, data_means, err_neg, err_pos, 'k', 'LineStyle', 'none', ...
         'LineWidth', 2, 'CapSize', 15);

% Formatting X and Y axes
set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');

% Expanded X-axis limit to 5.3 to make room for the text on the right
xlim([0.4 5.3]);
xticks(1:4);
xticklabels({'Case 1', 'Case 2', 'Case 3', 'Case 4'});

ylabel('Time-To-First-Authenticated-Fix (seconds)', 'FontSize', 14, 'FontWeight', 'bold');
title('Statistical TTFAF Comparison: Average with Min/Max Bounds', 'FontSize', 14, 'FontWeight', 'bold');
ylim([0 2100]);

% Create the Legend in the top-left corner
legend_labels = {'Case 1: Standard GPS L1C (Baseline)', ...
                 'Case 2: GPS Chimera (15-min Cycle)', ...
                 'Case 3: Proposed PQ-GNSS-TESLA (Primary)', ...
                 'Case 4: Proposed PQ-GNSS-TESLA (Fallback)'};
legend(b_handles, legend_labels, 'Location', 'northwest', 'FontSize', 12);

% Add Text Annotations for exact mean values on top of bars
for i = 1:4
    y_pos = data_maxs(i) + 50; 
    text(i, y_pos, sprintf('Mean: %.1f s\n[%.0f - %.0f]', data_means(i), data_mins(i), data_maxs(i)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
        'FontSize', 11, 'FontWeight', 'bold', 'Color', colors(i,:)*0.8, 'BackgroundColor', 'w');
end

