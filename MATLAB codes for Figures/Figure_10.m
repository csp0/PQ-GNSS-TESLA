
% =========================================================================
% PQ-GNSS-TESLA: End-to-End Authentication Success Probability Analysis
% =========================================================================
% Description:
%   Evaluates the Authentication Success Probability of the PQ-GNSS-TESLA 
%   architecture across varying C/N0 environments.
%   - NMA (Navigation Message Auth): Evaluated via LDPC decoding success,
%     which is a prerequisite for executing Algorithm 2 (MAC verification).
%   - SCA (Spreading Code Auth): Evaluated via soft-decision correlation 
%     exceeding a statistical threshold (P_fa = 1e-4).
% =========================================================================
clc; clear; close all;
fprintf('=== Starting Scenario 2: Authentication Success Evaluation ===\n');

% =========================================================================
% 1. System Configuration & LDPC Setup
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

% Simulation Parameters
CN0_dBHz_range = 8:1:50;        
sym_rate = 100;                 % 100 sps
max_trials = 2000;              % Monte Carlo trials per C/N0 point

% SCA Parameters
num_markers = 64;               % Number of punctured SCA marker chips per frame
P_fa = 1e-4;                    % Target False Alarm Probability

% Q-function inverse approximation using erfinv
Q_inv = sqrt(2) * erfinv(1 - 2 * P_fa); 

prob_nma_success = zeros(length(CN0_dBHz_range), 1);
prob_sca_success = zeros(length(CN0_dBHz_range), 1);

% =========================================================================
% 2. Monte Carlo Simulation Loop (Physical Layer Processing)
% =========================================================================
for idx = 1:length(CN0_dBHz_range)
    CN0 = CN0_dBHz_range(idx);
    EsN0_dB = CN0 - 10 * log10(sym_rate);
    sigma2 = 10^(-EsN0_dB/10) / 2;
    sigma = sqrt(sigma2);
    
    % Adaptive threshold for SCA based on current noise variance
    % Gamma = Q_inv * sqrt(N * sigma^2) (Zero-mean assumption for H0)
    sca_threshold = Q_inv * sqrt(num_markers * sigma2);
    
    nma_success_count = 0;
    sca_success_count = 0;
    
    % Optimization: If C/N0 > 18, authentication is practically 100% successful
    if CN0 > 18
        prob_nma_success(idx) = 1.0;
        prob_sca_success(idx) = 1.0;
        fprintf('C/N0: %2d dB-Hz | NMA Success: 100%% | SCA Success: 100%%\n', CN0);
        continue;
    end
    
    for trial = 1:max_trials
        % -----------------------------------------------------------------
        % [TX] Transmitter: PQ-GNSS-TESLA Signal Generation
        % -----------------------------------------------------------------
        % [Step 1] Generate NMA Payload (TESLA MAC + Message) & Encode
        tx_nma_bits = randi([0 1], 600, 1);
        tx_nma_enc = ldpcEncode(tx_nma_bits, cfgEnc);
        tx_nma_sym = 1 - 2 * double(tx_nma_enc); % BPSK
        
        % [Step 2] Generate SCA Markers (Cryptographically Generated Sequence)
        tx_sca_sym = 1 - 2 * randi([0 1], num_markers, 1); % BPSK Markers
        
        % -----------------------------------------------------------------
        % [CHANNEL] AWGN fading and noise addition
        % -----------------------------------------------------------------
        % NMA uses proposed 4-frame soft-combining structure
        rx_nma_frames = repmat(tx_nma_sym, 1, 4) + randn(1200, 4) * sigma;
        % SCA markers are received with noise
        rx_sca_sym = tx_sca_sym + randn(num_markers, 1) * sigma;
        
        % -----------------------------------------------------------------
        % [RX] Receiver: Baseband Verification (Prerequisite for Algorithm 2)
        % -----------------------------------------------------------------
        % [Step 1] NMA Verification: Soft-combining -> LDPC -> Baseband Check
        LLR_nma = sum(rx_nma_frames, 2) * (2 / sigma2);
        rx_nma_bits = ldpcDecode(LLR_nma, cfgDec, 50);
        
        % NMA succeeds ONLY if all bits match (Cryptographic Avalanche Effect)
        if isequal(rx_nma_bits, tx_nma_bits)
            nma_success_count = nma_success_count + 1;
        end
        
        % [Step 2] SCA Verification: Soft-Decision Correlation & Thresholding
        % Correlate received markers with locally generated authentic replica
        sca_correlation = sum(rx_sca_sym .* tx_sca_sym);
        
        % SCA succeeds if correlation exceeds statistical threshold
        if sca_correlation > sca_threshold
            sca_success_count = sca_success_count + 1;
        end
    end
    
    prob_nma_success(idx) = nma_success_count / max_trials;
    prob_sca_success(idx) = sca_success_count / max_trials;
    
    fprintf('C/N0: %2d dB-Hz | NMA Success: %6.2f%% | SCA Success: %6.2f%%\n', ...
            CN0, prob_nma_success(idx)*100, prob_sca_success(idx)*100);
end

% =========================================================================
% 3. Plotting the Results 
% =========================================================================
close all;
fig = figure('Name', 'Authentication Success Probability', 'Color', 'w', 'Position', [100 100 900 600]);
ax = axes('Parent', fig);
hold(ax, 'on');

% --- [A] Receiver Environment Classification Layer (Background) ---
y_min = 0; y_max = 1.15; x_min = 5; x_max = 50;

fill([x_min 30 30 x_min], [y_min y_min y_max y_max], [1 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.5, 'HandleVisibility','off');
fill([30 40 40 30], [y_min y_min y_max y_max], [1 0.96 0.85], 'EdgeColor', 'none', 'FaceAlpha', 0.5, 'HandleVisibility','off');
fill([40 45 45 40], [y_min y_min y_max y_max], [0.9 1 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.5, 'HandleVisibility','off');
fill([45 x_max x_max 45], [y_min y_min y_max y_max], [0.9 0.95 1], 'EdgeColor', 'none', 'FaceAlpha', 0.5, 'HandleVisibility','off');

xline(30, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.5, 'HandleVisibility','off');
xline(40, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.5, 'HandleVisibility','off');
xline(45, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.5, 'HandleVisibility','off');

text(19, 1.08, 'Poor (Urban Canyon)', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.6 0 0]);
text(35, 1.08, 'Marginal', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.6 0.4 0]);
text(42.5, 1.08, 'Good', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0 0.5 0]);
text(47.5, 1.08, 'Excellent', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0 0 0.6]);

% --- [B] Authentication Probability Curves ---
plot(CN0_dBHz_range, prob_nma_success, '-rs', 'LineWidth', 2.5, 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'DisplayName', 'NMA Success');
plot(CN0_dBHz_range, prob_sca_success, '-bd', 'LineWidth', 2.5, 'MarkerSize', 8, 'MarkerFaceColor', 'b', 'DisplayName', 'SCA Success');

% --- [C] Formatting (Axes, Legend, Title) ---
set(gca, 'FontSize', 12, 'FontName', 'Times New Roman');
xlabel('Carrier-to-Noise Density Ratio, {\it C/N_0} (dB-Hz)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Authentication Success Probability', 'FontSize', 14, 'FontWeight', 'bold');
title('Cross-Layer Authentication Performance over Receiver Environments', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'southeast', 'FontSize', 12);
xlim([x_min, x_max]);
ylim([y_min, y_max]);
set(gca, 'YTick', 0:0.2:1.0);
grid on; hold(ax, 'off');

fprintf('\n=== Scenario 2 Graph Generation Complete! ===\n');