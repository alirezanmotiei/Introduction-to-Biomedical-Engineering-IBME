% EEG Sleep Staging: REM vs Slow-Wave Deep Sleep Classification
% =========================================================================
% Author: Alireza Najafi Motiei (Student ID: 810100224)
% Course: Introduction to Biomedical Engineering (IBME), Fall 2023
% Instructor: Dr. Majid Badiee Rostami
% Department: Faculty of Electrical and Computer Engineering, University of Tehran
% =========================================================================

clc;
clear;
close all;
load matlab.mat
find1=to_find2.Data(:,1).';
n=length(find1);
fs=to_find2.Fs(1);
t_start = 0; 
t_end = to_find2.Duration;
step = t_end / n;
t = t_start: step: t_end - step;
f = (-fs/2) : (fs/n) : (fs/2)-(fs/n);
f1=f(1:length(f)-1);
plot(t,find1);
xlabel ('Time')
ylabel ('find2')
title ('find2(t)')
figure
y1 = fftshift(fft(find1));
subplot(2, 1, 1);
plot(f, abs(y1));
title('Fourier Transform Of find2');
xlabel 'Frequency (Hz)'
ylabel 'Magnitude'
hold on
Theta = angle(y1);
subplot(2, 1, 2);
plot(f, (Theta));
title('Signal Phase');
xlabel 'Frequency (Hz)'
ylabel 'Phase'
figure
delta=zeros(1,length(find1));
theta=zeros(1,length(find1));
alpha=zeros(1,length(find1));
beta=zeros(1,length(find1));
gamma=zeros(1,length(find1));
for i = 1:length(f) 
    if (abs(f(i))>0.5 && abs(f(i))<=4)
        delta(i) = y1(i);
    elseif(abs(f(i))>4 && abs(f(i))<=8)
        theta(i)= y1(i);
    elseif(abs(f(i))>=8 && abs(f(i))<=13)
        alpha(i)= y1(i);
    elseif(abs(f(i))>=13 && abs(f(i))<=35)
        beta(i)= y1(i);          
    elseif(abs(f(i))>=35) 
       gamma(i)= y1(i);
    end
end
delta_t=ifft(ifftshift(delta));
theta_t=ifft(ifftshift(theta));
alpha_t=ifft(ifftshift(alpha));
beta_t=ifft(ifftshift(beta));
gamma_t=ifft(ifftshift(gamma));
subplot(5,1,1)
plot(t,(delta_t));
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