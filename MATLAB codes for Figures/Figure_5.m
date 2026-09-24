
% ---------------------------------------------------------
% PQ-GNSS-TESLA: Minimum Pre-Quantum Key Length Evaluation
% Highlighting specific chain lengths with custom vertical lines
% ---------------------------------------------------------

% 1. Parameter Settings
T_epoch = 90; % Duration of one TESLA epoch (seconds)

% Continuous data for smooth lines
N_plot = logspace(2, 4, 500); % N from 100 to 10000

% Highlight targets 
N_hl = [240, 960, 2000, 5000]; 
label_time = {'(6 hrs)', '(24 hrs)', '(50 hrs)', '(125 hrs)'};

% Custom Vertical Lines 
N_vlines = [240, 500, 960, 2000, 5000];

% 2. Calculate Key Lengths (n)
% Lines
n_57_plot = 57 + log2(N_plot * T_epoch);
n_80_plot = 80 + log2(N_plot * T_epoch);
n_100_plot = 100 + log2(N_plot * T_epoch);

% Highlight points
n_57_hl = 57 + log2(N_hl * T_epoch);
n_80_hl = 80 + log2(N_hl * T_epoch);
n_100_hl = 100 + log2(N_hl * T_epoch);

% 3. Plotting the results
figure('Color', 'w', 'Position', [100, 100, 900, 650]);
hold on;

for i = 1:length(N_vlines)
    plot([N_vlines(i) N_vlines(i)], [45, 128], ':', 'Color', [0.7 0.7 0.7], 'LineWidth', 1.2, 'HandleVisibility', 'off');
end

% Plot continuous lines
plot(N_plot, n_57_plot, '-b', 'LineWidth', 2, 'DisplayName', '{\it t} = 2^{-57} s (Baseline)');
plot(N_plot, n_80_plot, '--r', 'LineWidth', 2, 'DisplayName', '{\it t} = 2^{-80} s');
plot(N_plot, n_100_plot, '-.k', 'LineWidth', 2, 'DisplayName', '{\it t} = 2^{-100} s');

% Plot Highlight Markers
plot(N_hl, n_57_hl, 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'w', 'LineWidth', 1.5, 'HandleVisibility', 'off');
plot(N_hl, n_80_hl, 'rs', 'MarkerSize', 8, 'MarkerFaceColor', 'w', 'LineWidth', 1.5, 'HandleVisibility', 'off');
plot(N_hl, n_100_hl, 'k^', 'MarkerSize', 8, 'MarkerFaceColor', 'w', 'LineWidth', 1.5, 'HandleVisibility', 'off');

% 4. Add Text Annotations for specific bit lengths
for i = 1:length(N_hl)
    % N and Time labels at the bottom
    text(N_hl(i), 46, {sprintf('{\\it N}=%d', N_hl(i)), label_time{i}}, ...
        'FontSize', 11, 'FontName', 'Times New Roman', 'Color', [0.3 0.3 0.3], ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');

    % Bit length annotations
    text(N_hl(i), n_100_hl(i) + 1.5, sprintf('%.1f bits', n_100_hl(i)), ...
        'FontSize', 10, 'FontName', 'Times New Roman', 'Color', 'k', ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontWeight', 'bold');
    
    text(N_hl(i), n_80_hl(i) - 1.5, sprintf('%.1f bits', n_80_hl(i)), ...
        'FontSize', 10, 'FontName', 'Times New Roman', 'Color', 'r', ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontWeight', 'bold');
    
    text(N_hl(i), n_57_hl(i) - 1.5, sprintf('%.1f bits', n_57_hl(i)), ...
        'FontSize', 10, 'FontName', 'Times New Roman', 'Color', 'b', ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontWeight', 'bold');
end

% 5. Formatting for Academic Paper
set(gca, 'XScale', 'log'); % Set X-axis to Log Scale for better readability

set(gca, 'XGrid', 'off', 'XMinorGrid', 'off');
set(gca, 'YGrid', 'off', 'YMinorGrid', 'off');

set(gca, 'Color', 'w'); 
box on;
set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');

% X-axis Ticks Configuration
xticks([100, 240, 500, 960, 2000, 5000, 10000]);
xticklabels({'100', '240', '500', '960', '2000', '5000', '10000'});

xlabel('Key Chain Length, {\it N} (epochs) - Log Scale', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Minimum Required Key Length, {\it n} (bits)', 'FontSize', 14, 'FontWeight', 'bold');

% Legend
legend('Location', 'northwest', 'FontSize', 12, 'FontName', 'Times New Roman');

ylim([45, 128]);

hold off;