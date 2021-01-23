clc
clear all
close all

load('prova.mat', 'signal', 'signal2', 'signal3', 'signal4', 'signal5', 'out');
A = reshape(signal, [], 1024);
B = timeseries(double(A));
beta = 0.5; % Rolloff factor
span = 10; % Filter span in symbols
sps = 2; % Samples per symbol
h = rcosdesign(beta, span, sps, 'sqrt'); % Generate the square-root, raised cosine filter coefficients.
%y = upfirdn(double(signal)', h, sps); % Upsample and filter the data for pulse shaping.
y = conv(double(signal)', h);
Y = 10*log10(abs(fft(y)));
Y1 = Y(1:end/2);
Y2 = Y(end/2+1:end);
clear Y
Y = [Y2; Y1];
plot(Y);

%{
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