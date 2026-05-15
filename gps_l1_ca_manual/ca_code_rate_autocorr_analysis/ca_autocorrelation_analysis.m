%% CA Code Autocorrelation Analysis - PRN1
% Analyze autocorrelation of PRN1 at two different sampling rates
% (1.023 MHz and 10.23 MHz)
% Generates plots showing autocorrelation curves

clear all;
close all;
clc;

%% 1. Generate PRN1 CA Code Sequence
fprintf('====== PRN1 CA Code Autocorrelation Analysis ======\n');
fprintf('Generating PRN1 CA code...\n');

g1 = ones(1, 10);
g2 = ones(1, 10);
ca01 = zeros(1, 1023);

for k = 1:1023
    g1_out = g1(10);
    g2_prn1_out = xor(g2(2), g2(6));
    ca01(k) = xor(g1_out, g2_prn1_out);
    
    g1_feedback = xor(g1(3), g1(10));
    g2_feedback = xor(xor(xor(g2(2), g2(3)), xor(g2(6), g2(8))), xor(g2(9), g2(10)));
    
    g1 = [g1_feedback, g1(1:9)];
    g2 = [g2_feedback, g2(1:9)];
end

% Convert to +1/-1 format
ca = 1 - 2 * ca01;

fprintf('CA code length: %d chips\n', length(ca));
fprintf('CA code period: %d chips\n\n', 1023);

%% 2. Calculate Autocorrelation at 1.023 MHz
fprintf('Computing autocorrelation at 1.023 MHz...\n');

% Normalize CA code
ca_norm_1023 = ca / norm(ca);

% Compute autocorrelation (delay from -1023 to +1023 chips)
max_lag = 1023;
autocorr_1023 = zeros(1, 2*max_lag + 1);
lags_1023 = (-max_lag:max_lag);

for lag_idx = 1:length(lags_1023)
    lag = lags_1023(lag_idx);
    
    if lag >= 0
        % Positive delay
        if lag < length(ca_norm_1023)
            autocorr_1023(lag_idx) = sum(ca_norm_1023(1:end-lag) .* ca_norm_1023(lag+1:end));
        end
    else
        % Negative delay
        lag_abs = abs(lag);
        if lag_abs < length(ca_norm_1023)
            autocorr_1023(lag_idx) = sum(ca_norm_1023(lag_abs+1:end) .* ca_norm_1023(1:end-lag_abs));
        end
    end
end

fprintf('1.023 MHz autocorrelation computation completed\n');

%% 3. Calculate Autocorrelation at 10.23 MHz (High Sampling Rate)
fprintf('Computing autocorrelation at 10.23 MHz...\n');

% 10x upsampling (each chip becomes 10 samples)
oversample_factor = 10;
ca_10x = zeros(1, length(ca) * oversample_factor);

for i = 1:length(ca)
    ca_10x((i-1)*oversample_factor + 1 : i*oversample_factor) = ca(i);
end

ca_norm_10230 = ca_10x / norm(ca_10x);

% Compute autocorrelation (delay from -10230 to +10230 samples)
max_lag_10x = 10230;
autocorr_10230 = zeros(1, 2*max_lag_10x + 1);
lags_10230 = (-max_lag_10x:max_lag_10x);

for lag_idx = 1:length(lags_10230)
    lag = lags_10230(lag_idx);
    
    if lag >= 0
        if lag < length(ca_norm_10230)
            autocorr_10230(lag_idx) = sum(ca_norm_10230(1:end-lag) .* ca_norm_10230(lag+1:end));
        end
    else
        lag_abs = abs(lag);
        if lag_abs < length(ca_norm_10230)
            autocorr_10230(lag_idx) = sum(ca_norm_10230(lag_abs+1:end) .* ca_norm_10230(1:end-lag_abs));
        end
    end
end

fprintf('10.23 MHz autocorrelation computation completed\n\n');

%% 4. Create Visualization Plots

% Get output directory (same as script location)
output_dir = fileparts(mfilename('fullpath'));

% Figure 1: 1.023 MHz autocorrelation (full range)
figure('Name', 'PRN1 CA Autocorr Analysis - 1.023 MHz', 'Color', 'w', 'Position', [100 100 1200 700]);

subplot(2,1,1);
plot(lags_1023, autocorr_1023, 'b-', 'LineWidth', 1.5);
grid on;
xlabel('Delay (chips)');
ylabel('Autocorrelation Value');
title('1.023 MHz - PRN1 CA Code Autocorrelation (Full Range)');
xlim([-1023 1023]);
set(gca, 'FontSize', 11);

% Figure 2: 1.023 MHz autocorrelation (zoomed to center, +/- 50 chips)
subplot(2,1,2);
center_idx = max_lag + 1;  % Index at zero delay
zoom_range = 50;
zoom_idx = center_idx - zoom_range : center_idx + zoom_range;
plot(lags_1023(zoom_idx), autocorr_1023(zoom_idx), 'b-', 'LineWidth', 2, 'Marker', 'o', 'MarkerSize', 4);
grid on;
xlabel('Delay (chips)');
ylabel('Autocorrelation Value');
title('1.023 MHz - PRN1 CA Code Autocorrelation (Zoomed, +/- 50 chips)');
xlim([-zoom_range zoom_range]);
set(gca, 'FontSize', 11);

% Mark peak value
[max_val, max_idx] = max(autocorr_1023(zoom_idx));
hold on;
plot(lags_1023(zoom_idx(max_idx)), max_val, 'r*', 'MarkerSize', 15);
legend(sprintf('Autocorr', sprintf('Peak=%.4f', max_val)), 'FontSize', 10);

output_file = fullfile(output_dir, 'ca_autocorr_1023MHz.png');
print(gcf, output_file, '-dpng', '-r150');
fprintf('Saved: %s\n', output_file);

% Figure 3: 10.23 MHz autocorrelation (full range)
figure('Name', 'PRN1 CA Autocorr Analysis - 10.23 MHz', 'Color', 'w', 'Position', [100 100 1200 700]);

subplot(2,1,1);
plot(lags_10230, autocorr_10230, 'r-', 'LineWidth', 1);
grid on;
xlabel('Delay (samples)');
ylabel('Autocorrelation Value');
title('10.23 MHz - PRN1 CA Code Autocorrelation (Full Range)');
xlim([-10230 10230]);
set(gca, 'FontSize', 11);

% Figure 4: 10.23 MHz autocorrelation (zoomed to center, +/- 500 samples)
subplot(2,1,2);
center_idx_10x = max_lag_10x + 1;
zoom_range_10x = 500;
zoom_idx_10x = center_idx_10x - zoom_range_10x : center_idx_10x + zoom_range_10x;
plot(lags_10230(zoom_idx_10x), autocorr_10230(zoom_idx_10x), 'r-', 'LineWidth', 1.5, 'Marker', '.', 'MarkerSize', 3);
grid on;
xlabel('Delay (samples)');
ylabel('Autocorrelation Value');
title('10.23 MHz - PRN1 CA Code Autocorrelation (Zoomed, +/- 500 samples)');
xlim([-zoom_range_10x zoom_range_10x]);
set(gca, 'FontSize', 11);

% Mark peak value
[max_val_10x, max_idx_10x] = max(autocorr_10230(zoom_idx_10x));
hold on;
plot(lags_10230(zoom_idx_10x(max_idx_10x)), max_val_10x, 'b*', 'MarkerSize', 15);
legend(sprintf('Autocorr', sprintf('Peak=%.4f', max_val_10x)), 'FontSize', 10);

output_file = fullfile(output_dir, 'ca_autocorr_10230MHz.png');
print(gcf, output_file, '-dpng', '-r150');
fprintf('Saved: %s\n', output_file);

% Figure 5: Overlay comparison with x-axis normalized to chips
% Key insight: both peaks are 2 chips wide, but differ 10x in physical time.
figure('Name', 'PRN1 CA Autocorr Comparison - Chip Normalized', 'Color', 'w', 'Position', [100 100 1400 550]);

% --- Subplot 1: Wide view (+/- 10 chips), normalized to chips ---
subplot(1,2,1);
zoom_chips = 10;
zoom_idx_w1 = center_idx - zoom_chips : center_idx + zoom_chips;
lags_chip_1023 = lags_1023(zoom_idx_w1);  % already in chips

% For 10.23 MHz: convert sample lag to chip lag (divide by oversample_factor)
zoom_samp_w2 = zoom_chips * oversample_factor;
zoom_idx_w2 = center_idx_10x - zoom_samp_w2 : center_idx_10x + zoom_samp_w2;
lags_chip_10230 = lags_10230(zoom_idx_w2) / oversample_factor;  % samples -> chips

plot(lags_chip_1023, autocorr_1023(zoom_idx_w1), 'b-o', 'LineWidth', 2, 'MarkerSize', 5);
hold on;
plot(lags_chip_10230, autocorr_10230(zoom_idx_w2), 'r-', 'LineWidth', 1.5);
grid on;
xlabel('Delay (chips)');
ylabel('Autocorrelation Value');
title('Both Rates - Overlay in Chip Units (+/- 10 chips)');
legend('1.023 MHz (1 pt/chip)', '10.23 MHz (10 pts/chip)', 'Location', 'north');
set(gca, 'FontSize', 11, 'FontWeight', 'bold');
xlim([-zoom_chips zoom_chips]);
% Annotation: peak width is the same in chips
text(0, 0.5, 'Peak width = 2 chips', 'HorizontalAlignment', 'center', ...
    'FontSize', 10, 'Color', [0.2 0.2 0.2], 'FontAngle', 'italic');

% --- Subplot 2: Close-up of the main lobe (+/- 2 chips) ---
subplot(1,2,2);
zoom_chips2 = 2;
zoom_idx_c1 = center_idx - zoom_chips2 : center_idx + zoom_chips2;
lags_chip_c1 = lags_1023(zoom_idx_c1);

zoom_samp_c2 = zoom_chips2 * oversample_factor;
zoom_idx_c2 = center_idx_10x - zoom_samp_c2 : center_idx_10x + zoom_samp_c2;
lags_chip_c2 = lags_10230(zoom_idx_c2) / oversample_factor;

plot(lags_chip_c1, autocorr_1023(zoom_idx_c1), 'b-o', 'LineWidth', 2.5, 'MarkerSize', 8);
hold on;
plot(lags_chip_c2, autocorr_10230(zoom_idx_c2), 'r-', 'LineWidth', 2);
grid on;
xlabel('Delay (chips)');
ylabel('Autocorrelation Value');
title('Main Lobe Close-up (+/- 2 chips)');
legend('1.023 MHz', '10.23 MHz', 'Location', 'north');
set(gca, 'FontSize', 11, 'FontWeight', 'bold');
xlim([-zoom_chips2 zoom_chips2]);
% Physical time annotation
Tc_1023  = 1 / 1.023e6 * 1e6;   % us
Tc_10230 = 1 / 10.23e6 * 1e6;   % us
text(-1.8, 0.15, sprintf('Tc(1.023 MHz) = %.0f ns', Tc_1023*1e3), ...
    'FontSize', 9, 'Color', 'b');
text(-1.8, 0.05, sprintf('Tc(10.23 MHz) = %.1f ns', Tc_10230*1e3), ...
    'FontSize', 9, 'Color', 'r');

output_file = fullfile(output_dir, 'ca_autocorr_comparison.png');
print(gcf, output_file, '-dpng', '-r150');
fprintf('Saved: %s\n\n', output_file);

% Figure 6: Time-domain overlay for true code-rate comparison
% IMPORTANT: This figure compares two code rates (chip durations), not sampling densities.
% The PRN chip sequence is the same; only chip period changes with code rate.
figure('Name', 'PRN1 CA Autocorr Comparison - Time Domain', 'Color', 'w', 'Position', [120 120 1400 550]);

% Convert lag axes to time (microseconds)
Rc_slow = 1.023e6;   % chips/s
Rc_fast = 10.23e6;   % chips/s
Tc_slow = 1 / Rc_slow;   % seconds/chip
Tc_fast = 1 / Rc_fast;   % seconds/chip
lags_time_us_1023 = lags_1023 * Tc_slow * 1e6;
lags_time_us_10230 = lags_1023 * Tc_fast * 1e6;

% Theoretical main-lobe full width (zero-crossing to zero-crossing)
main_lobe_width_slow_us = 2 * Tc_slow * 1e6;
main_lobe_width_fast_us = 2 * Tc_fast * 1e6;
width_ratio = main_lobe_width_slow_us / main_lobe_width_fast_us;

subplot(1,2,1);
time_window_us = 3.0;
idx_t1 = abs(lags_time_us_1023) <= time_window_us;
idx_t2 = abs(lags_time_us_10230) <= time_window_us;
plot(lags_time_us_1023(idx_t1), autocorr_1023(idx_t1), 'b-o', 'LineWidth', 2, 'MarkerSize', 5);
hold on;
plot(lags_time_us_10230(idx_t2), autocorr_1023(idx_t2), 'r-', 'LineWidth', 1.8);
grid on;
xlabel('Delay (\mus)');
ylabel('Autocorrelation Value');
title('Time Domain Overlay by Code Rate (+/- 3 \mus)');
legend('1.023 MHz', '10.23 MHz', 'Location', 'north');
set(gca, 'FontSize', 11, 'FontWeight', 'bold');
xlim([-time_window_us time_window_us]);

subplot(1,2,2);
time_window_us_zoom = 1.2;
idx_t1_zoom = abs(lags_time_us_1023) <= time_window_us_zoom;
idx_t2_zoom = abs(lags_time_us_10230) <= time_window_us_zoom;
plot(lags_time_us_1023(idx_t1_zoom), autocorr_1023(idx_t1_zoom), 'b-o', 'LineWidth', 2.2, 'MarkerSize', 6);
hold on;
plot(lags_time_us_10230(idx_t2_zoom), autocorr_1023(idx_t2_zoom), 'r-', 'LineWidth', 2);
grid on;
xlabel('Delay (\mus)');
ylabel('Autocorrelation Value');
title('Main Lobe in Time (Code Rate Effect, +/- 1.2 \mus)');
legend('1.023 MHz', '10.23 MHz', 'Location', 'north');
set(gca, 'FontSize', 11, 'FontWeight', 'bold');
xlim([-time_window_us_zoom time_window_us_zoom]);

text(-1.1, 0.18, sprintf('Main-lobe width (1.023 MHz): %.3f \mus', main_lobe_width_slow_us), ...
    'FontSize', 9, 'Color', 'b');
text(-1.1, 0.08, sprintf('Main-lobe width (10.23 MHz): %.3f \mus', main_lobe_width_fast_us), ...
    'FontSize', 9, 'Color', 'r');
text(-1.1, -0.02, sprintf('Width ratio: %.1f:1', width_ratio), ...
    'FontSize', 9, 'Color', [0.1 0.1 0.1], 'FontWeight', 'bold');

output_file = fullfile(output_dir, 'ca_autocorr_time_comparison.png');
print(gcf, output_file, '-dpng', '-r150');
fprintf('Saved: %s\n\n', output_file);

%% 5. Compute and Display Statistics
fprintf('====== Statistical Analysis ======\n');
fprintf('1.023 MHz Rate:\n');
fprintf('  Peak autocorrelation: %.6f (at zero delay)\n', autocorr_1023(center_idx));
fprintf('  Minimum autocorrelation: %.6f\n', min(autocorr_1023));
fprintf('  Mean autocorrelation: %.6f\n', mean(autocorr_1023));

fprintf('\n10.23 MHz Rate:\n');
fprintf('  Peak autocorrelation: %.6f (at zero delay)\n', autocorr_10230(center_idx_10x));
fprintf('  Minimum autocorrelation: %.6f\n', min(autocorr_10230));
fprintf('  Mean autocorrelation: %.6f\n', mean(autocorr_10230));

% Compute sidelobe analysis
sidelobe_1023 = max([autocorr_1023(center_idx-1023:center_idx-1), autocorr_1023(center_idx+1:center_idx+1023)]);
fprintf('\nSidelobe Analysis:\n');
fprintf('  1.023 MHz peak sidelobe: %.6f\n', sidelobe_1023);
fprintf('  Sidelobe to mainlobe ratio: %.4f\n', sidelobe_1023/autocorr_1023(center_idx));

fprintf('\nTime-Domain Main-Lobe Width (Theory):\n');
fprintf('  1.023 MHz width: %.6f us\n', main_lobe_width_slow_us);
fprintf('  10.23 MHz width: %.6f us\n', main_lobe_width_fast_us);
fprintf('  Width ratio (slow/fast): %.2f\n', width_ratio);

fprintf('\nAnalysis Complete! All plots saved.\n');
