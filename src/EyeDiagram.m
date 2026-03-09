% ========================================================================
% QPSK Pulse Shaping using Raised Cosine Filter and Eye Diagram Analysis
%
% This program simulates the pulse shaping process in a QPSK digital
% communication system using Raised Cosine filters with different
% roll-off factors.
%
% Main steps of the simulation:
%
% 1. Generate a random QPSK symbol sequence where each symbol contains
%    an in-phase (I) and quadrature (Q) component represented as
%    complex numbers.
%
% 2. Perform upsampling of the symbol sequence to increase the sampling
%    rate before pulse shaping.
%
% 3. Construct Raised Cosine filters using the analytical formula:
%
%       g(t) = sinc(t) * cos(pi*alpha*t) / (1 - (2*alpha*t)^2)
%
%    where:
%       alpha = roll-off factor.
%
% 4. Two filters are implemented for comparison:
%
%       alpha = 0.5  → moderate bandwidth expansion
%       alpha = 1    → wider bandwidth but reduced intersymbol interference
%
% 5. The upsampled symbol sequence is passed through the filters using
%    convolution to obtain the transmitted baseband signal.
%
% 6. The filtered signal is reshaped to generate eye diagrams, which
%    visualize the level of intersymbol interference (ISI).
%
% 7. Eye diagrams for different roll-off factors are plotted to illustrate
%    how the roll-off parameter affects signal quality and timing margin.
%
% This simulation helps demonstrate the role of pulse shaping filters in
% digital communication systems and how Raised Cosine filters control
% bandwidth and intersymbol interference.
% ========================================================================


clc; clear; close all;

%% Parameters
N = 10^4;              % number of symbols
fs = 10;               % sampling frequency

%% Generate random QPSK symbols
am = 2*(rand(1,N)>0.5)-1 + 1i*(2*(rand(1,N)>0.5)-1);

%% Time vector for filters
t = -fs:1/fs:fs;

%% ----- sinc filter -----
sincNum = sin(pi*t);
sincDen = pi*t;

sincOp = sincNum ./ sincDen;
sincDenZero = find(abs(sincDen) < 1e-10);
sincOp(sincDenZero) = 1;      % limit sin(pi*x)/(pi*x) = 1 at x=0

%% ===== Raised Cosine Filter (alpha = 0.5) =====
alpha = 0.5;

cosNum = cos(alpha*pi*t);
cosDen = (1 - (2*alpha*t).^2);

cosOp = cosNum ./ cosDen;
cosDenZero = find(abs(cosDen) < 1e-10);
cosOp(cosDenZero) = pi/4;

gt_alpha5 = sincOp .* cosOp;

%% ===== Raised Cosine Filter (alpha = 1) =====
alpha = 1;

cosNum = cos(alpha*pi*t);
cosDen = (1 - (2*alpha*t).^2);

cosOp = cosNum ./ cosDen;
cosDenZero = find(abs(cosDen) < 1e-10);
cosOp(cosDenZero) = pi/4;

gt_alpha1 = sincOp .* cosOp;

%% ===== Upsampling =====
amUpSampled = [am; zeros(fs-1,length(am))];
amU = amUpSampled(:).';

%% ===== Pulse shaping (convolution) =====
st_alpha5 = conv(amU, gt_alpha5);
st_alpha1 = conv(amU, gt_alpha1);

%% Take first samples for visualization
st_alpha5 = st_alpha5(1:10000);
st_alpha1 = st_alpha1(1:10000);

%% ===== Eye Diagram preparation =====
st_alpha5_reshape = reshape(st_alpha5, fs*2, length(st_alpha5)/(fs*2)).';
st_alpha1_reshape = reshape(st_alpha1, fs*2, length(st_alpha1)/(fs*2)).';
%% ===== Eye diagram alpha = 0.5 =====
figure;
plot(0:1/fs:1.99, real(st_alpha5_reshape).', 'b');
title('Eye diagram with alpha = 0.5');
xlabel('time');
ylabel('amplitude');
grid on;

%% ===== Eye diagram alpha = 1 =====
figure;
plot(0:1/fs:1.99, real(st_alpha1_reshape).', 'b');
title('Eye diagram with alpha = 1');
xlabel('time');
ylabel('amplitude');
grid on;
