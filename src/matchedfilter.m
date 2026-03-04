clc; clear; close all;

pkg load control

Ns = 100;                       % samples per symbol
bits = [0 1 0 0 1 1];
symbols = 2*bits - 1;          % BPSK

% ---- Cosine pulse ----
n = 0:Ns-1;
pulse = cos( pi*(2*n-(Ns-1))/(2*Ns) );

% ---- Signal generation ----
nrz_signal = zeros(1, length(symbols)*Ns);

for k = 1:length(symbols)
    start_index = (k-1)*Ns + 1;
    end_index   = k*Ns;
    nrz_signal(start_index:end_index) = symbols(k);
end

EbN0_dB = 20;                 % SNR theo dB (bạn có thể thay đổi)
EbN0 = 10^(EbN0_dB/10);
Eb = sum(pulse.^2);          % năng lượng 1 bit
sigma = sqrt(Eb/(2*EbN0));
noise = sigma * randn(1, length(nrz_signal));
rx_noisy = nrz_signal + noise;


%% ================= MATCHED FILTER =================
% Matched filter của NRZ là chính nó (rectangular pulse)
h = ones(1, Ns);
rx_signal = conv(rx_noisy, h);
%% ================= SAMPLING =================
delay = Ns - 1;  % delay của FIR rectangular

sample_index = delay + 1 : Ns : delay + 1 + Ns*(length(symbols)-1);

recovered = rx_signal(sample_index);

%% ================= DECISION =================
detected_bits = recovered > 0;

%% ================= DISPLAY =================
disp("Original bits:");
disp(bits);

disp("Detected bits:");
disp(detected_bits);

%% ================= PLOT =================
figure;

subplot(4,1,1);
stem(symbols);
title('BPSK Symbols');
grid on;

subplot(4,1,2);
plot(nrz_signal);
title('Transmit Signal');
grid on;

subplot(4,1,3);
plot(rx_noisy);
title(['Received Signal with AWGN (Eb/N0 = ', num2str(EbN0_dB),' dB)']);
grid on;

subplot(4,1,4);
plot(rx_signal); hold on;
stem(sample_index, recovered, 'r');
title('After Matched Filter');
grid on;
