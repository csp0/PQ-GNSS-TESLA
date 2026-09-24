
% =========================================================================
% Hardware Benchmark for PQ-GNSS-TESLA on Raspberry Pi Pico 2
% =========================================================================
clear; clc; close all;

% =========================================================================
% [1] Data Input (Arduino Measured Data)
% =========================================================================
epochs = 1:40;

cpu_legacy = [0.047, 0.043, 0.034, 0.036, 0.035, 0.033, 0.034, 0.035, 0.034, 0.070, ...
    0.039, 0.034, 0.037, 0.036, 0.034, 0.036, 0.035, 0.085, 0.039, 0.064, ...
    0.033, 0.037, 0.036, 0.035, 0.035, 0.032, 0.033, 0.035, 0.034, 0.057, ...
    0.033, 0.033, 0.036, 0.033, 0.077, 0.040, 0.037, 0.036, 0.054, 0.063];

cpu_primary = [6.800, 0.033, 0.036, 0.032, 0.032, 0.032, 0.031, 0.032, 0.032, 0.044, ...
    0.031, 0.039, 0.032, 0.034, 0.032, 0.031, 0.035, 0.069, 0.032, 0.032, ...
    0.051, 0.031, 0.032, 0.032, 0.032, 0.032, 0.034, 0.035, 0.032, 0.032, ...
    0.035, 0.031, 0.032, 0.032, 0.034, 0.036, 0.032, 0.031, 0.037, 0.032];

cpu_fallback = [0.091, 0.034, 0.034, 0.034, 0.039, 0.033, 0.034, 0.033, 0.034, 0.039, ...
    0.034, 0.034, 0.033, 0.034, 0.034, 0.034, 6.502, 0.035, 0.033, 0.034, ...
    0.039, 0.033, 0.034, 0.034, 0.033, 0.033, 0.034, 0.034, 0.034, 0.034, ...
    0.034, 0.034, 0.034, 0.034, 0.033, 0.034, 0.033, 0.034, 0.033, 0.034];

% =========================================================================
% [2] Plot Time-Series Graph (Figure 1: CPU Execution Time)
% =========================================================================
figure('Position', [100, 100, 800, 450], 'Color', 'w');
hold on; grid on;

% Set line colors and markers
plot(epochs, cpu_legacy, '-o', 'LineWidth', 1.5, 'MarkerSize', 5, 'Color', [0.4660, 0.6740, 0.1880], 'DisplayName', 'Chimera (ECDSA)');
plot(epochs, cpu_primary, '-^', 'LineWidth', 1.5, 'MarkerSize', 5, 'Color', [0, 0.4470, 0.7410], 'DisplayName', 'PQ-GNSS-TESLA (Primary)');
plot(epochs, cpu_fallback, '-s', 'LineWidth', 1.5, 'MarkerSize', 5, 'Color', [0.8500, 0.3250, 0.0980], 'DisplayName', 'PQ-GNSS-TESLA (Fallback)');

% Set axis labels and legend
xlabel('Epoch', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('CPU Execution Time (ms)', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'northeast', 'FontSize', 10);
xlim([0 41]);
set(gca, 'FontSize', 11);

% Change Y-axis to logarithmic scale to clearly show the difference
% (Comment out the line below if a linear scale is preferred)
set(gca, 'YScale', 'log'); 

% =========================================================================
% [3] Add Text Annotations for the Paper
% =========================================================================
% Indicated with \leftarrow for arrows

% (1) Primary Mode - Epoch 1 spike
text(1, 6.800, {' \leftarrow Primary (Falcon)', '   (One-time OOB Bootstrapping)'}, ...
    'FontSize', 10, 'FontWeight', 'bold', 'Color', [0, 0.4470, 0.7410], 'VerticalAlignment', 'middle');

% [수정됨] (2) Fallback Mode - Epoch 17 spike only (Added "One-time SIS Bootstrapping" and removed Epoch 34 spike text)
text(17, 6.502, {' \leftarrow Fallback (Falcon)', '   (One-time SIS Bootstrapping)'}, ...
    'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.8500, 0.3250, 0.0980], 'VerticalAlignment', 'middle');

% (3) Legacy (ECDSA) - Indicate representative spikes
% Annotated around Epoch 10 and 18 for readability
text(10, 0.070, {' \leftarrow Chimera', '       (ECDSA)'}, ...
    'FontSize', 9, 'Color', [0.4660, 0.6740, 0.1880], 'VerticalAlignment', 'middle');
text(18, 0.085, ' \leftarrow Chimera (ECDSA)', ...
    'FontSize', 9, 'Color', [0.4660, 0.6740, 0.1880], 'VerticalAlignment', 'middle');
hold off;