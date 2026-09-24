
% =========================================================================
% Hardware Memory Overhead Breakdown (Donut/Pie Charts) for PQ-GNSS-TESLA
% =========================================================================
clear; clc; close all;

% -------------------------------------------------------------------------
% Memory Data in KB [ROM, RAM]
% * Flash includes algorithm code + Pre-provisioned Public Key
% * SRAM includes TESLA baseline buffers + Signature fragments + Public Key buffer
% -------------------------------------------------------------------------
% Legacy: Flash(6.78 + 0.06 PK), SRAM(0.04 TESLA + 0.25 Sig + 0.06 PK)
mem_legacy   = [6.84,  0.35]; 

% Primary: Flash(56.23 + 0.88 PK), SRAM(0.06 TESLA + 0.88 PK for OOB Boot)
mem_primary  = [57.11, 0.94]; 

% Fallback: Flash(56.23 + 0.88 PK), SRAM(0.06 TESLA + 0.65 Sig + 0.88 PK)
mem_fallback = [57.11, 1.59]; 

% Colors: [ROM (Flash), RAM (SRAM)]
colors = [0.2, 0.6, 0.8;   % Blue for ROM
          0.8, 0.2, 0.2];  % Red for RAM

% Increase figure height to 450 to prevent text overlap and secure legend space
figure('Position', [100, 200, 1000, 450], 'Color', 'w');

% -------------------------------------------------------------------------
% 1. Chimera (ECDSA)
% -------------------------------------------------------------------------
subplot(1, 3, 1);
p1 = pie(mem_legacy, [0, 1]); % Explode RAM slice slightly
colormap(gca, colors);
title({'Chimera (Legacy)', sprintf('Total: %.2f KB', sum(mem_legacy)), '', ''}, ...
    'FontSize', 11, 'FontWeight', 'bold');
p1Text = findobj(p1, 'Type', 'text');
p1Text(1).String = sprintf('Flash\n%.2f KB\n(%.1f%%)', mem_legacy(1), mem_legacy(1)/sum(mem_legacy)*100);
p1Text(2).String = sprintf('SRAM  %.2f KB\n(%.1f%%)', mem_legacy(2), mem_legacy(2)/sum(mem_legacy)*100);
set(p1Text, 'FontSize', 9, 'FontWeight', 'bold');

% -------------------------------------------------------------------------
% 2. PQ-GNSS-TESLA (Primary)
% -------------------------------------------------------------------------
subplot(1, 3, 2);
p2 = pie(mem_primary, [0, 1]);
colormap(gca, colors);
title({'PQ-GNSS-TESLA (Primary)', sprintf('Total: %.2f KB', sum(mem_primary)), '', ''}, ...
    'FontSize', 11, 'FontWeight', 'bold');
p2Text = findobj(p2, 'Type', 'text');
p2Text(1).String = sprintf('Flash\n%.2f KB\n(%.1f%%)', mem_primary(1), mem_primary(1)/sum(mem_primary)*100);
p2Text(2).String = sprintf('SRAM  %.2f KB\n(%.1f%%)', mem_primary(2), mem_primary(2)/sum(mem_primary)*100);
set(p2Text, 'FontSize', 9, 'FontWeight', 'bold');

% -------------------------------------------------------------------------
% 3. PQ-GNSS-TESLA (Fallback)
% -------------------------------------------------------------------------
subplot(1, 3, 3);
p3 = pie(mem_fallback, [0, 1]);
colormap(gca, colors);
title({'         PQ-GNSS-TESLA (Fallback)', sprintf('Total: %.2f KB', sum(mem_fallback)), '', ''}, ...
    'FontSize', 11, 'FontWeight', 'bold');
p3Text = findobj(p3, 'Type', 'text');
p3Text(1).String = sprintf('Flash\n%.2f KB\n(%.1f%%)', mem_fallback(1), mem_fallback(1)/sum(mem_fallback)*100);
p3Text(2).String = sprintf('SRAM  %.2f KB\n(%.1f%%)', mem_fallback(2), mem_fallback(2)/sum(mem_fallback)*100);
set(p3Text, 'FontSize', 9, 'FontWeight', 'bold');

% -------------------------------------------------------------------------
% 4. Bottom Legend (Specifying Pico 2 hardware specs)
% -------------------------------------------------------------------------
legend_text = {'Flash  Overhead / Pico 2 Total: 4,088 KB (~4 MB)', ...
               'SRAM Overhead / Pico 2 Total: 512 KB'};
legend(legend_text, 'Position', [0.35, 0.05, 0.3, 0.08], ...
    'Orientation', 'vertical', 'FontSize', 10, 'FontWeight', 'bold');