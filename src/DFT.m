N = 32;
x = randn(1, N); % Generate a real-valued random noise sequence
X = fft(x, N); % Compute the N-point DFT
x_reconstructed = ifft(X, N); % Compute the IDFT
% Plotting the results to verify
subplot(3,1,1); stem(x);
title('Original Signal x(n)'); xlabel('n');

subplot(3,1,2); stem(abs(X));
title(['Magnitude of FFT, N = ' num2str(N)]); xlabel('k'); ylabel('Magnitude');

subplot(3,1,3); stem(real(x_reconstructed));
title('Reconstructed Signal via IFFT'); xlabel('n');



