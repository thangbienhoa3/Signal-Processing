clc; clear; close all;

rng(1);                     % reproducible

%% ================= PARAMETERS =================
Ns = 10;                     % samples per symbol
Nb = 1e6;                   % number of bits
EbN0_dB = 0:2:12;           % SNR range

BER = zeros(size(EbN0_dB));

%% ================= BIT GENERATION =================
bits = randi([0 1], 1, Nb);
symbols = 2*bits - 1;       % BPSK

%% ================= NRZ GENERATION =================
nrz_signal = repelem(symbols, Ns);

% ---- Energy normalization ----
nrz_signal = nrz_signal / sqrt(Ns);   % now Eb = 1

%% ================= LOOP OVER SNR =================
for i = 1:length(EbN0_dB)

    EbN0 = 10^(EbN0_dB(i)/10);

    % Since Eb = 1:
    sigma = sqrt(1/(2*EbN0));

    noise = sigma * randn(size(nrz_signal));
    rx_noisy = nrz_signal + noise;

    %% Matched filter (rectangular)
    h = ones(1, Ns) / sqrt(Ns);  % normalized
    rx_signal = conv(rx_noisy, h);

    %% Sampling
    delay = Ns - 1;
    sample_index = delay + 1 : Ns : delay + 1 + Ns*(Nb-1);
    recovered = rx_signal(sample_index);

    %% Decision
    detected_bits = recovered > 0;

    %% BER
    BER(i) = sum(bits ~= detected_bits)/Nb;

end

%% ================= THEORY =================
theory = 0.5 * erfc(sqrt(10.^(EbN0_dB/10)));

%% ================= PLOT =================
figure;
semilogy(EbN0_dB, BER, 'o-'); hold on;
semilogy(EbN0_dB, theory, '--');
grid on;
xlabel('Eb/N0 (dB)');
ylabel('BER');
legend('Simulation','Theory');
title('BPSK over AWGN (NRZ)');
