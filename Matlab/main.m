clc
clear all
close all

%% load data
[signal1, signal2, signal_IQ10, signal_IQ20, signal_IQ30] = load_data(["Signal_1.mat";...
    "Signal_2.mat"; "Signal_IQ10.mat"; "Signal_IQ20.mat"; "Signal_IQ30.mat"]);

%% delete first signal zeroes
%simout = delete_first_zeroes(signal2.simout);

%% Apply IQ imbal to original signal
A = 20*log10(1.3); % 30% imbalance
[imbalanced_signal,imbalanced_signal_timeseries] = apply_IQ_imbal(signal2.simout, A);

original_signal_vector = reshape(signal2.simout, 1, 801*12500);
original_signal = [real(original_signal_vector); imag(original_signal_vector)];

figure('Name','Real part of original signal vs real part of imbalanced signal','NumberTitle','off');
plot(original_signal(1, 1:1000));
hold on
plot(real(imbalanced_signal(1:1000)));
legend('Original signal', 'Imbalanced signal');

figure('Name','Imaginary part of original signal vs imaginary part of imbalanced signal','NumberTitle','off');
plot(original_signal(2, 1:1000));
hold on
plot(imag(imbalanced_signal(1:1000)));
legend('Original signal', 'Imbalanced signal');

%{
imbal1 = std(real(reshape(signal2.simout, 1, [])))./std(imag(reshape(signal2.simout, 1, [])));
imbal2 = std(real(reshape(y, 1, [])))./std(imag(reshape(y, 1, [])));
imbal3 = std(real(reshape(signal_IQ30.simout, 1, [])))./std(imag(reshape(signal_IQ30.simout, 1, [])));
%}


%% imbalance correction
corrected_signal = imbalance_correction(imbalanced_signal, A, 0);

figure('Name','Real part of corrected signal vs real part of original signal','NumberTitle','off');
plot(corrected_signal(1, 1:1000));
hold on
plot(original_signal(1, 1:1000));
legend('Corrected signal', 'Original signal');

hIQComp = comm.IQImbalanceCompensator('CoefficientOutputPort',true);
y = reshape(imbalanced_signal, 801*12500, 1);
[compSig,coef] = step(hIQComp,y);
[ampImbEst,phImbEst] = iqcoef2imbal(coef(end));
% Compare the estimated imbalance values with the specified ones.
[ampImbEst phImbEst; A 0]