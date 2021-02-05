clc
clear all
close all

%% load data
signal1 = load('Signal_1.mat');
signal2 = load('Signal_2.mat');
%signal_IQ10 = load('Signal_IQ10.mat');
%signal_IQ20 = load('Signal_IQ20.mat');
signal_IQ30 = load('Signal_IQ30.mat');

%% Apply IQ imbal to original signal
A = 20*log10(1.3); % 30% imbalance
y = iqimbal(signal2.simout, A);
l = size(signal2.simout);
i = 0: l(1)-1;
simout1 = timeseries(y, 0.0625*i');

imbal1 = std(real(reshape(signal2.simout, 1, [])))./std(imag(reshape(signal2.simout, 1, [])));
imbal2 = std(real(reshape(y, 1, [])))./std(imag(reshape(y, 1, [])));
imbal3 = std(real(reshape(signal_IQ30.simout, 1, [])))./std(imag(reshape(signal_IQ30.simout, 1, [])));
