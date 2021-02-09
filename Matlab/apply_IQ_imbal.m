function [signal_imb,signal_imb_timeseries] = apply_IQ_imbal(signal, A, P)
    signal_imb = iqimbal(signal, A, P);
    L = length(signal);
    i = 0: L-1;
    signal_imb_timeseries = timeseries(signal_imb, 0.0625*i');
end