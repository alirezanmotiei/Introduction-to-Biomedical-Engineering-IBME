% Vectorcardiography (VCG) Synthesis & 12-Lead ECG Reconstruction
% =========================================================================
% Author: Alireza Najafi Motiei (Student ID: 810100224)
% Course: Introduction to Biomedical Engineering (IBME), Fall 2023
% Instructor: Dr. Majid Badiee Rostami
% Department: Faculty of Electrical and Computer Engineering, University of Tehran
% =========================================================================

clc;
clear;
close all;
%% time
data1=load('v1.mat');
data2=load('v2.mat');
data3=load('v3.mat');
data1=data1.val(1,:);
data2=data2.val(1,:);
data3=data3.val(1,:);
T=10;
fs=length(data3)/T;
t=0:1/fs:T-1/fs;
subplot(3,1,1)
plot(t,data1);
xlabel ('Time')
ylabel ('data1')
title ('data1(t)')
hold on
subplot(3,1,2)
plot(t,data2);
xlabel ('Time')
ylabel ('data2')
title ('data2(t)')
hold on
subplot(3,1,3)
plot(t,data3);
xlabel ('Time')
ylabel ('data3')
title ('data3(t)')
figure
%% fft_data1
n = length(data1);
f = (-fs/2) : (fs/n) : (fs/2)-(fs/n);
y1 = fftshift(fft(data1));
hold on
subplot(2, 1, 1);
plot(f, abs(y1));
title('Fourier Transform Of Data1');
xlabel 'Frequency (Hz)'
ylabel 'Magnitude'
Theta = angle(y1);
subplot(2, 1, 2);
plot(f, (Theta));
title('Signal Phase');
xlabel 'Frequency (Hz)'
ylabel 'Phase'
figure
%% fft_data2
y2 = fftshift(fft(data2));
hold on
subplot(2, 1, 1);
plot(f, abs(y2));
title('Fourier Transform Of Data2');
xlabel 'Frequency (Hz)'
ylabel 'Magnitude'
Theta = angle(y2);
subplot(2, 1, 2);
plot(f, (Theta));
title('Signal Phase');
xlabel 'Frequency (Hz)'
ylabel 'Phase'
figure
%% fft_data3
y3 = fftshift(fft(data3));
hold on
subplot(2, 1, 1);
plot(f, abs(y3));
title('Fourier Transform Of Data3');
xlabel 'Frequency (Hz)'
ylabel 'Magnitude'
Theta = angle(y3);
subplot(2, 1, 2);
plot(f, (Theta));
title('Signal Phase');
xlabel 'Frequency (Hz)'
ylabel 'Phase'
figure
%% dividing freqs
%data1 was chosen
delta=zeros(1,length(data1));
theta=zeros(1,length(data1));
alpha=zeros(1,length(data1));
beta=zeros(1,length(data1));
gamma=zeros(1,length(data1));
for i = 1:length(f) 
    if (abs(f(i)) > 0.5 &&  abs(f(i)) <= 4)
        delta(i) = y1(i) ;
    elseif( abs(f(i)) > 4 && abs(f(i)) <= 8 )
        theta(i)= y1(i);
    elseif( abs(f(i)) >= 8 && abs(f(i)) <= 13 )
        alpha(i)= y1(i);
    elseif( abs(f(i)) >= 13 && abs(f(i)) <= 35 )
        beta(i)= y1(i)   ;          
    elseif( abs(f(i)) >= 35 ) 
       gamma(i)= y1(i)  ;
    end
end
delta_t=ifft(ifftshift(delta));
theta_t=ifft(ifftshift(theta));
alpha_t=ifft(ifftshift(alpha));
beta_t=ifft(ifftshift(beta));
gamma_t=ifft(ifftshift(gamma));
subplot(5,1,1)
plot(t,delta_t);
xlabel ('Time')
ylabel ('delta')
title ('Delta(t)')
hold on
subplot(5,1,2)
plot(t,theta_t);
xlabel ('Time')
ylabel ('theta')
title ('Theta(t)')
hold on
subplot(5,1,3)
plot(t,alpha_t);
xlabel ('Time')
ylabel ('alpha')
title ('Alpha(t)')
hold on
subplot(5,1,4)
plot(t,beta_t);
xlabel ('Time')
ylabel ('beta')
title ('Beta(t)')
hold on
subplot(5,1,5)
plot(t,gamma_t);
xlabel ('Time')
ylabel ('gamma')
title ('Gamma(t)')
hold on





