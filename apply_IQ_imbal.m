function [signal_imb,signal_imb_timeseries] = apply_IQ_imbal(signal, A, P, Fs)
    signal_imb = iqimbal(signal, A, P);
    L = size(signal);
    i = 0: 1 : L(1)-1;
    signal_imb_timeseries = timeseries(signal_imb, L(2)/Fs*i');
end