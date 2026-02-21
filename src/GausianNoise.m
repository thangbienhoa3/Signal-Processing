% Step 1: Define system parameters
clc; clear; close all;
fs = 1000;             % Sampling frequency (Hz)
t = 0:1/fs:1;          % Time vector from 0 to 1 second
fc = 5;                % Carrier frequency of the cosine signal (Hz)
A = 2;                 % Amplitude of the cosine signal

% Step 2: Generate the transmitted cosine signal
s_t = A * cos(2 * pi * fc * t);

% Step 3: Define noise statistical parameters and generate noise
mu = 0;                % Mean of the Gaussian noise
sigma = 0.8;           % Standard deviation of the noise (sqrt of variance)
% randn generates standard normal variables (mean 0, variance 1)
% We scale by sigma and add mu to match our desired distribution
n_t = sigma * randn(1, length(t)) + mu;

% Step 4: Simulate the AWGN channel (Interference)
% The received signal is the addition of the transmitted signal and the noise
r_t = s_t + n_t;

% Step 5: Plot the results
figure;

% Plot original transmitted signal
subplot(3,1,1);
plot(t, s_t, 'LineWidth', 1.5);
title('Transmitted Signal: s(t) = A cos(2\pi f_c t)');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

% Plot pure Gaussian noise
subplot(3,1,2);
plot(t, n_t, 'r');
title(['Gaussian Noise: n(t), \mu = ', num2str(mu), ', \sigma^2 = ', num2str(sigma^2)]);
xlabel('Time (s)'); ylabel('Amplitude');
grid on;

% Plot received signal with interference
subplot(3,1,3);
plot(t, r_t, 'k', 'LineWidth', 1.2);
title('Received Signal (Interference): r(t) = s(t) + n(t)');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;
