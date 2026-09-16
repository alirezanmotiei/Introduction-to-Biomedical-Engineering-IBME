%% Frequency-Domain Spectral Analysis of ECG and HRV (Welch PSD)
% =========================================================================
% Author: Alireza Najafi Motiei (Student ID: 810100224)
% Course: Introduction to Biomedical Engineering (IBME), Fall 2023
% Instructor: Dr. Majid Badiee Rostami
% Department: Faculty of Electrical and Computer Engineering, University of Tehran
% =========================================================================
% Description:
%   Calculates:
%   1. Full frequency spectrum of raw and filtered ECG to assess noise
%      contributions (powerline 50 Hz, motion artifacts < 0.5 Hz).
%   2. Power Spectral Density (PSD) of the R-R tachogram via Welch Periodogram
%      to decompose autonomic nervous system balance:
%        - VLF (Very Low Frequency: 0.003 - 0.04 Hz)
%        - LF  (Low Frequency: 0.04 - 0.15 Hz) -> Sympathetic & Baroreflex
%        - HF  (High Frequency: 0.15 - 0.40 Hz) -> Parasympathetic / Vagal
%        - LF/HF Ratio -> Sympathovagal Balance Index
% =========================================================================

close all;
clear;
clc;

dataPath = fullfile('..', 'data', 'ecg_recorded_lead1.csv');
data = readmatrix(dataPath);
ecg_raw = data(:, 2);
fs = 95;
N = length(ecg_raw);
time = (0:N-1) / fs;

%% 1. ECG Fourier Frequency Analysis
f_axis = (0:N-1) * (fs / N);
ecg_fft = abs(fft(ecg_raw)) / N;

%% 2. R-Peak Extraction for Tachogram
[b, a] = butter(2, [0.5 40] / (fs / 2), 'bandpass');
ecg_filt = filtfilt(b, a, ecg_raw);
ecg_norm = (ecg_filt - min(ecg_filt)) / (max(ecg_filt) - min(ecg_filt));

minPeakDist = round(0.45 * fs);
[~, locs] = findpeaks(ecg_norm, 'MinPeakHeight', 0.55, 'MinPeakDistance', minPeakDist);
r_times = time(locs);
rr_intervals = diff(r_times); % in seconds

%% 3. Welch Periodogram PSD of HRV
[pxx, f_psd] = periodogram(rr_intervals, [], [], fs);

%% 4. Band Energy Integration
vlf_mask = (f_psd >= 0.003) & (f_psd < 0.04);
lf_mask  = (f_psd >= 0.04)  & (f_psd < 0.15);
hf_mask  = (f_psd >= 0.15)  & (f_psd <= 0.40);

vlf_power = trapz(f_psd(vlf_mask), pxx(vlf_mask));
lf_power  = trapz(f_psd(lf_mask),  pxx(lf_mask));
hf_power  = trapz(f_psd(hf_mask),  pxx(hf_mask));
lf_hf_ratio = lf_power / max(hf_power, eps);

fprintf('==> Autonomic HRV Spectral Metrics:\n');
fprintf('    VLF Power : %.5f s^2\n', vlf_power);
fprintf('    LF Power  : %.5f s^2\n', lf_power);
fprintf('    HF Power  : %.5f s^2\n', hf_power);
fprintf('    LF/HF     : %.3f\n', lf_hf_ratio);

%% 5. Plotting
figure('Name', 'Spectral Decomposition', 'Color', 'w', 'Position', [150 150 900 500]);

subplot(2, 1, 1);
plot(f_axis(1:floor(N/2)), ecg_fft(1:floor(N/2)), 'Color', [0.1 0.4 0.7], 'LineWidth', 1.2);
grid on;
title('Single-Sided Amplitude Spectrum of Raw Biopotential Signal |FFT|');
xlabel('Frequency (Hz)');
ylabel('Normalized Magnitude');
xlim([0 50]);

subplot(2, 1, 2);
plot(f_psd, pxx, 'Color', [0.8 0.2 0.2], 'LineWidth', 1.4); hold on;
area(f_psd(lf_mask), pxx(lf_mask), 'FaceColor', [1 0.8 0.4], 'FaceAlpha', 0.5);
area(f_psd(hf_mask), pxx(hf_mask), 'FaceColor', [0.4 0.8 1], 'FaceAlpha', 0.5);
grid on;
title(sprintf('HRV Power Spectral Density (LF/HF Ratio: %.2f)', lf_hf_ratio));
xlabel('Frequency (Hz)');
ylabel('PSD (s^2 / Hz)');
xlim([0 0.5]);
legend('Total PSD', 'LF Band (0.04-0.15 Hz)', 'HF Band (0.15-0.40 Hz)');
