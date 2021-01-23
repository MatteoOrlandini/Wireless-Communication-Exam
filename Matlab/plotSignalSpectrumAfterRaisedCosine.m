function [] = plotSignalSpectrumAfterRaisedCosine(signal, beta, span, sps, sampling_frequency)
    L = length(signal);             % Length of signal
    h = rcosdesign(beta, span, sps, 'sqrt'); % Generate the square-root, raised cosine filter coefficients.
    y = conv(signal, h);
    Y = 10*log10(abs(fft(y/L)));
    Y1 = Y(1:end/2);
    Y2 = Y(end/2+1:end);
    clear Y
    Y = [Y2; Y1];
    frequency_axes = linspace(1, sampling_frequency, length(Y));
    figure('Name','Amplitude Spectrum After Raised Cosine','NumberTitle','off');
    plot(frequency_axes, Y);
    xlabel('Frequency [Hz]')
    ylabel('Signal (f) [dB]')
end

