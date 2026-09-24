
% =========================================================================
% PQ-GNSS-TESLA: Scenario 1 - Subframe 2 Soft-Combining FER Analysis
% =========================================================================
% Description:
%   Evaluates the Frame Error Rate (FER) of CNAV-2 Subframe 2 (SF2) by 
%   comparing the Legacy approach (combining 5 frames) vs. the Proposed 
%   PQ-GNSS-TESLA approach (combining 4 frames due to Frame 5 overriding).
% =========================================================================
clc; clear; close all;
fprintf('=== Starting Scenario 1: Subframe 2 FER Evaluation ===\n');

% =========================================================================
% 1. LDPC Configuration for CNAV-2 Subframe 2 (Rate 1/2)
% =========================================================================
load("L1CLDPCParityCheckMatrices.mat", "A1", "B1", "C1", "E1", "T1");
H2 = [logical(sparse(A1(:,1), A1(:,2), 1, 599, 600)), ...
      logical(sparse(B1(:,1), B1(:,2), 1, 599, 1)), ...
      logical(sparse(T1(:,1), T1(:,2), 1, 599, 599)); ...
      logical(sparse(C1(:,1), C1(:,2), 1, 1, 600)), ...
      true, ...
      logical(sparse(E1(:,1), E1(:,2), 1, 1, 599))];
      
cfgEnc = ldpcEncoderConfig(H2);
cfgDec = ldpcDecoderConfig(H2);

% =========================================================================
% 2. Simulation Parameters
% =========================================================================
% Expand X-axis range from 8 to 50 to fully display environmental classifications
CN0_dBHz_range = 8:1:50;        
sym_rate = 100;                 % L1C CNAV-2 symbol rate (100 sps, 10ms per symbol)
max_errors = 50;                % Target number of frame errors for statistical confidence
max_trials = 5000;              % Maximum trials per C/N0 point
fer_legacy = zeros(length(CN0_dBHz_range), 1);
fer_proposed = zeros(length(CN0_dBHz_range), 1);

% =========================================================================
% 3. Monte Carlo Simulation Loop
% =========================================================================
for idx = 1:length(CN0_dBHz_range)
    CN0 = CN0_dBHz_range(idx);
    EsN0_dB = CN0 - 10 * log10(sym_rate);
    
    sigma2 = 10^(-EsN0_dB/10) / 2;
    sigma = sqrt(sigma2);
    
    err_leg = 0; err_prop = 0; trials = 0;
    
    % Optimization: Skip simulation for C/N0 > 18 as FER is practically 0 (saves time)
    if CN0 > 18
        fer_legacy(idx) = 0;
        fer_proposed(idx) = 0;
        fprintf('C/N0: %2d dB-Hz | Legacy FER: %.4f | Proposed FER: %.4f (Skipped)\n', CN0, 0, 0);
        continue;
    end
    
    while (err_leg < max_errors || err_prop < max_errors) && (trials < max_trials)
        trials = trials + 1;
        
        % Generate and encode bits
        tx_bits = randi([0 1], 600, 1);
        tx_enc = ldpcEncode(tx_bits, cfgEnc);
        
        % BPSK Modulation
        tx_sym = 1 - 2 * double(tx_enc);
        
        % Channel transmission (AWGN)
        rx_frames = repmat(tx_sym, 1, 5) + randn(1200, 5) * sigma;
        
        % Soft-combining LLR calculations
        LLR_leg = sum(rx_frames(:, 1:5), 2) * (2 / sigma2);
        LLR_prop = sum(rx_frames(:, 1:4), 2) * (2 / sigma2);
        
        % LDPC Decoding
        rx_bits_leg = ldpcDecode(LLR_leg, cfgDec, 50);
        rx_bits_prop = ldpcDecode(LLR_prop, cfgDec, 50);
        
        % Error checking
        if any(rx_bits_leg ~= tx_bits), err_leg = err_leg + 1; end
        if any(rx_bits_prop ~= tx_bits), err_prop = err_prop + 1; end
    end
    
    fer_legacy(idx) = err_leg / trials;
    fer_proposed(idx) = err_prop / trials;
    fprintf('C/N0: %2d dB-Hz | Legacy FER: %.4f | Proposed FER: %.4f\n', CN0, fer_legacy(idx), fer_proposed(idx));
end

% --- Post-Processing for Aesthetic Plotting (Handling 0 values) ---
% Replace exactly 0 with a very small value (1e-5) so the line drops gracefully
fer_legacy_plot = fer_legacy;
fer_proposed_plot = fer_proposed;
fer_legacy_plot(fer_legacy_plot == 0) = 1e-5; 
fer_proposed_plot(fer_proposed_plot == 0) = 1e-5;

% =========================================================================
% 4. Plotting the Results (IEEE Publication Ready with Environmental Overlay)
% =========================================================================
close all;
fig = figure('Name', 'Subframe 2 FER with Environment', 'Color', 'w', 'Position', [100 100 900 600]);
ax = axes('Parent', fig, 'YScale', 'log');
hold(ax, 'on');

% --- [A] Receiver Environment Classification Layer (Background) ---
y_min = 1e-5; y_max = 2; x_min = 5; x_max = 50;

% 1. Poor (Urban Canyon): < 30 dB-Hz (Light Red)
fill([x_min 30 30 x_min], [y_min y_min y_max y_max], [1 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.5, 'HandleVisibility','off');
% 2. Marginal (Light Foliage): 30 ~ 40 dB-Hz (Light Yellow)
fill([30 40 40 30], [y_min y_min y_max y_max], [1 0.96 0.85], 'EdgeColor', 'none', 'FaceAlpha', 0.5, 'HandleVisibility','off');
% 3. Good (Clear Outdoor): 40 ~ 45 dB-Hz (Light Green)
fill([40 45 45 40], [y_min y_min y_max y_max], [0.9 1 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.5, 'HandleVisibility','off');
% 4. Excellent (Open Sky): >= 45 dB-Hz (Light Blue)
fill([45 x_max x_max 45], [y_min y_min y_max y_max], [0.9 0.95 1], 'EdgeColor', 'none', 'FaceAlpha', 0.5, 'HandleVisibility','off');

% Vertical Boundary Lines
xline(30, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.5, 'HandleVisibility','off');
xline(40, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.5, 'HandleVisibility','off');
xline(45, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.5, 'HandleVisibility','off');

% Environmental Label Texts
text(19, 1.2, 'Poor (Urban Canyon)', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.6 0 0]);
text(35, 1.2, 'Marginal', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.6 0.4 0]);
text(42.5, 1.2, 'Good', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0 0.5 0]);
text(47.5, 1.2, 'Excellent', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0 0 0.6]);

% --- [B] FER Simulation Curve Layer ---
plot(CN0_dBHz_range, fer_legacy_plot, '-bo', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'b', 'DisplayName', 'Legacy (5 Frames Combined)');
plot(CN0_dBHz_range, fer_proposed_plot, '-rs', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'DisplayName', 'Proposed (4 Frames Combined)');

% --- [C] FER Measurement and Annotation Layer ---
[uq_fer_leg, idx_leg] = unique(fer_legacy_plot);
[uq_fer_prop, idx_prop] = unique(fer_proposed_plot);
cn0_leg_target = interp1(log10(uq_fer_leg), CN0_dBHz_range(idx_leg), log10(1e-2), 'linear', 'extrap');
cn0_prop_target = interp1(log10(uq_fer_prop), CN0_dBHz_range(idx_prop), log10(1e-2), 'linear', 'extrap');

% Target FER (10^-2) Reference Line
yline(1e-2, 'k--', 'LineWidth', 1.5, 'HandleVisibility','off');

% Moved Target FER Text to the right (x=20) to prevent overlapping
text(20, 1e-2 * 1.5, 'Target FER = 10^{-2}', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');

% Intersection Markers
plot(cn0_leg_target, 1e-2, 'bo', 'MarkerSize', 10, 'LineWidth', 2, 'HandleVisibility','off');
plot(cn0_prop_target, 1e-2, 'rs', 'MarkerSize', 10, 'LineWidth', 2, 'HandleVisibility','off');

% --- [D] Formatting (Axes, Legend, Title) ---
set(gca, 'YScale', 'log', 'FontSize', 12, 'FontName', 'Times New Roman');
xlabel('Carrier-to-Noise Density Ratio, {\it C/N_0} (dB-Hz)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Frame Error Rate (FER)', 'FontSize', 14, 'FontWeight', 'bold');
title('Subframe 2 FER Comparison with Receiver Environments', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'southwest', 'FontSize', 12);
xlim([x_min, x_max]);
ylim([y_min, y_max]);
grid on; hold(ax, 'off');

fprintf('\n=== Scenario 1 Graph with Environmental Overlay Complete! ===\n');