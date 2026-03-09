% ========================================================================
% QPSK Modulation and Demodulation Simulation with BER Analysis
%
% This program simulates a complete Quadrature Phase Shift Keying (QPSK)
% digital communication system in MATLAB.
%
% The simulation includes the following steps:
%
% 1. Generate a random binary bit sequence.
% 2. Group bits into pairs and apply Gray mapping to map each pair
%    of bits into one of four QPSK phase symbols.
% 3. Modulate the symbols using a cosine carrier with different phases
%    corresponding to the QPSK constellation points.
% 4. Construct the transmitted signal by concatenating the modulated
%    carrier signals for all symbols.
% 5. Add Additive White Gaussian Noise (AWGN) to simulate a noisy
%    communication channel.
% 6. Perform coherent demodulation at the receiver using correlation
%    with reference carrier signals of the four possible phases.
% 7. Recover the transmitted bit sequence using inverse Gray mapping.
% 8. Compute the Bit Error Rate (BER) between transmitted and received bits.
% 9. Evaluate the BER performance for different values of Eb/N0 and compare
%    the simulated BER with the theoretical BER for QPSK.
%
% The program also visualizes:
%   - Carrier signals used for QPSK
%   - Modulated QPSK waveform
%   - Received signal with noise
%   - Original and recovered bit sequences
%   - BER vs Eb/N0 performance curve
%
% This simulation helps illustrate the fundamental principles of
% digital modulation, coherent detection, and performance analysis
% of QPSK communication systems.
% ========================================================================
clear; clc; close all;

%% QPSK parameters
M = 4;                  % QPSK
k = log2(M);            % Bits per symbol
Tb = 1;                 % Bit period
Ts = k * Tb;            % Symbol period
Rs = 1 / Ts;            % Symbol rate
f = 2 * Rs;             % Carrier frequency
num_samples = 100;      % Samples per symbol

t = Ts * (0:1/num_samples:1-1/num_samples);
carrier_signal = @(phase) cos(2*pi*f*t + phase);

%% Display carrier signals
phases = 2*pi*(0:M-1)/M;

figure;
hold on;
for i = 1:M
    plot(t, carrier_signal(phases(i)), 'LineWidth', 1.2);
end
xlabel('Time (s)');
ylabel('Amplitude');
title('Carrier signals for QPSK');
legend(arrayfun(@(x) sprintf('Phase = %.2f rad', x), phases, 'UniformOutput', false));
grid on;
hold off;

%% Generate random bits
len_bits = 500;
bits = randi([0 1], 1, len_bits);

num_symbols = floor(len_bits / k);
bits = bits(1:num_symbols * k);
bit_pairs = reshape(bits, k, []).';

%% Gray mapping
gray_map = containers.Map( ...
    {'00','01','11','10'}, ...
    {0, pi/2, pi, 3*pi/2} ...
);

symbol_phases = zeros(1, num_symbols);

for i = 1:num_symbols
    key = sprintf('%d%d', bit_pairs(i,1), bit_pairs(i,2));
    symbol_phases(i) = gray_map(key);
end

%% Modulation
modulation = [];

for i = 1:num_symbols
    modulation = [modulation, carrier_signal(symbol_phases(i))];
end

t_sequence = 0:(Ts/num_samples):(num_symbols*Ts - Ts/num_samples);

figure;
plot(t_sequence, modulation, 'LineWidth', 1.1);
title('QPSK Modulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

%% Add AWGN
mu = 0;
No = 10;
noise = sqrt(No/2) * randn(1, length(modulation)) + mu;
r_t = modulation + noise;

figure;
plot(t_sequence, r_t, 'LineWidth', 1.0);
title('QPSK Modulated Signal with AWGN');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

%% Demodulation
gray_map_inv = containers.Map( ...
    {0, pi/2, pi, 3*pi/2}, ...
    {[0 0], [0 1], [1 1], [1 0]} ...
);

demod_bits = [];

reference_carriers = containers.Map('KeyType','double','ValueType','any');
for p = phases
    reference_carriers(p) = carrier_signal(p);
end

for i = 1:num_symbols
    symbol = r_t((i-1)*num_samples + 1 : i*num_samples);

    max_corr = -Inf;
    best_phase = 0;

    for p = phases
        ref = reference_carriers(p);
        corr_val = trapz(symbol .* ref);

        if corr_val > max_corr
            max_corr = corr_val;
            best_phase = p;
        end
    end

    demod_bits = [demod_bits, gray_map_inv(best_phase)];
end

%% Plot original and demodulated bits
y_bit = repelem(bits(1:length(demod_bits)), num_samples);
x_bit = Tb * (0:length(y_bit)-1) / num_samples;
demo_bit = repelem(demod_bits, num_samples);

figure;
stairs(x_bit, y_bit, 'LineWidth', 1.2);
title('Original Bit Sequence');
ylim([-0.2, 1.2]);
grid on;

figure;
stairs(x_bit, demo_bit, 'LineWidth', 1.2);
title('Demodulated Bit Sequence');
ylim([-0.2, 1.2]);
grid on;

%% Compute BER for this noise level
P_b = sum(demod_bits ~= bits(1:length(demod_bits))) / length(demod_bits) * 100;
fprintf('BER: %.2f%%\n', P_b);

%% BER simulation over Eb/N0
Eb = trapz(modulation(1:num_samples).^2) / k;
Eb_No_db = linspace(-10, 4, 100);
BER_sim = zeros(size(Eb_No_db));

reference_carriers = containers.Map('KeyType','double','ValueType','any');
for p = phases
    reference_carriers(p) = carrier_signal(p);
end

for idx = 1:length(Eb_No_db)
    Eb_No = 10^(Eb_No_db(idx)/10);
    No_i = Eb / Eb_No;

    noise = sqrt(No_i/2) * randn(1, length(modulation));
    r_t = modulation + noise;

    demod_bits = [];

    for i = 1:num_symbols
        symbol = r_t((i-1)*num_samples + 1 : i*num_samples);

        max_corr = -Inf;
        best_phase = 0;

        for p = phases
            ref = reference_carriers(p);
            corr_val = trapz(symbol .* ref);

            if corr_val > max_corr
                max_corr = corr_val;
                best_phase = p;
            end
        end

        demod_bits = [demod_bits, gray_map_inv(best_phase)];
    end

    BER_sim(idx) = sum(demod_bits ~= bits(1:length(demod_bits))) / length(demod_bits);
end

%% Theoretical BER
Eb_No = 10.^(Eb_No_db/10);
BER_theory = 0.5 * erfc(sqrt(Eb_No));

figure;
semilogy(Eb_No_db, BER_theory, 'LineWidth', 2);
hold on;
semilogy(Eb_No_db, BER_sim, '.', 'MarkerSize', 10);
xlabel('$E_b/N_0$ (dB)', 'Interpreter', 'latex');
ylabel('BER');
title('BER vs $E_b/N_0$ for QPSK');
legend('Theoretical BER', 'Simulated BER');
grid on;
hold off;
