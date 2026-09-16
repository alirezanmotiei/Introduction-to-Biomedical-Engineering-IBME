%% Pan-Tompkins Style QRS Detection & Time-Domain HRV Metrics
% =========================================================================
% Author: Alireza Najafi Motiei (Student ID: 810100224)
% Course: Introduction to Biomedical Engineering (IBME), Fall 2023
% Instructor: Dr. Majid Badiee Rostami
% Department: Faculty of Electrical and Computer Engineering, University of Tehran
% =========================================================================
% Description:
%   Performs baseline wander removal, 2nd-order zero-phase Butterworth
%   bandpass filtering (0.5 - 45 Hz), adaptive peak thresholding to detect
%   cardiac R-peaks, and computes standard clinical Heart Rate Variability (HRV)
%   metrics:
%     - Mean RR interval (ms)
%     - Mean Heart Rate (BPM)
%     - SDNN (Standard Deviation of NN intervals)
%     - RMSSD (Root Mean Square of Successive Differences)
%     - pNN50 (Percentage of successive intervals > 50 ms)
% =========================================================================

close all;
clear;
clc;

%% 1. Load Experimental ECG Data
dataPath = fullfile('..', 'data', 'ecg_recorded_lead1.csv');
if ~exist(dataPath, 'file')
    error('ECG data file not found at: %s', dataPath);
end

data = readmatrix(dataPath);
ecg_raw = data(:, 2);
fs = 95;  % Sampling frequency (Hz)
N = length(ecg_raw);
time = (0:N-1) / fs;

%% 2. Bandpass Filtering (Zero-Phase Butterworth)
% Retain clinical ECG diagnostic bandwidth (0.5 to 45 Hz)
lowCutoff = 0.5;
highCutoff = 40.0;
[b, a] = butter(2, [lowCutoff highCutoff] / (fs / 2), 'bandpass');
ecg_filtered = filtfilt(b, a, ecg_raw);

% Normalize for consistent amplitude thresholding
ecg_norm = (ecg_filtered - min(ecg_filtered)) / (max(ecg_filtered) - min(ecg_filtered));

%% 3. R-Peak Detection
% Physiological constraints: Min distance 0.4s (~150 BPM max at rest)
minPeakDist = round(0.45 * fs);
minPeakHeight = 0.55;

[pks, locs] = findpeaks(ecg_norm, 'MinPeakHeight', minPeakHeight, 'MinPeakDistance', minPeakDist);
r_times = time(locs);

%% 4. Heart Rate Variability (HRV) Computation
rr_intervals_sec = diff(r_times);
rr_intervals_ms = rr_intervals_sec * 1000;

mean_RR = mean(rr_intervals_ms);
std_RR  = std(rr_intervals_ms);          % SDNN
bpm_inst = 60 ./ rr_intervals_sec;
mean_BPM = mean(bpm_inst);

% Successive difference metrics
diff_RR = diff(rr_intervals_ms);
rmssd   = sqrt(mean(diff_RR .^ 2));      % RMSSD
nn50    = sum(abs(diff_RR) > 50);
pnn50   = (nn50 / length(diff_RR)) * 100; % pNN50 (%)

%% 5. Display Statistical Results
fprintf('\n========================================================\n');
fprintf('  BIOMEDICAL HEART RATE & HRV STATISTICAL REPORT\n');
fprintf('========================================================\n');
fprintf('  Subject Recording Duration : %.2f seconds (%d samples)\n', time(end), N);
fprintf('  Total R-Peaks Detected     : %d beats\n', length(locs));
fprintf('  Mean Heart Rate (BPM)      : %.2f BPM\n', mean_BPM);
fprintf('  Mean RR Interval           : %.2f ms\n', mean_RR);
fprintf('  SDNN (Overall HRV)         : %.2f ms\n', std_RR);
fprintf('  RMSSD (Parasympathetic)    : %.2f ms\n', rmssd);
fprintf('  pNN50                      : %.2f %%\n', pnn50);
fprintf('========================================================\n\n');

%% 6. Visualization
figure('Name', 'ECG R-Peak Detection & HRV Analysis', 'Color', 'w', 'Position', [100 100 1000 650]);

subplot(2, 1, 1);
plot(time, ecg_norm, 'Color', [0.1 0.3 0.6], 'LineWidth', 1.2); hold on;
plot(r_times, pks, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6);
grid on;
title(sprintf('Filtered ECG Signal with Detected R-Peaks (Mean HR: %.1f BPM)', mean_BPM));
xlabel('Time (s)');
ylabel('Normalized Amplitude');
legend('Filtered ECG (0.5-40 Hz)', 'R-Peaks', 'Location', 'northeast');

subplot(2, 2, 3);
plot(r_times(2:end), rr_intervals_ms, '-s', 'Color', [0.8 0.2 0.2], 'LineWidth', 1.2, 'MarkerFaceColor', 'r');
grid on;
title('Tachogram: R-R Intervals over Time');
xlabel('Time (s)');
ylabel('R-R Interval (ms)');

subplot(2, 2, 4);
histogram(rr_intervals_ms, 12, 'FaceColor', [0.2 0.6 0.4], 'EdgeColor', 'k');
grid on;
title(sprintf('R-R Interval Distribution (SDNN: %.1f ms)', std_RR));
xlabel('RR Duration (ms)');
ylabel('Beat Count');
