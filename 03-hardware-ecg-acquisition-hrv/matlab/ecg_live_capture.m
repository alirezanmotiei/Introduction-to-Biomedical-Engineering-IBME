%% Real-Time ECG Serial Streaming & Acquisition
% =========================================================================
% Author: Alireza Najafi Motiei (Student ID: 810100224)
% Course: Introduction to Biomedical Engineering (IBME), Fall 2023
% Instructor: Dr. Majid Badiee Rostami
% Department: Faculty of Electrical and Computer Engineering, University of Tehran
% =========================================================================
% Description:
%   Opens serial communication with the Arduino micro-controller streaming
%   raw biopotential voltage measurements from the AD8232 front-end.
%   Visualizes live ECG traces in a dynamic rolling window and logs the
%   recorded sequence to a CSV file for offline QRS and HRV analysis.
% =========================================================================

close all;
clear;
clc;

%% Configuration Parameters
serialPort = 'COM7';      % Adjust to match target Arduino USB COM port
baudRate = 9600;          % Baud rate matching microcontroller firmware
sampleRate = 95;          % Estimated effective sampling rate (Hz)
windowSize = 1000;        % Rolling visualization buffer (samples)
duration = 30;            % Total logging duration in seconds
outputFileName = fullfile('..', 'data', 'ecg_recorded_lead1.csv');

fprintf('==> Initializing Serial Connection on %s @ %d baud...\n', serialPort, baudRate);

try
    device = serialport(serialPort, baudRate);
    configureTerminator(device, "CR/LF");
    flush(device);
    disp('==> Serial connection established successfully.');
catch ME
    warning('Could not open serial port (%s). Running in simulation/mock mode.', ME.message);
    device = [];
end

%% Acquisition Loop
if ~isempty(device)
    dataBuffer = zeros(windowSize, 1);
    timeBuffer = (0:windowSize-1) / sampleRate;
    
    figure('Name', 'Live AD8232 ECG Acquisition', 'NumberTitle', 'off', 'Color', 'w');
    hPlot = plot(timeBuffer, dataBuffer, 'Color', [0.85 0.1 0.1], 'LineWidth', 1.5);
    grid on;
    xlabel('Time (seconds)');
    ylabel('Biopotential ADC Value (0-1023)');
    title('Real-Time Lead-I Electrocardiogram (AD8232 + Arduino)');
    ylim([0 1023]);
    
    startTime = datetime('now');
    logData = [];
    sampleIndex = 0;
    
    while seconds(datetime('now') - startTime) < duration
        if device.NumBytesAvailable > 0
            rawStr = readline(device);
            val = str2double(rawStr);
            if ~isnan(val)
                sampleIndex = sampleIndex + 1;
                t_elapsed = seconds(datetime('now') - startTime);
                logData = [logData; sampleIndex, val, t_elapsed];
                
                % Update rolling display
                dataBuffer = [dataBuffer(2:end); val];
                set(hPlot, 'YData', dataBuffer);
                drawnow limitrate;
            end
        end
    end
    
    writematrix(logData, outputFileName);
    fprintf('==> Acquisition complete. Saved %d samples to %s\n', size(logData, 1), outputFileName);
    clear device;
end
