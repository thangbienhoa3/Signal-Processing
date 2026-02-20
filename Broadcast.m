FS = 44100;
TS = 1/FS;
f_carrier = 3000;
n = [1:64 * FS]; %10s of signal
t = n * TS;
carrier = sin(2*pi*f_carrier*t + pi/6);
speed = 1; %bits per second
bit_duration = 1 / speed; %length of one bit in seconds
bit_len = bit_duration * FS; %length of one bit in samples
bit_zero = -ones(1, bit_len); %bit 0
bit_one = ones(1, bit_len); %bit 1
A = [bit_zero, bit_one, bit_zero, bit_zero, bit_zero, bit_zero, bit_zero, bit_one]; % 'A' character
A = [A, A, A, A, A, A, A, A]; %8 characters fully cover 64 seconds of generated signals
x = A .* carrier;

osc = sin(2*pi*f_carrier*t);
y = x .* osc';
f_cut = f_carrier / FS;
w_cut = f_cut * 2 * pi;
n = [0:5000];
N = 2500;
h = sin(w_cut * (n - N)) ./ (pi * (n - N));
h(N + 1) = w_cut / pi;
z = filter(h, [1], y);
plot(z);
