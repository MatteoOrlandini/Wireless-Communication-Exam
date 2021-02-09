clc
clear all
close all

%% load data
[signal1, signal2, signal_IQ10, signal_IQ20, signal_IQ30] = load_data(["Signal_1.mat";...
    "Signal_2.mat"; "Signal_IQ10.mat"; "Signal_IQ20.mat"; "Signal_IQ30.mat"]);

%% delete first signal zeroes
%simout = delete_first_zeroes(signal2.simout);

%% Apply IQ imbal to original signal
ampImb = 20*log10(1.3); % 30% imbalance
phImb = 0;
[imbalanced_signal,imbalanced_signal_timeseries] = apply_IQ_imbal(signal2.simout, ampImb, phImb);

figure('Name','Real part of original signal vs real part of imbalanced signal','NumberTitle','off');
plot(real(signal2.simout(1:1000)));
hold on
plot(real(imbalanced_signal(1:1000)));
legend('Original signal', 'Imbalanced signal');

figure('Name','Imaginary part of original signal vs imaginary part of imbalanced signal','NumberTitle','off');
plot(imag(signal2.simout(1:1000)));
hold on
plot(imag(imbalanced_signal(1:1000)));
legend('Original signal', 'Imbalanced signal');

%{
imbal1 = std(real(reshape(signal2.simout, 1, [])))./std(imag(reshape(signal2.simout, 1, [])));
imbal2 = std(real(reshape(y, 1, [])))./std(imag(reshape(y, 1, [])));
imbal3 = std(real(reshape(signal_IQ30.simout, 1, [])))./std(imag(reshape(signal_IQ30.simout, 1, [])));
%}

%% Imbalance correction
corrected_signal = imbalance_correction(imbalanced_signal, ampImb, phImb);

figure('Name','Corrected signal and original signal comparison','NumberTitle','off');
subplot(2,1,1);
plot(corrected_signal(1, 1:1000));
hold on
plot(real(signal2.simout(1:1000)));
title('Real part of corrected signal vs real part of original signal');
legend('Corrected signal', 'Original signal');
subplot(2,1,2);
plot(corrected_signal(2, 1:1000));
hold on
plot(imag(signal2.simout(1:1000)));
title('Imaginary part of corrected signal vs imaginary part of original signal');
legend('Corrected signal', 'Original signal');

%% Imbalance estimation of imbalanced_signal
[ampImbEst phImbEst] = imbalance_estimation(imbalanced_signal);
% Compare the estimated imbalance values with the specified ones.
[ampImbEst phImbEst; ampImb phImb]

%% Imbalance estimation of signal_IQ30
signal_IQ30_out = load('Signal_IQ30_out.mat');
[ampImbEst phImbEst] = imbalance_estimation(signal_IQ30_out.simout(end-1000:end))