function [] = plotSignalSpectrum(signal, sampling_frequency)
    sampler = ones(1, 2000);
    L = length(signal);             % Length of signal
    data = conv(signal, sampler);
    DATA = 10*log10(abs(fft(data/L)));
    DATA1 = DATA(1:end/2);
    DATA2 = DATA(end/2+1:end);
    clear Y
    DATA = [DATA2; DATA1];
    frequency_axes = linspace(1, sampling_frequency, length(DATA));
    figure('Name','Amplitude Spectrum','NumberTitle','off');
    plot(frequency_axes, DATA);
    xlabel('Frequency [Hz]')
    ylabel('Signal (f) [dB]')
    index = find(DATA == max(DATA));
    signal_frequency = frequency_axes(index)
end

