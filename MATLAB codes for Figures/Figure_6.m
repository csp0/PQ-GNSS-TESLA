% ---------------------------------------------------------
% PQ-GNSS-TESLA: Absolute Physical Attack Time Bounds
% Pre-Quantum vs Post-Quantum (Bandwidth-Optimized Symmetric Margins)
% ---------------------------------------------------------

% 1. Parameter Settings
n = 60:200;                  % Cryptographic Key Length (bits)
t_ASIC = 2^-57;              % ASIC hash evaluation time (seconds)
sec_per_day = 86400;         % Seconds in a day

% 2. Calculate Attack Times (in Seconds, then converted to Days)
% Pre-Quantum: T_PR = 2^n * t_ASIC
T_PR_days = (2.^n * t_ASIC) / sec_per_day;

% Post-Quantum (Worst-case d=1): T_PQ = 2^(n/2) * t_ASIC
T_PQ_days = (2.^(n/2) * t_ASIC) / sec_per_day;

% 3. Plotting the results
figure('Color', 'w', 'Position', [100, 100, 750, 550]);

% Apply logarithmic scale to Y-axis
semilogy(n, T_PR_days, '-b', 'LineWidth', 2, 'DisplayName', 'Pre-Quantum Time ({\it T_{PR}})');
hold on;
semilogy(n, T_PQ_days, '--r', 'LineWidth', 2, 'DisplayName', 'Post-Quantum Time ({\it T_{PQ}}, {\it d}=1)');

% 4. Add Threshold and Margin Lines
% Threshold: 1 Day (24 hours) - The active chain lifetime
yline(1, 'k:', 'LineWidth', 1.5, 'HandleVisibility', 'off');

% Robust Margin: 97 Days (2^23 seconds)
margin_days = (2^23) / sec_per_day; % Approx 97.09 days
yline(margin_days, '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 1, 'HandleVisibility', 'off');

% 5. Highlight the Intersection Points (10^0 / 1 Day Threshold)
% Place text below the horizontal line and to the right of the diagonal line
plot(73.4, 1, 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'w', 'LineWidth', 1.5, 'HandleVisibility', 'off');
text(74.5, 0.6, '{\it n} = 73.4 bits', 'FontSize', 11, 'FontName', 'Times New Roman', ...
    'Color', 'b', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');

plot(146.8, 1, 'rs', 'MarkerSize', 8, 'MarkerFaceColor', 'w', 'LineWidth', 1.5, 'HandleVisibility', 'off');
text(148.5, 0.6, '{\it n} = 146.8 bits', 'FontSize', 11, 'FontName', 'Times New Roman', ...
    'Color', 'r', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');

% 6. Highlight the Symmetric Optimal Margin Points (10^2 / 97 Days)
% Place text below the horizontal line and to the right of the diagonal line (same placement logic)
plot(80, margin_days, 'bo', 'MarkerSize', 9, 'MarkerFaceColor', 'w', 'LineWidth', 1.5, 'HandleVisibility', 'off');
text(81.5, margin_days * 0.6, '{\it n} = 80 bits', 'FontSize', 12, 'FontName', 'Times New Roman', ...
    'Color', 'b', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');

plot(160, margin_days, 'rs', 'MarkerSize', 9, 'MarkerFaceColor', 'w', 'LineWidth', 1.5, 'HandleVisibility', 'off');
text(161.5, margin_days * 0.6, '{\it n} = 160 bits', 'FontSize', 12, 'FontName', 'Times New Roman', ...
    'Color', 'r', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');

% 7. Formatting for Academic Paper
grid off; % [Modified] Remove grid for a perfectly clean white background
set(gca, 'Color', 'w'); % Explicitly set the axis background color to white
box on;
set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');

% X-axis Configuration
xlim([60, 200]);
xticks(60:20:200);
xlabel('Cryptographic Key Length, {\it n} (bits)', 'FontSize', 14, 'FontWeight', 'bold');

% Y-axis Configuration
ylim([10^-4, 10^10]);
yticks(10.^(-4:2:10));
ylabel('Absolute Attack Time (Days) - Log Scale', 'FontSize', 14, 'FontWeight', 'bold');
title('Pre/Post-Quantum Attack Time vs. Truncated Key Lengths', 'FontSize', 14);

% Adding Text Annotations for the Lines directly on the plot
% Place the line description text 'above' the line to avoid overlapping with the bit length labels below
text(62, margin_days * 1.3, 'Robust Security Margin (97 Days)', ...
    'FontSize', 11, 'FontName', 'Times New Roman', 'Color', [0.4 0.4 0.4], ...
    'VerticalAlignment', 'bottom');
text(62, 1.3, 'Chain Expiry Threshold (1 Day / 24 Hours)', ...
    'FontSize', 11, 'FontName', 'Times New Roman', 'Color', 'k', ...
    'VerticalAlignment', 'bottom');

% Legend
legend('Location', 'northwest', 'FontSize', 12, 'FontName', 'Times New Roman');
hold off;