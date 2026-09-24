
% =========================================================================
% GNSS-TESLA Required MAC Size vs Target Integrity Risk
% =========================================================================
clear; clc; close all;

% -------------------------------------------------------------------------
% 1. Parameter Setup
% -------------------------------------------------------------------------
% Define P_target range (from 10^-1 to 10^-10)
P_target = logspace(-10, -1, 200); 
G_set = [4, 8, 16, 32];

% Define colors to strictly match the reference figure (Fig. 7)
color_G4  = [0.4660, 0.6740, 0.1880]; % Green
color_G8  = [0.9290, 0.6940, 0.1250]; % Yellow/Orange
color_G16 = [0, 0.4470, 0.7410];      % Blue (Baseline)
color_G32 = [0.6350, 0.0780, 0.1840]; % Dark Red
colors = {color_G4, color_G8, color_G16, color_G32};

% Define line styles and widths
line_styles = {'-', '--', '-', '-.'};
line_widths = [2.5, 2.5, 3.5, 2.5]; % Make G=16 (Baseline) slightly thicker

% -------------------------------------------------------------------------
% 2. Figure Initialization & Background
% -------------------------------------------------------------------------
fig = figure('Position', [200, 200, 750, 550], 'Color', 'w');
ax = axes('Parent', fig);
hold(ax, 'on'); grid on;

% Draw Strict Integrity Zone (Shaded Area for P_target <= 10^-6)
% Using patch/fill before plotting lines ensures it stays in the background
fill([1e-10, 1e-6, 1e-6, 1e-10], [0, 0, 45, 45], [0.88 0.94 0.99], ...
    'EdgeColor', 'none', 'HandleVisibility', 'off');

% -------------------------------------------------------------------------
% 3. Plot MAC Length Curves
% -------------------------------------------------------------------------
% Calculate and plot required minimum MAC length: v = log2(G) - log2(P_target)
h_lines = zeros(1, length(G_set));
for idx = 1:length(G_set)
    G = G_set(idx);
    v_req = log2(G) - log2(P_target);
    h_lines(idx) = semilogx(P_target, v_req, 'LineWidth', line_widths(idx), ...
        'Color', colors{idx}, 'LineStyle', line_styles{idx});
end

% -------------------------------------------------------------------------
% 4. Baseline Requirement Annotations (P_target = 10^-6, G = 16)
% -------------------------------------------------------------------------
P_th = 1e-6;
v_th = log2(16) - log2(P_th); % ~23.93 bits

% Draw vertical and horizontal dotted guide lines
plot([P_th, P_th], [0, v_th], 'k:', 'LineWidth', 1.8, 'HandleVisibility', 'off');
plot([1e-1, P_th], [v_th, v_th], 'k:', 'LineWidth', 1.8, 'HandleVisibility', 'off');

% Draw the intersection marker (Large orange circle with black edge)
plot(P_th, v_th, 'o', 'MarkerSize', 11, 'MarkerFaceColor', [0.9 0.4 0.1], ...
    'MarkerEdgeColor', 'k', 'LineWidth', 1.5, 'HandleVisibility', 'off');

% Add text annotations for Baseline Requirement
text(10^-4.8, 28, 'Baseline Requirement:', 'FontWeight', 'bold', ...
    'FontSize', 13, 'FontName', 'Times New Roman', 'HorizontalAlignment', 'center');
text(10^-4.8, 25, '{\it v} = 24 bits for {\it P_{target}} = 10^{-6}', ...
    'FontWeight', 'bold', 'FontSize', 13, 'FontName', 'Times New Roman', ...
    'HorizontalAlignment', 'center');

% Add text annotations for Strict Integrity Zone
text(10^-8, 12, 'Strict Integrity Zone', 'FontWeight', 'bold', ...
    'FontSize', 14, 'FontName', 'Times New Roman', 'Color', [0 0.3 0.6], ...
    'HorizontalAlignment', 'center');
text(10^-8, 9, '( {\it P_{target}} \leq 10^{-6} )', 'FontWeight', 'bold', ...
    'FontSize', 14, 'FontName', 'Times New Roman', 'Color', [0 0.3 0.6], ...
    'HorizontalAlignment', 'center');

% -------------------------------------------------------------------------
% 5. Axis Formatting
% -------------------------------------------------------------------------
set(gca, 'XScale', 'log');
set(gca, 'XDir', 'reverse'); % Reverse X-axis: 10^-1 (left) to 10^-10 (right)
xlim([1e-10, 1e-1]);
ylim([0, 42]);

% Explicitly define X-axis ticks for every exponent
xticks(10.^(-10:1:-1));

% Axis labels matching the paper text
xlabel('Target Integrity Risk per Epoch ({\it P_{target}}) - Log Scale (Reversed)', ...
    'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ylabel('Minimum Required MAC Length, {\it v} (bits)', ...
    'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');

% -------------------------------------------------------------------------
% 6. Legend Configuration
% -------------------------------------------------------------------------
legend_labels = {'{\it G} = 4 Satellites', '{\it G} = 8 Satellites', ...
                 '{\it G} = 16 Satellites', '{\it G} = 32 Satellites'};
legend(h_lines, legend_labels, 'Location', 'northwest', 'FontSize', 12, ...
    'FontName', 'Times New Roman');

hold(ax, 'off');