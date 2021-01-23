function [out_signal] = adaptivelyAdjustGain(signal)
    agc = comm.AGC;
    out_signal = agc(signal);
    release(agc);
end