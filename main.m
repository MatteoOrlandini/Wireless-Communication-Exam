
clc
clear all
close all

%% load data
signal1 = load('Signal_1.mat');
signal2 = load('Signal_2.mat');
signal_IQ10 = load('Signal_IQ10.mat');
signal_IQ20 = load('Signal_IQ20.mat');
signal_IQ30 = load('Signal_IQ30.mat');

%% delete first signal zeroes
%signal_array = reshape(signal1.simout', 1,[]);
%simout = delete_first_zeroes(signal_array);

%% Apply IQ imbal to original signal
ampImb = 20*log10(1.3); % 30% imbalance
phImb = 0; % 0 degrees
Fs = 2e05; % sampling frequency
[imbalanced_signal,imbalanced_signal_timeseries] = apply_IQ_imbal(signal1.simout, ampImb, phImb, Fs);

figure('Name','Real part of original signal vs real part of imbalanced signal','NumberTitle','off');
plot(real(signal1.simout(end, end-1000:end)));
hold on
plot(real(imbalanced_signal(end, end-1000:end)));
xlim([0 1000]);
legend('Original signal', 'Imbalanced signal');

figure('Name','Imaginary part of original signal vs imaginary part of imbalanced signal','NumberTitle','off');
plot(imag(signal1.simout(end, end-1000:end)));
hold on
plot(imag(imbalanced_signal(end, end-1000:end)));
xlim([0 1000]);
legend('Original signal', 'Imbalanced signal');

%% Imbalance correction
corrected_signal = imbalance_correction(reshape(imbalanced_signal.', 1, []), ampImb, phImb);

figure('Name','Real part of corrected signal vs real part of original signal','NumberTitle','off');
plot(corrected_signal(1, end-1000:end));
hold on
plot(real(signal1.simout(end, end-1000:end)));
xlim([0 1000]);
legend('Corrected signal', 'Original signal');

figure('Name','Imaginary part of corrected signal vs real part of original signal','NumberTitle','off');
plot(corrected_signal(2, end-1000:end));
hold on
plot(imag(signal1.simout(end, end-1000:end)));
xlim([0 1000]);
legend('Corrected signal', 'Original signal');

%% Imbalance estimation of imbalanced_signal
[ampImbEst phImbEst] = imbalance_estimation(reshape(imbalanced_signal.', [], 1));
% Compare the estimated imbalance values with the specified ones.
[ampImbEst phImbEst; ampImb phImb]

%% Imbalance estimation of signal_IQ30
[ampImbEst phImbEst] = imbalance_estimation(reshape((signal_IQ30.simout)', [],1))
% Compare the estimated imbalance values with the specified ones.
[ampImbEst phImbEst; ampImb phImb]

%% Imbalance algorithm
signal_IQ30_after_carrier_synch = load('Signal_IQ30_after_carrier_synch.mat');
[ampImbEst] = imbalance_algorithm_estimation(reshape((signal_IQ30_after_carrier_synch.simout)', 1,[]))