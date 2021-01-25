clc
clear all
close all

Fs = 0.5e6;                 % Sampling frequency
load('prova.mat', 'signal', 'signal2', 'signal3', 'signal4', 'signal5', 'out');
beta = 0.5; % Rolloff factor
span = 10; % Filter span in symbols
sps = 2; % Samples per symbol


envspectrum(double(real(signal)),500000)
hold on;
envspectrum(double(real(signal2)),500000)
% envspectrum(double(real(signal3)),500000)
% envspectrum(double(real(signal4)),500000)

% n=length(signal);
% s1=abs(fft(signal));
% S1=[s1(n/2+1:end),s1(1:n/2)];
% plot(S1);
% 
% s2=abs(fft(signal2));
% S2=[s2(n/2+1:end),s2(1:n/2)];
% hold on;
% plot(S2);
% 
% s3=abs(fft(signal3));
% S3=[s3(n/2+1:end),s3(1:n/2)];
% plot(S3);

% signal = adaptivelyAdjustGain(double(signal)');
% a=plotSignalSpectrumAfterRaisedCosine(signal, beta, span, sps, Fs);
% 
% signal2 = adaptivelyAdjustGain(double(signal2)');
% b=plotSignalSpectrumAfterRaisedCosine(signal2, beta, span, sps, Fs);
% 
% figure;
% plot(a);
% hold on;
% plot(b);
%{
A = reshape(signal, [], 1024);
B = timeseries(double(A));
% Open and Inspect the Model
model = 'QPSK_receiver.slx';
open_system(model);
sablock = 'QPSK_receiver/Spectrum';
cfg = get_param(sablock, 'ScopeConfiguration');
% Enable Measurements Data
cfg.CursorMeasurements.Enable = true;
cfg.ChannelMeasurements.Enable = true;
cfg.PeakFinder.Enable = true;
cfg.DistortionMeasurements.Enable = true;
% Simulate the Model
sim(model)
% Using getMeasurementsData
data = getMeasurementsData(cfg);
% Compare Peak Values
peakvalues = data.PeakFinder.Value
frequencieskHz = data.PeakFinder.Frequency/1000
%}

%{
Fs = 0.512e6;                 % Sampling frequency
T = 1/Fs;                     % Sampling period
L = length(signal);           % Length of signal
t = (0:L-1)*T;                % Time vector
SamplesPerFrame = 1024;
SA = dsp.SpectrumAnalyzer('SampleRate',Fs,'SpectrumType', 'Power',...
    'PlotAsTwoSidedSpectrum',true,'PowerUnits','dBW',...
    'ShowLegend',true, 'RBWSource', 'Property', 'RBW', 75,...
    'InputDomain', 'Time', 'Method', 'Welch', 'ViewType', 'Spectrum and spectrogram',...
    'TimeSpanSource', 'Auto', 'TimeResolutionSource', 'Auto');
    %'FrequencyResolutionMethod', 'WindowLength', 'WindowLength', 1024, ...
    %'FFTLengthSource', 'Property', 'FFTLength', 1024);
show(SA);
for idx = 0:4882
    dsp_signal = dsp.SignalSource(double(signal(1+idx*1024:1024+idx*1024))', SamplesPerFrame);
    Y = dsp_signal();
    SA(Y);
end
release(SA);
release (dsp_signal);
%}

%{
for Iter = 0:4882
    SA(double(signal(1+Iter*1024:1024+1024*Iter))');
end
%}
%{
xdft = fft(signal);
xdft = xdft(1:L/2+1);
psdx = (1/(Fs*L)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:Fs/length(signal):Fs/2;

plot(freq, 10*log10(psdx))
grid on
title('Periodogram Using FFT')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')
%}

%n = 2^nextpow2(L);
%Y = fft(signal, n);
%P2 = abs(Y/L);
%P1 = P2(:,1:n/2+1);
%P1(:,2:end-1) = 2*P1(:,2:end-1);
%plot(0:(Fs/n):(Fs/2-Fs/n), 20*log10(P1(1,1:n/2)))