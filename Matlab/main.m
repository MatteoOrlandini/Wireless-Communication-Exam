clc
clear all
close all

%% load data
[signal1, signal2, signal_IQ10, signal_IQ20, signal_IQ30] = load_data(["Signal_1.mat";...
    "Signal_2.mat"; "Signal_IQ10.mat"; "Signal_IQ20.mat"; "Signal_IQ30.mat"]);

%% delete first signal zeroes
%signal_array = reshape(signal1.simout', 1,[]);
%simout = delete_first_zeroes(signal_array);

%% Apply IQ imbal to original signal
ampImb = 20*log10(1.3); % 30% imbalance
phImb = 0;
% signal must be an array
signal_array = reshape(signal1.simout', 1,[]);
[imbalanced_signal,imbalanced_signal_timeseries] = apply_IQ_imbal(signal_array, ampImb, phImb);

figure('Name','Real part of original signal vs real part of imbalanced signal','NumberTitle','off');
plot(real(signal_array(end-1000:end)));
hold on
plot(real(imbalanced_signal(end-1000:end)));
legend('Original signal', 'Imbalanced signal');

figure('Name','Imaginary part of original signal vs imaginary part of imbalanced signal','NumberTitle','off');
plot(imag(signal_array(end-1000:end)));
hold on
plot(imag(imbalanced_signal(end-1000:end)));
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
plot(corrected_signal(1, end-1000:end));
hold on
plot(real(signal_array(end-1000:end)));
title('Real part of corrected signal vs real part of original signal');
legend('Corrected signal', 'Original signal');
subplot(2,1,2);
plot(corrected_signal(2, end-1000:end));
hold on
plot(imag(signal_array(end-1000:end)));
title('Imaginary part of corrected signal vs imaginary part of original signal');
legend('Corrected signal', 'Original signal');

%% Imbalance estimation of imbalanced_signal
[ampImbEst phImbEst] = imbalance_estimation(imbalanced_signal);
% Compare the estimated imbalance values with the specified ones.
[ampImbEst phImbEst; ampImb phImb]

%% Imbalance estimation of signal_IQ30
%signal_IQ30.simout = reshape((signal_IQ30.simout)', 1,[]);
[ampImbEst phImbEst] = imbalance_estimation(reshape((signal_IQ30.simout)', 1,[]))

%% Imbalance algorithm
Signal_IQ30_after_carrier_synch = load('Signal_IQ30_after_carrier_synch.mat');
[ampImbEst] = imbalance_algorithm_estimation(Signal_IQ30_after_carrier_synch.simout)