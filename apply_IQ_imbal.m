function [signal_imb,signal_imb_timeseries] = apply_IQ_imbal(signal, A, P, Fs)
% apply_IQ_imbal applies an IQ imbalance to a signal
%   [signal_imb,signal_imb_timeseries] = apply_IQ_imbal(signal, A, P, Fs)
%   returns an array signal_imb with amplitude imbalance A, phase imbalance
%   P, sampling frequency Fs from signal array. signal_imb_timeseries is a
%   timeseries that could be used in simulink
    signal_imb = iqimbal(signal, A, P);
    L = size(signal);
    i = 0: 1 : L(1)-1;
    signal_imb_timeseries = timeseries(signal_imb, L(2)/Fs*i');
end