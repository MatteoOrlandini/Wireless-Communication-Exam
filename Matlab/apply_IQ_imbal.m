function [simout,simout1] = apply_IQ_imbal(signal, A)
    simout = iqimbal(signal, A);
    [M,N] = size(signal);
    i = 0: M-1;
    simout1 = timeseries(simout, 0.0625*i');
end

